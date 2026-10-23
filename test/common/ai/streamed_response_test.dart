import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_assistant/common/ai/streamed_response.dart';

GenerateContentResponse _chunk(
  List<Part> parts, {
  FinishReason? finishReason,
}) => GenerateContentResponse([
  Candidate(Content.model(parts), null, null, finishReason, null),
], null);

void main() {
  group('collectStreamedResponse', () {
    test('joins the text of every chunk', () async {
      final response = await collectStreamedResponse(
        Stream.fromIterable([
          _chunk([const TextPart('Hello, ')]),
          _chunk([const TextPart('world')], finishReason: FinishReason.stop),
        ]),
      );

      expect(response.text, 'Hello, world');
      expect(response.candidates.single.finishReason, FinishReason.stop);
    });

    test('keeps function calls from any chunk', () async {
      final response = await collectStreamedResponse(
        Stream.fromIterable([
          _chunk([
            const FunctionCall('getWeather', {'city': 'Vienna'}),
          ]),
          _chunk([
            const FunctionCall('getExchangeRate', {'from': 'TRY'}),
          ]),
        ]),
      );

      expect(response.functionCalls.map((c) => c.name), [
        'getWeather',
        'getExchangeRate',
      ]);
    });

    test('still throws for a candidate blocked mid-stream', () async {
      final response = await collectStreamedResponse(
        Stream.fromIterable([
          _chunk([const TextPart('partial')]),
          _chunk(const [], finishReason: FinishReason.safety),
        ]),
      );

      expect(() => response.text, throwsA(isA<FirebaseAIException>()));
    });

    test('returns no candidates for an empty stream', () async {
      final response = await collectStreamedResponse(const Stream.empty());

      expect(response.candidates, isEmpty);
      expect(response.text, isNull);
    });

    test('propagates a stream error', () async {
      await expectLater(
        collectStreamedResponse(Stream.error(Exception('Load failed'))),
        throwsA(isA<Exception>()),
      );
    });
  });
}
