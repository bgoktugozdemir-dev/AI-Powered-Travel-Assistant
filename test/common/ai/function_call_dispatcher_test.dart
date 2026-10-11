import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_assistant/common/ai/function_call_dispatcher.dart';
import 'package:travel_assistant/common/models/response/open_meteo_response.dart';
import 'package:travel_assistant/common/repositories/currency_repository.dart';
import 'package:travel_assistant/common/repositories/weather_repository.dart';

class _FakeCurrencyRepository implements CurrencyRepository {
  _FakeCurrencyRepository(this.rate);

  final double rate;

  @override
  Future<double?> getExchangeRate(
    String fromCurrency,
    String toCurrency,
  ) async {
    return rate;
  }
}

class _FakeWeatherRepository implements WeatherRepository {
  _FakeWeatherRepository(this.result);

  final WeatherForecastResult result;

  @override
  Future<WeatherForecastResult> getWeatherForecast({
    required double latitude,
    required double longitude,
    required DateTime startDate,
    required DateTime endDate,
    String timezone = 'auto',
  }) async {
    return result;
  }
}

final _sampleResponse = OpenMeteoResponse.fromJson({
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

Future<FunctionResponse> _dispatchWeather(WeatherForecastResult result) async {
  final dispatcher = FunctionCallDispatcher(
    currencyRepository: _FakeCurrencyRepository(1),
    weatherRepository: _FakeWeatherRepository(result),
  );

  final part = await dispatcher.dispatch(
    FunctionCall(
      'get_weather_forecast',
      {
        'latitude': 41.0,
        'longitude': 29.0,
        'start_date': '2026-06-01',
        'end_date': '2026-06-02',
      },
    ),
  );

  return part as FunctionResponse;
}

void main() {
  group('FunctionCallDispatcher', () {
    test('dispatches get_exchange_rate function', () async {
      final dispatcher = FunctionCallDispatcher(
        currencyRepository: _FakeCurrencyRepository(39.25),
        weatherRepository: _FakeWeatherRepository(
          const WeatherForecastFailed(),
        ),
      );

      final part = await dispatcher.dispatch(
        FunctionCall(
          'get_exchange_rate',
          {'base_currency': 'USD', 'target_currency': 'TRY'},
        ),
      );

      expect(part, isA<FunctionResponse>());
      final response = part as FunctionResponse;
      expect(response.name, 'get_exchange_rate');
      expect(response.response['exchange_rate'], 39.25);
    });

    test(
      'returns weather error payload when the weather lookup failed',
      () async {
        final response = await _dispatchWeather(const WeatherForecastFailed());

        expect(response.name, 'get_weather_forecast');
        expect(response.response['error'], 'Failed to fetch weather data');
      },
    );

    test(
      'says the forecast is unavailable when the dates are beyond the window',
      () async {
        final response = await _dispatchWeather(
          WeatherForecastBeyondWindow(lastForecastDate: DateTime(2026, 10, 26)),
        );

        expect(
          response.response['error'],
          'Forecast unavailable: the requested dates are beyond the 16-day '
          'forecast window.',
        );
        expect(response.response['forecast_available_until'], '2026-10-26');
        expect(response.response, isNot(contains('current')));
      },
    );

    test('returns the forecast of a range inside the window', () async {
      final response = await _dispatchWeather(
        WeatherForecastFound(_sampleResponse),
      );

      expect(response.response['timezone'], 'Europe/Istanbul');
      expect(response.response, contains('current'));
      expect(response.response, contains('hourly'));
      expect(response.response, isNot(contains('note')));
      expect(response.response, isNot(contains('error')));
    });

    test('notes where the forecast ends when the range was cut short', () async {
      final response = await _dispatchWeather(
        WeatherForecastFound(
          _sampleResponse,
          clampedEndDate: DateTime(2026, 10, 26),
        ),
      );

      expect(response.response['note'], contains('ends on 2026-10-26'));
      expect(response.response, contains('hourly'));
      expect(response.response, isNot(contains('error')));
    });
  });
}
