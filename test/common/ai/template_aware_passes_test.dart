import 'package:firebase_ai/firebase_ai.dart' show ServerException;
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_assistant/common/ai/ai_pass_run.dart';
import 'package:travel_assistant/common/ai/template_aware_passes.dart';
import 'package:travel_assistant/common/ai/travel_format_pass.dart';
import 'package:travel_assistant/common/ai/travel_research_pass.dart';
import 'package:travel_assistant/common/models/response/travel_details.dart';
import 'package:travel_assistant/common/repositories/firebase_remote_config_repository.dart';
import 'package:travel_assistant/common/utils/error_monitoring/error_monitoring_client.dart';
import 'package:travel_assistant/common/utils/error_monitoring/error_monitoring_facade.dart';

import 'travel_details_fixture.dart';

class _FakeRemoteConfigRepository implements FirebaseRemoteConfigRepository {
  _FakeRemoteConfigRepository({
    this.useTemplates = true,
    this.researchTemplateId = 'research-template',
    this.formatTemplateId = 'format-template',
  });

  final bool useTemplates;
  final String researchTemplateId;
  final String formatTemplateId;

  @override
  bool get aiUsePromptTemplates => useTemplates;

  @override
  String get aiResearchTemplateId => researchTemplateId;

  @override
  String get aiFormatTemplateId => formatTemplateId;

  @override
  String get aiModel => 'client-model';

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _RecordingErrorMonitoringClient implements ErrorMonitoringClient {
  final List<String> breadcrumbs = [];
  final List<String?> warningLevels = [];

  /// The `run` of every "AI pass started." breadcrumb, kept apart from
  /// [breadcrumbs] so the fallback assertions only see fallbacks.
  final List<Object?> startedRuns = [];

  @override
  void captureMessage(
    String message, {
    String? level,
    Map<String, dynamic>? context,
  }) {
    warningLevels.add(level);
  }

  @override
  void addBreadcrumb(
    String message, {
    String? category,
    Map<String, dynamic>? data,
  }) {
    if (message == 'AI pass started.') {
      startedRuns.add(data?['run']);
      return;
    }
    breadcrumbs.add(message);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeResearchPass implements TravelResearchPassRunner {
  _FakeResearchPass(this.name, {this.errorToThrow});

  final String name;
  final Object? errorToThrow;
  int callCount = 0;

  @override
  Future<String> generateResearchFindings({
    required String userPrompt,
    required String systemPrompt,
  }) async {
    callCount++;
    if (errorToThrow case final error?) {
      throw error;
    }
    return '$name-findings';
  }
}

class _FakeFormatPass implements TravelFormatPassRunner {
  _FakeFormatPass({this.errorToThrow});

  final Object? errorToThrow;
  int callCount = 0;

  @override
  Future<TravelDetails> formatResearchFindings({
    required String userPrompt,
    required String researchFindings,
    required String systemPrompt,
  }) async {
    callCount++;
    if (errorToThrow case final error?) {
      throw error;
    }
    return travelDetailsFixture();
  }
}

void main() {
  late _RecordingErrorMonitoringClient monitoringClient;
  late ErrorMonitoringFacade errorMonitoring;

  setUp(() {
    resetReportedTemplateFallbacks();
    monitoringClient = _RecordingErrorMonitoringClient();
    errorMonitoring = ErrorMonitoringFacade([monitoringClient]);
  });

  group('TemplateAwareResearchPass', () {
    TemplateAwareResearchPass build({
      required _FakeResearchPass templatePass,
      required _FakeResearchPass fallbackPass,
      _FakeRemoteConfigRepository? remoteConfig,
      AiRunRecorder? runRecorder,
    }) {
      return TemplateAwareResearchPass(
        templatePass: templatePass,
        fallbackPass: fallbackPass,
        remoteConfig: remoteConfig ?? _FakeRemoteConfigRepository(),
        errorMonitoring: errorMonitoring,
        runRecorder: runRecorder,
      );
    }

    Future<String> run(TemplateAwareResearchPass pass) {
      return pass.generateResearchFindings(
        userPrompt: '{}',
        systemPrompt: 'system',
      );
    }

    test('uses the template when the flag is on', () async {
      final template = _FakeResearchPass('template');
      final fallback = _FakeResearchPass('fallback');

      final result = await run(
        build(templatePass: template, fallbackPass: fallback),
      );

      expect(result, 'template-findings');
      expect(template.callCount, 1);
      expect(fallback.callCount, 0);
    });

    test('records a template run', () async {
      final recorder = AiRunRecorder();

      await run(
        build(
          templatePass: _FakeResearchPass('template'),
          fallbackPass: _FakeResearchPass('fallback'),
          runRecorder: recorder,
        ),
      );

      expect(recorder.describe(), 'research=template:research-template');
      expect(monitoringClient.startedRuns, ['template:research-template']);
    });

    test('records the client-built run when the flag is off', () async {
      final recorder = AiRunRecorder();

      await run(
        build(
          templatePass: _FakeResearchPass('template'),
          fallbackPass: _FakeResearchPass('fallback'),
          remoteConfig: _FakeRemoteConfigRepository(useTemplates: false),
          runRecorder: recorder,
        ),
      );

      expect(recorder.describe(), 'research=client:client-model');
    });

    test('records the fallback in place of the template attempt', () async {
      final recorder = AiRunRecorder();

      await run(
        build(
          templatePass: _FakeResearchPass(
            'template',
            errorToThrow: TravelResearchPassException(
              'Research pass failed.',
              cause: ServerException('Template research-template not found'),
            ),
          ),
          fallbackPass: _FakeResearchPass('fallback'),
          runRecorder: recorder,
        ),
      );

      expect(recorder.describe(), 'research=client:client-model');
      expect(monitoringClient.startedRuns, [
        'template:research-template',
        'client:client-model',
      ]);
    });

    test('skips the template when the flag is off', () async {
      final template = _FakeResearchPass('template');
      final fallback = _FakeResearchPass('fallback');

      final result = await run(
        build(
          templatePass: template,
          fallbackPass: fallback,
          remoteConfig: _FakeRemoteConfigRepository(useTemplates: false),
        ),
      );

      expect(result, 'fallback-findings');
      expect(template.callCount, 0);
      expect(fallback.callCount, 1);
    });

    test('skips the template when the template ID is empty', () async {
      final template = _FakeResearchPass('template');
      final fallback = _FakeResearchPass('fallback');

      final result = await run(
        build(
          templatePass: template,
          fallbackPass: fallback,
          remoteConfig: _FakeRemoteConfigRepository(researchTemplateId: ''),
        ),
      );

      expect(result, 'fallback-findings');
      expect(template.callCount, 0);
      expect(fallback.callCount, 1);
    });

    test('falls back when the template is not found', () async {
      final template = _FakeResearchPass(
        'template',
        errorToThrow: TravelResearchPassException(
          'Research pass failed.',
          cause: ServerException('Template research-template not found'),
        ),
      );
      final fallback = _FakeResearchPass('fallback');

      final result = await run(
        build(templatePass: template, fallbackPass: fallback),
      );

      expect(result, 'fallback-findings');
      expect(template.callCount, 1);
      expect(fallback.callCount, 1);
      expect(monitoringClient.breadcrumbs, hasLength(1));
      expect(monitoringClient.warningLevels, ['warning']);
    });

    test(
      'reports a fallback once per session, breadcrumbs every time',
      () async {
        TemplateAwareResearchPass failingPass() => build(
          templatePass: _FakeResearchPass(
            'template',
            errorToThrow: ServerException(
              'Template research-template not found',
            ),
          ),
          fallbackPass: _FakeResearchPass('fallback'),
        );

        await run(failingPass());
        await run(failingPass());

        expect(monitoringClient.breadcrumbs, hasLength(2));
        expect(monitoringClient.warningLevels, ['warning']);
      },
    );

    test('does not fall back on other server errors', () async {
      final appCheckError = TravelResearchPassException(
        'Research pass failed.',
        cause: ServerException('App Check token rejected'),
      );
      final template = _FakeResearchPass(
        'template',
        errorToThrow: appCheckError,
      );
      final fallback = _FakeResearchPass('fallback');

      await expectLater(
        () => run(build(templatePass: template, fallbackPass: fallback)),
        throwsA(same(appCheckError)),
      );

      expect(fallback.callCount, 0);
      expect(monitoringClient.breadcrumbs, isEmpty);
      expect(monitoringClient.warningLevels, isEmpty);
    });

    test('does not fall back on non-server errors', () async {
      final template = _FakeResearchPass(
        'template',
        errorToThrow: const TravelResearchPassException('exceeded rounds'),
      );
      final fallback = _FakeResearchPass('fallback');

      await expectLater(
        () => run(build(templatePass: template, fallbackPass: fallback)),
        throwsA(isA<TravelResearchPassException>()),
      );

      expect(fallback.callCount, 0);
    });

    test('propagates a failing fallback after a missing template', () async {
      final template = _FakeResearchPass(
        'template',
        errorToThrow: ServerException('not found'),
      );
      final fallback = _FakeResearchPass(
        'fallback',
        errorToThrow: const TravelResearchPassException('fallback failed'),
      );

      await expectLater(
        () => run(build(templatePass: template, fallbackPass: fallback)),
        throwsA(isA<TravelResearchPassException>()),
      );

      expect(fallback.callCount, 1);
    });
  });

  group('TemplateAwareFormatPass', () {
    TemplateAwareFormatPass build({
      required _FakeFormatPass templatePass,
      required _FakeFormatPass fallbackPass,
      _FakeRemoteConfigRepository? remoteConfig,
    }) {
      return TemplateAwareFormatPass(
        templatePass: templatePass,
        fallbackPass: fallbackPass,
        remoteConfig: remoteConfig ?? _FakeRemoteConfigRepository(),
        errorMonitoring: errorMonitoring,
      );
    }

    Future<TravelDetails> run(TemplateAwareFormatPass pass) {
      return pass.formatResearchFindings(
        userPrompt: '{}',
        researchFindings: 'findings',
        systemPrompt: 'system',
      );
    }

    test('uses the template when the flag is on', () async {
      final template = _FakeFormatPass();
      final fallback = _FakeFormatPass();

      await run(build(templatePass: template, fallbackPass: fallback));

      expect(template.callCount, 1);
      expect(fallback.callCount, 0);
    });

    test('skips the template when the flag is off', () async {
      final template = _FakeFormatPass();
      final fallback = _FakeFormatPass();

      await run(
        build(
          templatePass: template,
          fallbackPass: fallback,
          remoteConfig: _FakeRemoteConfigRepository(useTemplates: false),
        ),
      );

      expect(template.callCount, 0);
      expect(fallback.callCount, 1);
    });

    test('skips the template when the template ID is empty', () async {
      final template = _FakeFormatPass();
      final fallback = _FakeFormatPass();

      await run(
        build(
          templatePass: template,
          fallbackPass: fallback,
          remoteConfig: _FakeRemoteConfigRepository(formatTemplateId: ''),
        ),
      );

      expect(template.callCount, 0);
      expect(fallback.callCount, 1);
    });

    test('falls back when the template is not found', () async {
      final template = _FakeFormatPass(
        errorToThrow: ServerException('Requested entity was not found.'),
      );
      final fallback = _FakeFormatPass();

      final result = await run(
        build(templatePass: template, fallbackPass: fallback),
      );

      expect(result.city.name, 'New York');
      expect(template.callCount, 1);
      expect(fallback.callCount, 1);
      expect(monitoringClient.breadcrumbs, hasLength(1));
      expect(monitoringClient.warningLevels, ['warning']);
    });

    test('does not fall back on other server errors', () async {
      final appCheckError = ServerException('App Check token rejected');
      final template = _FakeFormatPass(errorToThrow: appCheckError);
      final fallback = _FakeFormatPass();

      await expectLater(
        () => run(build(templatePass: template, fallbackPass: fallback)),
        throwsA(same(appCheckError)),
      );

      expect(fallback.callCount, 0);
      expect(monitoringClient.breadcrumbs, isEmpty);
      expect(monitoringClient.warningLevels, isEmpty);
    });

    test('does not fall back on unparsable output', () async {
      final template = _FakeFormatPass(
        errorToThrow: const FormatException('bad json'),
      );
      final fallback = _FakeFormatPass();

      await expectLater(
        () => run(build(templatePass: template, fallbackPass: fallback)),
        throwsA(isA<FormatException>()),
      );

      expect(fallback.callCount, 0);
    });
  });
}
