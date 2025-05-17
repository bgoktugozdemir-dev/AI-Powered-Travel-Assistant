import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:travel_assistant/common/utils/logger.dart';

/// Error categories for better organization and filtering of errors.
enum ErrorCategory {
  /// Network-related errors (API failures, connectivity issues)
  network,
  
  /// Authentication errors (login failures, token issues)
  auth,
  
  /// Data parsing or processing errors
  data,
  
  /// UI-related errors
  ui,
  
  /// AI/ML service errors (Gemini, VertexAI)
  ai,
  
  /// General unclassified errors
  general
}

/// A utility class for structured error logging throughout the application.
class ErrorLogger {
  static final Logger _logger = appLogger;
  
  /// The minimum error level for which to capture full details
  /// This can be set differently for debug vs production
  static Level _minLevelForDetails = kDebugMode ? Level.warning : Level.error;
  
  /// Log an error with detailed context information
  /// 
  /// [message] A descriptive message about what went wrong
  /// [error] The actual error/exception object
  /// [category] The category of error for better organization
  /// [stackTrace] The stack trace associated with the error
  /// [context] Additional context data that might help debug the issue
  static void logError({
    required String message,
    required dynamic error,
    ErrorCategory category = ErrorCategory.general,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    final errorDetails = {
      'category': category.toString(),
      'timestamp': DateTime.now().toIso8601String(),
      'error': error.toString(),
      'context': context ?? {},
    };
    
    // Log with appropriate level based on category
    switch (category) {
      case ErrorCategory.network:
        _logWithLevel(Level.error, message, error, stackTrace, errorDetails);
        break;
      case ErrorCategory.auth:
        _logWithLevel(Level.error, message, error, stackTrace, errorDetails);
        break;
      case ErrorCategory.data:
        _logWithLevel(Level.warning, message, error, stackTrace, errorDetails);
        break;
      case ErrorCategory.ui:
        _logWithLevel(Level.warning, message, error, stackTrace, errorDetails);
        break;
      case ErrorCategory.ai:
        _logWithLevel(Level.error, message, error, stackTrace, errorDetails);
        break;
      case ErrorCategory.general:
      default:
        _logWithLevel(Level.error, message, error, stackTrace, errorDetails);
        break;
    }
  }
  
  /// Helper method to log with the appropriate level
  static void _logWithLevel(
    Level level, 
    String message, 
    dynamic error, 
    StackTrace? stackTrace,
    Map<String, dynamic> details,
  ) {
    final fullMessage = '$message\nDetails: $details';
    
    if (level.index >= _minLevelForDetails.index) {
      // For serious errors, include stack trace and error object
      _logger.log(level, fullMessage, error: error, stackTrace: stackTrace);
    } else {
      // For less serious errors, just log the message and details
      _logger.log(level, fullMessage);
    }
    
    // Here you could add additional error reporting like Firebase Crashlytics
    // Or sending to a monitoring service in production
  }
  
  /// Log a network error
  static void logNetworkError(String message, dynamic error, {StackTrace? stackTrace, Map<String, dynamic>? context}) {
    logError(
      message: message, 
      error: error, 
      category: ErrorCategory.network, 
      stackTrace: stackTrace,
      context: context,
    );
  }
  
  /// Log an AI service error
  static void logAIError(String message, dynamic error, {StackTrace? stackTrace, Map<String, dynamic>? context}) {
    logError(
      message: message, 
      error: error, 
      category: ErrorCategory.ai, 
      stackTrace: stackTrace,
      context: context,
    );
  }
  
  /// Log a data processing error
  static void logDataError(String message, dynamic error, {StackTrace? stackTrace, Map<String, dynamic>? context}) {
    logError(
      message: message, 
      error: error, 
      category: ErrorCategory.data, 
      stackTrace: stackTrace,
      context: context,
    );
  }
} 