import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_assistant/common/models/response/open_meteo_response.dart';
import 'package:travel_assistant/common/repositories/firebase_remote_config_repository.dart';
import 'package:travel_assistant/common/repositories/weather_repository.dart';
import 'package:travel_assistant/common/services/open_meteo_service.dart';
import 'package:travel_assistant/common/utils/error_monitoring/error_monitoring_facade.dart';

import '../../support/recording_error_monitoring_client.dart';

class _FakeOpenMeteoService implements OpenMeteoService {
  _FakeOpenMeteoService({
    required this.response,
    this.shouldThrow = false,
    this.error,
  });

  final OpenMeteoResponse response;
  final bool shouldThrow;

  /// Thrown by every call when set.
  final Object? error;
  int callCount = 0;
  final List<String> requestedStartDates = [];
  final List<String> requestedEndDates = [];

  @override
  Future<OpenMeteoResponse> getWeatherForecast({
    required double latitude,
    required double longitude,
    required String startDate,
    required String endDate,
    required String hourly,
    required String current,
    String timezone = 'auto',
  }) async {
    callCount++;
    requestedStartDates.add(startDate);
    requestedEndDates.add(endDate);
    if (error != null) {
      throw error!;
    }
    if (shouldThrow) {
      throw Exception('network');
    }
    return response;
  }
}

class _FakeFirebaseRemoteConfigRepository
    implements FirebaseRemoteConfigRepository {
  _FakeFirebaseRemoteConfigRepository({required this.cacheWeatherData});

  @override
  final bool cacheWeatherData;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// A bad request as Open-Meteo answers a date outside its forecast window.
DioException _badRequest() {
  final requestOptions = RequestOptions(path: '/forecast');
  return DioException(
    requestOptions: requestOptions,
    type: DioExceptionType.badResponse,
    response: Response<Map<String, dynamic>>(
      requestOptions: requestOptions,
      statusCode: 400,
      data: {
        'error': true,
        'reason':
            "Parameter 'end_date' is out of allowed range from "
            '2026-07-10 to 2026-10-26',
      },
    ),
  );
}

DioException _serverError() {
  final requestOptions = RequestOptions(path: '/forecast');
  return DioException(
    requestOptions: requestOptions,
    type: DioExceptionType.badResponse,
    response: Response<void>(requestOptions: requestOptions, statusCode: 500),
  );
}

void main() {
  // The forecast window is 16 days: 2026-10-11 up to and including 2026-10-26.
  final today = DateTime(2026, 10, 11, 14, 30);
  final lastForecastDate = DateTime(2026, 10, 26);

  final sampleResponse = OpenMeteoResponse.fromJson({
    'latitude': 41.0,
    'longitude': 29.0,
    'timezone': 'Europe/Istanbul',
    'current': {
      'temperature_2m': 21.5,
      'weather_code': 2,
      'relative_humidity_2m': 56,
    },
    'hourly': {
      'time': ['2026-06-01T00:00'],
      'temperature_2m': [21.5],
      'weather_code': [2],
      'relative_humidity_2m': [56],
    },
  });

  WeatherRepository repository(
    OpenMeteoService service, {
    bool cacheWeatherData = true,
    ErrorMonitoringFacade errorMonitoring = const ErrorMonitoringFacade([]),
    DateTime Function()? now,
  }) => WeatherRepository(
    service,
    _FakeFirebaseRemoteConfigRepository(cacheWeatherData: cacheWeatherData),
    errorMonitoring,
    now: now ?? () => today,
  );

  test('parses current temperature from temperature_2m', () {
    expect(sampleResponse.current.temperature, 21.5);
  });

  test('uses timezone in cache key', () async {
    WeatherRepository.clearCache();
    final service = _FakeOpenMeteoService(response: sampleResponse);
    final repo = repository(service);

    await repo.getWeatherForecast(
      latitude: 41,
      longitude: 29,
      startDate: DateTime(2026, 10, 12),
      endDate: DateTime(2026, 10, 13),
      timezone: 'Europe/Istanbul',
    );
    await repo.getWeatherForecast(
      latitude: 41,
      longitude: 29,
      startDate: DateTime(2026, 10, 12),
      endDate: DateTime(2026, 10, 13),
      timezone: 'UTC',
    );

    expect(service.callCount, 2);
  });

  test('uses date-only values in cache key', () async {
    WeatherRepository.clearCache();
    final service = _FakeOpenMeteoService(response: sampleResponse);
    final repo = repository(service);

    await repo.getWeatherForecast(
      latitude: 41,
      longitude: 29,
      startDate: DateTime(2026, 10, 12, 8, 30),
      endDate: DateTime(2026, 10, 13, 18, 45),
    );
    await repo.getWeatherForecast(
      latitude: 41,
      longitude: 29,
      startDate: DateTime(2026, 10, 12, 22, 15),
      endDate: DateTime(2026, 10, 13, 6, 5),
    );

    expect(service.callCount, 1);
    expect(service.requestedStartDates, ['2026-10-12']);
    expect(service.requestedEndDates, ['2026-10-13']);
  });

  test('bypasses cached reads when cache is disabled', () async {
    WeatherRepository.clearCache();
    final service = _FakeOpenMeteoService(response: sampleResponse);
    final cacheEnabledRepo = repository(service);
    final cacheDisabledRepo = repository(service, cacheWeatherData: false);

    await cacheEnabledRepo.getWeatherForecast(
      latitude: 41,
      longitude: 29,
      startDate: DateTime(2026, 10, 12),
      endDate: DateTime(2026, 10, 13),
    );
    await cacheDisabledRepo.getWeatherForecast(
      latitude: 41,
      longitude: 29,
      startDate: DateTime(2026, 10, 12),
      endDate: DateTime(2026, 10, 13),
    );

    expect(service.callCount, 2);
  });

  test('evicts expired cache entries before reads', () async {
    WeatherRepository.clearCache();
    var now = DateTime(2026, 10, 11);
    final service = _FakeOpenMeteoService(response: sampleResponse);
    final repo = repository(service, now: () => now);

    await repo.getWeatherForecast(
      latitude: 41,
      longitude: 29,
      startDate: DateTime(2026, 10, 11),
      endDate: DateTime(2026, 10, 12),
    );
    now = DateTime(2026, 10, 11, 7);
    await repo.getWeatherForecast(
      latitude: 41,
      longitude: 29,
      startDate: DateTime(2026, 10, 11),
      endDate: DateTime(2026, 10, 12),
    );

    expect(service.callCount, 2);
  });

  test('returns a failure when service throws', () async {
    WeatherRepository.clearCache();
    final service = _FakeOpenMeteoService(
      response: sampleResponse,
      shouldThrow: true,
    );
    final repo = repository(service);

    final result = await repo.getWeatherForecast(
      latitude: 41,
      longitude: 29,
      startDate: DateTime(2026, 10, 12),
      endDate: DateTime(2026, 10, 13),
    );

    expect(result, isA<WeatherForecastFailed>());
  });

  test('reports a failure with the real error under the error key', () async {
    WeatherRepository.clearCache();
    final monitoring = RecordingErrorMonitoringClient();
    final repo = repository(
      _FakeOpenMeteoService(response: sampleResponse, shouldThrow: true),
      errorMonitoring: ErrorMonitoringFacade([monitoring]),
    );

    await repo.getWeatherForecast(
      latitude: 41,
      longitude: 29,
      startDate: DateTime(2026, 10, 12),
      endDate: DateTime(2026, 10, 13),
    );

    expect(monitoring.reports, hasLength(1));
    expect(monitoring.reports.single.error, isA<String>());
    expect(monitoring.reports.single.context?['error'], isA<Exception>());
  });

  group('forecast window', () {
    late RecordingErrorMonitoringClient monitoring;

    setUp(() {
      WeatherRepository.clearCache();
      monitoring = RecordingErrorMonitoringClient();
    });

    WeatherRepository repositoryFor(
      OpenMeteoService service, {
      DateTime Function()? now,
    }) => repository(
      service,
      errorMonitoring: ErrorMonitoringFacade([monitoring]),
      now: now,
    );

    test(
      'skips the request and the report when the range starts beyond it',
      () async {
        final service = _FakeOpenMeteoService(response: sampleResponse);

        // The range of the Sentry issue: three weeks ahead.
        final result = await repositoryFor(service).getWeatherForecast(
          latitude: 52.2297,
          longitude: 21.0122,
          startDate: DateTime(2026, 11),
          endDate: DateTime(2026, 11, 6),
        );

        expect(service.callCount, 0);
        expect(result, isA<WeatherForecastBeyondWindow>());
        expect(
          (result as WeatherForecastBeyondWindow).lastForecastDate,
          lastForecastDate,
        );
        expect(monitoring.reports, isEmpty);
        expect(monitoring.breadcrumbs, isEmpty);
      },
    );

    test('treats the day after the window as beyond it', () async {
      final service = _FakeOpenMeteoService(response: sampleResponse);

      final result = await repositoryFor(service).getWeatherForecast(
        latitude: 41,
        longitude: 29,
        startDate: DateTime(2026, 10, 27),
        endDate: DateTime(2026, 10, 28),
      );

      expect(result, isA<WeatherForecastBeyondWindow>());
      expect(service.callCount, 0);
    });

    test('requests a range that starts on the last day of the window', () async {
      final service = _FakeOpenMeteoService(response: sampleResponse);

      final result = await repositoryFor(service).getWeatherForecast(
        latitude: 41,
        longitude: 29,
        // Late in the day: only the date counts.
        startDate: DateTime(2026, 10, 26, 23, 59),
        endDate: DateTime(2026, 10, 26, 23, 59),
      );

      expect(service.callCount, 1);
      expect(result, isA<WeatherForecastFound>());
      expect((result as WeatherForecastFound).clampedEndDate, isNull);
      expect(service.requestedStartDates, ['2026-10-26']);
      expect(service.requestedEndDates, ['2026-10-26']);
    });

    test('clamps the end date when the range ends beyond it', () async {
      final service = _FakeOpenMeteoService(response: sampleResponse);

      final result = await repositoryFor(service).getWeatherForecast(
        latitude: 41,
        longitude: 29,
        startDate: DateTime(2026, 10, 20),
        endDate: DateTime(2026, 11, 2),
      );

      expect(service.requestedStartDates, ['2026-10-20']);
      expect(service.requestedEndDates, ['2026-10-26']);
      expect(result, isA<WeatherForecastFound>());
      expect(
        (result as WeatherForecastFound).clampedEndDate,
        lastForecastDate,
      );
      expect(monitoring.reports, isEmpty);
    });

    test('leaves a range inside the window as requested', () async {
      final service = _FakeOpenMeteoService(response: sampleResponse);

      final result = await repositoryFor(service).getWeatherForecast(
        latitude: 41,
        longitude: 29,
        startDate: DateTime(2026, 10, 11),
        endDate: DateTime(2026, 10, 14),
      );

      expect(service.requestedStartDates, ['2026-10-11']);
      expect(service.requestedEndDates, ['2026-10-14']);
      expect((result as WeatherForecastFound).clampedEndDate, isNull);
    });

    test('measures the window from the current date', () async {
      final service = _FakeOpenMeteoService(response: sampleResponse);

      // Nine days later the same range is inside the window.
      final result = await repositoryFor(
        service,
        now: () => DateTime(2026, 10, 20),
      ).getWeatherForecast(
        latitude: 41,
        longitude: 29,
        startDate: DateTime(2026, 11),
        endDate: DateTime(2026, 11, 3),
      );

      expect(service.callCount, 1);
      expect((result as WeatherForecastFound).clampedEndDate, isNull);
    });

    test('keeps reporting the clamp when the answer is cached', () async {
      final service = _FakeOpenMeteoService(response: sampleResponse);
      final repo = repositoryFor(service);

      for (var i = 0; i < 2; i++) {
        final result = await repo.getWeatherForecast(
          latitude: 41,
          longitude: 29,
          startDate: DateTime(2026, 10, 20),
          endDate: DateTime(2026, 11, 2),
        );
        expect(
          (result as WeatherForecastFound).clampedEndDate,
          lastForecastDate,
        );
      }

      expect(service.callCount, 1);
    });
  });

  group('failed requests', () {
    late RecordingErrorMonitoringClient monitoring;

    setUp(() {
      WeatherRepository.clearCache();
      monitoring = RecordingErrorMonitoringClient();
    });

    test('records a rejected range (HTTP 400) as a breadcrumb', () async {
      final repo = repository(
        _FakeOpenMeteoService(response: sampleResponse, error: _badRequest()),
        errorMonitoring: ErrorMonitoringFacade([monitoring]),
      );

      final result = await repo.getWeatherForecast(
        latitude: 41,
        longitude: 29,
        startDate: DateTime(2026, 10, 12),
        endDate: DateTime(2026, 10, 13),
      );

      expect(result, isA<WeatherForecastFailed>());
      expect(monitoring.reports, isEmpty);
      expect(monitoring.breadcrumbs, hasLength(1));
    });

    test('still reports other HTTP failures', () async {
      final repo = repository(
        _FakeOpenMeteoService(response: sampleResponse, error: _serverError()),
        errorMonitoring: ErrorMonitoringFacade([monitoring]),
      );

      final result = await repo.getWeatherForecast(
        latitude: 41,
        longitude: 29,
        startDate: DateTime(2026, 10, 12),
        endDate: DateTime(2026, 10, 13),
      );

      expect(result, isA<WeatherForecastFailed>());
      expect(monitoring.reports, hasLength(1));
      expect(monitoring.reports.single.context?['error'], isA<DioException>());
      expect(monitoring.breadcrumbs, isEmpty);
    });
  });
}
