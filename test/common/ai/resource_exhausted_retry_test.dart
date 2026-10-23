import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_assistant/common/ai/resource_exhausted_retry.dart';
import 'package:travel_assistant/common/utils/error_monitoring/error_monitoring_facade.dart';

void main() {
  const errorMonitoring = ErrorMonitoringFacade([]);
  final resourceExhausted = ServerException(
    'Resource exhausted. Please try again later.',
  );

  group('isResourceExhaustedError', () {
    test('matches a 429 from the backend', () {
      expect(isResourceExhaustedError(resourceExhausted), isTrue);
      expect(isResourceExhaustedError(QuotaExceeded('quota')), isTrue);
    });

    test('ignores other errors', () {
      expect(isResourceExhaustedError(ServerException('not found')), isFalse);
      expect(isResourceExhaustedError(Exception('Load failed')), isFalse);
    });
  });

  group('retryOnResourceExhausted', () {
    test('retries a 429 with growing delays until it succeeds', () async {
      final delays = <Duration>[];
      var calls = 0;

      final result = await retryOnResourceExhausted(
        () async {
          calls++;
          if (calls < 3) {
            throw resourceExhausted;
          }
          return 'ok';
        },
        errorMonitoring: errorMonitoring,
        requestName: 'test',
        wait: (delay) async => delays.add(delay),
      );

      expect(result, 'ok');
      expect(calls, 3);
      expect(delays, const [Duration(seconds: 2), Duration(seconds: 4)]);
    });

    test('gives up after the last retry', () async {
      var calls = 0;

      await expectLater(
        retryOnResourceExhausted<String>(
          () async {
            calls++;
            throw resourceExhausted;
          },
          errorMonitoring: errorMonitoring,
          requestName: 'test',
          wait: (_) async {},
        ),
        throwsA(same(resourceExhausted)),
      );
      expect(calls, 4);
    });

    test('does not retry other errors', () async {
      final error = ServerException('Firebase App Check token is invalid.');
      var calls = 0;

      await expectLater(
        retryOnResourceExhausted<String>(
          () async {
            calls++;
            throw error;
          },
          errorMonitoring: errorMonitoring,
          requestName: 'test',
          wait: (_) async {},
        ),
        throwsA(same(error)),
      );
      expect(calls, 1);
    });
  });
}
