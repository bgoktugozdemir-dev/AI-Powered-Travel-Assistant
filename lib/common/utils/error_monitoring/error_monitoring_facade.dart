import 'package:travel_assistant/common/utils/error_monitoring/error_monitoring_client.dart';
import 'package:travel_assistant/common/utils/logger/logger.dart';

class ErrorMonitoringFacade implements ErrorMonitoringClient {
  const ErrorMonitoringFacade(this._clients);

  final List<ErrorMonitoringClient> _clients;

  @override
  void setErrorMonitoringEnabled(bool enabled) {
    _dispatch(
      (client) async => client.setErrorMonitoringEnabled(enabled),
    );
  }

  @override
  void setUser(String userId) {
    _dispatch(
      (client) async => client.setUser(userId),
    );
  }

  @override
  void reportError(
    Object error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    _dispatch(
      (client) async => client.reportError(
        error,
        stackTrace: stackTrace,
        context: context,
      ),
    );
  }

  @override
  void reportException(
    Exception exception, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    _dispatch(
      (client) async => client.reportException(
        exception,
        stackTrace: stackTrace,
        context: context,
      ),
    );
  }

  @override
  void addBreadcrumb(
    String message, {
    String? category,
    Map<String, dynamic>? data,
  }) {
    _dispatch(
      (client) async => client.addBreadcrumb(
        message,
        category: category,
        data: data,
      ),
    );
  }

  @override
  void setCustomData(String key, dynamic value) {
    _dispatch(
      (client) async => client.setCustomData(key, value),
    );
  }

  @override
  void setCustomContext(Map<String, dynamic> context) {
    _dispatch(
      (client) async => client.setCustomContext(context),
    );
  }

  @override
  void captureMessage(
    String message, {
    String? level,
    Map<String, dynamic>? context,
  }) {
    _dispatch(
      (client) async => client.captureMessage(
        message,
        level: level,
        context: context,
      ),
    );
  }

  @override
  void clearUser() {
    _dispatch(
      (client) async => client.clearUser(),
    );
  }

  @override
  void clearCustomData() {
    _dispatch(
      (client) async => client.clearCustomData(),
    );
  }

  Future<void> _dispatch(Future<void> Function(ErrorMonitoringClient client) work) async {
    for (var client in _clients) {
      try {
        await work(client);
      } catch (e) {
        // Log error but continue with other clients to avoid cascading failures
        // We can't use the error monitoring here to avoid infinite loops
        appLogger.w('Error monitoring client failed: $e');
      }
    }
  }
}
