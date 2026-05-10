import 'package:flutter_test/flutter_test.dart';
import 'package:travel_assistant/common/models/response/open_meteo_response.dart';
import 'package:travel_assistant/common/repositories/firebase_remote_config_repository.dart';
import 'package:travel_assistant/common/repositories/weather_repository.dart';
import 'package:travel_assistant/common/services/open_meteo_service.dart';
import 'package:travel_assistant/common/utils/error_monitoring/error_monitoring_facade.dart';

class _FakeOpenMeteoService implements OpenMeteoService {
  _FakeOpenMeteoService({required this.response, this.shouldThrow = false});

  final OpenMeteoResponse response;
  final bool shouldThrow;
  int callCount = 0;

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

void main() {
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

  test('parses current temperature from temperature_2m', () {
    expect(sampleResponse.current.temperature, 21.5);
  });

  test('uses timezone in cache key', () async {
    WeatherRepository.clearCache();
    final service = _FakeOpenMeteoService(response: sampleResponse);
    final repo = WeatherRepository(
      service,
      _FakeFirebaseRemoteConfigRepository(cacheWeatherData: true),
      const ErrorMonitoringFacade([]),
    );

    await repo.getWeatherForecast(
      latitude: 41,
      longitude: 29,
      startDate: DateTime(2026, 6, 1),
      endDate: DateTime(2026, 6, 2),
      timezone: 'Europe/Istanbul',
    );
    await repo.getWeatherForecast(
      latitude: 41,
      longitude: 29,
      startDate: DateTime(2026, 6, 1),
      endDate: DateTime(2026, 6, 2),
      timezone: 'UTC',
    );

    expect(service.callCount, 2);
  });

  test('returns null when service throws', () async {
    WeatherRepository.clearCache();
    final service = _FakeOpenMeteoService(
      response: sampleResponse,
      shouldThrow: true,
    );
    final repo = WeatherRepository(
      service,
      _FakeFirebaseRemoteConfigRepository(cacheWeatherData: true),
      const ErrorMonitoringFacade([]),
    );

    final result = await repo.getWeatherForecast(
      latitude: 41,
      longitude: 29,
      startDate: DateTime(2026, 6, 1),
      endDate: DateTime(2026, 6, 2),
    );

    expect(result, isNull);
  });
}
