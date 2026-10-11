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
    this._errorMonitoring, {
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final OpenMeteoService _service;
  final FirebaseRemoteConfigRepository _remoteConfig;
  final ErrorMonitoringFacade _errorMonitoring;
  final DateTime Function() _now;

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
      final requestStartDate = _formatDate(startDate);
      final requestEndDate = _formatDate(endDate);
      final cacheKey =
          '$latitude|$longitude|$requestStartDate|$requestEndDate|$timezone';
      final shouldCache = _remoteConfig.cacheWeatherData;

      if (shouldCache) {
        _evictExpiredCacheEntries();
        final cachedValue = _cache[cacheKey];
        if (cachedValue != null) {
          return cachedValue.response;
        }
      }

      final response = await _service.getWeatherForecast(
        latitude: latitude,
        longitude: longitude,
        startDate: requestStartDate,
        endDate: requestEndDate,
        hourly: _Constants.hourlyFields,
        current: _Constants.currentFields,
        timezone: timezone,
      );

      if (shouldCache) {
        _evictExpiredCacheEntries();
        _cache[cacheKey] = _CachedWeather(
          response,
          _now().add(
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

  String _formatDate(DateTime date) => date.toIso8601String().split('T').first;

  void _evictExpiredCacheEntries() {
    _cache.removeWhere((_, cachedWeather) => cachedWeather.isExpired(_now()));
  }
}

class _CachedWeather {
  _CachedWeather(this.response, this.expiresAt);

  final OpenMeteoResponse response;
  final DateTime expiresAt;

  bool isExpired(DateTime now) => now.isAfter(expiresAt);
}
