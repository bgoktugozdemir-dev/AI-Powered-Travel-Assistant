import 'package:firebase_ai/firebase_ai.dart' show ServerException;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_assistant/common/ai/ai_pass_run.dart';
import 'package:travel_assistant/common/ai/travel_format_pass.dart';
import 'package:travel_assistant/common/ai/travel_research_pass.dart';
import 'package:travel_assistant/common/error/firebase_error.dart';
import 'package:travel_assistant/common/models/airport.dart';
import 'package:travel_assistant/common/models/country.dart';
import 'package:travel_assistant/common/models/response/travel_details.dart';
import 'package:travel_assistant/common/models/travel_information.dart';
import 'package:travel_assistant/common/models/travel_purpose.dart';
import 'package:travel_assistant/common/repositories/firebase_ai_repository.dart';
import 'package:travel_assistant/common/repositories/firebase_remote_config_repository.dart';
import 'package:travel_assistant/common/utils/analytics/analytics_client.dart';
import 'package:travel_assistant/common/utils/analytics/analytics_facade.dart';
import 'package:travel_assistant/common/utils/error_monitoring/error_monitoring_facade.dart';

import '../../support/fake_app_background_watch.dart';

class _FakeRemoteConfigRepository implements FirebaseRemoteConfigRepository {
  @override
  String get aiResearchSystemPrompt => '';

  @override
  String get aiFormatSystemPrompt => '';

  @override
  bool get aiUsePromptTemplates => true;

  @override
  String get aiResearchTemplateId => 'research-template';

  @override
  String get aiFormatTemplateId => '';

  @override
  String get aiModel => 'gemini-test';

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// Records the `model` argument of the LLM analytics events.
class _RecordingAnalyticsClient implements AnalyticsClient {
  final List<String> promptModels = [];
  final List<String> responseModels = [];

  @override
  void logLLMPrompt(String model, String prompt) => promptModels.add(model);

  @override
  void logLLMResponse(
    String model,
    String prompt,
    String response,
    int durationMs,
  ) => responseModels.add(model);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// Research pass that records a run like `TemplateAwareResearchPass` does.
class _RecordingResearchPass implements TravelResearchPassRunner {
  _RecordingResearchPass(this.recorder, this.run);

  final AiRunRecorder recorder;
  final AiPassRun run;

  @override
  Future<String> generateResearchFindings({
    required String userPrompt,
    required String systemPrompt,
  }) async {
    recorder.record(run);
    return 'findings';
  }
}

class _FakeResearchPass implements TravelResearchPassRunner {
  _FakeResearchPass({this.errorToThrow});

  final Object? errorToThrow;

  @override
  Future<String> generateResearchFindings({
    required String userPrompt,
    required String systemPrompt,
  }) async {
    if (errorToThrow case final error?) {
      throw error;
    }
    return 'research-findings';
  }
}

class _FakeFormatPass implements TravelFormatPassRunner {
  _FakeFormatPass(this.result);

  final TravelDetails result;
  int callCount = 0;

  @override
  Future<TravelDetails> formatResearchFindings({
    required String userPrompt,
    required String researchFindings,
    required String systemPrompt,
  }) async {
    callCount++;
    return result;
  }
}

TravelInformation _sampleTravelInformation() {
  return TravelInformation(
    departureAirport: const Airport(
      iataCode: 'IST',
      name: 'Istanbul Airport',
      countryCode: 'TR',
      countryName: 'Turkey',
      cityName: 'Istanbul',
    ),
    arrivalAirport: const Airport(
      iataCode: 'JFK',
      name: 'John F. Kennedy International Airport',
      countryCode: 'US',
      countryName: 'United States',
      cityName: 'New York',
    ),
    dateRange: DateTimeRange(
      start: DateTime(2026, 7, 1),
      end: DateTime(2026, 7, 10),
    ),
    nationality: const Country(code: 'TR', name: 'Turkey'),
    travelPurposes: const [
      TravelPurpose(
        id: 'sightseeing',
        name: 'Sightseeing',
        localizationKey: 'travelPurposeSightseeing',
      ),
    ],
    locale: 'en',
  );
}

TravelDetails _sampleTravelDetails() {
  return TravelDetails.fromJson({
    'city': {
      'name': 'New York',
      'country': 'United States',
      'crowd_level': 3,
      'time': null,
      'weather': [
        {'date': '2026-07-01', 'weather': 'Sunny', 'temperature': 28.0},
      ],
    },
    'required_documents': {
      'type': 'passport',
      'message': 'Passport required',
      'steps': null,
      'more_information': null,
    },
    'currency': {
      'code': 'USD',
      'name': 'US Dollar',
      'departure_currency_code': 'TRY',
      'exchange_rate': 39.0,
      'departure_average_living_cost_per_day': 70.0,
      'arrival_average_living_cost_per_day': 160.0,
    },
    'flight_options': {
      'cheapest': {
        'departure': {
          'airline': 'TK',
          'departure_airport': 'IST',
          'arrival_airport': 'JFK',
          'flight_number': 'TK111',
          'departure_time': '2026-07-01T08:00:00Z',
          'arrival_time': '2026-07-01T14:00:00Z',
          'duration': 600,
          'price': 900.0,
          'currency': 'USD',
          'stops': 0,
          'layover_details': [],
          'more_information': 'info',
        },
        'arrival': {
          'airline': 'TK',
          'departure_airport': 'IST',
          'arrival_airport': 'JFK',
          'flight_number': 'TK111',
          'departure_time': '2026-07-01T08:00:00Z',
          'arrival_time': '2026-07-01T14:00:00Z',
          'duration': 600,
          'price': 900.0,
          'currency': 'USD',
          'stops': 0,
          'layover_details': [],
          'more_information': 'info',
        },
        'booking_url': 'https://example.com',
      },
      'comfortable': {
        'departure': {
          'airline': 'TK',
          'departure_airport': 'IST',
          'arrival_airport': 'JFK',
          'flight_number': 'TK111',
          'departure_time': '2026-07-01T08:00:00Z',
          'arrival_time': '2026-07-01T14:00:00Z',
          'duration': 600,
          'price': 1200.0,
          'currency': 'USD',
          'stops': 0,
          'layover_details': [],
          'more_information': 'info',
        },
        'arrival': {
          'airline': 'TK',
          'departure_airport': 'IST',
          'arrival_airport': 'JFK',
          'flight_number': 'TK111',
          'departure_time': '2026-07-01T08:00:00Z',
          'arrival_time': '2026-07-01T14:00:00Z',
          'duration': 600,
          'price': 1200.0,
          'currency': 'USD',
          'stops': 0,
          'layover_details': [],
          'more_information': 'info',
        },
        'booking_url': 'https://example.com',
      },
    },
    'tax_information': {
      'has_tax_free_options': true,
      'tax_rate': 8.0,
      'refundable_tax_rate': 5.0,
      'tax_refund_information': 'Bring receipts',
    },
    'spots': [
      {'place': 'Times Square', 'description': 'Visit', 'requirements': null},
    ],
    'travel_plan': [
      {
        'date': '2026-07-02T00:00:00.000Z',
        'events': [
          {
            'name': 'Walk',
            'time': '10:00',
            'location': 'Manhattan',
            'description': 'Walk tour',
            'requirements': null,
          },
        ],
      },
    ],
    'recommendations': ['Use metro'],
  });
}

void main() {
  test('orchestrates research then format pass', () async {
    final formatPass = _FakeFormatPass(_sampleTravelDetails());
    final repository = FirebaseAIRepository(
      firebaseRemoteConfigRepository: _FakeRemoteConfigRepository(),
      travelResearchPass: _FakeResearchPass(),
      travelFormatPass: formatPass,
      analyticsFacade: const AnalyticsFacade([]),
      errorMonitoringFacade: const ErrorMonitoringFacade([]),
      startBackgroundWatch: fakeBackgroundWatch(),
    );

    final result = await repository.generateTravelPlan(
      _sampleTravelInformation(),
    );

    expect(result.city.name, 'New York');
    expect(formatPass.callCount, 1);
  });

  test('reports configured paths for the prompt, recorded ones for the '
      'response', () async {
    final analytics = _RecordingAnalyticsClient();
    final recorder = AiRunRecorder()
      ..record(const AiPassRun.client(pass: 'stale', model: 'old-model'));
    final repository = FirebaseAIRepository(
      firebaseRemoteConfigRepository: _FakeRemoteConfigRepository(),
      travelResearchPass: _RecordingResearchPass(
        recorder,
        const AiPassRun.client(pass: 'research', model: 'fallback-model'),
      ),
      travelFormatPass: _FakeFormatPass(_sampleTravelDetails()),
      analyticsFacade: AnalyticsFacade([analytics]),
      errorMonitoringFacade: const ErrorMonitoringFacade([]),
      startBackgroundWatch: fakeBackgroundWatch(),
      aiRunRecorder: recorder,
    );

    await repository.generateTravelPlan(_sampleTravelInformation());
    await Future<void>.delayed(Duration.zero);

    expect(analytics.promptModels, [
      'research=template:research-template, format=client:gemini-test',
    ]);
    // The previous generation's runs are dropped; the research pass fell
    // back, and the fake format pass recorded nothing.
    expect(analytics.responseModels, ['research=client:fallback-model']);
  });

  test('wraps non-firebase errors from research pass', () async {
    final formatPass = _FakeFormatPass(_sampleTravelDetails());
    final repository = FirebaseAIRepository(
      firebaseRemoteConfigRepository: _FakeRemoteConfigRepository(),
      travelResearchPass: _FakeResearchPass(
        errorToThrow: const TravelResearchPassException('research failure'),
      ),
      travelFormatPass: formatPass,
      analyticsFacade: const AnalyticsFacade([]),
      errorMonitoringFacade: const ErrorMonitoringFacade([]),
      startBackgroundWatch: fakeBackgroundWatch(),
    );

    await expectLater(
      () => repository.generateTravelPlan(_sampleTravelInformation()),
      throwsA(isA<Exception>()),
    );
    expect(formatPass.callCount, 0);
  });

  test('rethrows firebase errors without wrapping', () async {
    final formatPass = _FakeFormatPass(_sampleTravelDetails());
    final repository = FirebaseAIRepository(
      firebaseRemoteConfigRepository: _FakeRemoteConfigRepository(),
      travelResearchPass: _FakeResearchPass(
        errorToThrow: FirebaseAppCheckError(),
      ),
      travelFormatPass: formatPass,
      analyticsFacade: const AnalyticsFacade([]),
      errorMonitoringFacade: const ErrorMonitoringFacade([]),
      startBackgroundWatch: fakeBackgroundWatch(),
    );

    await expectLater(
      () => repository.generateTravelPlan(_sampleTravelInformation()),
      throwsA(isA<FirebaseAppCheckError>()),
    );
    expect(formatPass.callCount, 0);
  });

  test(
    'maps wrapped firebase_ai ServerException to FirebaseAppCheckError',
    () async {
      final formatPass = _FakeFormatPass(_sampleTravelDetails());
      final repository = FirebaseAIRepository(
        firebaseRemoteConfigRepository: _FakeRemoteConfigRepository(),
        travelResearchPass: _FakeResearchPass(
          errorToThrow: TravelResearchPassException(
            'Research pass failed.',
            cause: ServerException('app check rejected'),
          ),
        ),
        travelFormatPass: formatPass,
        analyticsFacade: const AnalyticsFacade([]),
        errorMonitoringFacade: const ErrorMonitoringFacade([]),
        startBackgroundWatch: fakeBackgroundWatch(),
      );

      await expectLater(
        () => repository.generateTravelPlan(_sampleTravelInformation()),
        throwsA(isA<FirebaseAppCheckError>()),
      );
      expect(formatPass.callCount, 0);
    },
  );
}
