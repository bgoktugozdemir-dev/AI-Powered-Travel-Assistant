import 'package:firebase_ai/firebase_ai.dart';
import 'package:travel_assistant/common/utils/error_monitoring/error_monitoring_facade.dart';

abstract class _Constants {
  /// Waits before each retry. Their count is the number of retries.
  static const List<Duration> retryDelays = [
    Duration(seconds: 2),
    Duration(seconds: 4),
    Duration(seconds: 8),
  ];

  /// Matches "Resource exhausted" / "RESOURCE_EXHAUSTED" in a server message.
  static final RegExp resourceExhaustedPattern = RegExp(
    r'resource.?exhausted',
  );
}

/// Whether [error] is a 429 from the AI backend: the model is out of capacity
/// or the project hit a rate quota. Both usually clear within seconds.
bool isResourceExhaustedError(Object error) => switch (error) {
  QuotaExceeded() => true,
  ServerException(:final message) =>
    _Constants.resourceExhaustedPattern.hasMatch(message.toLowerCase()),
  _ => false,
};

/// Runs [request], retrying it with a growing delay while it fails with a
/// 429 (see [isResourceExhaustedError]). Other errors, and the last 429, are
/// rethrown.
///
/// Retrying a chat message is safe: the SDK only records a turn in the chat
/// history once its response has arrived.
///
/// [wait] replaces the real delay in tests.
Future<T> retryOnResourceExhausted<T>(
  Future<T> Function() request, {
  required ErrorMonitoringFacade errorMonitoring,
  required String requestName,
  Future<void> Function(Duration delay) wait = Future<void>.delayed,
}) async {
  for (var attempt = 0; ; attempt++) {
    try {
      return await request();
    } catch (e) {
      if (attempt >= _Constants.retryDelays.length ||
          !isResourceExhaustedError(e)) {
        rethrow;
      }
      final delay = _Constants.retryDelays[attempt];
      errorMonitoring.addBreadcrumb(
        'Firebase AI request was rate limited, retrying.',
        category: 'Firebase AI',
        data: {
          'request': requestName,
          'attempt': attempt + 1,
          'delayMs': delay.inMilliseconds,
          'error': e.toString(),
        },
      );
      await wait(delay);
    }
  }
}
