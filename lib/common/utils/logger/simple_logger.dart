import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

/// Simple logger for the application that provides clean, easy-to-read output
class SimpleLogger {
  /// Log information message
  static void info(String message, {String? tag}) {
    if (!kDebugMode) return;

    final logTag = tag != null ? '[$tag]' : '';
    developer.log('ℹ️ $logTag $message', name: 'app');
  }

  /// Log warning message
  static void warning(String message, {String? tag, Object? error}) {
    if (!kDebugMode) return;

    final logTag = tag != null ? '[$tag]' : '';
    final errorInfo = error != null ? ' - $error' : '';
    developer.log('⚠️ $logTag $message$errorInfo', name: 'app');
  }

  /// Log error message
  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    bool printStack = true,
  }) {
    if (!kDebugMode) return;

    final logTag = tag != null ? '[$tag]' : '';
    final errorInfo = error != null ? ' - $error' : '';

    developer.log('❌ $logTag $message$errorInfo', name: 'app', error: error);

    if (printStack && stackTrace != null) {
      developer.log('  at: ${_formatStackTrace(stackTrace)}', name: 'app');
    }
  }

  /// Log debug message
  static void debug(String message, {String? tag}) {
    if (!kDebugMode) return;

    final logTag = tag != null ? '[$tag]' : '';
    developer.log('🔍 $logTag $message', name: 'app');
  }

  /// Format stack trace to show only the most relevant frame
  static String _formatStackTrace(StackTrace stackTrace) {
    final frames = stackTrace.toString().split('\n');
    if (frames.isEmpty) return '';

    // Find first frame that's not from the logger
    for (final frame in frames) {
      if (!frame.contains('logger') &&
          frame.contains('package:travel_assistant')) {
        return frame.trim();
      }
    }

    return frames.first.trim();
  }
}
