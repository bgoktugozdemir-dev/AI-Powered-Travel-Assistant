import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:travel_assistant/common/utils/network/sentry_dio_interceptor.dart';

const _secret = 'SUPER-SECRET-VALUE';

/// Answers every request with [status], or fails with [failure] if given.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter({this.status = 200, this.failure});

  final int status;
  final DioException Function(RequestOptions options)? failure;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final failure = this.failure;
    if (failure != null) {
      throw failure(options);
    }
    return ResponseBody.fromString('{}', status);
  }

  @override
  void close({bool force = false}) {}
}

Dio _dio(List<Breadcrumb> crumbs, {_FakeAdapter? adapter}) {
  return Dio()
    ..httpClientAdapter = adapter ?? _FakeAdapter()
    ..interceptors.add(SentryDioInterceptor(breadcrumbSink: crumbs.add));
}

/// Everything a breadcrumb exposes, as one string.
String _everything(Breadcrumb crumb) => crumb.data?.values.join(' | ') ?? '';

void main() {
  group('redactUri', () {
    test('redacts the FreeCurrency apikey', () {
      final uri = redactUri(
        Uri.parse(
          'https://api.freecurrencyapi.com/v1/latest?apikey=$_secret&base_currency=USD',
        ),
      );

      expect(uri.toString(), isNot(contains(_secret)));
      expect(uri.queryParameters['apikey'], 'REDACTED');
      expect(uri.queryParameters['base_currency'], 'USD');
    });

    test('redacts the Unsplash client_id', () {
      final uri = redactUri(
        Uri.parse(
          'https://api.unsplash.com/search/photos?query=Paris&client_id=$_secret&per_page=1',
        ),
      );

      expect(uri.toString(), isNot(contains(_secret)));
      expect(uri.queryParameters['client_id'], 'REDACTED');
      expect(uri.queryParameters['query'], 'Paris');
    });

    for (final name in [
      'apikey',
      'api_key',
      'key',
      'client_id',
      'token',
      'access_token',
      'signature',
    ]) {
      test('redacts $name', () {
        final uri = redactUri(Uri.parse('https://example.com/p?$name=$_secret'));

        expect(uri.toString(), isNot(contains(_secret)));
        expect(uri.queryParameters[name], 'REDACTED');
      });
    }

    test('matches names case-insensitively', () {
      final uri = redactUri(
        Uri.parse('https://example.com/p?ApiKey=$_secret&CLIENT_ID=$_secret'),
      );

      expect(uri.toString(), isNot(contains(_secret)));
    });

    test('redacts every occurrence of a repeated parameter', () {
      final uri = redactUri(
        Uri.parse('https://example.com/p?token=$_secret&a=1&token=$_secret'),
      );

      expect(uri.toString(), isNot(contains(_secret)));
      expect(uri.queryParametersAll['token'], ['REDACTED', 'REDACTED']);
    });

    test('matches a percent-encoded name', () {
      final uri = redactUri(Uri.parse('https://example.com/p?api%5Fkey=$_secret'));

      expect(uri.toString(), isNot(contains(_secret)));
    });

    test('keeps other parameters, their order and encoding', () {
      final uri = redactUri(
        Uri.parse('https://example.com/p?q=New%20York&apikey=$_secret&n=2'),
      );

      expect(uri.query, 'q=New%20York&apikey=REDACTED&n=2');
    });

    test('does not redact parameters that only contain a sensitive word', () {
      final uri = redactUri(
        Uri.parse('https://example.com/p?monkey=1&keyboard=2&tokens=3'),
      );

      expect(uri.query, 'monkey=1&keyboard=2&tokens=3');
    });

    test('returns a URL without query unchanged, without a dangling ?', () {
      final uri = redactUri(Uri.parse('https://example.com/path'));

      expect(uri.toString(), 'https://example.com/path');
    });

    test('redacts tokens in the fragment', () {
      final uri = redactUri(
        Uri.parse('https://example.com/cb#access_token=$_secret&state=1'),
      );

      expect(uri.toString(), isNot(contains(_secret)));
      expect(uri.fragment, 'access_token=REDACTED&state=1');
    });
  });

  group('redactSensitiveText', () {
    test('redacts a URL quoted in a message', () {
      final text = redactSensitiveText(
        'Failed to connect to https://api.x.com/v1?apikey=$_secret&a=1 (timeout)',
      );

      expect(text, isNot(contains(_secret)));
      expect(text, contains('apikey=REDACTED&a=1'));
    });

    test('leaves text without credentials alone', () {
      const text = 'The connection errored: Failed host lookup';

      expect(redactSensitiveText(text), text);
    });
  });

  group('SentryDioInterceptor', () {
    test('redacts credentials from the request breadcrumb', () async {
      final crumbs = <Breadcrumb>[];

      await _dio(crumbs).get<dynamic>(
        'https://api.freecurrencyapi.com/v1/latest',
        queryParameters: {'apikey': _secret, 'base_currency': 'USD'},
      );

      final request = crumbs.first;
      expect(_everything(request), isNot(contains(_secret)));
      expect(request.data?['url'], contains('apikey=REDACTED'));
      expect(request.data?['http.query'], contains('apikey=REDACTED'));
      expect(request.data?['http.query'], contains('base_currency=USD'));
      expect(request.data?['method'], 'GET');
    });

    test('redacts credentials from the response breadcrumb', () async {
      final crumbs = <Breadcrumb>[];

      await _dio(crumbs).get<dynamic>(
        'https://api.unsplash.com/search/photos',
        queryParameters: {'client_id': _secret, 'query': 'Paris'},
      );

      expect(crumbs, hasLength(2));
      final response = crumbs.last;
      expect(_everything(response), isNot(contains(_secret)));
      expect(response.data?['status_code'], 200);
      expect(response.data?['http.query'], contains('client_id=REDACTED'));
    });

    test('redacts credentials from the error breadcrumb', () async {
      final crumbs = <Breadcrumb>[];
      final dio = _dio(crumbs, adapter: _FakeAdapter(status: 401));

      await expectLater(
        dio.get<dynamic>(
          'https://api.unsplash.com/search/photos',
          queryParameters: {'client_id': _secret},
        ),
        throwsA(isA<DioException>()),
      );

      expect(crumbs, isNotEmpty);
      for (final crumb in crumbs) {
        expect(_everything(crumb), isNot(contains(_secret)));
      }
      expect(crumbs.last.data?['status_code'], 401);
    });

    test('redacts credentials quoted in an error message', () async {
      final crumbs = <Breadcrumb>[];
      final dio = _dio(
        crumbs,
        adapter: _FakeAdapter(
          failure: (options) => DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
            message: 'Failed to connect to ${options.uri}',
          ),
        ),
      );

      await expectLater(
        dio.get<dynamic>(
          'https://api.freecurrencyapi.com/v1/latest',
          queryParameters: {'apikey': _secret},
        ),
        throwsA(isA<DioException>()),
      );

      final error = crumbs.last;
      expect(_everything(error), isNot(contains(_secret)));
      expect(error.data?['reason'], contains('apikey=REDACTED'));
    });

    test('does not add a query to a request without one', () async {
      final crumbs = <Breadcrumb>[];

      await _dio(crumbs).get<dynamic>('https://example.com/countries.json');

      expect(crumbs.first.data?['url'], 'https://example.com/countries.json');
      expect(crumbs.first.data?.containsKey('http.query'), isFalse);
    });

    test('never breaks the request when the sink throws', () async {
      final dio = Dio()
        ..httpClientAdapter = _FakeAdapter()
        ..interceptors.add(
          SentryDioInterceptor(breadcrumbSink: (_) => throw StateError('x')),
        );

      final response = await dio.get<dynamic>('https://example.com/a');

      expect(response.statusCode, 200);
    });
  });
}
