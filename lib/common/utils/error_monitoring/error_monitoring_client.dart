import 'dart:async';

abstract class ErrorMonitoringClient {
  /// Initializes the error monitoring client.
  FutureOr<void> init();

  /// Sets the error monitoring collection enabled flag.
  FutureOr<void> setErrorMonitoringEnabled(bool enabled);

  /// Identifies a user in error monitoring with the given [userId].
  FutureOr<void> setUser(String userId);

  /// Reports an error with optional [stackTrace] and [context].
  ///
  /// Pass the caught exception as [error] whenever possible so it is monitored
  /// with its real type and message. For call sites that want to describe what
  /// failed, `reportError('Failed to X.', context: {'error': e})` is
  /// supported too: the string is kept as the report message and
  /// `context['error']` is what gets captured (see `resolveErrorReport`).
  FutureOr<void> reportError(
    Object error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  });

  /// Reports an exception with optional [stackTrace] and [context].
  FutureOr<void> reportException(
    Exception exception, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  });

  /// Adds a breadcrumb to track user actions with optional [category] and [data].
  FutureOr<void> addBreadcrumb(
    String message, {
    String? category,
    Map<String, dynamic>? data,
  });

  /// Sets custom data for additional context.
  FutureOr<void> setCustomData(String key, dynamic value);

  /// Sets multiple custom data entries.
  FutureOr<void> setCustomContext(Map<String, dynamic> context);

  /// Captures a message with optional [level] and [context].
  FutureOr<void> captureMessage(
    String message, {
    String? level,
    Map<String, dynamic>? context,
  });

  /// Clears the current user and context.
  FutureOr<void> clearUser();

  /// Clears all custom data.
  FutureOr<void> clearCustomData();
}
