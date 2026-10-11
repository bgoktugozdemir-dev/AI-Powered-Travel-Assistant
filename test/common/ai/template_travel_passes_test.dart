import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_assistant/common/ai/function_call_dispatcher.dart';
import 'package:travel_assistant/common/ai/template_travel_passes.dart';
import 'package:travel_assistant/common/ai/travel_research_pass.dart';
import 'package:travel_assistant/common/ai/travel_template_client.dart';
import 'package:travel_assistant/common/models/response/open_meteo_response.dart';
import 'package:travel_assistant/common/repositories/currency_repository.dart';
import 'package:travel_assistant/common/repositories/weather_repository.dart';
import 'package:travel_assistant/common/utils/error_monitoring/error_monitoring_facade.dart';

import 'travel_details_fixture.dart';

class _FakeCurrencyRepository implements CurrencyRepository {
  @override
  Future<double?> getExchangeRate(String from, String to) async => 39.25;
}

class _FakeWeatherRepository implements WeatherRepository {
  @override
  Future<OpenMeteoResponse?> getWeatherForecast({
    required double latitude,
    required double longitude,
    required DateTime startDate,
    required DateTime endDate,
    String timezone = 'auto',
  }) async => null;
}

GenerateContentResponse _response(List<Part> parts) {
  return GenerateContentResponse(
    [Candidate(Content.model(parts), null, null, null, null)],
    null,
  );
}

GenerateContentResponse _textResponse(String text) =>
    _response([TextPart(text)]);

GenerateContentResponse _exchangeRateCallResponse() => _response([
  const FunctionCall('get_exchange_rate', {
    'base_currency': 'USD',
    'target_currency': 'TRY',
  }),
]);

class _FakeTemplateChat implements TravelTemplateChat {
  _FakeTemplateChat(this._responses);

  final List<Object> _responses;
  final List<Content> sentMessages = [];

  @override
  Future<GenerateContentResponse> sendMessage(Content message) async {
    sentMessages.add(message);
    final next = _responses.removeAt(0);
    if (next is GenerateContentResponse) {
      return next;
    }
    throw next;
  }
}

class _FakeTemplateClient implements TravelTemplateClient {
  _FakeTemplateClient({this.chat, List<Object>? generateResponses})
    : _generateResponses = generateResponses ?? [];

  final _FakeTemplateChat? chat;
  final List<Object> _generateResponses;

  String? startedTemplateId;
  Map<String, Object?>? startedInputs;
  final List<String> generatedTemplateIds = [];
  final List<Map<String, Object?>> generatedInputs = [];

  @override
  TravelTemplateChat startChat(
    String templateId, {
    required Map<String, Object?> inputs,
  }) {
    startedTemplateId = templateId;
    startedInputs = inputs;
    return chat!;
  }

  @override
  Future<GenerateContentResponse> generateContent(
    String templateId, {
    required Map<String, Object?> inputs,
  }) async {
    generatedTemplateIds.add(templateId);
    generatedInputs.add(inputs);
    final next = _generateResponses.removeAt(0);
    if (next is GenerateContentResponse) {
      return next;
    }
    throw next;
  }
}

void main() {
  const errorMonitoring = ErrorMonitoringFacade([]);

  group('TemplateTravelResearchPass', () {
    TemplateTravelResearchPass build(_FakeTemplateClient client) {
      return TemplateTravelResearchPass(
        templateClient: client,
        dispatcher: FunctionCallDispatcher(
          currencyRepository: _FakeCurrencyRepository(),
          weatherRepository: _FakeWeatherRepository(),
        ),
        templateId: () => 'research-template',
        errorMonitoring: errorMonitoring,
      );
    }

    test('starts the template chat with the trip JSON as input', () async {
      final chat = _FakeTemplateChat([_textResponse('findings')]);
      final client = _FakeTemplateClient(chat: chat);

      final result = await build(client).generateResearchFindings(
        userPrompt: '{"nationality":"TR"}',
        systemPrompt: 'ignored system prompt',
      );

      expect(result, 'findings');
      expect(client.startedTemplateId, 'research-template');
      expect(client.startedInputs, {
        'travel_information': '{"nationality":"TR"}',
      });
      expect(chat.sentMessages, hasLength(1));
    });

    test('answers function calls and returns the final text', () async {
      final chat = _FakeTemplateChat([
        _exchangeRateCallResponse(),
        _textResponse('findings with rate'),
      ]);
      final client = _FakeTemplateClient(chat: chat);

      final result = await build(client).generateResearchFindings(
        userPrompt: '{}',
        systemPrompt: '',
      );

      expect(result, 'findings with rate');
      expect(chat.sentMessages, hasLength(2));
      final functionResponse =
          chat.sentMessages.last.parts.single as FunctionResponse;
      expect(functionResponse.name, 'get_exchange_rate');
      expect(functionResponse.response['exchange_rate'], 39.25);
    });

    test('fails when the model keeps calling functions', () async {
      final chat = _FakeTemplateChat(
        List.generate(20, (_) => _exchangeRateCallResponse()),
      );
      final client = _FakeTemplateClient(chat: chat);

      await expectLater(
        () => build(client).generateResearchFindings(
          userPrompt: '{}',
          systemPrompt: '',
        ),
        throwsA(isA<TravelResearchPassException>()),
      );
    });

    test('wraps template errors keeping the cause', () async {
      final serverError = ServerException('template not found');
      final chat = _FakeTemplateChat([serverError]);
      final client = _FakeTemplateClient(chat: chat);

      await expectLater(
        () => build(client).generateResearchFindings(
          userPrompt: '{}',
          systemPrompt: '',
        ),
        throwsA(
          isA<TravelResearchPassException>().having(
            (e) => e.cause,
            'cause',
            same(serverError),
          ),
        ),
      );
    });
  });

  group('TemplateTravelFormatPass', () {
    TemplateTravelFormatPass build(_FakeTemplateClient client) {
      return TemplateTravelFormatPass(
        templateClient: client,
        templateId: () => 'format-template',
        errorMonitoring: errorMonitoring,
      );
    }

    Future<Object> run(TemplateTravelFormatPass pass) {
      return pass.formatResearchFindings(
        userPrompt: '{"nationality":"TR"}',
        researchFindings: 'the findings',
        systemPrompt: 'ignored system prompt',
      );
    }

    test('passes trip JSON and findings and parses the response', () async {
      final client = _FakeTemplateClient(
        generateResponses: [_textResponse(travelDetailsFixtureText())],
      );

      await run(build(client));

      expect(client.generatedTemplateIds, ['format-template']);
      expect(client.generatedInputs.single, {
        'travel_information': '{"nationality":"TR"}',
        'research_findings': 'the findings',
      });
    });

    test('retries unparsable output', () async {
      final client = _FakeTemplateClient(
        generateResponses: [
          _textResponse('not json'),
          _textResponse(travelDetailsFixtureText()),
        ],
      );

      await run(build(client));

      expect(client.generatedInputs, hasLength(2));
    });

    test('gives up after repeated unparsable output', () async {
      final client = _FakeTemplateClient(
        generateResponses: [
          _textResponse('not json'),
          _textResponse('still not json'),
          _textResponse('nope'),
        ],
      );

      await expectLater(() => run(build(client)), throwsFormatException);
      expect(client.generatedInputs, hasLength(3));
    });

    test('rethrows server errors without retrying', () async {
      final serverError = ServerException('template not found');
      final client = _FakeTemplateClient(generateResponses: [serverError]);

      await expectLater(
        () => run(build(client)),
        throwsA(same(serverError)),
      );
      expect(client.generatedInputs, hasLength(1));
    });
  });
}
