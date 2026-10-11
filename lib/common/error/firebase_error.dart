/// Marks an error that was already sent to error monitoring by the layer that
/// threw it, so upper layers must not report it again.
abstract interface class AlreadyReportedError {}

abstract class FirebaseError extends Error implements AlreadyReportedError {}

class FirebaseAppCheckError extends FirebaseError {}

/// The request to the AI backend was interrupted before a response arrived
/// (for example the browser suspended a backgrounded tab, or the network
/// dropped). Retrying while the app stays in the foreground usually works.
class FirebaseConnectionError extends FirebaseError {}

/// The AI pipeline failed for a reason that has no dedicated error type.
///
/// The underlying [cause] was already reported by the repository.
class AiGenerationException implements Exception, AlreadyReportedError {
  const AiGenerationException(this.cause);

  final Object cause;

  @override
  String toString() => 'Failed to generate text: $cause';
}
