import 'package:flutter/foundation.dart'; // For kDebugMode
import 'package:logger/logger.dart';

/// Global logger instance for the application.
final appLogger = Logger(
  printer: PrettyPrinter(
    methodCount: 1,       // Number of method calls to be displayed
    errorMethodCount: 8,  // Number of method calls if stacktrace is provided
    lineLength: 100,      // Width of the output
    colors: true,         // Colorful log messages
    printEmojis: true,    // Print an emoji for each log message
    printTime: true,     // Should each log print contain a timestamp
  ),
  // Optional: Filter logs in release mode
  filter: kDebugMode ? DevelopmentFilter() : ProductionFilter(), 
  // By default, DevelopmentFilter logs all levels in debug mode, 
  // and ProductionFilter logs nothing in release mode.
  // You can customize further if needed, e.g., ProductionFilter(level: Level.warning)
);

// To make it even more concise, you can define simple log functions:
// void logD(dynamic message) => appLogger.d(message);
// void logI(dynamic message) => appLogger.i(message);
// void logW(dynamic message, [dynamic error, StackTrace? stackTrace]) => appLogger.w(message, error: error, stackTrace: stackTrace);
// void logE(dynamic message, [dynamic error, StackTrace? stackTrace]) => appLogger.e(message, error: error, stackTrace: stackTrace); 