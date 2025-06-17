import 'package:travel_assistant/common/repositories/firebase_remote_config_repository.dart';
import 'package:travel_assistant/common/services/free_currency_api_service.dart';
import 'package:travel_assistant/common/utils/error_monitoring/error_monitoring_facade.dart';

class CurrencyRepository {
  const CurrencyRepository({
    required FreeCurrencyApiService freeCurrencyApiService,
    required FirebaseRemoteConfigRepository firebaseRemoteConfigRepository,
    required ErrorMonitoringFacade errorMonitoringFacade,
  }) : _freeCurrencyApiService = freeCurrencyApiService,
       _firebaseRemoteConfigRepository = firebaseRemoteConfigRepository,
       _errorMonitoringFacade = errorMonitoringFacade;

  final FreeCurrencyApiService _freeCurrencyApiService;
  final FirebaseRemoteConfigRepository _firebaseRemoteConfigRepository;
  final ErrorMonitoringFacade _errorMonitoringFacade;

  static final Map<String, Map<String, double>> _exchangeRatesCache = {};

  Future<double?> getExchangeRate(
    String fromCurrency,
    String toCurrency,
  ) async {
    if (_firebaseRemoteConfigRepository.cacheFreeCurrencyApiData && _exchangeRatesCache.containsKey(fromCurrency)) {
      return _exchangeRatesCache[fromCurrency]![toCurrency];
    }
    final apiKey = _firebaseRemoteConfigRepository.freeCurrencyApiKey;

    try {
      final response = await _freeCurrencyApiService.getExchangeRates(
        apiKey: apiKey,
        baseCurrency: fromCurrency,
      );

      final exchangeRates = response.data;

      if (exchangeRates.isNotEmpty) {
        _cacheExchangeRates(fromCurrency, exchangeRates);

        return exchangeRates[toCurrency] ?? 0;
      }

      throw Exception(
        'Failed to get exchange rate from $fromCurrency to $toCurrency',
      );
    } catch (e) {
      _errorMonitoringFacade.reportError(
        'Error getting exchange rate',
        stackTrace: StackTrace.current,
        context: {
          'error': e,
          'api': 'Free Currency API',
          'apiKey': apiKey,
          'fromCurrency': fromCurrency,
          'toCurrency': toCurrency,
        },
      );
      return null;
    }
  }

  void _cacheExchangeRates(
    String fromCurrency,
    Map<String, double> exchangeRates,
  ) {
    if (_firebaseRemoteConfigRepository.cacheFreeCurrencyApiData) {
      _exchangeRatesCache[fromCurrency] = exchangeRates;
    }
  }
}
