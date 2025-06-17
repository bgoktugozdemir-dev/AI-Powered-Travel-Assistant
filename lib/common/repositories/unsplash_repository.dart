import 'package:travel_assistant/common/repositories/firebase_remote_config_repository.dart';
import 'package:travel_assistant/common/services/unsplash_service.dart';
import 'package:travel_assistant/common/utils/error_monitoring/error_monitoring_facade.dart';

abstract class _Constants {
  static const String cityKey = '{city}';
  static const String countryKey = '{country}';
}

class UnsplashRepository {
  UnsplashRepository({
    required UnsplashService unsplashService,
    required FirebaseRemoteConfigRepository firebaseRemoteConfigRepository,
    required ErrorMonitoringFacade errorMonitoringFacade,
  }) : _unsplashService = unsplashService,
       _firebaseRemoteConfigRepository = firebaseRemoteConfigRepository,
       _errorMonitoringFacade = errorMonitoringFacade;

  final UnsplashService _unsplashService;
  final FirebaseRemoteConfigRepository _firebaseRemoteConfigRepository;
  final ErrorMonitoringFacade _errorMonitoringFacade;

  Future<UnsplashPhoto?> getCityView({
    required String cityName,
    required String countryName,
  }) async {
    try {
      final clientId = _firebaseRemoteConfigRepository.unsplashClientId;
      final response = await _unsplashService.searchPhotos(
        query: _firebaseRemoteConfigRepository.unsplashCityImageSearchQuery
            .replaceFirst(_Constants.cityKey, cityName)
            .replaceFirst(_Constants.countryKey, countryName),
        clientId: clientId,
        perPage: 1,
      );

      return response.results.first;
    } catch (e, stackTrace) {
      _errorMonitoringFacade.reportError(
        'Error getting city view from Unsplash',
        stackTrace: stackTrace,
        context: {
          'error': e,
          'cityName': cityName,
          'countryName': countryName,
        },
      );
      return null;
    }
  }
}
