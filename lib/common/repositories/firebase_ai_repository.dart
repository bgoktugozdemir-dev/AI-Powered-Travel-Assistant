import 'dart:convert';

import 'package:travel_assistant/common/ai/travel_format_pass.dart'
    show TravelFormatPassRunner;
import 'package:travel_assistant/common/ai/travel_research_pass.dart'
    show TravelResearchPassRunner;
import 'package:travel_assistant/common/models/response/travel_details.dart';
import 'package:travel_assistant/common/models/travel_information.dart';
import 'package:travel_assistant/common/repositories/firebase_remote_config_repository.dart';
import 'package:travel_assistant/common/utils/analytics/analytics_facade.dart';
import 'package:travel_assistant/common/utils/error_monitoring/error_monitoring_facade.dart';

abstract class _Constants {
  static const String defaultResearchPrompt =
      'You are a travel research assistant. Use functions and grounding to '
      'collect up-to-date flight, visa, tax, weather, and currency findings.';
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

  /// Generates a travel plan with two-pass AI orchestration.
  Future<TravelDetails> generateTravelPlan(
    TravelInformation travelInformation,
  ) async {
    final userPrompt = jsonEncode(travelInformation.toJson());
    analyticsFacade.logLLMPrompt(modelName, userPrompt);
    final stopwatch = Stopwatch()..start();

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
      errorMonitoringFacade.reportError(
        'Exception occurred while generating text with Firebase AI',
        stackTrace: stackTrace,
        context: {
          'error': e,
          'prompt': userPrompt,
          'model': modelName,
          'durationMs': stopwatch.elapsedMilliseconds,
        },
      );
      throw Exception('Failed to generate text: $e');
    }
  }
}
