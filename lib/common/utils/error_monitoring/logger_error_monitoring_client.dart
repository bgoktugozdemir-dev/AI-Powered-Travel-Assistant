import 'package:travel_assistant/common/utils/error_monitoring/error_monitoring_client.dart';
import 'package:travel_assistant/common/utils/logger/logger.dart';

abstract class _Constants {
  static const String defaultCategory = 'app';
  static const String defaultLevel = 'error';
}

class LoggerErrorMonitoringClient implements ErrorMonitoringClient {
  LoggerErrorMonitoringClient() : _enabled = true;

  bool _enabled;
  String? _userId;
  final Map<String, dynamic> _customData = {};

  @override
  void init() {}

  @override
  void setErrorMonitoringEnabled(bool enabled) {
    _enabled = enabled;
    appLogger.i('Error monitoring ${enabled ? 'enabled' : 'disabled'}');
  }

  @override
  void setUser(String userId) {
    _userId = userId;
    appLogger.i('Error monitoring user set: $userId');
  }

  @override
  void reportError(
    Object error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    if (!_enabled) return;

    final combinedContext = _buildContext(context);
    appLogger.e(
      'Error reported: $error',
      error: error,
      stackTrace: stackTrace,
    );
    if (combinedContext.isNotEmpty) {
      appLogger.d('Error context: $combinedContext');
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
    appLogger.e(
      'Exception reported: $exception',
      error: exception,
      stackTrace: stackTrace,
    );
    if (combinedContext.isNotEmpty) {
      appLogger.d('Exception context: $combinedContext');
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

    appLogger.d('Breadcrumb [$breadcrumbCategory]: $message');
    if (breadcrumbData.isNotEmpty) {
      appLogger.d('Breadcrumb data: $breadcrumbData');
    }
  }

  @override
  void setCustomData(String key, dynamic value) {
    _customData[key] = value;
    appLogger.d('Custom data set: $key = $value');
  }

  @override
  void setCustomContext(Map<String, dynamic> context) {
    _customData.addAll(context);
    appLogger.d('Custom context set: $context');
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

    appLogger.i('Message captured [$messageLevel]: $message');
    if (combinedContext.isNotEmpty) {
      appLogger.d('Message context: $combinedContext');
    }
  }

  @override
  void clearUser() {
    _userId = null;
    appLogger.i('Error monitoring user cleared');
  }

  @override
  void clearCustomData() {
    _customData.clear();
    appLogger.i('Error monitoring custom data cleared');
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
