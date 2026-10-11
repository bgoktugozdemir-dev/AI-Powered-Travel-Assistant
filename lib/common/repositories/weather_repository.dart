import 'package:dio/dio.dart';
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

  /// How many days, counting today, the Open-Meteo forecast API answers.
  /// A request for a later date is rejected with HTTP 400.
  static const int forecastWindowDays = 16;

  static const int badRequestStatusCode = 400;
  static const String breadcrumbCategory = 'weather';
}

/// The outcome of [WeatherRepository.getWeatherForecast].
sealed class WeatherForecastResult {
  const WeatherForecastResult();
}

/// A forecast was found.
final class WeatherForecastFound extends WeatherForecastResult {
  const WeatherForecastFound(this.response, {this.clampedEndDate});

  final OpenMeteoResponse response;

  /// Set when the requested range ended after the forecast window: the last
  /// day the forecast covers. `null` when the whole range is covered.
  final DateTime? clampedEndDate;
}

/// The range starts after the forecast window, so no forecast exists yet.
/// This is expected for trips that are far ahead, not an error.
final class WeatherForecastBeyondWindow extends WeatherForecastResult {
  const WeatherForecastBeyondWindow({required this.lastForecastDate});

  /// The last day a forecast can be requested for.
  final DateTime lastForecastDate;
}

/// The lookup failed. The failure is already reported or recorded.
final class WeatherForecastFailed extends WeatherForecastResult {
  const WeatherForecastFailed();
}

/// Repository for weather forecast retrieval and short-lived caching.
class WeatherRepository {
  WeatherRepository(
    this._service,
    this._remoteConfig,
    this._errorMonitoring, {
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  /// How many days, counting today, a forecast is available for.
  static const int forecastWindowDays = _Constants.forecastWindowDays;

  final OpenMeteoService _service;
  final FirebaseRemoteConfigRepository _remoteConfig;
  final ErrorMonitoringFacade _errorMonitoring;
  final DateTime Function() _now;

  static final Map<String, _CachedWeather> _cache = {};

  /// Returns weather forecast for given coordinates and date range.
  ///
  /// The forecast API only covers [forecastWindowDays] days from today. A range
  /// that starts after that window is answered without a request
  /// ([WeatherForecastBeyondWindow]), and a range that ends after it is cut
  /// short ([WeatherForecastFound.clampedEndDate]). The window is measured in
  /// the clock's own calendar. The API measures it in the time zone of the
  /// location, so the last day can still be refused: that answer (HTTP 400) is
  /// recorded as a breadcrumb, not reported as an error.
  Future<WeatherForecastResult> getWeatherForecast({
    required double latitude,
    required double longitude,
    required DateTime startDate,
    required DateTime endDate,
    String timezone = 'auto',
  }) async {
    final today = _dateOnly(_now());
    final lastForecastDate = DateTime(
      today.year,
      today.month,
      today.day + _Constants.forecastWindowDays - 1,
    );
    if (_dateOnly(startDate).isAfter(lastForecastDate)) {
      return WeatherForecastBeyondWindow(lastForecastDate: lastForecastDate);
    }
    final isClamped = _dateOnly(endDate).isAfter(lastForecastDate);

    final requestStartDate = _formatDate(startDate);
    final requestEndDate = _formatDate(isClamped ? lastForecastDate : endDate);

    try {
      final cacheKey =
          '$latitude|$longitude|$requestStartDate|$requestEndDate|$timezone';
      final shouldCache = _remoteConfig.cacheWeatherData;

      final cachedValue = shouldCache ? _readCache(cacheKey) : null;
      if (cachedValue != null) {
        return _found(cachedValue.response, isClamped, lastForecastDate);
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

      return _found(response, isClamped, lastForecastDate);
    } on DioException catch (e, st) {
      if (e.response?.statusCode != _Constants.badRequestStatusCode) {
        _reportFailure(e, st, latitude, longitude, startDate, endDate);
        return const WeatherForecastFailed();
      }
      // The API refuses a range it cannot serve. That is a condition of the
      // request, not a bug, so it must not become an issue.
      final body = e.response?.data;
      final reason = body is Map ? body['reason'] : null;
      _errorMonitoring.addBreadcrumb(
        'Open-Meteo rejected the weather forecast request.',
        category: _Constants.breadcrumbCategory,
        data: {
          if (reason != null) 'reason': reason,
          'latitude': latitude,
          'longitude': longitude,
          'startDate': requestStartDate,
          'endDate': requestEndDate,
        },
      );
      return const WeatherForecastFailed();
    } catch (e, st) {
      _reportFailure(e, st, latitude, longitude, startDate, endDate);
      return const WeatherForecastFailed();
    }
  }

  /// Clears weather cache.
  static void clearCache() => _cache.clear();

  WeatherForecastFound _found(
    OpenMeteoResponse response,
    bool isClamped,
    DateTime lastForecastDate,
  ) => WeatherForecastFound(
    response,
    clampedEndDate: isClamped ? lastForecastDate : null,
  );

  void _reportFailure(
    Object error,
    StackTrace stackTrace,
    double latitude,
    double longitude,
    DateTime startDate,
    DateTime endDate,
  ) {
    _errorMonitoring.reportError(
      'Failed to get weather forecast.',
      stackTrace: stackTrace,
      context: {
        'error': error,
        'latitude': latitude,
        'longitude': longitude,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      },
    );
  }

  DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  String _formatDate(DateTime date) => date.toIso8601String().split('T').first;

  _CachedWeather? _readCache(String cacheKey) {
    _evictExpiredCacheEntries();
    return _cache[cacheKey];
  }

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
