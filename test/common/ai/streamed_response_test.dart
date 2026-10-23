import 'package:firebase_ai/firebase_ai.dart';
// UsageMetadata has no public constructor; this parses it as the SDK does.
// ignore: implementation_imports
import 'package:firebase_ai/src/api.dart' show parseUsageMetadata;
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
      final error = Exception('Load failed');

      await expectLater(
        collectStreamedResponse(Stream.error(error)),
        throwsA(same(error)),
      );
    });

    test('reports an unreadable response apart from bad output', () async {
      await expectLater(
        collectStreamedResponse(
          Stream.error(const FormatException('<html>')),
        ),
        throwsA(isA<UnreadableResponseException>()),
      );
    });

    test('reports the timing of a completed request', () async {
      final timings = <StreamedResponseStats>[];

      await collectStreamedResponse(
        Stream.fromIterable([
          _chunk([const TextPart('a')]),
          _chunk([const TextPart('b')]),
        ]),
        onDone: timings.add,
      );

      final timing = timings.single;
      expect(timing.chunkCount, 2);
      expect(timing.failed, isFalse);
      expect(timing.firstChunkMs, isNotNull);
      expect(timing.longestSilenceMs, lessThanOrEqualTo(timing.totalMs));
    });

    test('reports the token usage of the last chunk carrying it', () async {
      final stats = <StreamedResponseStats>[];

      await collectStreamedResponse(
        Stream.fromIterable([
          _chunk([const TextPart('a')]),
          GenerateContentResponse(
            [
              Candidate(
                Content.model([const TextPart('b')]),
                null,
                null,
                FinishReason.stop,
                null,
              ),
            ],
            null,
            usageMetadata: parseUsageMetadata({
              'promptTokenCount': 10,
              'candidatesTokenCount': 20,
              'thoughtsTokenCount': 30,
              'totalTokenCount': 60,
            }),
          ),
        ]),
        onDone: stats.add,
      );

      expect(stats.single.toJson(), containsPair('thoughtsTokens', 30));
      expect(stats.single.promptTokens, 10);
      expect(stats.single.outputTokens, 20);
      expect(stats.single.totalTokens, 60);
    });

    test('reports the timing of a failed request', () async {
      final timings = <StreamedResponseStats>[];

      await expectLater(
        collectStreamedResponse(
          Stream.error(Exception('Load failed')),
          onDone: timings.add,
        ),
        throwsA(isA<Exception>()),
      );

      final timing = timings.single;
      expect(timing.chunkCount, 0);
      expect(timing.failed, isTrue);
      expect(timing.firstChunkMs, isNull);
    });
  });
}
