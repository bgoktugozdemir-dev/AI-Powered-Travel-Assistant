import 'package:flutter_test/flutter_test.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:travel_assistant/common/utils/error_monitoring/sentry_error_monitoring_client.dart';

class _RecordingTransport implements Transport {
  final List<SentryEvent> events = [];

  @override
  Future<SentryId?> send(SentryEnvelope envelope) async {
    for (final item in envelope.items) {
      final original = item.originalObject;
      if (original is SentryEvent) {
        events.add(original);
      }
    }
    return envelope.header.eventId;
  }
}

SentryEvent _eventWithException(String value) => SentryEvent(
  exceptions: [SentryException(type: 'Error', value: value)],
);

void main() {
  group('SentryErrorMonitoringClient.filterEvent', () {
    test('drops events when sending is disabled', () {
      final event = _eventWithException('anything');

      expect(
        SentryErrorMonitoringClient.filterEvent(event, shouldSend: false),
        isNull,
      );
    });

    test('keeps ordinary events', () {
      final event = _eventWithException('Something else went wrong');

      expect(
        SentryErrorMonitoringClient.filterEvent(event, shouldSend: true),
        same(event),
      );
    });

    test('keeps events without exceptions', () {
      final event = SentryEvent(message: SentryMessage('hello'));

      expect(
        SentryErrorMonitoringClient.filterEvent(event, shouldSend: true),
        same(event),
      );
    });
  });

  group('SentryErrorMonitoringClient.reportError', () {
    late _RecordingTransport transport;
    late SentryErrorMonitoringClient client;

    setUp(() async {
      transport = _RecordingTransport();
      await Sentry.init((options) {
        options
          ..dsn = 'https://public@o0.ingest.sentry.io/0'
          ..transport = transport
          ..sendDefaultPii = false;
      });
      client = SentryErrorMonitoringClient();
    });

    tearDown(() async {
      await Sentry.close();
    });

    test('captures the real exception when a message is the error', () async {
      await client.reportError(
        'Failed to submit travel form.',
        stackTrace: StackTrace.current,
        context: {
          'error': const FormatException('Unexpected character'),
          'model': 'gemini',
        },
      );

      expect(transport.events, hasLength(1));
      final event = transport.events.single;
      final exception = event.exceptions!.single;
      expect(exception.type, 'FormatException');
      expect(exception.value, contains('Unexpected character'));
      expect(event.tags!['report_message'], 'Failed to submit travel form.');
      expect(event.contexts['report'], {
        'message': 'Failed to submit travel form.',
      });
      expect(event.contexts['model'], isNotNull);
      expect(event.contexts.containsKey('error'), isFalse);
      expect(event.level, SentryLevel.error);
    });

    test('captures a directly reported exception unchanged', () async {
      await client.reportError(
        StateError('boom'),
        stackTrace: StackTrace.current,
      );

      final event = transport.events.single;
      expect(event.exceptions!.single.type, 'StateError');
      expect(event.tags?.containsKey('report_message') ?? false, isFalse);
    });

    test('truncates very long report messages in the tag', () async {
      await client.reportError(
        'x' * 500,
        context: {'error': Exception('boom')},
      );

      expect(
        transport.events.single.tags!['report_message']!.length,
        lessThanOrEqualTo(200),
      );
    });
  });
}
