import 'dart:async';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:travel_assistant/common/utils/error_monitoring/error_monitoring_client.dart';

/// Reports errors that escaped every other handler (the `runZonedGuarded`
/// error callback) to error monitoring.
///
/// It must never throw or recurse: it runs as the last line of defence, and an
/// error raised while reporting would otherwise land in the very same handler
/// again. A failure that keeps repeating (for example on every tap) is
/// reported once per distinct message, not once per occurrence.
class UncaughtErrorReporter {
  UncaughtErrorReporter({ErrorMonitoringClient? errorMonitoring})
    : _errorMonitoring = errorMonitoring;

  ErrorMonitoringClient? _errorMonitoring;
  bool _isReporting = false;
  final Set<String> _reportedErrors = {};

  /// Where uncaught errors are reported. Errors that occur before it is set
  /// (during start up) are only printed.
  set errorMonitoring(ErrorMonitoringClient? value) => _errorMonitoring = value;

  /// Prints and reports an uncaught [error].
  void report(Object error, StackTrace stackTrace) {
    debugPrint('Global error handler: $error');

    final errorMonitoring = _errorMonitoring;
    if (errorMonitoring == null || _isReporting) {
      return;
    }
    if (!_reportedErrors.add(error.toString())) {
      return;
    }

    _isReporting = true;
    try {
      final result = errorMonitoring.reportError(
        'Uncaught error',
        stackTrace: stackTrace,
        context: {'error': error},
      );
      if (result is Future<void>) {
        // A failing report must not become another uncaught error.
        unawaited(result.catchError((Object _) {}));
      }
    } catch (_) {
      // Swallowed on purpose, see the class documentation.
    } finally {
      _isReporting = false;
    }
  }
}
