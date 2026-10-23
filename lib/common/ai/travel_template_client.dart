import 'package:firebase_ai/firebase_ai.dart';
import 'package:travel_assistant/common/ai/resource_exhausted_retry.dart';
import 'package:travel_assistant/common/ai/streamed_response.dart';
import 'package:travel_assistant/common/utils/error_monitoring/error_monitoring_facade.dart';

/// Chat session bound to a server prompt template.
///
/// App-owned seam over `TemplateChatSession`, which is a `final` class and
/// cannot be faked in tests.
abstract interface class TravelTemplateChat {
  /// Sends [message] as the next turn of the conversation and returns the
  /// whole response once it has been received.
  Future<GenerateContentResponse> sendMessage(Content message);
}

/// Client for Firebase AI Logic server prompt templates.
///
/// App-owned seam over `TemplateGenerativeModel`, which is `@experimental`
/// and a `final` class. All experimental API usage is confined to
/// [FirebaseTravelTemplateClient] so the rest of the app depends on this
/// interface only.
abstract interface class TravelTemplateClient {
  /// Runs the single-turn template [templateId] with the given [inputs] and
  /// returns the whole response once it has been received.
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
///
/// Requests are streamed and collected (see [collectStreamedResponse]) so a
/// long generation is not cut off by Safari, and retried while the backend
/// is rate limited (see [retryOnResourceExhausted]). Each request leaves its
/// stats as a breadcrumb.
class FirebaseTravelTemplateClient implements TravelTemplateClient {
  /// Creates a client that talks to templates through [firebaseAI].
  FirebaseTravelTemplateClient({
    required FirebaseAI firebaseAI,
    required ErrorMonitoringFacade errorMonitoring,
  }) : _firebaseAI = firebaseAI,
       _errorMonitoring = errorMonitoring;

  final FirebaseAI _firebaseAI;
  final ErrorMonitoringFacade _errorMonitoring;

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
    final requestName = 'template:$templateId';
    return retryOnResourceExhausted(
      () => collectStreamedResponse(
        // ignore: experimental_member_use
        _model.generateContentStream(templateId, inputs: inputs),
        onDone: requestBreadcrumb(_errorMonitoring, requestName),
      ),
      errorMonitoring: _errorMonitoring,
      requestName: requestName,
    );
  }

  @override
  TravelTemplateChat startChat(
    String templateId, {
    required Map<String, Object?> inputs,
  }) {
    final session = _model.startChat(templateId, inputs: inputs);
    return _FirebaseTravelTemplateChat(
      session,
      errorMonitoring: _errorMonitoring,
      requestName: 'template-chat:$templateId',
    );
  }
}

class _FirebaseTravelTemplateChat implements TravelTemplateChat {
  const _FirebaseTravelTemplateChat(
    this._session, {
    required this.errorMonitoring,
    required this.requestName,
  });

  final TemplateChatSession _session;
  final ErrorMonitoringFacade errorMonitoring;
  final String requestName;

  @override
  Future<GenerateContentResponse> sendMessage(Content message) {
    return retryOnResourceExhausted(
      () => collectStreamedResponse(
        _session.sendMessageStream(message),
        onDone: requestBreadcrumb(errorMonitoring, requestName),
      ),
      errorMonitoring: errorMonitoring,
      requestName: requestName,
    );
  }
}
