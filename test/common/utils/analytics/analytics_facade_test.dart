import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:travel_assistant/common/utils/analytics/analytics_client.dart';
import 'package:travel_assistant/common/utils/analytics/analytics_facade.dart';

class _RecordingClient implements AnalyticsClient {
  _RecordingClient({this.failure});

  final Object? failure;
  final List<String> searches = [];

  @override
  Future<void> logSearchDepartureAirport(String query) async {
    if (failure case final failure?) {
      throw failure;
    }
    searches.add(query);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  test('a failing client does not stop the others', () async {
    final failing = _RecordingClient(failure: StateError('Stack Overflow'));
    final healthy = _RecordingClient();
    final facade = AnalyticsFacade([failing, healthy]);

    facade.logSearchDepartureAirport(' ist ');
    await Future<void>.delayed(Duration.zero);

    expect(healthy.searches, ['ist']);
  });

  test('a failing client does not surface as an uncaught error', () async {
    final uncaught = <Object>[];
    final failures = <Object>[];

    await runZonedGuarded(() async {
      final facade = AnalyticsFacade(
        [_RecordingClient(failure: StateError('boom'))],
        onError: (error, stackTrace, client) => failures.add(error),
      );

      facade.logSearchDepartureAirport('ist');
      await Future<void>.delayed(Duration.zero);
    }, (error, stack) => uncaught.add(error));

    expect(uncaught, isEmpty);
    expect(failures.single, isA<StateError>());
  });

  test('a throwing failure callback does not surface either', () async {
    final uncaught = <Object>[];

    await runZonedGuarded(() async {
      final facade = AnalyticsFacade(
        [_RecordingClient(failure: StateError('boom'))],
        onError: (error, stackTrace, client) => throw StateError('callback'),
      );

      facade.logSearchDepartureAirport('ist');
      await Future<void>.delayed(Duration.zero);
    }, (error, stack) => uncaught.add(error));

    expect(uncaught, isEmpty);
  });
}
