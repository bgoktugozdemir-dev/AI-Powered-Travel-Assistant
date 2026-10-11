import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_assistant/common/error/firebase_error.dart';
import 'package:travel_assistant/common/repositories/airport_repository.dart';
import 'package:travel_assistant/common/services/airport_api_service.dart';
import 'package:travel_assistant/common/utils/error_monitoring/error_monitoring_facade.dart';

import '../../support/recording_error_monitoring_client.dart';

class _FailingAirportApiService extends Fake implements AirportApiService {
  _FailingAirportApiService(this.error);

  final Object error;

  @override
  Future<AirportApiResponse> searchAirports(
    String datasetId,
    String query, {
    int rows = 10,
  }) async => throw error;
}

void main() {
  late RecordingErrorMonitoringClient monitoring;

  AirportRepository repositoryFailingWith(Object error) => AirportRepository(
    apiService: _FailingAirportApiService(error),
    errorMonitoringFacade: ErrorMonitoringFacade([monitoring]),
  );

  setUp(() => monitoring = RecordingErrorMonitoringClient());

  test('reports a network failure once and marks the thrown error', () async {
    final dioError = DioException(
      requestOptions: RequestOptions(path: '/search/'),
      message: 'offline',
    );

    await expectLater(
      () => repositoryFailingWith(dioError).searchAirports('istanbul'),
      throwsA(
        isA<AirportSearchException>().having(
          (e) => e,
          'is already reported',
          isA<AlreadyReportedError>(),
        ),
      ),
    );

    expect(monitoring.reports, hasLength(1));
    expect(monitoring.reports.single.context?['error'], same(dioError));
  });

  test('reports an unexpected failure once and marks the thrown error', () async {
    final boom = StateError('boom');

    await expectLater(
      () => repositoryFailingWith(boom).searchAirports('istanbul'),
      throwsA(isA<AirportSearchException>()),
    );

    expect(monitoring.reports, hasLength(1));
    expect(monitoring.reports.single.context?['error'], same(boom));
  });

  test('does not call the API for a short query', () async {
    final result = await repositoryFailingWith(
      StateError('must not be called'),
    ).searchAirports('is');

    expect(result, isEmpty);
    expect(monitoring.reports, isEmpty);
  });
}
