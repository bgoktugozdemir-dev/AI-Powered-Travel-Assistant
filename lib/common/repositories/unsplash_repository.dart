import 'package:dio/dio.dart';
import 'package:travel_assistant/common/repositories/firebase_remote_config_repository.dart';
import 'package:travel_assistant/common/services/unsplash_service.dart';
import 'package:travel_assistant/common/utils/error_monitoring/error_monitoring_facade.dart';

abstract class _Constants {
  static const String cityKey = '{city}';
  static const String countryKey = '{country}';
  static const String breadcrumbCategory = 'Unsplash';
  static const String clientIdParameter = 'client_id';
}

class UnsplashRepository {
  UnsplashRepository({
    required UnsplashService unsplashService,
    required Dio dio,
    required FirebaseRemoteConfigRepository firebaseRemoteConfigRepository,
    required ErrorMonitoringFacade errorMonitoringFacade,
  }) : _unsplashService = unsplashService,
       _dio = dio,
       _firebaseRemoteConfigRepository = firebaseRemoteConfigRepository,
       _errorMonitoringFacade = errorMonitoringFacade;

  final UnsplashService _unsplashService;
  final Dio _dio;
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

      final photo = response.results.firstOrNull;
      if (photo == null) {
        // An unusual city or query can have no photo. That is an expected
        // outcome, not an error: the results screen works without a photo.
        _errorMonitoringFacade.addBreadcrumb(
          'No Unsplash photo found for the city.',
          category: _Constants.breadcrumbCategory,
          data: {
            'cityName': cityName,
            'countryName': countryName,
          },
        );
      }
      return photo;
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

  /// Tells Unsplash that [photo] is being used.
  ///
  /// The Unsplash API guidelines require this call (the photo's
  /// `links.download_location`) whenever an app uses a photo; it is how
  /// photographers are credited for their downloads.
  ///
  /// Never throws: failing to count a download must not affect the app, and
  /// is only left as a breadcrumb.
  Future<void> trackDownload(UnsplashPhoto photo) async {
    try {
      await _dio.get<void>(
        photo.downloadLocation,
        queryParameters: {
          _Constants.clientIdParameter:
              _firebaseRemoteConfigRepository.unsplashClientId,
        },
      );
    } catch (e) {
      _errorMonitoringFacade.addBreadcrumb(
        'Could not trigger the Unsplash download endpoint.',
        category: _Constants.breadcrumbCategory,
        data: {
          'photoId': photo.id,
          // The error itself is not logged: its text can quote the request URL.
          'failure': e is DioException ? e.type.name : 'unexpected',
        },
      );
    }
  }
}
