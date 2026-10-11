import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:travel_assistant/common/ai/template_errors.dart';
import 'package:travel_assistant/common/ai/travel_format_pass.dart'
    show TravelFormatPassRunner;
import 'package:travel_assistant/common/ai/travel_research_pass.dart'
    show TravelResearchPassRunner;
import 'package:travel_assistant/common/models/response/travel_details.dart';
import 'package:travel_assistant/common/repositories/firebase_remote_config_repository.dart';
import 'package:travel_assistant/common/utils/error_monitoring/error_monitoring_facade.dart';

abstract class _Constants {
  static const String breadcrumbCategory = 'Firebase AI';
  static const String researchPassName = 'research';
  static const String formatPassName = 'format';
}

/// Template fallbacks already reported in this app session, as
/// `<pass>:<templateId>`, so a misconfigured template is reported once instead
/// of on every trip.
final Set<String> _reportedFallbacks = {};

/// Forgets the fallbacks reported in this session. For tests only.
@visibleForTesting
void resetReportedTemplateFallbacks() => _reportedFallbacks.clear();

/// Runs [runTemplate] and falls back to [runFallback] when the template is
/// unavailable (see [isTemplateUnavailableError]). Any other error propagates.
///
/// A fallback is also reported as a warning: the app keeps working, but the
/// template (or the model it uses) is misconfigured, e.g. a model that isn't
/// served in the app's location.
Future<T> _runWithTemplateFallback<T>({
  required String passName,
  required String templateId,
  required ErrorMonitoringFacade errorMonitoring,
  required Future<T> Function() runTemplate,
  required Future<T> Function() runFallback,
}) async {
  try {
    return await runTemplate();
  } catch (e) {
    if (!isTemplateUnavailableError(e)) {
      rethrow;
    }
    const message =
        'Prompt template unavailable, falling back to client-built prompt.';
    final details = {
      'pass': passName,
      'templateId': templateId,
      'error': e.toString(),
    };
    errorMonitoring.addBreadcrumb(
      message,
      category: _Constants.breadcrumbCategory,
      data: details,
    );
    if (_reportedFallbacks.add('$passName:$templateId')) {
      errorMonitoring.captureMessage(
        message,
        level: 'warning',
        context: details,
      );
    }
    return runFallback();
  }
}

/// Research pass that prefers a server prompt template over the client-built
/// prompt.
///
/// The template is used when `ai_use_prompt_templates` is on and a template ID
/// is configured. If the template cannot be used (not uploaded to the
/// console, invalid) the client-built [fallbackPass] runs instead, so the app
/// keeps working without the template.
class TemplateAwareResearchPass implements TravelResearchPassRunner {
  TemplateAwareResearchPass({
    required TravelResearchPassRunner templatePass,
    required TravelResearchPassRunner fallbackPass,
    required FirebaseRemoteConfigRepository remoteConfig,
    required ErrorMonitoringFacade errorMonitoring,
  }) : _templatePass = templatePass,
       _fallbackPass = fallbackPass,
       _remoteConfig = remoteConfig,
       _errorMonitoring = errorMonitoring;

  final TravelResearchPassRunner _templatePass;
  final TravelResearchPassRunner _fallbackPass;
  final FirebaseRemoteConfigRepository _remoteConfig;
  final ErrorMonitoringFacade _errorMonitoring;

  @override
  Future<String> generateResearchFindings({
    required String userPrompt,
    required String systemPrompt,
  }) {
    final templateId = _remoteConfig.aiResearchTemplateId;
    Future<String> runFallback() => _fallbackPass.generateResearchFindings(
      userPrompt: userPrompt,
      systemPrompt: systemPrompt,
    );

    if (!_remoteConfig.aiUsePromptTemplates || templateId.isEmpty) {
      return runFallback();
    }

    return _runWithTemplateFallback(
      passName: _Constants.researchPassName,
      templateId: templateId,
      errorMonitoring: _errorMonitoring,
      runTemplate: () => _templatePass.generateResearchFindings(
        userPrompt: userPrompt,
        systemPrompt: systemPrompt,
      ),
      runFallback: runFallback,
    );
  }
}

/// Format pass that prefers a server prompt template over the client-built
/// prompt. See [TemplateAwareResearchPass] for the selection rule.
class TemplateAwareFormatPass implements TravelFormatPassRunner {
  TemplateAwareFormatPass({
    required TravelFormatPassRunner templatePass,
    required TravelFormatPassRunner fallbackPass,
    required FirebaseRemoteConfigRepository remoteConfig,
    required ErrorMonitoringFacade errorMonitoring,
  }) : _templatePass = templatePass,
       _fallbackPass = fallbackPass,
       _remoteConfig = remoteConfig,
       _errorMonitoring = errorMonitoring;

  final TravelFormatPassRunner _templatePass;
  final TravelFormatPassRunner _fallbackPass;
  final FirebaseRemoteConfigRepository _remoteConfig;
  final ErrorMonitoringFacade _errorMonitoring;

  @override
  Future<TravelDetails> formatResearchFindings({
    required String userPrompt,
    required String researchFindings,
    required String systemPrompt,
  }) {
    final templateId = _remoteConfig.aiFormatTemplateId;
    Future<TravelDetails> runFallback() => _fallbackPass.formatResearchFindings(
      userPrompt: userPrompt,
      researchFindings: researchFindings,
      systemPrompt: systemPrompt,
    );

    if (!_remoteConfig.aiUsePromptTemplates || templateId.isEmpty) {
      return runFallback();
    }

    return _runWithTemplateFallback(
      passName: _Constants.formatPassName,
      templateId: templateId,
      errorMonitoring: _errorMonitoring,
      runTemplate: () => _templatePass.formatResearchFindings(
        userPrompt: userPrompt,
        researchFindings: researchFindings,
        systemPrompt: systemPrompt,
      ),
      runFallback: runFallback,
    );
  }
}
