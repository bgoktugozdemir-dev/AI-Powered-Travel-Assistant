import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:travel_assistant/common/error/network_error.dart';

/// Stands in for exceptions from packages the app does not depend on
/// directly. Only their `toString()` is relied upon, so the fake mimics it.
class _FakeError implements Exception {
  _FakeError(this._description);

  final String _description;

  @override
  String toString() => _description;
}

void main() {
  group('isNetworkInterruption', () {
    test('matches http ClientException from a suspended browser tab', () {
      expect(
        isNetworkInterruption(
          _FakeError('ClientException: Load failed, uri=https://example.com'),
        ),
        isTrue,
      );
      expect(
        isNetworkInterruption(
          _FakeError('ClientException: Failed to fetch, uri=https://a.b'),
        ),
        isTrue,
      );
    });

    test('matches ClientException wrapping a socket error', () {
      expect(
        isNetworkInterruption(
          _FakeError(
            'ClientException with SocketException: Connection reset by peer',
          ),
        ),
        isTrue,
      );
    });

    test('matches SocketException', () {
      expect(
        isNetworkInterruption(
          _FakeError('SocketException: Failed host lookup'),
        ),
        isTrue,
      );
    });

    test('matches TimeoutException', () {
      expect(isNetworkInterruption(TimeoutException('slow')), isTrue);
    });

    test('does not match unrelated errors', () {
      expect(isNetworkInterruption(const FormatException('bad')), isFalse);
      expect(isNetworkInterruption(StateError('x')), isFalse);
      expect(isNetworkInterruption(Exception('Server Error [500]')), isFalse);
      expect(isNetworkInterruption(null), isFalse);
    });
  });
}
