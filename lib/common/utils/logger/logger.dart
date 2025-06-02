import 'package:flutter/foundation.dart'; // For kDebugMode
import 'package:logger/logger.dart';

abstract class _Constants {
  static const int methodCount = 1;
  static const int errorMethodCount = 8;
  static const int lineLength = 100;
}

/// Custom filter that completely disables logging in production
class _ReleaseFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    // Only log in debug mode, completely disable in release
    return kDebugMode;
  }
}

/// Global logger instance for the application.
final appLogger = Logger(
  printer: HybridPrinter(
    _simplePrinter,
    error: _prettierPrinter,
    fatal: _prettierPrinter,
    warning: _prettierPrinter,
  ),
  // Custom filter that completely disables logs in release mode
  filter: _ReleaseFilter(),
);

final _simplePrinter = SimplePrinter(
  colors: true,
);

final _prettierPrinter = PrettyPrinter(
  methodCount: _Constants.methodCount, // Number of method calls to be displayed
  errorMethodCount: _Constants.errorMethodCount, // Number of method calls if stacktrace is provided
  lineLength: _Constants.lineLength, // Width of the output
  printEmojis: true, // Print an emoji for each log message
  dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart, // Print timestamp
);
