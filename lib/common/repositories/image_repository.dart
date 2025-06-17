import 'package:travel_assistant/common/services/image_to_base64_service.dart';
import 'package:travel_assistant/common/utils/error_monitoring/error_monitoring_facade.dart';

/// Repository for handling image operations.
class ImageRepository {
  final ImageToBase64Service _imageService;
  final ErrorMonitoringFacade _errorMonitoringFacade;

  /// Creates an [ImageRepository].
  ///
  /// Requires an [ImageToBase64Service] instance.
  const ImageRepository({
    required ImageToBase64Service imageService,
    required ErrorMonitoringFacade errorMonitoringFacade,
  }) : _imageService = imageService,
       _errorMonitoringFacade = errorMonitoringFacade;

  /// Downloads an image from the provided [url] and converts it to base64.
  ///
  /// Returns a base64 encoded string of the image.
  /// Returns null if the operation fails or url is invalid.
  Future<String?> downloadImageAsBase64({required String url}) async {
    if (!isValidImageUrl(url)) {
      return null;
    }

    try {
      final base64String = await _imageService.downloadImageAsBase64(url: url);
      return base64String;
    } catch (e, stackTrace) {
      _errorMonitoringFacade.reportError(
        'Failed to download and convert image',
        stackTrace: stackTrace,
        context: {
          'error': e,
          'url': url,
        },
      );
      return null;
    }
  }

  /// Validates if the provided [url] is a potentially valid image URL.
  ///
  /// This is a basic validation that checks URL format and common image extensions.
  bool isValidImageUrl(String url) {
    if (url.isEmpty) {
      _errorMonitoringFacade.reportError(
        'Image URL is empty',
        context: {
          'url': url,
        },
      );
      return false;
    }

    try {
      final uri = Uri.parse(url);
      if (!uri.hasScheme || (!uri.scheme.startsWith('http'))) {
        _errorMonitoringFacade.reportError(
          'Image URL is invalid',
          context: {
            'url': url,
          },
        );
        return false;
      }

      // Check for common image extensions (optional, as some URLs might not have extensions)
      final commonImageExtensions = [
        '.jpg',
        '.jpeg',
        '.png',
        '.gif',
        '.bmp',
        '.webp',
        '.svg',
      ];
      final path = uri.path.toLowerCase();

      // If no extension found, still consider it valid (could be a dynamic URL)
      if (commonImageExtensions.any((ext) => path.endsWith(ext))) {
        return true;
      }

      // Also valid if it's a URL without a clear extension (API endpoints, etc.)
      return true;
    } catch (e, stackTrace) {
      _errorMonitoringFacade.reportError(
        'Invalid URL format',
        stackTrace: stackTrace,
        context: {
          'url': url,
        },
      );
      return false;
    }
  }
}
