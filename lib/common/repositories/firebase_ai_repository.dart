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
      'The travel plan you generated previously was not correct. '
      'Please fix the following error: ';
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
    return _generateWithRetry(prompt);
  }

  /// Generates travel plan with automatic retry mechanism for format errors.
  /// 
  /// [prompt] The prompt to send to Firebase AI
  /// [retryCount] Current retry attempt count
  /// [isRetry] Whether this is a retry attempt
  /// 
  /// Returns the generated travel details
  /// Throws an exception if generation fails after all retries
  Future<TravelDetails> _generateWithRetry(
    String prompt, [
    int retryCount = 0,
    bool isRetry = false,
  ]) async {
    try {
      final response = await _sendMessage(prompt);
      final travelDetails = _processResponse(response, prompt);
      return travelDetails;
    } on FormatException catch (e) {
      if (retryCount >= _Constants.maxRetries) {
        rethrow;
      }
      
      _logFormatError(e, prompt, retryCount);
      final retryPrompt = _Constants.retryPromptTemplate + e.message;
      return _generateWithRetry(retryPrompt, retryCount + 1, true);
    } on ServerException catch (e, stackTrace) {
      _logServerError(e, stackTrace, prompt);
      throw FirebaseAppCheckError();
    } catch (e, stackTrace) {
      _logGenericError(e, stackTrace, prompt);
      throw Exception('Failed to generate text: $e');
    }
  }

  /// Sends a message to Firebase AI and returns the response.
  /// 
  /// [prompt] The prompt to send
  /// 
  /// Returns the Firebase AI response
  /// Throws an exception if the response is empty
  Future<GenerateContentResponse> _sendMessage(String prompt) async {
    final content = Content.text(prompt);
    final chatSession = firebaseAIService.startChatSession();
    
    analyticsFacade.logLLMPrompt(firebaseAIService.model, prompt);
    final stopwatch = Stopwatch()..start();

    try {
      final response = await chatSession.sendMessage(content);
      stopwatch.stop();

      if (response.text == null || response.text!.isEmpty) {
        throw Exception('Empty response received from Firebase AI');
      }

      analyticsFacade.logLLMResponse(
        firebaseAIService.model,
        prompt,
        response.text!,
        stopwatch.elapsedMilliseconds,
      );

      return response;
    } catch (e) {
      stopwatch.stop();
      rethrow;
    }
  }

  /// Processes the Firebase AI response and converts it to TravelDetails.
  /// 
  /// [response] The response from Firebase AI
  /// [prompt] The original prompt (for error logging)
  /// 
  /// Returns the parsed TravelDetails
  /// Throws FormatException if JSON parsing fails
  TravelDetails _processResponse(
    GenerateContentResponse response, 
    String prompt,
  ) {
    var responseText = response.text!;
    
    // Clean up markdown code blocks
    responseText = responseText
        .replaceAll(_Constants.jsonCodeBlockStart, '')
        .replaceAll(_Constants.codeBlockEnd, '');

    try {
      final responseJson = jsonDecode(responseText);
      return TravelDetails.fromJson(responseJson);
    } on FormatException catch (e) {
      // Re-throw with additional context for retry logic
      throw FormatException('${e.message}\nResponse: $responseText');
    }
  }

  /// Logs format errors with appropriate context.
  void _logFormatError(FormatException e, String prompt, int retryCount) {
    errorMonitoringFacade.reportError(
      'FormatException occurred while generating text with Firebase AI '
      '(retry attempt: $retryCount)',
      context: {
        'error': e.message,
        'prompt': prompt,
        'model': firebaseAIService.model,
        'retryCount': retryCount,
      },
    );
  }

  /// Logs server errors with appropriate context.
  void _logServerError(
    ServerException e, 
    StackTrace stackTrace, 
    String prompt,
  ) {
    errorMonitoringFacade.reportError(
      'Firebase App Check error',
      stackTrace: stackTrace,
      context: {
        'error': e.toString(),
        'prompt': prompt,
        'model': firebaseAIService.model,
      },
    );
  }

  /// Logs generic errors with appropriate context.
  void _logGenericError(
    dynamic e, 
    StackTrace stackTrace, 
    String prompt,
  ) {
    errorMonitoringFacade.reportError(
      'Exception occurred while generating text with Firebase AI',
      stackTrace: stackTrace,
      context: {
        'error': e.toString(),
        'prompt': prompt,
        'model': firebaseAIService.model,
      },
    );
  }
}
