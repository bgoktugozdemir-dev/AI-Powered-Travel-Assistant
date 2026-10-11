import 'dart:async';

import 'package:firebase_ai/firebase_ai.dart' show ServerException;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_assistant/common/ai/travel_format_pass.dart';
import 'package:travel_assistant/common/ai/travel_research_pass.dart';
import 'package:travel_assistant/common/error/firebase_error.dart';
import 'package:travel_assistant/common/models/airport.dart';
import 'package:travel_assistant/common/models/country.dart';
import 'package:travel_assistant/common/models/response/travel_details.dart';
import 'package:travel_assistant/common/models/travel_information.dart';
import 'package:travel_assistant/common/repositories/firebase_ai_repository.dart';
import 'package:travel_assistant/common/repositories/firebase_remote_config_repository.dart';
import 'package:travel_assistant/common/utils/analytics/analytics_facade.dart';
import 'package:travel_assistant/common/utils/error_monitoring/error_monitoring_client.dart';
import 'package:travel_assistant/common/utils/error_monitoring/error_monitoring_facade.dart';
import 'package:travel_assistant/features/travel_form/error/travel_form_error.dart';

class _FakeRemoteConfigRepository implements FirebaseRemoteConfigRepository {
  @override
  String get aiResearchSystemPrompt => '';

  @override
  String get aiFormatSystemPrompt => '';

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FailingResearchPass implements TravelResearchPassRunner {
  _FailingResearchPass(this.error);

  final Object error;

  @override
  Future<String> generateResearchFindings({
    required String userPrompt,
    required String systemPrompt,
  }) async => throw error;
}

class _UnusedFormatPass implements TravelFormatPassRunner {
  @override
  Future<TravelDetails> formatResearchFindings({
    required String userPrompt,
    required String researchFindings,
    required String systemPrompt,
  }) async => throw UnimplementedError();
}

class _RecordingClient implements ErrorMonitoringClient {
  final List<Object> reportedErrors = [];

  @override
  void reportError(
    Object error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    reportedErrors.add(error);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// Mimics `package:http`'s `ClientException.toString()`.
class _FakeClientException implements Exception {
  @override
  String toString() => 'ClientException: Load failed, uri=https://example.com';
}

TravelInformation _travelInformation() => TravelInformation(
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
  travelPurposes: const [],
  locale: 'en',
);

FirebaseAIRepository _repositoryFailingWith(
  Object error, {
  _RecordingClient? monitoring,
}) => FirebaseAIRepository(
  modelName: 'gemini-test',
  firebaseRemoteConfigRepository: _FakeRemoteConfigRepository(),
  travelResearchPass: _FailingResearchPass(error),
  travelFormatPass: _UnusedFormatPass(),
  analyticsFacade: const AnalyticsFacade([]),
  errorMonitoringFacade: ErrorMonitoringFacade([?monitoring]),
);

void main() {
  group('FirebaseAIRepository error mapping', () {
    test('maps an interrupted request to FirebaseConnectionError', () async {
      final repository = _repositoryFailingWith(_FakeClientException());

      await expectLater(
        () => repository.generateTravelPlan(_travelInformation()),
        throwsA(isA<FirebaseConnectionError>()),
      );
    });

    test('maps an interrupted request wrapped by the research pass', () async {
      final repository = _repositoryFailingWith(
        TravelResearchPassException(
          'Research pass failed.',
          cause: _FakeClientException(),
        ),
      );

      await expectLater(
        () => repository.generateTravelPlan(_travelInformation()),
        throwsA(isA<FirebaseConnectionError>()),
      );
    });

    test('maps a timeout to FirebaseConnectionError', () async {
      final repository = _repositoryFailingWith(TimeoutException('slow'));

      await expectLater(
        () => repository.generateTravelPlan(_travelInformation()),
        throwsA(isA<FirebaseConnectionError>()),
      );
    });

    test('still maps ServerException to FirebaseAppCheckError', () async {
      final repository = _repositoryFailingWith(ServerException('rejected'));

      await expectLater(
        () => repository.generateTravelPlan(_travelInformation()),
        throwsA(isA<FirebaseAppCheckError>()),
      );
    });

    test('wraps other failures keeping the cause', () async {
      final repository = _repositoryFailingWith(const FormatException('bad'));

      await expectLater(
        () => repository.generateTravelPlan(_travelInformation()),
        throwsA(
          isA<AiGenerationException>().having(
            (e) => e.cause,
            'cause',
            isA<FormatException>(),
          ),
        ),
      );
    });

    test('does not report a failure a pass already reported', () async {
      final monitoring = _RecordingClient();
      final repository = _repositoryFailingWith(
        TravelResearchPassException(
          'Research pass failed.',
          cause: _FakeClientException(),
        ),
        monitoring: monitoring,
      );

      await expectLater(
        () => repository.generateTravelPlan(_travelInformation()),
        throwsA(isA<FirebaseConnectionError>()),
      );
      await Future<void>.delayed(Duration.zero);

      expect(monitoring.reportedErrors, isEmpty);
    });

    test('maps a server error wrapped by the format pass', () async {
      final repository = _repositoryFailingWith(
        TravelFormatPassException(ServerException('rejected')),
      );

      await expectLater(
        () => repository.generateTravelPlan(_travelInformation()),
        throwsA(isA<FirebaseAppCheckError>()),
      );
    });

    test('maps an interrupted request wrapped by the format pass', () async {
      final repository = _repositoryFailingWith(
        TravelFormatPassException(_FakeClientException()),
      );

      await expectLater(
        () => repository.generateTravelPlan(_travelInformation()),
        throwsA(isA<FirebaseConnectionError>()),
      );
    });

    test('reports the failure exactly once', () async {
      final monitoring = _RecordingClient();
      final repository = _repositoryFailingWith(
        _FakeClientException(),
        monitoring: monitoring,
      );

      await expectLater(
        () => repository.generateTravelPlan(_travelInformation()),
        throwsA(isA<FirebaseConnectionError>()),
      );
      await Future<void>.delayed(Duration.zero);

      expect(monitoring.reportedErrors, hasLength(1));
    });
  });

  group('travelFormErrorFor', () {
    test('tells the user the connection was interrupted', () {
      expect(
        travelFormErrorFor(FirebaseConnectionError()),
        isA<ConnectionInterruptedError>(),
      );
    });

    test('keeps the server error for other firebase errors', () {
      expect(
        travelFormErrorFor(FirebaseAppCheckError()),
        isA<ServerError>(),
      );
    });

    test('falls back to the general error', () {
      expect(
        travelFormErrorFor(AiGenerationException(StateError('x'))),
        isA<GeneralTravelFormError>(),
      );
      expect(
        travelFormErrorFor(Exception('x')),
        isA<GeneralTravelFormError>(),
      );
    });
  });

  group('AlreadyReportedError', () {
    test('marks errors the repository reported itself', () {
      expect(FirebaseConnectionError(), isA<AlreadyReportedError>());
      expect(FirebaseAppCheckError(), isA<AlreadyReportedError>());
      expect(
        AiGenerationException(StateError('x')),
        isA<AlreadyReportedError>(),
      );
      expect(Exception('x'), isNot(isA<AlreadyReportedError>()));
    });
  });
}
