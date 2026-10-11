/// An error report resolved from the `(error, context)` pair that callers hand
/// to the error monitoring layer.
class ResolvedErrorReport {
  const ResolvedErrorReport({
    required this.error,
    this.message,
    this.context = const {},
  });

  /// The object that should be captured as the monitored exception.
  final Object error;

  /// Human readable description of what the app was doing when [error]
  /// occurred, if the caller provided one.
  final String? message;

  /// Remaining context entries (without the entry that carried [error]).
  final Map<String, dynamic> context;
}

/// Resolves what should be captured for a `reportError(error, context: ...)`.
///
/// Historically call sites report with a human message as [error] and the
/// caught exception as `context['error']`:
///
/// ```dart
/// reportError('Failed to load X.', stackTrace: st, context: {'error': e});
/// ```
///
/// Capturing that literally yields a `String` exception with no real type or
/// message, which makes Sentry group unrelated failures together. This keeps
/// the call sites untouched but promotes `context['error']` to the captured
/// exception and keeps the message as [ResolvedErrorReport.message].
///
/// Anything else is passed through unchanged.
ResolvedErrorReport resolveErrorReport(
  Object error, {
  Map<String, dynamic>? context,
}) {
  final wrapped = context?['error'];
  if (error is String && wrapped != null) {
    return ResolvedErrorReport(
      error: wrapped,
      message: error,
      context: Map<String, dynamic>.of(context!)..remove('error'),
    );
  }
  return ResolvedErrorReport(error: error, context: context ?? const {});
}
