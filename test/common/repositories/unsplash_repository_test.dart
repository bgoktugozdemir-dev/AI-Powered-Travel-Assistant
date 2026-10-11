import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_assistant/common/repositories/firebase_remote_config_repository.dart';
import 'package:travel_assistant/common/repositories/unsplash_repository.dart';
import 'package:travel_assistant/common/services/unsplash_service.dart';
import 'package:travel_assistant/common/utils/error_monitoring/error_monitoring_facade.dart';

import '../../support/recording_error_monitoring_client.dart';

class _FakeRemoteConfig extends Fake implements FirebaseRemoteConfigRepository {
  @override
  String get unsplashClientId => 'client-123';

  @override
  String get unsplashCityImageSearchQuery => '{city} {country} City View';
}

class _FakeUnsplashService extends Fake implements UnsplashService {
  List<UnsplashPhoto> results = [];
  Object? error;
  String? lastQuery;

  @override
  Future<UnsplashSearchResponse> searchPhotos({
    required String query,
    int perPage = 1,
    String orientation = 'landscape',
    required String clientId,
  }) async {
    lastQuery = query;
    if (error case final error?) {
      throw error;
    }
    return UnsplashSearchResponse(
      total: results.length,
      totalPages: 1,
      results: results,
    );
  }
}

class _RecordingAdapter implements HttpClientAdapter {
  _RecordingAdapter({this.status = 200});

  final int status;
  final List<Uri> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options.uri);
    return ResponseBody.fromString('{}', status);
  }

  @override
  void close({bool force = false}) {}
}

UnsplashPhoto _photo() => UnsplashPhoto(
  id: 'abc',
  urls: UnsplashPhotoUrls(
    raw: 'raw',
    full: 'full',
    regular: 'regular',
    small: 'small',
    thumb: 'thumb',
  ),
  user: const UnsplashUser(
    name: 'Jane Doe',
    username: 'jane_doe',
    portfolioUrl: null,
  ),
  downloadLocation: 'https://api.unsplash.com/photos/abc/download?ixid=XYZ',
);

void main() {
  late RecordingErrorMonitoringClient monitoring;
  late _FakeUnsplashService service;
  late _RecordingAdapter adapter;
  late UnsplashRepository repository;

  UnsplashRepository build({int status = 200}) {
    adapter = _RecordingAdapter(status: status);
    return UnsplashRepository(
      unsplashService: service,
      dio: Dio()..httpClientAdapter = adapter,
      firebaseRemoteConfigRepository: _FakeRemoteConfig(),
      errorMonitoringFacade: ErrorMonitoringFacade([monitoring]),
    );
  }

  setUp(() {
    monitoring = RecordingErrorMonitoringClient();
    service = _FakeUnsplashService();
    repository = build();
  });

  group('getCityView', () {
    test('returns the first photo', () async {
      final photo = _photo();
      service.results = [photo];

      final result = await repository.getCityView(
        cityName: 'Paris',
        countryName: 'France',
      );

      expect(result, same(photo));
      expect(service.lastQuery, 'Paris France City View');
    });

    test('no photo is a breadcrumb, not an error report', () async {
      service.results = [];

      final result = await repository.getCityView(
        cityName: 'Nowhere',
        countryName: 'Atlantis',
      );

      expect(result, isNull);
      expect(monitoring.reports, isEmpty);
      expect(monitoring.breadcrumbs, isNotEmpty);
    });

    test('a failing search is reported once, with the real error', () async {
      final boom = StateError('boom');
      service.error = boom;

      final result = await repository.getCityView(
        cityName: 'Paris',
        countryName: 'France',
      );

      expect(result, isNull);
      expect(monitoring.reports, hasLength(1));
      expect(monitoring.reports.single.context?['error'], same(boom));
    });
  });

  group('trackDownload', () {
    test('calls download_location with the client id', () async {
      await repository.trackDownload(_photo());

      final request = adapter.requests.single;
      expect(request.host, 'api.unsplash.com');
      expect(request.path, '/photos/abc/download');
      expect(request.queryParameters, {'ixid': 'XYZ', 'client_id': 'client-123'});
    });

    test('never throws when Unsplash answers with an error', () async {
      repository = build(status: 500);

      await repository.trackDownload(_photo());

      expect(adapter.requests, hasLength(1));
      expect(monitoring.reports, isEmpty);
      expect(monitoring.breadcrumbs, isNotEmpty);
    });
  });
}
