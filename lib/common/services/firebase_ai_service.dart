import 'package:firebase_ai/firebase_ai.dart';
import 'package:travel_assistant/common/ai/function_declarations.dart';
import 'package:travel_assistant/common/models/response/travel_details.dart';
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

  /// Build schema-bound model for default single-pass responses.
  GenerativeModel _getModel({
    required String systemPrompt,
    Schema? responseSchema,
  }) {
    return _firebaseAI.generativeModel(
      model: model,
      generationConfig: _firebaseRemoteConfigRepository.generationConfig
          ?.toGenerationConfig(model, responseSchema: responseSchema),
      systemInstruction: Content.system(systemPrompt),
    );
  }

  /// Build a research model with tools and grounding enabled.
  GenerativeModel buildResearchModel({
    required String systemPrompt,
  }) {
    return _firebaseAI.generativeModel(
      model: model,
      generationConfig: _firebaseRemoteConfigRepository.generationConfig
          ?.toGenerationConfig(model, responseSchema: null),
      systemInstruction: Content.system(systemPrompt),
      tools: [
        Tool.functionDeclarations(FunctionDeclarations.all),
      ],
    );
  }

  /// Build a schema-constrained model for formatting pass.
  GenerativeModel buildFormatModel({
    required String systemPrompt,
  }) {
    return _getModel(
      systemPrompt: systemPrompt,
      responseSchema: TravelDetails.aiSchema,
    );
  }

  /// Returns the chat session for the Firebase AI model.
  ChatSession startChatSession() {
    if (_chatSession != null) {
      return _chatSession!;
    }

    final model = _getModel(
      systemPrompt: _firebaseRemoteConfigRepository.aiSystemPrompt,
      responseSchema: TravelDetails.aiSchema,
    );

    _chatSession = model.startChat();

    return _chatSession!;
  }

  void endChatSession() {
    _chatSession = null;
  }
}
