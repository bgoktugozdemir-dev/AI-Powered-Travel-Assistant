import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:travel_assistant/common/error/firebase_error.dart';
import 'package:travel_assistant/common/models/response/travel_details.dart';
import 'package:travel_assistant/common/models/travel_information.dart';
import 'package:travel_assistant/common/services/gemini_service.dart';
import 'package:travel_assistant/common/utils/logger/error_logger.dart';
import 'package:travel_assistant/common/utils/logger/llm_conversation_logger.dart';

/// Repository for interacting with Gemini AI capabilities
class GeminiRepository {
  /// Creates a [GeminiRepository].
  const GeminiRepository({required this.geminiService});

  /// The Gemini service instance used by this repository
  final GeminiService geminiService;

  /// Generates text based on the provided prompt using Gemini AI.
  ///
  /// [prompt] The text prompt to send to the Gemini model.
  ///
  /// Returns the generated text response.
  /// Throws an exception if text generation fails.
  Future<TravelDetails> generateTravelPlan(TravelInformation travelInformation) async {
    final prompt = jsonEncode(travelInformation.toJson());
    final content = Content.text(prompt);
    final stopwatch = Stopwatch()..start();

    // Log the prompt being sent to Gemini
    LlmLogger.prompt('Gemini', prompt);

    try {
      final chatSession = geminiService.chatSession();
      final response = await chatSession.sendMessage(content);
      stopwatch.stop();
      var responseText = response.text;

      if (responseText == null || responseText.isEmpty) {
        final error = Exception('Empty response received from Gemini');

        // Log the error
        LlmLogger.error('Gemini', 'Empty response received from model', error);

        // Also log with the error logger
        ErrorLogger.logAIError(
          'Failed to generate text for prompt',
          error,
          context: {'prompt': prompt, 'response': 'Empty or null'},
        );

        throw error;
      }

      // Log the successful response
      LlmLogger.response('Gemini', responseText, durationMs: stopwatch.elapsedMilliseconds);
      responseText = responseText.replaceAll('```json', '').replaceAll('```', '');
      final responseJson = jsonDecode(responseText);

      return TravelDetails.fromJson(responseJson);
    } catch (e, stackTrace) {
      stopwatch.stop();

      // Log the error
      LlmLogger.error('Gemini', 'Exception while generating text', e, stackTrace: stackTrace);

      // Also log with the error logger
      ErrorLogger.logAIError(
        'Exception occurred while generating text with Gemini',
        e,
        stackTrace: stackTrace,
        context: {'prompt': prompt},
      );

      if (e is ServerException) {
        throw FirebaseAppCheckError();
      } else {
        throw Exception('Failed to generate text: $e');
      }
    }
  }
}
