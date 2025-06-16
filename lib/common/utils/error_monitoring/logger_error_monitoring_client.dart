import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:travel_assistant/common/utils/error_monitoring/error_monitoring_client.dart';

abstract class _Constants {
  static const String defaultCategory = 'app';
  static const String defaultLevel = 'error';
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

class LoggerErrorMonitoringClient implements ErrorMonitoringClient {
  LoggerErrorMonitoringClient() : _enabled = true;

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

  late final _logger = Logger(
    printer: HybridPrinter(
      _simplePrinter,
      error: _prettierPrinter,
      fatal: _prettierPrinter,
      warning: _prettierPrinter,
    ),
    // Custom filter that completely disables logs in release mode
    filter: _ReleaseFilter(),
  );

  bool _enabled;
  String? _userId;
  final Map<String, dynamic> _customData = {};

  @override
  void init() {}

  @override
  void setErrorMonitoringEnabled(bool enabled) {
    _enabled = enabled;
    _logger.i('Error monitoring ${enabled ? 'enabled' : 'disabled'}');
  }

  @override
  void setUser(String userId) {
    _userId = userId;
    _logger.i('Error monitoring user set: $userId');
  }

  @override
  void reportError(
    Object error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    if (!_enabled) return;

    final combinedContext = _buildContext(context);
    _logger.e(
      'Error reported: $error',
      error: error,
      stackTrace: stackTrace,
    );
    if (combinedContext.isNotEmpty) {
      _logger.d('Error context: $combinedContext');
    }
  }

  @override
  void reportException(
    Exception exception, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    if (!_enabled) return;

    final combinedContext = _buildContext(context);
    _logger.e(
      'Exception reported: $exception',
      error: exception,
      stackTrace: stackTrace,
    );
    if (combinedContext.isNotEmpty) {
      _logger.d('Exception context: $combinedContext');
    }
  }

  @override
  void addBreadcrumb(
    String message, {
    String? category,
    Map<String, dynamic>? data,
  }) {
    if (!_enabled) return;

    final breadcrumbCategory = category ?? _Constants.defaultCategory;
    final breadcrumbData = data ?? {};

    _logger.d('Breadcrumb [$breadcrumbCategory]: $message');
    if (breadcrumbData.isNotEmpty) {
      _logger.d('Breadcrumb data: $breadcrumbData');
    }
  }

  @override
  void setCustomData(String key, dynamic value) {
    _customData[key] = value;
    _logger.d('Custom data set: $key = $value');
  }

  @override
  void setCustomContext(Map<String, dynamic> context) {
    _customData.addAll(context);
    _logger.d('Custom context set: $context');
  }

  @override
  void captureMessage(
    String message, {
    String? level,
    Map<String, dynamic>? context,
  }) {
    if (!_enabled) return;

    final messageLevel = level ?? _Constants.defaultLevel;
    final combinedContext = _buildContext(context);

    _logger.i('Message captured [$messageLevel]: $message');
    if (combinedContext.isNotEmpty) {
      _logger.d('Message context: $combinedContext');
    }
  }

  @override
  void clearUser() {
    _userId = null;
    _logger.i('Error monitoring user cleared');
  }

  @override
  void clearCustomData() {
    _customData.clear();
    _logger.i('Error monitoring custom data cleared');
  }

  Map<String, dynamic> _buildContext(Map<String, dynamic>? additionalContext) {
    final context = <String, dynamic>{};

    if (_userId != null) {
      context['userId'] = _userId;
    }

    context.addAll(_customData);

    if (additionalContext != null) {
      context.addAll(additionalContext);
    }

    return context;
  }
}
