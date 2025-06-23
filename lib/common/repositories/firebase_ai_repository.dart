import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:travel_assistant/common/error/firebase_error.dart';
import 'package:travel_assistant/common/models/response/travel_details.dart';
import 'package:travel_assistant/common/models/travel_information.dart';
import 'package:travel_assistant/common/services/firebase_ai_service.dart';
import 'package:travel_assistant/common/utils/analytics/analytics_facade.dart';
import 'package:travel_assistant/common/utils/error_monitoring/error_monitoring_facade.dart';

abstract class _Constants {
  static const int maxRetries = 3;
  static const String jsonCodeBlockStart = '```json';
  static const String codeBlockEnd = '```';
  static const String retryPromptTemplate =
      'The format of the travel plan you generated previously was not valid. '
      'The error message is: $errorMessagePlaceholder '
      'Please fix the following error. ';
  static const String errorMessagePlaceholder = '{error_message}';
}

/// Repository for interacting with Firebase AI capabilities
class FirebaseAIRepository {
  /// Creates a [FirebaseAIRepository].
  const FirebaseAIRepository({
    required this.firebaseAIService,
    required this.analyticsFacade,
    required this.errorMonitoringFacade,
  });

  /// The Firebase AI service instance used by this repository
  final FirebaseAIService firebaseAIService;

  /// The analytics facade instance used by this repository
  final AnalyticsFacade analyticsFacade;

  /// The error monitoring facade instance used by this repository
  final ErrorMonitoringFacade errorMonitoringFacade;

  /// Generates text based on the provided prompt using Firebase AI.
  ///
  /// [travelInformation] The travel information to send to the Firebase AI model.
  ///
  /// Returns the generated travel details response.
  /// Throws an exception if text generation fails.
  Future<TravelDetails> generateTravelPlan(
    TravelInformation travelInformation,
  ) async {
    final prompt = jsonEncode(travelInformation.toJson());
    return _generateTravelPlan(prompt);
  }

  Future<TravelDetails> _generateTravelPlan(
    String prompt, {
    int retryCount = 0,
  }) async {
    final content = Content.text(prompt);
    final chatSession = firebaseAIService.startChatSession();
    analyticsFacade.logLLMPrompt(firebaseAIService.model, prompt);
    // Log the prompt being sent to Firebase AI
    final stopwatch = Stopwatch()..start();

    try {
      final response = await chatSession.sendMessage(content);

      stopwatch.stop();

      var responseText = response.text;

      if (responseText == null || responseText.isEmpty) {
        final error = Exception('Empty response received from Firebase AI');

        throw error;
      }

      // Log the successful response
      analyticsFacade.logLLMResponse(
        firebaseAIService.model,
        prompt,
        responseText,
        stopwatch.elapsedMilliseconds,
      );
      responseText = responseText.replaceAll(_Constants.jsonCodeBlockStart, '').replaceAll(_Constants.codeBlockEnd, '');
      final responseJson = jsonDecode(responseText);

      return TravelDetails.fromJson(responseJson);
    } catch (e, stackTrace) {
      stopwatch.stop();

      if (e is FormatException) {
        if (retryCount >= _Constants.maxRetries) {
          rethrow;
        }

        final prompt = _Constants.retryPromptTemplate.replaceFirst(
          _Constants.errorMessagePlaceholder,
          e.message,
        );

        errorMonitoringFacade.reportError(
          'FormatException occurred while generating text with Firebase AI',
          stackTrace: stackTrace,
          context: {
            'error': e,
            'prompt': prompt,
            'model': firebaseAIService.model,
            'durationMs': stopwatch.elapsedMilliseconds,
            'retryCount': retryCount,
          },
        );

        return _generateTravelPlan(
          prompt,
          retryCount: retryCount + 1,
        );
      } else if (e is ServerException) {
        errorMonitoringFacade.reportError(
          'Firebase App Check error',
          stackTrace: stackTrace,
          context: {
            'error': e,
            'prompt': prompt,
            'model': firebaseAIService.model,
            'durationMs': stopwatch.elapsedMilliseconds,
          },
        );
        throw FirebaseAppCheckError();
      } else {
        errorMonitoringFacade.reportError(
          'Exception occurred while generating text with Firebase AI',
          stackTrace: stackTrace,
          context: {
            'error': e,
            'prompt': prompt,
            'model': firebaseAIService.model,
            'durationMs': stopwatch.elapsedMilliseconds,
          },
        );
        throw Exception('Failed to generate text: $e');
      }
    }
  }
}
