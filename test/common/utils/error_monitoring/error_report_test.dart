import 'package:flutter_test/flutter_test.dart';
import 'package:travel_assistant/common/utils/error_monitoring/error_report.dart';

void main() {
  group('resolveErrorReport', () {
    test('promotes context error to the captured exception', () {
      final cause = const FormatException('bad json');

      final report = resolveErrorReport(
        'Failed to submit travel form.',
        context: {'error': cause, 'searchTerm': 'ist'},
      );

      expect(report.error, same(cause));
      expect(report.message, 'Failed to submit travel form.');
      expect(report.context, {'searchTerm': 'ist'});
    });

    test('does not mutate the caller context', () {
      final context = <String, dynamic>{'error': Exception('x'), 'a': 1};

      resolveErrorReport('msg', context: context);

      expect(context.containsKey('error'), isTrue);
    });

    test('keeps a message-only report as is', () {
      final report = resolveErrorReport(
        'Image URL is empty',
        context: {'url': ''},
      );

      expect(report.error, 'Image URL is empty');
      expect(report.message, isNull);
      expect(report.context, {'url': ''});
    });

    test('keeps a real exception passed directly as is', () {
      final error = StateError('boom');

      final report = resolveErrorReport(error, context: {'a': 1});

      expect(report.error, same(error));
      expect(report.message, isNull);
      expect(report.context, {'a': 1});
    });

    test('ignores a context error when the error is not a message', () {
      final error = StateError('boom');

      final report = resolveErrorReport(
        error,
        context: {'error': Exception('other')},
      );

      expect(report.error, same(error));
      expect(report.context.containsKey('error'), isTrue);
    });

    test('handles a missing context', () {
      final report = resolveErrorReport('msg');

      expect(report.error, 'msg');
      expect(report.context, isEmpty);
    });
  });
}
