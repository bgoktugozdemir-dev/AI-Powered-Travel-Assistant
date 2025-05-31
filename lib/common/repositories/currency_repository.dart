import 'package:travel_assistant/common/repositories/firebase_remote_config_repository.dart';
import 'package:travel_assistant/common/services/free_currency_api_service.dart';
import 'package:travel_assistant/common/utils/logger/logger.dart';

class CurrencyRepository {
  const CurrencyRepository({
    required FreeCurrencyApiService freeCurrencyApiService,
    required FirebaseRemoteConfigRepository firebaseRemoteConfigRepository,
  }) : _freeCurrencyApiService = freeCurrencyApiService,
       _firebaseRemoteConfigRepository = firebaseRemoteConfigRepository;

  final FreeCurrencyApiService _freeCurrencyApiService;
  final FirebaseRemoteConfigRepository _firebaseRemoteConfigRepository;

  static final Map<String, Map<String, double>> _exchangeRatesCache = {};

  Future<double?> getExchangeRate(String fromCurrency, String toCurrency) async {
    try {
      if (_firebaseRemoteConfigRepository.cacheFreeCurrencyApiData && _exchangeRatesCache.containsKey(fromCurrency)) {
        return _exchangeRatesCache[fromCurrency]![toCurrency];
      }
      final apiKey = _firebaseRemoteConfigRepository.freeCurrencyApiKey;

      final response = await _freeCurrencyApiService.getExchangeRates(apiKey: apiKey, baseCurrency: fromCurrency);

      final exchangeRates = response.data;

      if (exchangeRates.isNotEmpty) {
        _cacheExchangeRates(fromCurrency, exchangeRates);

        return exchangeRates[toCurrency] ?? 0;
      }

      throw Exception('Failed to get exchange rate from $fromCurrency to $toCurrency');
    } catch (e) {
      appLogger.e(e.toString());
      return null;
    }
  }

  void _cacheExchangeRates(String fromCurrency, Map<String, double> exchangeRates) {
    if (_firebaseRemoteConfigRepository.cacheFreeCurrencyApiData) {
      _exchangeRatesCache[fromCurrency] = exchangeRates;
    }
  }
}
