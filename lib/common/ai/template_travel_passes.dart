import 'package:firebase_ai/firebase_ai.dart';
import 'package:travel_assistant/common/ai/function_call_dispatcher.dart';
import 'package:travel_assistant/common/ai/template_errors.dart';
import 'package:travel_assistant/common/ai/travel_format_pass.dart'
    show TravelFormatPassException, TravelFormatPassRunner;
import 'package:travel_assistant/common/ai/travel_research_pass.dart'
    show
        ResearchToolLoop,
        TravelResearchPassException,
        TravelResearchPassRunner;
import 'package:travel_assistant/common/ai/travel_template_client.dart';
import 'package:travel_assistant/common/models/response/travel_details.dart';
import 'package:travel_assistant/common/utils/error_monitoring/error_monitoring_facade.dart';
import 'package:travel_assistant/common/utils/helpers/parser_utils.dart';

abstract class _Constants {
  /// Template input carrying the JSON-encoded `TravelInformation`.
  static const String travelInformationInput = 'travel_information';

  /// Template input carrying the findings produced by the research pass.
  static const String researchFindingsInput = 'research_findings';

  /// First chat turn of the research template. The trip details and the
  /// instructions live in the server template, but a chat needs a message.
  static const String researchKickoffMessage = 'Begin the research now.';

  static const int maxFormatRetries = 3;
}

/// Pass 1 backed by a Firebase AI Logic server prompt template.
///
/// The system prompt, model, config and function declarations (exchange rate
/// and weather) live in the template. Function calls are still executed on the
/// device through [FunctionCallDispatcher].
class TemplateTravelResearchPass implements TravelResearchPassRunner {
  TemplateTravelResearchPass({
    required TravelTemplateClient templateClient,
    required FunctionCallDispatcher dispatcher,
    required String Function() templateId,
    required ErrorMonitoringFacade errorMonitoring,
  }) : _templateClient = templateClient,
       _loop = ResearchToolLoop(dispatcher: dispatcher),
       _templateId = templateId,
       _errorMonitoring = errorMonitoring;

  final TravelTemplateClient _templateClient;
  final ResearchToolLoop _loop;
  final String Function() _templateId;
  final ErrorMonitoringFacade _errorMonitoring;

  /// Runs the research template.
  ///
  /// [systemPrompt] is ignored: the system prompt is part of the template.
  @override
  Future<String> generateResearchFindings({
    required String userPrompt,
    required String systemPrompt,
  }) async {
    final stopwatch = Stopwatch()..start();
    try {
      final chat = _templateClient.startChat(
        _templateId(),
        inputs: {_Constants.travelInformationInput: userPrompt},
      );
      return await _loop.run(
        sendMessage: chat.sendMessage,
        firstMessage: Content.text(_Constants.researchKickoffMessage),
        // The exception thrown after this callback is reported below, so this
        // only leaves a breadcrumb.
        onRoundsExhausted: () => _errorMonitoring.addBreadcrumb(
          'TemplateTravelResearchPass max tool call rounds exceeded.',
          category: 'Firebase AI',
        ),
      );
    } catch (e, st) {
      // A missing template is not an incident: the caller falls back.
      if (!isTemplateUnavailableError(e)) {
        _errorMonitoring.reportError(
          'TemplateTravelResearchPass.generateResearchFindings failed.',
          stackTrace: st,
          context: {'error': e, 'durationMs': stopwatch.elapsedMilliseconds},
        );
      }
      if (e is TravelResearchPassException) {
        rethrow;
      }
      throw TravelResearchPassException(
        'Research pass failed.',
        cause: e,
      );
    }
  }
}

/// Pass 2 backed by a Firebase AI Logic server prompt template.
///
/// The template declares the `TravelDetails` output schema, so the response is
/// constrained server-side to the same shape as `TravelDetails.aiSchema`.
class TemplateTravelFormatPass implements TravelFormatPassRunner {
  TemplateTravelFormatPass({
    required TravelTemplateClient templateClient,
    required String Function() templateId,
    required ErrorMonitoringFacade errorMonitoring,
  }) : _templateClient = templateClient,
       _templateId = templateId,
       _errorMonitoring = errorMonitoring;

  final TravelTemplateClient _templateClient;
  final String Function() _templateId;
  final ErrorMonitoringFacade _errorMonitoring;

  /// Runs the format template.
  ///
  /// [systemPrompt] is ignored: the system prompt is part of the template.
  @override
  Future<TravelDetails> formatResearchFindings({
    required String userPrompt,
    required String researchFindings,
    required String systemPrompt,
  }) async {
    final stopwatch = Stopwatch()..start();
    var retryCount = 0;
    while (retryCount < _Constants.maxFormatRetries) {
      try {
        final response = await _templateClient.generateContent(
          _templateId(),
          inputs: {
            _Constants.travelInformationInput: userPrompt,
            _Constants.researchFindingsInput: researchFindings,
          },
        );
        final text = response.text ?? '{}';
        return ParserUtils.parseTravelDetailsOrThrow(text);
      } on FormatException catch (e) {
        retryCount++;
        if (retryCount >= _Constants.maxFormatRetries) {
          _errorMonitoring.reportException(
            e,
            context: {
              'retryCount': retryCount,
              'durationMs': stopwatch.elapsedMilliseconds,
            },
          );
          throw TravelFormatPassException(e);
        }
      } catch (e, st) {
        // A missing template is not an incident: the caller falls back, which
        // needs the original error to recognize it.
        if (isTemplateUnavailableError(e)) {
          rethrow;
        }
        _errorMonitoring.reportError(
          'TemplateTravelFormatPass.formatResearchFindings failed.',
          stackTrace: st,
          context: {'error': e, 'durationMs': stopwatch.elapsedMilliseconds},
        );
        throw TravelFormatPassException(e);
      }
    }
    throw StateError('Unexpected format pass state');
  }
}
