import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

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
  UnsplashPhoto({required this.id, required this.urls, required this.user, required this.downloadLocation});

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
  UnsplashUser({required this.name, required this.username, required this.portfolioUrl});

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

/// Model class for a token response from Unsplash
class UnsplashTokenResponse {
  /// Creates an [UnsplashTokenResponse] instance
  UnsplashTokenResponse({required this.accessToken, required this.refreshToken});

  /// The access token
  final String accessToken;

  /// The refresh token
  final String refreshToken;
}

/// Model class for a search response from Unsplash
class UnsplashSearchResponse {
  /// Creates an [UnsplashSearchResponse] instance
  UnsplashSearchResponse({required this.total, required this.totalPages, required this.results});

  /// Creates an [UnsplashSearchResponse] from a JSON map
  factory UnsplashSearchResponse.fromJson(Map<String, dynamic> json) => UnsplashSearchResponse(
    total: json['total'] as int,
    totalPages: json['total_pages'] as int,
    results:
        (json['results'] as List<dynamic>)
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
