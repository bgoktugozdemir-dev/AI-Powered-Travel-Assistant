import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter/services.dart';

/// Constants for the Gemini service.
abstract class _Constants {
  /// The name of the Gemini model to use.
  static const String defaultModel = 'gemini-2.0-flash';

  /// The path to the system prompt file.
  static const String systemPromptPath = 'assets/system_prompt.md';
}

/// Service class for interacting with the Gemini AI model through Firebase VertexAI.
class GeminiService {
  /// Creates a [GeminiService] with the given configuration.
  GeminiService({required FirebaseVertexAI vertexAI}) : _vertexAI = vertexAI;

  final FirebaseVertexAI _vertexAI;

  /// Returns the generative model for the Gemini model.
  Future<GenerativeModel> getModel() async {
    final systemPrompt = await getSystemPrompt();

    return _vertexAI.generativeModel(model: _Constants.defaultModel, systemInstruction: Content.system(systemPrompt));
  }

  /// Returns the chat session for the Gemini model.
  Future<ChatSession> chatSession() async {
    final model = await getModel();

    return model.startChat();
  }

  Future<String> getSystemPrompt() => rootBundle.loadString(_Constants.systemPromptPath);
}
