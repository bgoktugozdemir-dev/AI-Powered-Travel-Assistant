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

class _FakeRemoteConfig extends Fake implements FirebaseRemoteConfigRepository {
  @override
  bool get navigateToNextStepAfterSelectingTravelPurpose => false;

  @override
  bool get showCityView => false;

  @override
  int get minimumTravelPurposes => 1;

  @override
  int get maximumTravelPurposes => 3;
}

class _FakeAirportRepository extends Fake implements AirportRepository {
  final List<String> queries = [];

  @override
  Future<List<Airport>> searchAirports(String query) async {
    queries.add(query);
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
  @override
  Future<UnsplashPhoto?> getCityView({
    required String cityName,
    required String countryName,
  }) async => null;
}

class _FakeCurrencyRepository extends Fake implements CurrencyRepository {
  @override
  Future<double?> getExchangeRate(
    String fromCurrency,
    String toCurrency,
  ) async => 1.0;
}

class _FakeImageRepository extends Fake implements ImageRepository {
  @override
  Future<String?> downloadImageAsBase64({required String url}) async => null;
}

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
  late TravelFormBloc bloc;

  setUp(() {
    airportRepository = _FakeAirportRepository();
    countryService = _FakeCountryService();
    aiRepository = _FakeAIRepository();
    bloc = TravelFormBloc(
      analyticsFacade: const AnalyticsFacade([]),
      errorMonitoringFacade: const ErrorMonitoringFacade([]),
      airportRepository: airportRepository,
      travelPurposeService: _FakeTravelPurposeService(),
      firebaseAIRepository: aiRepository,
      unsplashRepository: _FakeUnsplashRepository(),
      imageRepository: _FakeImageRepository(),
      currencyRepository: _FakeCurrencyRepository(),
      firebaseRemoteConfigRepository: _FakeRemoteConfig(),
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
  });
}
