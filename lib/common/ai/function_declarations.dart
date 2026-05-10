import 'package:firebase_ai/firebase_ai.dart';

/// Central registry for Gemini function signatures used in research pass.
class FunctionDeclarations {
  const FunctionDeclarations._();

  static FunctionDeclaration get exchangeRateFunction {
    return FunctionDeclaration(
      'get_exchange_rate',
      'Get the current exchange rate between two currencies.',
      parameters: {
        'base_currency': Schema.string(),
        'target_currency': Schema.string(),
      },
    );
  }

  static FunctionDeclaration get weatherForecastFunction {
    return FunctionDeclaration(
      'get_weather_forecast',
      'Get weather forecast by coordinates and date range.',
      parameters: {
        'latitude': Schema.number(),
        'longitude': Schema.number(),
        'start_date': Schema.string(),
        'end_date': Schema.string(),
        'timezone': Schema.string(),
      },
      optionalParameters: ['timezone'],
    );
  }

  static List<FunctionDeclaration> get all => [
    exchangeRateFunction,
    weatherForecastFunction,
  ];
}
