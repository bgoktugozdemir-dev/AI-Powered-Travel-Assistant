import 'dart:async';

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
  FutureOr<void> setErrorMonitoringEnabled(bool enabled) {
    _enabled = enabled;
    appLogger.i('Error monitoring ${enabled ? 'enabled' : 'disabled'}');
  }

  @override
  FutureOr<void> setUser(String userId) {
    _userId = userId;
    appLogger.i('Error monitoring user set: $userId');
  }

  @override
  FutureOr<void> reportError(
    Object error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    if (!_enabled) return Future<void>.value();

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
  FutureOr<void> reportException(
    Exception exception, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    if (!_enabled) return Future<void>.value();

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
  FutureOr<void> addBreadcrumb(
    String message, {
    String? category,
    Map<String, dynamic>? data,
  }) {
    if (!_enabled) return Future<void>.value();

    final breadcrumbCategory = category ?? _Constants.defaultCategory;
    final breadcrumbData = data ?? {};

    appLogger.d('Breadcrumb [$breadcrumbCategory]: $message');
    if (breadcrumbData.isNotEmpty) {
      appLogger.d('Breadcrumb data: $breadcrumbData');
    }
  }

  @override
  FutureOr<void> setCustomData(String key, dynamic value) {
    _customData[key] = value;
    appLogger.d('Custom data set: $key = $value');
  }

  @override
  FutureOr<void> setCustomContext(Map<String, dynamic> context) {
    _customData.addAll(context);
    appLogger.d('Custom context set: $context');
  }

  @override
  FutureOr<void> captureMessage(
    String message, {
    String? level,
    Map<String, dynamic>? context,
  }) {
    if (!_enabled) return Future<void>.value();

    final messageLevel = level ?? _Constants.defaultLevel;
    final combinedContext = _buildContext(context);

    appLogger.i('Message captured [$messageLevel]: $message');
    if (combinedContext.isNotEmpty) {
      appLogger.d('Message context: $combinedContext');
    }
  }

  @override
  FutureOr<void> clearUser() {
    _userId = null;
    appLogger.i('Error monitoring user cleared');
  }

  @override
  FutureOr<void> clearCustomData() {
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
