import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:travel_assistant/common/models/response/free_currency_api_response.dart';

part 'free_currency_api_service.g.dart';

/// Constants for the Free Currency API service
abstract class _Constants {
  /// Base URL for the Free Currency API
  static const String baseUrl = 'https://api.freecurrencyapi.com/v1';
}

@RestApi(baseUrl: _Constants.baseUrl)
abstract class FreeCurrencyApiService {
  factory FreeCurrencyApiService(Dio dio, {String baseUrl}) =
      _FreeCurrencyApiService;

  /// Get exchange rates for a given base currency
  @GET('/latest')
  Future<FreeCurrencyApiResponse> getExchangeRates({
    @Query('apikey') required String apiKey,
    @Query('base_currency') String? baseCurrency,
  });
}
