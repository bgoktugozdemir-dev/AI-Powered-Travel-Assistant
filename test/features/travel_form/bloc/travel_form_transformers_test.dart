import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:travel_assistant/features/travel_form/bloc/travel_form_transformers.dart';

// `testWidgets` runs on a fake clock, so `tester.pump(duration)` moves time
// forward without waiting. These tests use it only for the clock.
void main() {
  group('debounceRestartable', () {
    late StreamController<String> input;
    late List<String> mapped;
    late List<String> output;

    // The transformer under test, wired the way `Bloc.on` wires it: the
    // mapper stands in for the event handler.
    void listen({Duration? duration}) {
      final transformer = duration == null
          ? debounceRestartable<String>()
          : debounceRestartable<String>(duration);
      transformer(input.stream, (event) async* {
        mapped.add(event);
        yield event;
      }).listen(output.add);
    }

    setUp(() {
      input = StreamController<String>();
      mapped = [];
      output = [];
    });

    tearDown(() => input.close());

    testWidgets('runs the handler once for a burst of events', (tester) async {
      listen();

      input.add('ist');
      await tester.pump(const Duration(milliseconds: 100));
      input.add('ista');
      await tester.pump(const Duration(milliseconds: 100));
      input.add('istan');

      // The handler must not run while the user is still typing.
      await tester.pump(const Duration(milliseconds: 299));
      expect(mapped, isEmpty);

      await tester.pump(const Duration(milliseconds: 1));
      expect(mapped, ['istan']);
      expect(output, ['istan']);
    });

    testWidgets('runs the handler again after a pause', (tester) async {
      listen();

      input.add('ist');
      await tester.pump(searchDebounceDuration);
      input.add('istan');
      await tester.pump(searchDebounceDuration);

      expect(mapped, ['ist', 'istan']);
    });

    testWidgets('debounces the input, not the handler output', (tester) async {
      // `switchMap(handler).debounceTime(d)` would run the handler for every
      // event immediately. Guard against that order coming back.
      listen();

      input
        ..add('a')
        ..add('ab')
        ..add('abc');
      await tester.pump(const Duration(milliseconds: 10));
      expect(mapped, isEmpty);

      await tester.pump(searchDebounceDuration);
      expect(mapped, ['abc']);
    });

    testWidgets('honors a custom duration', (tester) async {
      listen(duration: const Duration(milliseconds: 50));

      input.add('x');
      await tester.pump(const Duration(milliseconds: 50));

      expect(mapped, ['x']);
    });

    testWidgets('drops the result of a handler a newer event replaced', (
      tester,
    ) async {
      final results = <String>[];
      debounceRestartable<String>()(input.stream, (event) async* {
        await Future<void>.delayed(const Duration(milliseconds: 500));
        yield event;
      }).listen(results.add);

      input.add('first');
      await tester.pump(searchDebounceDuration); // handler for 'first' starts
      input.add('second');
      await tester.pump(searchDebounceDuration); // 'second' replaces it
      await tester.pump(const Duration(seconds: 1));

      expect(results, ['second']);
    });
  });
}
