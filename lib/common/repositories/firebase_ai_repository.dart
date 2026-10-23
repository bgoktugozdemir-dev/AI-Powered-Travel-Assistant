import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart' show ServerException;
import 'package:travel_assistant/common/ai/travel_format_pass.dart'
    show TravelFormatPassException, TravelFormatPassRunner;
import 'package:travel_assistant/common/ai/travel_research_pass.dart'
    show TravelResearchPassException, TravelResearchPassRunner;
import 'package:travel_assistant/common/error/firebase_error.dart';
import 'package:travel_assistant/common/error/network_error.dart';
import 'package:travel_assistant/common/models/response/travel_details.dart';
import 'package:travel_assistant/common/models/travel_information.dart';
import 'package:travel_assistant/common/repositories/firebase_remote_config_repository.dart';
import 'package:travel_assistant/common/utils/analytics/analytics_facade.dart';
import 'package:travel_assistant/common/utils/error_monitoring/error_monitoring_facade.dart';
import 'package:travel_assistant/common/utils/helpers/app_background_watch.dart';

abstract class _Constants {
  static const String defaultResearchPrompt =
      'You are a travel research assistant. Use the provided functions to '
      'collect up-to-date weather and currency findings, and your own knowledge '
      'for flight, visa, and tax findings.';
  static const String defaultFormatPrompt =
      'Format given findings into TravelDetails JSON matching schema exactly.';
}

/// Repository for interacting with Firebase AI capabilities.
class FirebaseAIRepository {
  /// Creates a [FirebaseAIRepository].
  const FirebaseAIRepository({
    required this.modelName,
    required this.firebaseRemoteConfigRepository,
    required this.travelResearchPass,
    required this.travelFormatPass,
    required this.analyticsFacade,
    required this.errorMonitoringFacade,
    this.startBackgroundWatch = LifecycleAppBackgroundWatch.start,
  });

  /// Model name used for analytics and diagnostics.
  final String modelName;

  /// Remote config repository.
  final FirebaseRemoteConfigRepository firebaseRemoteConfigRepository;

  /// First pass orchestrator for tool-grounded research.
  final TravelResearchPassRunner travelResearchPass;

  /// Second pass orchestrator for schema formatting.
  final TravelFormatPassRunner travelFormatPass;

  /// Analytics facade instance.
  final AnalyticsFacade analyticsFacade;

  /// Error monitoring facade instance.
  final ErrorMonitoringFacade errorMonitoringFacade;

  /// Watches whether the app leaves the foreground during a generation, which
  /// tells an interrupted request caused by a suspended tab apart from other
  /// connection failures.
  final AppBackgroundWatchStarter startBackgroundWatch;

  /// Generates a travel plan with two-pass AI orchestration.
  Future<TravelDetails> generateTravelPlan(
    TravelInformation travelInformation,
  ) async {
    final userPrompt = jsonEncode(travelInformation.toJson());
    analyticsFacade.logLLMPrompt(modelName, userPrompt);
    final stopwatch = Stopwatch()..start();
    // Breadcrumbs are attached to the events reported afterwards, so a failure
    // the passes report shows whether the app was backgrounded, and when.
    final backgroundWatch = startBackgroundWatch(
      onBackground: () => errorMonitoringFacade.addBreadcrumb(
        'App went to the background while generating a travel plan.',
        category: 'Firebase AI',
        data: {'elapsedMs': stopwatch.elapsedMilliseconds},
      ),
    );

    try {
      final researchPrompt =
          firebaseRemoteConfigRepository.aiResearchSystemPrompt.isNotEmpty
          ? firebaseRemoteConfigRepository.aiResearchSystemPrompt
          : _Constants.defaultResearchPrompt;

      final researchFindings = await travelResearchPass
          .generateResearchFindings(
            userPrompt: userPrompt,
            systemPrompt: researchPrompt,
          );

      final formatPrompt =
          firebaseRemoteConfigRepository.aiFormatSystemPrompt.isNotEmpty
          ? firebaseRemoteConfigRepository.aiFormatSystemPrompt
          : _Constants.defaultFormatPrompt;

      final travelDetails = await travelFormatPass.formatResearchFindings(
        userPrompt: userPrompt,
        researchFindings: researchFindings,
        systemPrompt: formatPrompt,
      );

      stopwatch.stop();
      errorMonitoringFacade.addBreadcrumb(
        'Two-pass Firebase AI pipeline completed.',
        category: 'Firebase AI',
        data: {
          'prompt': userPrompt,
          'researchPrompt': researchPrompt,
          'formatPrompt': formatPrompt,
          'model': modelName,
          'durationMs': stopwatch.elapsedMilliseconds,
        },
      );
      analyticsFacade.logLLMResponse(
        modelName,
        userPrompt,
        travelDetails.toString(),
        stopwatch.elapsedMilliseconds,
      );
      return travelDetails;
    } catch (e, stackTrace) {
      stopwatch.stop();
      final failureData = {
        'prompt': userPrompt,
        'model': modelName,
        'durationMs': stopwatch.elapsedMilliseconds,
        'wentToBackground': backgroundWatch.wentToBackground,
      };
      if (e is AlreadyReportedError) {
        // A pass already reported the failure. Keep what only this layer
        // knows as a breadcrumb instead of creating a second issue.
        errorMonitoringFacade.addBreadcrumb(
          'Two-pass Firebase AI pipeline failed.',
          category: 'Firebase AI',
          data: failureData,
        );
      } else {
        errorMonitoringFacade.reportError(
          'Exception occurred while generating text with Firebase AI',
          stackTrace: stackTrace,
          context: {'error': e, ...failureData},
        );
      }
      if (e is FirebaseError) {
        rethrow;
      }
      if (_isServerException(e)) {
        throw FirebaseAppCheckError();
      }
      if (isNetworkInterruption(_rootCause(e))) {
        throw FirebaseConnectionError(
          wentToBackground: backgroundWatch.wentToBackground,
        );
      }
      throw AiGenerationException(e);
    } finally {
      backgroundWatch.dispose();
    }
  }

  /// The error a pass wrapped, or [error] itself.
  Object _rootCause(Object error) => switch (error) {
    TravelResearchPassException(:final cause?) => cause,
    TravelFormatPassException(:final cause) => cause,
    _ => error,
  };

  /// Whether [error] is (or wraps) a Firebase AI [ServerException], which is
  /// how App Check / backend rejections surface from the SDK.
  bool _isServerException(Object error) =>
      _rootCause(error) is ServerException;
}
