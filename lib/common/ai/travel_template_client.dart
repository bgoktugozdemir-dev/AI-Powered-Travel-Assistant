import 'package:firebase_ai/firebase_ai.dart';

/// Chat session bound to a server prompt template.
///
/// App-owned seam over `TemplateChatSession`, which is a `final` class and
/// cannot be faked in tests.
abstract interface class TravelTemplateChat {
  /// Sends [message] as the next turn of the conversation.
  Future<GenerateContentResponse> sendMessage(Content message);
}

/// Client for Firebase AI Logic server prompt templates.
///
/// App-owned seam over `TemplateGenerativeModel`, which is `@experimental`
/// and a `final` class. All experimental API usage is confined to
/// [FirebaseTravelTemplateClient] so the rest of the app depends on this
/// interface only.
abstract interface class TravelTemplateClient {
  /// Runs the single-turn template [templateId] with the given [inputs].
  Future<GenerateContentResponse> generateContent(
    String templateId, {
    required Map<String, Object?> inputs,
  });

  /// Starts a multi-turn chat with the template [templateId].
  ///
  /// Tools (function declarations) are defined in the template itself.
  TravelTemplateChat startChat(
    String templateId, {
    required Map<String, Object?> inputs,
  });
}

/// [TravelTemplateClient] backed by `FirebaseAI.templateGenerativeModel()`.
class FirebaseTravelTemplateClient implements TravelTemplateClient {
  /// Creates a client that talks to templates through [firebaseAI].
  FirebaseTravelTemplateClient({required FirebaseAI firebaseAI})
    : _firebaseAI = firebaseAI;

  final FirebaseAI _firebaseAI;

  // ignore: experimental_member_use
  late final TemplateGenerativeModel _model = _createModel();

  // ignore: experimental_member_use
  TemplateGenerativeModel _createModel() {
    // ignore: experimental_member_use
    return _firebaseAI.templateGenerativeModel();
  }

  @override
  Future<GenerateContentResponse> generateContent(
    String templateId, {
    required Map<String, Object?> inputs,
  }) {
    // ignore: experimental_member_use
    return _model.generateContent(templateId, inputs: inputs);
  }

  @override
  TravelTemplateChat startChat(
    String templateId, {
    required Map<String, Object?> inputs,
  }) {
    final session = _model.startChat(templateId, inputs: inputs);
    return _FirebaseTravelTemplateChat(session);
  }
}

class _FirebaseTravelTemplateChat implements TravelTemplateChat {
  const _FirebaseTravelTemplateChat(this._session);

  final TemplateChatSession _session;

  @override
  Future<GenerateContentResponse> sendMessage(Content message) {
    return _session.sendMessage(message);
  }
}
