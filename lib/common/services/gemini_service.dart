import 'package:firebase_ai/firebase_ai.dart';
import 'package:travel_assistant/common/repositories/firebase_remote_config_repository.dart';
import 'package:travel_assistant/common/utils/logger/logger.dart';

abstract class _Constants {
  // Gemini 2.0 Max Output Tokens
  static const int _gemini2MaxOutputTokens = 8_192;

  // Gemini 2.5 Max Output Tokens
  static const int _gemini25MaxOutputTokens = 65_536;
}

/// Service class for interacting with the Gemini AI model through Firebase VertexAI.
class GeminiService {
  /// Creates a [GeminiService] with the given configuration.
  GeminiService({
    required FirebaseAI firebaseAI,
    required FirebaseRemoteConfigRepository firebaseRemoteConfigRepository,
  }) : _firebaseAI = firebaseAI,
       _firebaseRemoteConfigRepository = firebaseRemoteConfigRepository;

  final FirebaseAI _firebaseAI;
  final FirebaseRemoteConfigRepository _firebaseRemoteConfigRepository;

  /// Returns the generative model for the Gemini model.
  GenerativeModel getModel() {
    try {
      final generationConfigData = _firebaseRemoteConfigRepository.generationConfig;
      if (generationConfigData == null) {
        return _firebaseAI.generativeModel(
          model: _model,
          systemInstruction: Content.system(_systemPrompt),
        );
      }

      return _firebaseAI.generativeModel(
        model: _model,
        generationConfig: generationConfig,
        systemInstruction: Content.system(_systemPrompt),
      );
    } catch (e) {
      appLogger.e('Error getting generative model', error: e);
      return _firebaseAI.generativeModel(
        model: _model,
        systemInstruction: Content.system(_systemPrompt),
      );
    }
  }

  /// Returns the chat session for the Gemini model.
  ChatSession chatSession() {
    final model = getModel();

    return model.startChat();
  }

  String get _model => _firebaseRemoteConfigRepository.aiModel;

  String get _systemPrompt => _firebaseRemoteConfigRepository.aiSystemPrompt;
}
