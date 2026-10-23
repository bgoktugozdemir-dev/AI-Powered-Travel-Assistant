import 'package:firebase_ai/firebase_ai.dart';
import 'package:travel_assistant/common/ai/streamed_response.dart';
import 'package:travel_assistant/common/error/firebase_error.dart';
import 'package:travel_assistant/common/models/response/travel_details.dart';
import 'package:travel_assistant/common/services/firebase_ai_service.dart';
import 'package:travel_assistant/common/utils/error_monitoring/error_monitoring_facade.dart';
import 'package:travel_assistant/common/utils/helpers/parser_utils.dart';

abstract class _Constants {
  static const int maxFormatRetries = 3;
}

/// Thrown when the format pass cannot complete successfully.
///
/// The pass reports the failure to error monitoring before throwing this, so
/// callers must not report it again ([AlreadyReportedError]). The original
/// error is kept as [cause].
class TravelFormatPassException implements Exception, AlreadyReportedError {
  const TravelFormatPassException(this.cause);

  final Object cause;

  @override
  String toString() => 'TravelFormatPassException($cause)';
}

/// Pass 2 orchestrator: schema-bound formatting into TravelDetails.
abstract class TravelFormatPassRunner {
  Future<TravelDetails> formatResearchFindings({
    required String userPrompt,
    required String researchFindings,
    required String systemPrompt,
  });
}

class TravelFormatPass implements TravelFormatPassRunner {
  TravelFormatPass({
    required FirebaseAIService firebaseAIService,
    required ErrorMonitoringFacade errorMonitoring,
  }) : _firebaseAIService = firebaseAIService,
       _errorMonitoring = errorMonitoring;

  final FirebaseAIService _firebaseAIService;
  final ErrorMonitoringFacade _errorMonitoring;

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
        final model = _firebaseAIService.buildFormatModel(
          systemPrompt: systemPrompt,
        );
        final response = await collectStreamedResponse(
          model.generateContentStream([
            Content.text(
              'User Input:\n$userPrompt\n\nResearch Findings:\n$researchFindings',
            ),
          ]),
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
        _errorMonitoring.reportError(
          'TravelFormatPass.formatResearchFindings failed.',
          stackTrace: st,
          context: {'error': e, 'durationMs': stopwatch.elapsedMilliseconds},
        );
        throw TravelFormatPassException(e);
      }
    }
    throw StateError('Unexpected format pass state');
  }
}
