import 'package:travel_assistant/common/services/image_to_base64_service.dart';
import 'package:travel_assistant/common/utils/logger/logger.dart';

abstract class _Constants {
  static const int minUrlLength = 10;
}

/// Repository for handling image operations.
class ImageRepository {
  final ImageToBase64Service _imageService;

  /// Creates an [ImageRepository].
  ///
  /// Requires an [ImageToBase64Service] instance.
  const ImageRepository({
    required ImageToBase64Service imageService,
  }) : _imageService = imageService;

  /// Downloads an image from the provided [url] and converts it to base64.
  ///
  /// Returns a base64 encoded string of the image.
  /// Returns null if the operation fails or url is invalid.
  Future<String?> downloadImageAsBase64({required String url}) async {
    if (url.isEmpty || url.length < _Constants.minUrlLength) {
      appLogger.w("Image URL too short or empty: '$url'. Returning null.");
      return null;
    }

    try {
      appLogger.d("Downloading image from URL: '$url'");
      final base64String = await _imageService.downloadImageAsBase64(url: url);
      appLogger.i("Successfully downloaded and converted image to base64. Length: ${base64String.length} characters.");
      return base64String;
    } catch (e, stackTrace) {
      appLogger.e('ImageRepository Error: Failed to download and convert image', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Validates if the provided [url] is a potentially valid image URL.
  ///
  /// This is a basic validation that checks URL format and common image extensions.
  bool isValidImageUrl(String url) {
    if (url.isEmpty || url.length < _Constants.minUrlLength) {
      return false;
    }

    try {
      final uri = Uri.parse(url);
      if (!uri.hasScheme || (!uri.scheme.startsWith('http'))) {
        return false;
      }

      // Check for common image extensions (optional, as some URLs might not have extensions)
      final commonImageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp', '.svg'];
      final path = uri.path.toLowerCase();

      // If no extension found, still consider it valid (could be a dynamic URL)
      if (commonImageExtensions.any((ext) => path.endsWith(ext))) {
        return true;
      }

      // Also valid if it's a URL without a clear extension (API endpoints, etc.)
      return true;
    } catch (e) {
      appLogger.w("Invalid URL format: '$url'", error: e);
      return false;
    }
  }
}
