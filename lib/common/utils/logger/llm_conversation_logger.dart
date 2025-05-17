import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Simple logger for tracking conversations between the app and LLM models
class LlmLogger {
  /// Log a prompt sent to an LLM
  static void prompt(String modelName, String prompt) {
    if (!kDebugMode) return;

    developer.log('➡️ [$modelName] $prompt', name: 'llm');
  }

  /// Log a response received from an LLM
  static void response(String modelName, String response, {int? durationMs}) {
    if (!kDebugMode) return;

    final timing = durationMs != null ? ' [${durationMs}ms]' : '';
    developer.log('⬅️ [$modelName]$timing $response', name: 'llm');
  }

  /// Log an error that occurred during LLM communication
  static void error(String modelName, String message, Object error, {StackTrace? stackTrace}) {
    if (!kDebugMode) return;

    developer.log('❌ [$modelName] $message - $error', name: 'llm');

    if (stackTrace != null) {
      final frame = stackTrace.toString().split('\n').first;
      developer.log('  at: $frame', name: 'llm');
    }
  }

  /// Save full conversation to console (both prompt and response)
  static void conversation(String modelName, String prompt, String response, {int? durationMs}) {
    LlmLogger.prompt(modelName, prompt);
    LlmLogger.response(modelName, response, durationMs: durationMs);
  }
}
