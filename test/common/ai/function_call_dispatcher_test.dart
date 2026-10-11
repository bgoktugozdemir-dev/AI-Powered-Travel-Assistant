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
  _FakeWeatherRepository(this.response);

  final OpenMeteoResponse? response;

  @override
  Future<OpenMeteoResponse?> getWeatherForecast({
    required double latitude,
    required double longitude,
    required DateTime startDate,
    required DateTime endDate,
    String timezone = 'auto',
  }) async {
    return response;
  }
}

void main() {
  group('FunctionCallDispatcher', () {
    test('dispatches get_exchange_rate function', () async {
      final dispatcher = FunctionCallDispatcher(
        currencyRepository: _FakeCurrencyRepository(39.25),
        weatherRepository: _FakeWeatherRepository(null),
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
      'returns weather error payload when weather repo returns null',
      () async {
        final dispatcher = FunctionCallDispatcher(
          currencyRepository: _FakeCurrencyRepository(1),
          weatherRepository: _FakeWeatherRepository(null),
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

        final response = part as FunctionResponse;
        expect(response.name, 'get_weather_forecast');
        expect(response.response['error'], 'Failed to fetch weather data');
      },
    );
  });
}
