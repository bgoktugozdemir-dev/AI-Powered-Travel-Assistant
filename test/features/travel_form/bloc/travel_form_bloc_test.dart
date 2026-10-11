import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_assistant/common/models/airport.dart';
import 'package:travel_assistant/common/models/country.dart';
import 'package:travel_assistant/common/models/response/travel_details.dart';
import 'package:travel_assistant/common/models/travel_information.dart';
import 'package:travel_assistant/common/models/travel_purpose.dart';
import 'package:travel_assistant/common/repositories/airport_repository.dart';
import 'package:travel_assistant/common/repositories/currency_repository.dart';
import 'package:travel_assistant/common/repositories/firebase_ai_repository.dart';
import 'package:travel_assistant/common/repositories/firebase_remote_config_repository.dart';
import 'package:travel_assistant/common/repositories/image_repository.dart';
import 'package:travel_assistant/common/repositories/unsplash_repository.dart';
import 'package:travel_assistant/common/services/country_service.dart';
import 'package:travel_assistant/common/services/travel_purpose_service.dart';
import 'package:travel_assistant/common/services/unsplash_service.dart';
import 'package:travel_assistant/common/utils/analytics/analytics_facade.dart';
import 'package:travel_assistant/common/utils/analytics/data/submit_travel_details_source.dart';
import 'package:travel_assistant/common/utils/error_monitoring/error_monitoring_facade.dart';
import 'package:travel_assistant/features/travel_form/bloc/travel_form_bloc.dart';

import '../../../common/ai/travel_details_fixture.dart';
import '../../../support/recording_error_monitoring_client.dart';

class _FakeRemoteConfig extends Fake implements FirebaseRemoteConfigRepository {
  @override
  bool get navigateToNextStepAfterSelectingTravelPurpose => false;

  bool showCityViewValue = false;

  @override
  bool get showCityView => showCityViewValue;

  @override
  int get minimumTravelPurposes => 1;

  @override
  int get maximumTravelPurposes => 3;
}

class _FakeAirportRepository extends Fake implements AirportRepository {
  final List<String> queries = [];

  /// Thrown by every search when set.
  Object? error;

  @override
  Future<List<Airport>> searchAirports(String query) async {
    queries.add(query);
    if (error case final error?) {
      throw error;
    }
    return const [];
  }
}

class _FakeCountryService extends Fake implements CountryService {
  final List<String> queries = [];

  @override
  Future<List<Country>> searchCountries(String query) async {
    queries.add(query);
    return const [];
  }
}

class _FakeTravelPurposeService extends Fake implements TravelPurposeService {}

class _FakeAIRepository extends Fake implements FirebaseAIRepository {
  int calls = 0;
  Completer<TravelDetails> pending = Completer<TravelDetails>();

  @override
  Future<TravelDetails> generateTravelPlan(
    TravelInformation travelInformation,
  ) {
    calls++;
    return pending.future;
  }
}

class _FakeUnsplashRepository extends Fake implements UnsplashRepository {
  /// The photo found for the city, if any.
  UnsplashPhoto? photo;
  final List<UnsplashPhoto> trackedDownloads = [];

  @override
  Future<UnsplashPhoto?> getCityView({
    required String cityName,
    required String countryName,
  }) async => photo;

  @override
  Future<void> trackDownload(UnsplashPhoto photo) async {
    trackedDownloads.add(photo);
  }
}

class _FakeCurrencyRepository extends Fake implements CurrencyRepository {
  @override
  Future<double?> getExchangeRate(
    String fromCurrency,
    String toCurrency,
  ) async => 1.0;
}

class _FakeImageRepository extends Fake implements ImageRepository {
  /// What a download returns. Null means the download failed.
  String? bytes;
  final List<String> downloadedUrls = [];

  @override
  Future<String?> downloadImageAsBase64({required String url}) async {
    downloadedUrls.add(url);
    return bytes;
  }
}

const _photographer = UnsplashUser(
  name: 'Jane Doe',
  username: 'jane_doe',
  portfolioUrl: null,
);

UnsplashPhoto _photo() => UnsplashPhoto(
  id: 'abc',
  urls: UnsplashPhotoUrls(
    raw: 'raw',
    full: 'https://images.unsplash.com/full',
    regular: 'regular',
    small: 'small',
    thumb: 'thumb',
  ),
  user: _photographer,
  downloadLocation: 'https://api.unsplash.com/photos/abc/download?ixid=XYZ',
);

const _istanbul = Airport(
  iataCode: 'IST',
  name: 'Istanbul Airport',
  countryCode: 'TR',
  countryName: 'Turkey',
  cityName: 'Istanbul',
);
const _newYork = Airport(
  iataCode: 'JFK',
  name: 'John F. Kennedy International Airport',
  countryCode: 'US',
  countryName: 'United States',
  cityName: 'New York',
);
const _turkey = Country(code: 'TR', name: 'Turkey');
const _sightseeing = TravelPurpose(
  id: 'sightseeing',
  name: 'Sightseeing',
  localizationKey: 'travelPurposeSightseeing',
);

void main() {
  late _FakeAirportRepository airportRepository;
  late _FakeCountryService countryService;
  late _FakeAIRepository aiRepository;
  late _FakeRemoteConfig remoteConfig;
  late _FakeUnsplashRepository unsplashRepository;
  late _FakeImageRepository imageRepository;
  late RecordingErrorMonitoringClient monitoring;
  late TravelFormBloc bloc;

  setUp(() {
    monitoring = RecordingErrorMonitoringClient();
    airportRepository = _FakeAirportRepository();
    countryService = _FakeCountryService();
    aiRepository = _FakeAIRepository();
    remoteConfig = _FakeRemoteConfig();
    unsplashRepository = _FakeUnsplashRepository();
    imageRepository = _FakeImageRepository();
    bloc = TravelFormBloc(
      analyticsFacade: const AnalyticsFacade([]),
      errorMonitoringFacade: ErrorMonitoringFacade([monitoring]),
      airportRepository: airportRepository,
      travelPurposeService: _FakeTravelPurposeService(),
      firebaseAIRepository: aiRepository,
      unsplashRepository: unsplashRepository,
      imageRepository: imageRepository,
      currencyRepository: _FakeCurrencyRepository(),
      firebaseRemoteConfigRepository: remoteConfig,
      countryService: countryService,
    );
  });

  tearDown(() => bloc.close());

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  group('search debounce', () {
    test('searches once, with the last term, for a burst of typing', () async {
      bloc
        ..add(const TravelFormDepartureAirportSearchTermChanged('ist'))
        ..add(const TravelFormDepartureAirportSearchTermChanged('ista'))
        ..add(const TravelFormDepartureAirportSearchTermChanged('istan'));

      await Future<void>.delayed(const Duration(milliseconds: 150));
      expect(airportRepository.queries, isEmpty);

      await Future<void>.delayed(const Duration(milliseconds: 400));
      expect(airportRepository.queries, ['istan']);
    });

    test('searches once for a burst of arrival airport typing', () async {
      bloc
        ..add(const TravelFormArrivalAirportSearchTermChanged('new'))
        ..add(const TravelFormArrivalAirportSearchTermChanged('new y'));

      await Future<void>.delayed(const Duration(milliseconds: 550));
      expect(airportRepository.queries, ['new y']);
    });
  });

  group('airport search errors', () {
    Future<void> searchDepartureAndArrival() async {
      bloc
        ..add(const TravelFormDepartureAirportSearchTermChanged('ist'))
        ..add(const TravelFormArrivalAirportSearchTermChanged('new'));
      await Future<void>.delayed(const Duration(milliseconds: 450));
    }

    test('does not report again what the repository already reported', () async {
      airportRepository.error = const AirportSearchException('Failed.');

      await searchDepartureAndArrival();

      expect(airportRepository.queries, hasLength(2));
      expect(monitoring.reports, isEmpty);
      expect(bloc.state.error, isNotNull);
    });

    test('reports an unexpected error', () async {
      airportRepository.error = StateError('unexpected');

      await searchDepartureAndArrival();

      expect(monitoring.reports, hasLength(2));
    });
  });

  group('submit', () {
    void fillForm() {
      bloc
        ..add(const TravelFormDepartureAirportSelected(_istanbul))
        ..add(const TravelFormArrivalAirportSelected(_newYork))
        ..add(
          TravelFormDateRangeSelected(
            DateTimeRange(
              start: DateTime(2026, 7, 1),
              end: DateTime(2026, 7, 10),
            ),
          ),
        )
        ..add(const TravelFormNationalitySelected(_turkey))
        ..add(
          const ToggleTravelPurposeEvent(
            purpose: _sightseeing,
            isSelected: true,
          ),
        );
    }

    const submit = SubmitTravelFormEvent(
      locale: 'en',
      source: SubmitTravelDetailsSource.fab,
    );

    test('a double tap starts a single AI pipeline', () async {
      fillForm();
      await settle();
      expect(bloc.state.isFormValid, isTrue);

      bloc
        ..add(submit)
        ..add(submit);
      await settle();

      expect(aiRepository.calls, 1);
      expect(
        bloc.state.formSubmissionStatus,
        FormSubmissionStatus.submitting,
      );
    });

    test('accepts a new submit once the previous one has finished', () async {
      fillForm();
      await settle();

      bloc.add(submit);
      await settle();
      aiRepository.pending.complete(travelDetailsFixture());
      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<TravelFormState>(
            (state) =>
                state.formSubmissionStatus == FormSubmissionStatus.success,
          ),
        ),
      );

      aiRepository.pending = Completer<TravelDetails>();
      bloc.add(submit);
      await settle();

      expect(aiRepository.calls, 2);
    });

    group('city photo', () {
      Future<void> submitAndFinish() async {
        fillForm();
        await settle();
        bloc.add(submit);
        await settle();
        aiRepository.pending.complete(travelDetailsFixture());
        await expectLater(
          bloc.stream,
          emitsThrough(
            predicate<TravelFormState>(
              (state) =>
                  state.formSubmissionStatus == FormSubmissionStatus.success,
            ),
          ),
        );
        await settle();
      }

      test('keeps the photographer to credit and counts the download', () async {
        unsplashRepository.photo = _photo();
        imageRepository.bytes = 'base64-image';
        remoteConfig.showCityViewValue = true;

        await submitAndFinish();

        expect(bloc.state.cityImageInBytes, 'base64-image');
        expect(bloc.state.cityImageAuthor, _photographer);
        expect(imageRepository.downloadedUrls, ['https://images.unsplash.com/full']);
        expect(unsplashRepository.trackedDownloads, hasLength(1));
        expect(unsplashRepository.trackedDownloads.single.id, 'abc');
      });

      test('does not count a download while the city view is off', () async {
        unsplashRepository.photo = _photo();
        imageRepository.bytes = 'base64-image';
        remoteConfig.showCityViewValue = false;

        await submitAndFinish();

        expect(unsplashRepository.trackedDownloads, isEmpty);
      });

      test('does not count a download when the image failed to load', () async {
        unsplashRepository.photo = _photo();
        imageRepository.bytes = null;
        remoteConfig.showCityViewValue = true;

        await submitAndFinish();

        expect(bloc.state.cityImageAuthor, isNull);
        expect(unsplashRepository.trackedDownloads, isEmpty);
      });

      test('has nothing to download or credit without a photo', () async {
        unsplashRepository.photo = null;
        remoteConfig.showCityViewValue = true;

        await submitAndFinish();

        expect(imageRepository.downloadedUrls, isEmpty);
        expect(bloc.state.cityImageAuthor, isNull);
        expect(bloc.state.formSubmissionStatus, FormSubmissionStatus.success);
        expect(monitoring.reports, isEmpty);
      });
    });
  });
}
