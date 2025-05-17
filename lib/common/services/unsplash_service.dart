import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:travel_assistant/common/utils/logger/logger.dart';

part 'unsplash_service.g.dart';

/// Constants for the Unsplash API service
abstract class _Constants {
  /// Base URL for the Unsplash API
  static const String baseUrl = 'https://api.unsplash.com';
  
  /// Default number of results to fetch
  static const int defaultPerPage = 1;
  
  /// Default photo orientation
  static const String defaultOrientation = 'landscape';
  
  /// Default image quality
  static const String defaultQuality = 'regular';
}

/// Service for interacting with the Unsplash API to fetch images
@RestApi(baseUrl: _Constants.baseUrl)
abstract class UnsplashService {
  /// Factory constructor for creating an instance of [UnsplashService]
  factory UnsplashService(Dio dio, {String baseUrl}) = _UnsplashService;

  /// Searches for photos on Unsplash based on the provided query
  @GET('/search/photos')
  Future<UnsplashSearchResponse> searchPhotos({
    @Query('query') required String query,
    @Query('per_page') int perPage = _Constants.defaultPerPage,
    @Query('orientation') String orientation = _Constants.defaultOrientation,
    @Query('client_id') required String clientId,
  });

  /// Gets random photos, optionally filtered by a search term
  @GET('/photos/random')
  Future<List<UnsplashPhoto>> getRandomPhotos({
    @Query('query') String? query,
    @Query('count') int count = _Constants.defaultPerPage,
    @Query('orientation') String orientation = _Constants.defaultOrientation,
    @Query('client_id') required String clientId,
  });
}

/// Model class for a photo from Unsplash
class UnsplashPhoto {
  /// Creates an [UnsplashPhoto] instance
  UnsplashPhoto({
    required this.id,
    required this.urls,
    required this.user,
    required this.downloadLocation,
  });

  /// Creates an [UnsplashPhoto] from a JSON map
  factory UnsplashPhoto.fromJson(Map<String, dynamic> json) => UnsplashPhoto(
        id: json['id'] as String,
        urls: UnsplashPhotoUrls.fromJson(json['urls'] as Map<String, dynamic>),
        user: UnsplashUser.fromJson(json['user'] as Map<String, dynamic>),
        downloadLocation: json['links']['download_location'] as String,
      );

  /// The photo ID
  final String id;
  
  /// URLs for different sizes of the image
  final UnsplashPhotoUrls urls;
  
  /// The photo's creator
  final UnsplashUser user;
  
  /// The download location for the photo
  final String downloadLocation;
}

/// Model class for photo URLs from Unsplash
class UnsplashPhotoUrls {
  /// Creates an [UnsplashPhotoUrls] instance
  UnsplashPhotoUrls({
    required this.raw,
    required this.full,
    required this.regular,
    required this.small,
    required this.thumb,
  });

  /// Creates [UnsplashPhotoUrls] from a JSON map
  factory UnsplashPhotoUrls.fromJson(Map<String, dynamic> json) => UnsplashPhotoUrls(
        raw: json['raw'] as String,
        full: json['full'] as String,
        regular: json['regular'] as String,
        small: json['small'] as String,
        thumb: json['thumb'] as String,
      );

  /// URL for the raw image
  final String raw;
  
  /// URL for the full-size image
  final String full;
  
  /// URL for the regular-size image
  final String regular;
  
  /// URL for the small-size image
  final String small;
  
  /// URL for the thumbnail image
  final String thumb;

  /// Returns the URL for the given quality level
  String getUrl(String quality) {
    switch (quality) {
      case 'raw':
        return raw;
      case 'full':
        return full;
      case 'small':
        return small;
      case 'thumb':
        return thumb;
      case 'regular':
      default:
        return regular;
    }
  }
}

/// Model class for an Unsplash user
class UnsplashUser {
  /// Creates an [UnsplashUser] instance
  UnsplashUser({
    required this.name,
    required this.username,
    required this.portfolioUrl,
  });

  /// Creates an [UnsplashUser] from a JSON map
  factory UnsplashUser.fromJson(Map<String, dynamic> json) => UnsplashUser(
        name: json['name'] as String,
        username: json['username'] as String,
        portfolioUrl: json['portfolio_url'] as String?,
      );

  /// The user's name
  final String name;
  
  /// The user's username
  final String username;
  
  /// The user's portfolio URL, if any
  final String? portfolioUrl;
}

/// Model class for a search response from Unsplash
class UnsplashSearchResponse {
  /// Creates an [UnsplashSearchResponse] instance
  UnsplashSearchResponse({
    required this.total,
    required this.totalPages,
    required this.results,
  });

  /// Creates an [UnsplashSearchResponse] from a JSON map
  factory UnsplashSearchResponse.fromJson(Map<String, dynamic> json) => UnsplashSearchResponse(
        total: json['total'] as int,
        totalPages: json['total_pages'] as int,
        results: (json['results'] as List<dynamic>)
            .map((result) => UnsplashPhoto.fromJson(result as Map<String, dynamic>))
            .toList(),
      );

  /// The total number of results
  final int total;
  
  /// The total number of pages of results
  final int totalPages;
  
  /// The list of photo results
  final List<UnsplashPhoto> results;
}

/// Repository for fetching and tracking city images from Unsplash
class UnsplashRepository {
  /// Creates an [UnsplashRepository] instance
  UnsplashRepository({
    required this.service,
    required this.clientId,
  });
  
  /// The Unsplash API service
  final UnsplashService service;
  
  /// The API client ID for Unsplash
  final String clientId;

  /// Gets a city image from Unsplash
  Future<CityImage?> getCityImage(String cityName) async {
    try {
      // Search for photos of the city
      final response = await service.searchPhotos(
        query: '$cityName city',
        clientId: clientId,
      );
      
      if (response.results.isEmpty) {
        appLogger.w('No images found for city: $cityName');
        return null;
      }
      
      final photo = response.results.first;
      
      // Track the download as required by Unsplash API guidelines
      _trackDownload(photo);
      
      return CityImage(
        imageUrl: photo.urls.getUrl(_Constants.defaultQuality),
        photographerName: photo.user.name,
        photographerUsername: photo.user.username,
      );
    } catch (e) {
      appLogger.e('Error fetching city image: $e');
      return null;
    }
  }
  
  /// Tracks a download as required by Unsplash API guidelines
  Future<void> _trackDownload(UnsplashPhoto photo) async {
    try {
      // Create a raw Dio instance for tracking the download
      final dio = Dio();
      await dio.get(
        photo.downloadLocation,
        queryParameters: {'client_id': clientId},
      );
    } catch (e) {
      appLogger.e('Error tracking download: $e');
    }
  }
}

/// Model for a city image with attribution details
class CityImage {
  /// Creates a [CityImage] instance
  const CityImage({
    required this.imageUrl,
    required this.photographerName,
    required this.photographerUsername,
  });
  
  /// The URL of the image
  final String imageUrl;
  
  /// The name of the photographer
  final String photographerName;
  
  /// The username of the photographer
  final String photographerUsername;
  
  /// Gets the attribution text for the image
  String get attribution => 'Photo by $photographerName (@$photographerUsername) on Unsplash';
  
  /// Gets the attribution link for the photographer
  String get photographerLink => 'https://unsplash.com/@$photographerUsername?utm_source=travel_assistant&utm_medium=referral';
  
  /// Gets the Unsplash attribution link
  String get unsplashLink => 'https://unsplash.com/?utm_source=travel_assistant&utm_medium=referral';
} 