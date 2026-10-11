import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_assistant/common/models/response/city.dart';
import 'package:travel_assistant/common/repositories/firebase_remote_config_repository.dart';
import 'package:travel_assistant/common/services/unsplash_service.dart';
import 'package:travel_assistant/features/results/ui/widgets/city_card.dart';
import 'package:travel_assistant/features/results/ui/widgets/unsplash_credit.dart';
import 'package:travel_assistant/l10n/app_localizations.dart';

/// A 1x1 PNG.
const _image =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==';

class _FakeRemoteConfig extends Fake implements FirebaseRemoteConfigRepository {
  _FakeRemoteConfig({required this.showCityView});

  @override
  final bool showCityView;

  @override
  bool get showCityCrowdLevel => true;
}

const _photographer = UnsplashUser(
  name: 'Jane Doe',
  username: 'jane_doe',
  portfolioUrl: null,
);

const _time = TimeDetails(
  departureTimezone: 'Europe/Istanbul',
  arrivalTimezone: 'America/New_York',
  differenceInHours: -7,
);

City _city({TimeDetails? time}) => City(
  name: 'New York',
  country: 'United States',
  crowdLevel: 40,
  time: time,
  weather: const [],
);

Widget _app({
  required bool showCityView,
  required City city,
  String? image,
  UnsplashUser? photographer,
  // Wide enough for the card in the test font, which is wider than real ones.
  double width = 800,
}) {
  return RepositoryProvider<FirebaseRemoteConfigRepository>.value(
    value: _FakeRemoteConfig(showCityView: showCityView),
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: width,
            child: SingleChildScrollView(
              child: CityCard(
                city: city,
                cityImageInBytes: image,
                photographer: photographer,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('CityCard with the city view off', () {
    testWidgets('shows the city name when there is an image', (tester) async {
      await tester.pumpWidget(
        _app(showCityView: false, city: _city(), image: _image),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('New York, United States'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('shows the time difference next to the name', (tester) async {
      await tester.pumpWidget(
        _app(showCityView: false, city: _city(time: _time), image: _image),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('New York, United States'), findsOneWidget);
      expect(find.byType(Chip), findsOneWidget);
    });
  });

  group('CityCard with the city view on', () {
    testWidgets('shows the image with the city and the photo credit', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          showCityView: true,
          city: _city(),
          image: _image,
          photographer: _photographer,
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(Image), findsOneWidget);
      expect(find.text('New York'), findsOneWidget);
      expect(find.byType(UnsplashCredit), findsOneWidget);
    });

    testWidgets('shows no credit without a photographer', (tester) async {
      await tester.pumpWidget(
        _app(showCityView: true, city: _city(), image: _image),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(UnsplashCredit), findsNothing);
    });
  });
}
