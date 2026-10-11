import 'package:travel_assistant/common/utils/error_monitoring/error_monitoring_client.dart';

/// One call to `reportError` or `reportException`.
class RecordedReport {
  const RecordedReport(this.error, this.context);

  /// The first argument, as passed by the caller (often a human message).
  final Object error;

  /// The context map, if any.
  final Map<String, dynamic>? context;
}

/// An [ErrorMonitoringClient] that records what is reported to it.
///
/// Anything it does not record is ignored.
class RecordingErrorMonitoringClient implements ErrorMonitoringClient {
  final List<RecordedReport> reports = [];
  final List<String> breadcrumbs = [];

  @override
  void reportError(
    Object error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) => reports.add(RecordedReport(error, context));

  @override
  void reportException(
    Exception exception, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) => reports.add(RecordedReport(exception, context));

  @override
  void addBreadcrumb(
    String message, {
    String? category,
    Map<String, dynamic>? data,
  }) => breadcrumbs.add(message);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
