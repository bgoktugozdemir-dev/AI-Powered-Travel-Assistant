import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_assistant/features/startup/ui/startup_error_app.dart';
import 'package:travel_assistant/l10n/app_localizations_en.dart';
import 'package:travel_assistant/l10n/app_localizations_tr.dart';

void main() {
  final en = AppLocalizationsEn();
  final tr = AppLocalizationsTr();

  testWidgets('explains the failure in English and offers a retry', (
    tester,
  ) async {
    await tester.pumpWidget(StartupErrorApp(onRetry: () async {}));
    await tester.pumpAndSettle();

    expect(find.text(en.startupErrorTitle), findsOneWidget);
    expect(find.text(en.startupErrorMessage), findsOneWidget);
    expect(find.text(en.startupErrorRetry), findsOneWidget);
  });

  testWidgets('is localized', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('tr')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(StartupErrorApp(onRetry: () async {}));
    await tester.pumpAndSettle();

    expect(find.text(tr.startupErrorTitle), findsOneWidget);
    expect(find.text(tr.startupErrorRetry), findsOneWidget);
    expect(tr.startupErrorTitle, isNot(en.startupErrorTitle));
  });

  testWidgets('retries once per tap and accepts another tap afterwards', (
    tester,
  ) async {
    var retries = 0;
    var pending = Completer<void>();
    await tester.pumpWidget(
      StartupErrorApp(
        onRetry: () {
          retries++;
          return pending.future;
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(en.startupErrorRetry));
    await tester.pump();
    // The button is disabled while the retry runs.
    await tester.tap(find.text(en.startupErrorRetry), warnIfMissed: false);
    await tester.pump();
    expect(retries, 1);

    // The retry failed and the same screen is still shown.
    pending.complete();
    await tester.pumpAndSettle();
    pending = Completer<void>();

    await tester.tap(find.text(en.startupErrorRetry));
    await tester.pump();
    expect(retries, 2);

    pending.complete();
    await tester.pumpAndSettle();
  });
}
