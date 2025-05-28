import 'package:travel_assistant/common/repositories/firebase_remote_config_repository.dart';
import 'package:travel_assistant/common/services/unsplash_service.dart';
import 'package:travel_assistant/common/utils/logger/logger.dart';

class UnsplashRepository {
  UnsplashRepository({
    required UnsplashService unsplashService,
    required FirebaseRemoteConfigRepository firebaseRemoteConfigRepository,
  }) : _unsplashService = unsplashService,
       _firebaseRemoteConfigRepository = firebaseRemoteConfigRepository;

  final UnsplashService _unsplashService;
  final FirebaseRemoteConfigRepository _firebaseRemoteConfigRepository;

  Future<UnsplashPhoto?> getCityView({required String cityName, required String countryName}) async {
    try {
      final clientId = _firebaseRemoteConfigRepository.unsplashClientId;
      final response = await _unsplashService.searchPhotos(
        query: '$cityName $countryName City View',
        clientId: clientId,
        perPage: 1,
      );

      return response.results.first;
    } catch (e) {
      appLogger.e('Error getting city view from Unsplash', error: e);
      return null;
    }
  }
}
