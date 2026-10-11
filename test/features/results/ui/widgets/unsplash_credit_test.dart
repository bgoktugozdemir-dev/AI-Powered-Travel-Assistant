import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_assistant/common/services/unsplash_service.dart';
import 'package:travel_assistant/features/results/ui/widgets/unsplash_credit.dart';
import 'package:travel_assistant/l10n/app_localizations.dart';

const _photographer = UnsplashUser(
  name: 'Jane Doe',
  username: 'jane_doe',
  portfolioUrl: null,
);

Widget _app(Widget child, {Locale locale = const Locale('en')}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

/// The text spans of the credit that have a tap recognizer, by their text.
Map<String, VoidCallback?> _links(WidgetTester tester) {
  final links = <String, VoidCallback?>{};
  final richText = tester.widget<RichText>(
    find.descendant(
      of: find.byType(UnsplashCredit),
      matching: find.byType(RichText),
    ),
  );
  richText.text.visitChildren((span) {
    if (span is TextSpan && span.recognizer is TapGestureRecognizer) {
      links[span.text!] = (span.recognizer! as TapGestureRecognizer).onTap;
    }
    return true;
  });
  return links;
}

void main() {
  group('UnsplashLinks', () {
    test('link to the photographer with the UTM parameters', () {
      final uri = UnsplashLinks.profile('jane_doe');

      expect(uri.host, 'unsplash.com');
      expect(uri.path, '/@jane_doe');
      expect(uri.queryParameters, {
        'utm_source': UnsplashLinks.utmSource,
        'utm_medium': 'referral',
      });
    });

    test('link to Unsplash with the UTM parameters', () {
      final uri = UnsplashLinks.home();

      expect(uri.host, 'unsplash.com');
      expect(uri.queryParameters['utm_source'], UnsplashLinks.utmSource);
      expect(uri.queryParameters['utm_medium'], 'referral');
    });
  });

  group('UnsplashCredit', () {
    testWidgets('credits the photographer on Unsplash', (tester) async {
      await tester.pumpWidget(
        _app(const UnsplashCredit(photographer: _photographer)),
      );

      expect(
        find.textContaining('Photo by Jane Doe on Unsplash', findRichText: true),
        findsOneWidget,
      );
    });

    testWidgets('follows the word order of the translation', (tester) async {
      await tester.pumpWidget(
        _app(
          const UnsplashCredit(photographer: _photographer),
          locale: const Locale('tr'),
        ),
      );

      expect(
        find.textContaining('Fotoğraf: Jane Doe / Unsplash', findRichText: true),
        findsOneWidget,
      );
    });

    testWidgets('opens the profile and Unsplash with UTM parameters', (
      tester,
    ) async {
      final opened = <Uri>[];
      await tester.pumpWidget(
        _app(
          UnsplashCredit(
            photographer: _photographer,
            onOpenLink: (uri) async => opened.add(uri),
          ),
        ),
      );

      final links = _links(tester);
      expect(links.keys, unorderedEquals(['Jane Doe', 'Unsplash']));

      links['Jane Doe']!();
      links['Unsplash']!();

      expect(opened, [UnsplashLinks.profile('jane_doe'), UnsplashLinks.home()]);
      for (final uri in opened) {
        expect(uri.queryParameters['utm_source'], UnsplashLinks.utmSource);
        expect(uri.queryParameters['utm_medium'], 'referral');
      }
    });
  });
}
