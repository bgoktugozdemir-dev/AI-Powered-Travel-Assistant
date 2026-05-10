import 'package:travel_assistant/common/models/response/open_meteo_response.dart';
import 'package:travel_assistant/common/repositories/firebase_remote_config_repository.dart';
import 'package:travel_assistant/common/services/open_meteo_service.dart';
import 'package:travel_assistant/common/utils/error_monitoring/error_monitoring_facade.dart';

abstract class _Constants {
  static const int cacheHours = 6;
  static const String hourlyFields =
      'temperature_2m,weather_code,relative_humidity_2m';
  static const String currentFields =
      'temperature_2m,weather_code,relative_humidity_2m';
}

/// Repository for weather forecast retrieval and short-lived caching.
class WeatherRepository {
  WeatherRepository(
    this._service,
    this._remoteConfig,
    this._errorMonitoring,
  );

  final OpenMeteoService _service;
  final FirebaseRemoteConfigRepository _remoteConfig;
  final ErrorMonitoringFacade _errorMonitoring;

  static final Map<String, _CachedWeather> _cache = {};

  /// Returns weather forecast for given coordinates and date range.
  Future<OpenMeteoResponse?> getWeatherForecast({
    required double latitude,
    required double longitude,
    required DateTime startDate,
    required DateTime endDate,
    String timezone = 'auto',
  }) async {
    try {
      final cacheKey =
          '$latitude|$longitude|${startDate.toIso8601String()}|${endDate.toIso8601String()}';
      final cachedValue = _cache[cacheKey];

      if (cachedValue != null && !cachedValue.isExpired) {
        return cachedValue.response;
      }

      final response = await _service.getWeatherForecast(
        latitude: latitude,
        longitude: longitude,
        startDate: startDate.toIso8601String().split('T').first,
        endDate: endDate.toIso8601String().split('T').first,
        hourly: _Constants.hourlyFields,
        current: _Constants.currentFields,
        timezone: timezone,
      );

      if (_remoteConfig.cacheWeatherData) {
        _cache[cacheKey] = _CachedWeather(
          response,
          DateTime.now().add(
            const Duration(hours: _Constants.cacheHours),
          ),
        );
      }

      return response;
    } catch (e, st) {
      _errorMonitoring.reportError(
        'WeatherRepository.getWeatherForecast failed: $e',
        stackTrace: st,
      );
      return null;
    }
  }

  /// Clears weather cache.
  static void clearCache() => _cache.clear();
}

class _CachedWeather {
  _CachedWeather(this.response, this.expiresAt);

  final OpenMeteoResponse response;
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
