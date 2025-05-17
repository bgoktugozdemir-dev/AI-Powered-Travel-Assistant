import 'dart:convert'; // For jsonEncode

import 'package:dio/dio.dart';
import 'package:travel_assistant/common/utils/logger/logger.dart'; // Your appLogger

/// A Dio interceptor that logs API request, response, and error details in JSON format.
class ApiLoggerInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final logData = {
      'type': 'API Request',
      'method': options.method,
      'uri': options.uri.toString(),
      'headers': options.headers,
      'queryParameters': options.queryParameters,
      'data': options.data,
    };
    appLogger.d(jsonEncode(logData));
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final logData = {
      'type': 'API Response',
      'statusCode': response.statusCode,
      'statusMessage': response.statusMessage,
      'uri': response.requestOptions.uri.toString(),
      // 'headers': response.headers.map, // Can be verbose, convert to Map if needed
      'data': response.data,
    };
    appLogger.i(jsonEncode(logData));
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final logData = {
      'type': 'API Error',
      'message': err.message,
      'uri': err.requestOptions.uri.toString(),
      'errorType': err.type.toString(),
      'responseData': err.response?.data,
      'error': err.error?.toString(), // The original error object, if any
    };
    // For stackTrace, it's better to log it separately if needed, as it can be very long
    // and might not fit well within a single JSON log line intended for quick overview.
    // appLogger.e accepts stackTrace as a separate parameter.
    appLogger.e(jsonEncode(logData), stackTrace: err.stackTrace);
    super.onError(err, handler);
  }
} 