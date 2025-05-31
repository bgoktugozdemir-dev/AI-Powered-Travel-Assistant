import 'package:firebase_ai/firebase_ai.dart';
import 'package:travel_assistant/common/repositories/firebase_remote_config_repository.dart';

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
    return _firebaseAI.generativeModel(
      model: _model,
      systemInstruction: Content.system(_systemPrompt),
    );
  }

  /// Returns the chat session for the Gemini model.
  ChatSession chatSession() {
    final model = getModel();

    return model.startChat();
  }

  String get _model => _firebaseRemoteConfigRepository.aiModel;

  String get _systemPrompt => _firebaseRemoteConfigRepository.aiSystemPrompt;
}
