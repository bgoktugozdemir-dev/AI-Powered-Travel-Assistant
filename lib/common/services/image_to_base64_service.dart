import 'dart:convert';

import 'package:dio/dio.dart';

abstract class _Constants {
  static const int timeoutDurationInSeconds = 30;
  static const String errorMessageImageDownloadFailed =
      'Failed to download image';
}

/// Service for converting images to base64.
class ImageToBase64Service {
  final Dio _dio;

  /// Creates an [ImageToBase64Service] with a [Dio] instance.
  ImageToBase64Service({Dio? dio}) : _dio = dio ?? Dio();

  /// Downloads and converts an image to base64.
  Future<String> downloadImageAsBase64({required String url}) async {
    try {
      final response = await _dio.get(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          receiveTimeout: const Duration(
            seconds: _Constants.timeoutDurationInSeconds,
          ),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<int> bytes = response.data as List<int>;
        return base64Encode(bytes);
      }

      throw Exception(
        '${_Constants.errorMessageImageDownloadFailed}: HTTP ${response.statusCode}',
      );
    } catch (e) {
      if (e is DioException) {
        throw Exception(
          '${_Constants.errorMessageImageDownloadFailed}: ${e.message}',
        );
      }
      throw Exception('${_Constants.errorMessageImageDownloadFailed}: $e');
    }
  }
}
