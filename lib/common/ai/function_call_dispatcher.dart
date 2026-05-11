import 'package:firebase_ai/firebase_ai.dart';
import 'package:travel_assistant/common/repositories/currency_repository.dart';
import 'package:travel_assistant/common/repositories/weather_repository.dart';

/// Executes function calls emitted by Gemini and maps them to repositories.
class FunctionCallDispatcher {
  FunctionCallDispatcher({
    required CurrencyRepository currencyRepository,
    required WeatherRepository weatherRepository,
  }) : _currencyRepository = currencyRepository,
       _weatherRepository = weatherRepository;

  final CurrencyRepository _currencyRepository;
  final WeatherRepository _weatherRepository;

  /// Dispatches a function call and returns a model-consumable function response.
  Future<Part> dispatch(FunctionCall call) async {
    try {
      final result = await _executeFunction(call);
      return FunctionResponse(
        call.name,
        result,
        id: call.id,
      );
    } catch (e) {
      return FunctionResponse(
        call.name,
        {
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        },
        id: call.id,
      );
    }
  }

  Future<Map<String, dynamic>> _executeFunction(FunctionCall call) async {
    switch (call.name) {
      case 'get_exchange_rate':
        return _handleExchangeRate(call);
      case 'get_weather_forecast':
        return _handleWeatherForecast(call);
      default:
        throw UnsupportedError('Unknown function: ${call.name}');
    }
  }

  Future<Map<String, dynamic>> _handleExchangeRate(FunctionCall call) async {
    final args = Map<String, dynamic>.from(call.args);
    final baseCurrency = args['base_currency'] as String;
    final targetCurrency = args['target_currency'] as String;

    final rate = await _currencyRepository.getExchangeRate(
      baseCurrency,
      targetCurrency,
    );

    return {
      'base_currency': baseCurrency,
      'target_currency': targetCurrency,
      'exchange_rate': rate,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  Future<Map<String, dynamic>> _handleWeatherForecast(FunctionCall call) async {
    final args = Map<String, dynamic>.from(call.args);
    final latitude = (args['latitude'] as num).toDouble();
    final longitude = (args['longitude'] as num).toDouble();
    final startDate = DateTime.parse(args['start_date'] as String);
    final endDate = DateTime.parse(args['end_date'] as String);
    final timezone = args['timezone'] as String? ?? 'auto';

    final response = await _weatherRepository.getWeatherForecast(
      latitude: latitude,
      longitude: longitude,
      startDate: startDate,
      endDate: endDate,
      timezone: timezone,
    );

    if (response == null) {
      return {
        'error': 'Failed to fetch weather data',
        'latitude': latitude,
        'longitude': longitude,
      };
    }

    return {
      'latitude': response.latitude,
      'longitude': response.longitude,
      'timezone': response.timezone,
      'current': {
        'temperature': response.current.temperature,
        'weather_code': response.current.weatherCode,
        'relative_humidity': response.current.relativeHumidity,
      },
      'hourly': {
        'time': response.hourly.time,
        'temperature_2m': response.hourly.temperature2m,
        'weather_code': response.hourly.weatherCode,
      },
    };
  }
}
