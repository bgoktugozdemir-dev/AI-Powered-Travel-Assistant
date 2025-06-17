import 'package:dio/dio.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Constants for the Sentry Dio interceptor
abstract class _Constants {
  /// Maximum length for error messages in breadcrumbs
  static const int maxErrorMessageLength = 500;
}

/// Dio interceptor that adds HTTP breadcrumbs to Sentry for monitoring network requests
///
/// This interceptor captures HTTP requests, responses, and errors as Sentry breadcrumbs
/// using the built-in `Breadcrumb.http()` constructor for optimal integration.
///
/// Usage:
/// ```dart
/// final dio = Dio();
/// dio.interceptors.add(SentryDioInterceptor());
/// ```
class SentryDioInterceptor extends Interceptor {
  /// Creates a new instance of [SentryDioInterceptor]
  const SentryDioInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _addHttpBreadcrumb(
      url: options.uri.toString(),
      method: options.method,
      requestBodySize: _getRequestBodySize(options.data),
    );
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _addHttpBreadcrumb(
      url: response.requestOptions.uri.toString(),
      method: response.requestOptions.method,
      statusCode: response.statusCode,
      responseBodySize: _getResponseBodySize(response.data),
    );
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _addHttpBreadcrumb(
      url: err.requestOptions.uri.toString(),
      method: err.requestOptions.method,
      statusCode: err.response?.statusCode,
      reason: _formatErrorMessage(err),
    );
    super.onError(err, handler);
  }

  /// Adds an HTTP breadcrumb to Sentry using the built-in constructor
  void _addHttpBreadcrumb({
    required String url,
    required String method,
    int? statusCode,
    int? requestBodySize,
    int? responseBodySize,
    String? reason,
  }) {
    try {
      final uri = Uri.parse(url);
      Sentry.addBreadcrumb(
        Breadcrumb.http(
          url: uri,
          method: method,
          httpQuery: uri.query,
          httpFragment: uri.fragment,
          statusCode: statusCode,
          requestBodySize: requestBodySize,
          responseBodySize: responseBodySize,
          reason: reason,
        ),
      );
    } catch (e) {
      // Silently fail to avoid breaking HTTP requests
    }
  }

  /// Gets the request body size if available
  int? _getRequestBodySize(dynamic data) {
    if (data == null) return null;
    if (data is String) return data.length;
    if (data is List<int>) return data.length;
    return null;
  }

  /// Gets the response body size if available
  int? _getResponseBodySize(dynamic data) {
    if (data == null) return null;
    if (data is String) return data.length;
    if (data is List<int>) return data.length;
    return null;
  }

  /// Formats error message with length limit
  String _formatErrorMessage(DioException error) {
    final message = error.message ?? error.type.toString();
    return message.length > _Constants.maxErrorMessageLength
        ? '${message.substring(0, _Constants.maxErrorMessageLength)}...'
        : message;
  }
}

extension SentryDioX on Dio {
  void addSentryInterceptor() {
    interceptors.add(SentryDioInterceptor());
  }
}
