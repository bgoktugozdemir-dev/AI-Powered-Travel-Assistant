import 'package:firebase_ai/firebase_ai.dart';
import 'package:travel_assistant/common/repositories/firebase_remote_config_repository.dart';

/// Service class for interacting with the Firebase AI model through Firebase VertexAI.
class FirebaseAIService {
  /// Creates a [FirebaseAIService] with the given configuration.
  FirebaseAIService({
    required FirebaseAI firebaseAI,
    required FirebaseRemoteConfigRepository firebaseRemoteConfigRepository,
  }) : _firebaseAI = firebaseAI,
       _firebaseRemoteConfigRepository = firebaseRemoteConfigRepository;

  final FirebaseAI _firebaseAI;
  final FirebaseRemoteConfigRepository _firebaseRemoteConfigRepository;

  ChatSession? _chatSession;

  String get model => _firebaseRemoteConfigRepository.aiModel;
  String get _systemPrompt => _firebaseRemoteConfigRepository.aiSystemPrompt;

  /// Returns the generative model for the Firebase AI model.
  GenerativeModel _getModel() {
    return _firebaseAI.generativeModel(
      model: model,
      generationConfig: _firebaseRemoteConfigRepository.generationConfig?.toGenerationConfig(model),
      systemInstruction: Content.system(_systemPrompt),
    );
  }

  /// Returns the chat session for the Firebase AI model.
  ChatSession startChatSession() {
    if (_chatSession != null) {
      return _chatSession!;
    }

    final model = _getModel();

    _chatSession = model.startChat();

    return _chatSession!;
  }

  void endChatSession() {
    _chatSession = null;
  }
}
