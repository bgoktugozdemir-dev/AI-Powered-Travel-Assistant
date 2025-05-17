import 'package:dio/dio.dart';
import 'package:travel_assistant/common/utils/logger.dart'; // Your appLogger

/// A Dio interceptor that logs API request, response, and error details.
class ApiLoggerInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    appLogger.d(
      "[API Request] ==>\n"
      "METHOD: ${options.method}\n"
      "URI: ${options.uri}\n"
      "HEADERS: ${options.headers}\n"
      "QUERY PARAMS: ${options.queryParameters}\n"
      "DATA: ${options.data}",
    );
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    appLogger.i(
      "[API Response] <==\n"
      "STATUS: ${response.statusCode} ${response.statusMessage}\n"
      "URI: ${response.requestOptions.uri}\n"
      // "HEADERS: ${response.headers}\n" // Often too verbose
      "DATA: ${response.data}",
    );
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    appLogger.e(
      "[API Error] <==\n"
      "MESSAGE: ${err.message}\n"
      "URI: ${err.requestOptions.uri}\n"
      "TYPE: ${err.type}\n"
      "RESPONSE DATA: ${err.response?.data}",
      error: err.error, // The original error object, if any
      stackTrace: err.stackTrace,
    );
    super.onError(err, handler);
  }
} 