import 'package:dio/dio.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Constants for the Sentry Dio interceptor
abstract class _Constants {
  /// Maximum length for error messages in breadcrumbs
  static const int maxErrorMessageLength = 500;

  /// Replaces the value of a sensitive query parameter.
  static const String redactedValue = 'REDACTED';

  /// Query parameters whose values are credentials and must never reach Sentry.
  ///
  /// Compared in lower case. Covers the FreeCurrency `apikey` and the Unsplash
  /// `client_id`, which are sent as query parameters.
  static const Set<String> sensitiveQueryParameters = {
    'apikey',
    'api_key',
    'key',
    'client_id',
    'token',
    'access_token',
    'signature',
  };

  /// Matches `name=value` for a sensitive parameter inside free text, such as
  /// an error message that quotes the request URL.
  static final RegExp sensitiveAssignment = RegExp(
    '(?<![A-Za-z0-9_-])(${sensitiveQueryParameters.join('|')})=[^&\\s\'"<>]+',
    caseSensitive: false,
  );
}

/// Receives the breadcrumbs the interceptor creates.
typedef BreadcrumbSink = void Function(Breadcrumb breadcrumb);

/// Returns [uri] with the values of sensitive query (and fragment) parameters
/// replaced by a placeholder. Everything else, including the order and
/// duplicates of the other parameters, is kept as is.
Uri redactUri(Uri uri) {
  var redacted = uri;
  if (uri.hasQuery) {
    final query = redactParameters(uri.query);
    if (query != uri.query) {
      redacted = redacted.replace(query: query);
    }
  }
  // Implicit OAuth flows return tokens in the fragment.
  if (uri.hasFragment && uri.fragment.contains('=')) {
    final fragment = redactParameters(uri.fragment);
    if (fragment != uri.fragment) {
      redacted = redacted.replace(fragment: fragment);
    }
  }
  return redacted;
}

/// Redacts the value of every sensitive parameter in a raw `a=1&b=2` string.
String redactParameters(String parameters) {
  return parameters
      .split('&')
      .map((pair) {
        final separator = pair.indexOf('=');
        if (separator < 0) {
          return pair;
        }
        final name = pair.substring(0, separator);
        return _isSensitive(name)
            ? '$name=${_Constants.redactedValue}'
            : pair;
      })
      .join('&');
}

/// Redacts `name=value` assignments of sensitive parameters in free [text].
String redactSensitiveText(String text) {
  return text.replaceAllMapped(
    _Constants.sensitiveAssignment,
    (match) => '${match[1]}=${_Constants.redactedValue}',
  );
}

bool _isSensitive(String rawName) {
  String name;
  try {
    name = Uri.decodeQueryComponent(rawName);
  } on FormatException {
    name = rawName;
  }
  return _Constants.sensitiveQueryParameters.contains(name.toLowerCase());
}

/// Dio interceptor that adds HTTP breadcrumbs to Sentry for monitoring network requests
///
/// This interceptor captures HTTP requests, responses, and errors as Sentry breadcrumbs
/// using the built-in `Breadcrumb.http()` constructor for optimal integration.
///
/// Credentials sent as query parameters (API keys, client IDs, tokens) are
/// redacted from the URL, the query and error messages before a breadcrumb is
/// created.
///
/// Usage:
/// ```dart
/// final dio = Dio();
/// dio.interceptors.add(SentryDioInterceptor());
/// ```
class SentryDioInterceptor extends Interceptor {
  /// Creates a new instance of [SentryDioInterceptor].
  ///
  /// Breadcrumbs go to Sentry unless a [breadcrumbSink] is given (tests).
  SentryDioInterceptor({BreadcrumbSink? breadcrumbSink})
    : _breadcrumbSink = breadcrumbSink ?? _addToSentry;

  final BreadcrumbSink _breadcrumbSink;

  static void _addToSentry(Breadcrumb breadcrumb) {
    Sentry.addBreadcrumb(breadcrumb);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _addHttpBreadcrumb(
      uri: options.uri,
      method: options.method,
      requestBodySize: _getRequestBodySize(options.data),
    );
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _addHttpBreadcrumb(
      uri: response.requestOptions.uri,
      method: response.requestOptions.method,
      statusCode: response.statusCode,
      responseBodySize: _getResponseBodySize(response.data),
    );
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _addHttpBreadcrumb(
      uri: err.requestOptions.uri,
      method: err.requestOptions.method,
      statusCode: err.response?.statusCode,
      reason: _formatErrorMessage(err),
    );
    super.onError(err, handler);
  }

  /// Adds an HTTP breadcrumb to Sentry using the built-in constructor
  void _addHttpBreadcrumb({
    required Uri uri,
    required String method,
    int? statusCode,
    int? requestBodySize,
    int? responseBodySize,
    String? reason,
  }) {
    try {
      final redacted = redactUri(uri);
      _breadcrumbSink(
        Breadcrumb.http(
          url: redacted,
          method: method,
          httpQuery: redacted.hasQuery ? redacted.query : null,
          httpFragment: redacted.hasFragment ? redacted.fragment : null,
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

  /// Formats error message with length limit, without credentials.
  String _formatErrorMessage(DioException error) {
    final message = redactSensitiveText(error.message ?? error.type.toString());
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
