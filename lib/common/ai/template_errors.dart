import 'package:firebase_ai/firebase_ai.dart' show ServerException;
import 'package:travel_assistant/common/ai/travel_research_pass.dart'
    show TravelResearchPassException;

abstract class _Constants {
  /// Matches "not found", "NOT_FOUND" and "notfound" in a server message.
  static final RegExp notFoundPattern = RegExp(r'not.?found');
}

/// Whether [error] means the server prompt template cannot be used.
///
/// True for a firebase_ai [ServerException] (directly or wrapped in a
/// [TravelResearchPassException]) reporting a missing resource, or an invalid
/// template. The SDK reduces every HTTP error body to a [ServerException]
/// message, so the message is the only signal available.
///
/// Other server errors, most importantly App Check denials, return false so
/// they keep propagating to the repository instead of being retried.
bool isTemplateUnavailableError(Object error) {
  final cause = error is TravelResearchPassException ? error.cause : error;
  if (cause is! ServerException) {
    return false;
  }
  final message = cause.message.toLowerCase();
  return _Constants.notFoundPattern.hasMatch(message) ||
      (message.contains('template') && message.contains('invalid'));
}
