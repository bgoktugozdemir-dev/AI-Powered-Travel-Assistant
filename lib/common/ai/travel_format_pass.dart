import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:travel_assistant/common/models/response/travel_details.dart';
import 'package:travel_assistant/common/services/firebase_ai_service.dart';
import 'package:travel_assistant/common/utils/error_monitoring/error_monitoring_facade.dart';
import 'package:travel_assistant/common/utils/helpers/parser_utils.dart';

abstract class _Constants {
  static const int maxFormatRetries = 3;
}

/// Pass 2 orchestrator: schema-bound formatting into TravelDetails.
class TravelFormatPass {
  TravelFormatPass({
    required FirebaseAIService firebaseAIService,
    required ErrorMonitoringFacade errorMonitoring,
  }) : _firebaseAIService = firebaseAIService,
       _errorMonitoring = errorMonitoring;

  final FirebaseAIService _firebaseAIService;
  final ErrorMonitoringFacade _errorMonitoring;

  Future<TravelDetails> formatResearchFindings({
    required String userPrompt,
    required String researchFindings,
    required String systemPrompt,
  }) async {
    var retryCount = 0;
    while (retryCount < _Constants.maxFormatRetries) {
      try {
        final model = _firebaseAIService.buildFormatModel(
          systemPrompt: systemPrompt,
        );
        final response = await model.generateContent([
          Content.text(
            'User Input:\n$userPrompt\n\nResearch Findings:\n$researchFindings',
          ),
        ]);
        final text = response.text ?? '{}';
        final parsed = ParserUtils.parseTravelDetails(text);
        if (parsed != null) {
          return parsed;
        }
        final fallbackJson = jsonDecode(text) as Map<String, dynamic>;
        return TravelDetails.fromJson(fallbackJson);
      } on FormatException catch (e) {
        retryCount++;
        if (retryCount >= _Constants.maxFormatRetries) {
          _errorMonitoring.reportException(
            e,
            context: {'retryCount': retryCount},
          );
          rethrow;
        }
      } catch (e, st) {
        _errorMonitoring.reportError(
          'TravelFormatPass.formatResearchFindings failed: $e',
          stackTrace: st,
        );
        rethrow;
      }
    }
    throw StateError('Unexpected format pass state');
  }
}
