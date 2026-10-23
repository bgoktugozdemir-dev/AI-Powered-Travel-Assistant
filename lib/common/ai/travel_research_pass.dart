import 'package:firebase_ai/firebase_ai.dart';
import 'package:travel_assistant/common/ai/function_call_dispatcher.dart';
import 'package:travel_assistant/common/ai/streamed_response.dart';
import 'package:travel_assistant/common/error/firebase_error.dart';
import 'package:travel_assistant/common/repositories/currency_repository.dart';
import 'package:travel_assistant/common/repositories/weather_repository.dart';
import 'package:travel_assistant/common/services/firebase_ai_service.dart';
import 'package:travel_assistant/common/utils/error_monitoring/error_monitoring_facade.dart';

abstract class _Constants {
  static const int maxToolCallRounds = 6;
}

/// Thrown when research pass cannot complete successfully.
///
/// The pass reports the failure to error monitoring before throwing this, so
/// callers must not report it again ([AlreadyReportedError]).
class TravelResearchPassException implements Exception, AlreadyReportedError {
  const TravelResearchPassException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => 'TravelResearchPassException($message)';
}

/// Pass 1 orchestrator: function-calling research (live FX and weather).
abstract class TravelResearchPassRunner {
  Future<String> generateResearchFindings({
    required String userPrompt,
    required String systemPrompt,
  });
}

/// Drives the function-calling conversation of the research pass.
///
/// Shared by the client-built prompt path ([TravelResearchPass]) and the
/// server prompt template path, which only differ in how a chat is started.
class ResearchToolLoop {
  const ResearchToolLoop({required FunctionCallDispatcher dispatcher})
    : _dispatcher = dispatcher;

  final FunctionCallDispatcher _dispatcher;

  /// Sends [firstMessage] and keeps answering the model's function calls
  /// until it produces the final research text.
  ///
  /// [onRoundsExhausted] runs right before a
  /// [TravelResearchPassException] is thrown for exceeding the tool-call
  /// round limit.
  Future<String> run({
    required Future<GenerateContentResponse> Function(Content message)
    sendMessage,
    required Content firstMessage,
    void Function()? onRoundsExhausted,
  }) async {
    var roundCount = 0;
    var response = await sendMessage(firstMessage);

    while (roundCount < _Constants.maxToolCallRounds) {
      roundCount++;
      final functionCalls = response.functionCalls.toList();
      if (functionCalls.isEmpty) {
        final text = response.text;
        if (text == null || text.isEmpty) {
          throw const TravelResearchPassException(
            'Research pass completed without response text.',
          );
        }
        return text;
      }

      final functionResponses = <Part>[];
      for (final call in functionCalls) {
        functionResponses.add(await _dispatcher.dispatch(call));
      }

      response = await sendMessage(Content.multi(functionResponses));
    }

    onRoundsExhausted?.call();
    throw const TravelResearchPassException(
      'Research pass exceeded maximum tool-call rounds.',
    );
  }
}

class TravelResearchPass implements TravelResearchPassRunner {
  TravelResearchPass({
    required FirebaseAIService firebaseAIService,
    required CurrencyRepository currencyRepository,
    required WeatherRepository weatherRepository,
    required ErrorMonitoringFacade errorMonitoring,
  }) : _firebaseAIService = firebaseAIService,
       _loop = ResearchToolLoop(
         dispatcher: FunctionCallDispatcher(
           currencyRepository: currencyRepository,
           weatherRepository: weatherRepository,
         ),
       ),
       _errorMonitoring = errorMonitoring;

  final FirebaseAIService _firebaseAIService;
  final ResearchToolLoop _loop;
  final ErrorMonitoringFacade _errorMonitoring;

  @override
  Future<String> generateResearchFindings({
    required String userPrompt,
    required String systemPrompt,
  }) async {
    final stopwatch = Stopwatch()..start();
    try {
      final model = _firebaseAIService.buildResearchModel(
        systemPrompt: systemPrompt,
      );

      final chat = model.startChat();
      return await _loop.run(
        sendMessage: (message) =>
            collectStreamedResponse(chat.sendMessageStream(message)),
        firstMessage: Content.text(userPrompt),
        // The exception thrown after this callback is reported below, so this
        // only leaves a breadcrumb.
        onRoundsExhausted: () => _errorMonitoring.addBreadcrumb(
          'TravelResearchPass max tool call rounds exceeded.',
          category: 'Firebase AI',
        ),
      );
    } catch (e, st) {
      _errorMonitoring.reportError(
        'TravelResearchPass.generateResearchFindings failed.',
        stackTrace: st,
        context: {'error': e, 'durationMs': stopwatch.elapsedMilliseconds},
      );
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
