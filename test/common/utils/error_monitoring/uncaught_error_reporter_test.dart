import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:travel_assistant/common/utils/error_monitoring/error_monitoring_client.dart';
import 'package:travel_assistant/common/utils/error_monitoring/uncaught_error_reporter.dart';

class _Report {
  _Report(this.error, this.message, this.context);

  final Object error;
  final Object message;
  final Map<String, dynamic>? context;
}

class _FakeClient implements ErrorMonitoringClient {
  _FakeClient({this.onReport});

  final FutureOr<void> Function(Object error)? onReport;
  final List<_Report> reports = [];

  @override
  FutureOr<void> reportError(
    Object error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    reports.add(_Report(context?['error'] ?? error, error, context));
    return onReport?.call(error);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  test('reports uncaught errors with the real error as context', () {
    final client = _FakeClient();
    final reporter = UncaughtErrorReporter(errorMonitoring: client);
    final error = StateError('boom');

    reporter.report(error, StackTrace.current);

    expect(client.reports, hasLength(1));
    expect(client.reports.single.error, same(error));
  });

  test('only prints errors until error monitoring is attached', () {
    final reporter = UncaughtErrorReporter();

    expect(
      () => reporter.report(StateError('early'), StackTrace.current),
      returnsNormally,
    );

    final client = _FakeClient();
    reporter.errorMonitoring = client;
    reporter.report(StateError('late'), StackTrace.current);

    expect(client.reports, hasLength(1));
  });

  test('reports a repeating failure once per distinct message', () {
    final client = _FakeClient();
    final reporter = UncaughtErrorReporter(errorMonitoring: client);

    for (var i = 0; i < 3; i++) {
      reporter.report(StateError('same'), StackTrace.current);
    }
    reporter.report(StateError('different'), StackTrace.current);

    expect(client.reports, hasLength(2));
  });

  test('does not recurse when reporting itself fails to report', () {
    late UncaughtErrorReporter reporter;
    final client = _FakeClient(
      onReport: (error) {
        // An error raised while reporting reaches the zone handler again.
        reporter.report(StateError('nested'), StackTrace.current);
      },
    );
    reporter = UncaughtErrorReporter(errorMonitoring: client);

    reporter.report(StateError('outer'), StackTrace.current);

    expect(client.reports, hasLength(1));
  });

  test('swallows synchronous failures of the client', () {
    final client = _FakeClient(onReport: (_) => throw StateError('broken'));
    final reporter = UncaughtErrorReporter(errorMonitoring: client);

    expect(
      () => reporter.report(StateError('x'), StackTrace.current),
      returnsNormally,
    );

    // And the guard is released afterwards.
    reporter.report(StateError('y'), StackTrace.current);
    expect(client.reports, hasLength(2));
  });

  test('swallows asynchronous failures of the client', () async {
    final uncaught = <Object>[];
    await runZonedGuarded(() async {
      final client = _FakeClient(
        onReport: (_) => Future<void>.error(StateError('async broken')),
      );
      UncaughtErrorReporter(errorMonitoring: client).report(
        StateError('x'),
        StackTrace.current,
      );
      await Future<void>.delayed(Duration.zero);
    }, (error, stack) => uncaught.add(error));

    expect(uncaught, isEmpty);
  });
}
