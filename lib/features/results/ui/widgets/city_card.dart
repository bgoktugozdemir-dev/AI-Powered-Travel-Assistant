import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_assistant/common/utils/helpers/formatters.dart';
import 'package:travel_assistant/common/models/response/city.dart';
import 'package:travel_assistant/common/repositories/firebase_remote_config_repository.dart';
import 'package:travel_assistant/common/ui/travel_card.dart';
import 'package:travel_assistant/l10n/app_localizations.dart';

abstract class _Constants {
  static const double weatherCardHeight = 120.0;
  static const double weatherCardMaxHeight = 140.0;
  static const double weatherCardMinHeight = 100.0;
  static const double smallScreenWidth = 600.0;
  static const double mediumScreenWidth = 1200.0;
  static const double cityImageMaxHeight = 300.0;
  static const double crowdLevelBarHeightMultiplier = 0.025;
}

/// A widget that displays information about a city.
class CityCard extends StatelessWidget {
  /// Creates a [CityCard].
  const CityCard({
    required this.city,
    required this.cityImageInBytes,
    super.key,
  });

  /// The city to display information for.
  final City city;

  /// The city image.
  final String? cityImageInBytes;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final firebaseRemoteConfigRepository = context.read<FirebaseRemoteConfigRepository>();

    return TravelCard(
      icon: Icons.location_on,
      title: l10n.cityInformationTitle,
      header: firebaseRemoteConfigRepository.showCityView && cityImageInBytes != null ? _buildCityImage(context) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // City Name and Time
          if (!firebaseRemoteConfigRepository.showCityView && cityImageInBytes != null) ...[
            _buildCityNameAndTime(context),
          ],
          // Weather information if available
          if (city.weather.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              l10n.cityCardWeatherForecastTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _WeatherCards(weathers: city.weather),
          ],
        ],
      ),
    );
  }

  /// Gets a dynamic color based on crowd level percentage
  Color _getCrowdLevelColor(int crowdLevel) {
    if (crowdLevel <= 20) {
      // Very low crowd: Deep green
      return Colors.green.shade700;
    } else if (crowdLevel <= 40) {
      // Low crowd: Light green to yellow-green
      final t = (crowdLevel - 20) / 20; // 0.0 to 1.0
      return Color.lerp(Colors.green.shade500, Colors.lightGreen, t)!;
    } else if (crowdLevel <= 60) {
      // Medium crowd: Yellow-green to orange
      final t = (crowdLevel - 40) / 20; // 0.0 to 1.0
      return Color.lerp(Colors.lightGreen, Colors.orange.shade600, t)!;
    } else if (crowdLevel <= 80) {
      // High crowd: Orange to red-orange
      final t = (crowdLevel - 60) / 20; // 0.0 to 1.0
      return Color.lerp(Colors.orange.shade600, Colors.deepOrange, t)!;
    } else {
      // Very high crowd: Deep red
      return Colors.red.shade700;
    }
  }

  Widget _buildCityImage(BuildContext context) {
    final screenHeight = MediaQuery.maybeSizeOf(context)?.height;
    final imageHeight = screenHeight != null ? screenHeight * 0.4 : _Constants.cityImageMaxHeight;
    final crowdLevelBarHeight = imageHeight * _Constants.crowdLevelBarHeightMultiplier;
    final crowdLevelColor = _getCrowdLevelColor(city.crowdLevel);

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: imageHeight,
      ),
      child: Image.memory(
        base64Decode(cityImageInBytes!),
        fit: BoxFit.cover,
        width: double.infinity,
        frameBuilder: (context, widget, frame, wasSynchronouslyLoaded) {
          return Stack(
            children: [
              widget,
              // Black gradient overlay for better text visibility
              Positioned.fill(
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.center,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black87,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: LinearProgressIndicator(
                  minHeight: crowdLevelBarHeight,
                  value: city.crowdLevel / 100,
                  backgroundColor: Colors.grey.shade300.withValues(alpha: 0.25),
                  valueColor: AlwaysStoppedAnimation<Color>(crowdLevelColor),
                ),
              ),
              Positioned(
                left: 8,
                right: 8,
                bottom: crowdLevelBarHeight + 8,
                child: _buildCityNameOnImage(context, crowdLevelColor),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCityNameOnImage(BuildContext context, Color crowdLevelColor) {
    final l10n = AppLocalizations.of(context);

    return Row(
      spacing: 8,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              city.country,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.white),
            ),
            Text(
              city.name,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.white),
            ),
          ],
        ),
        if (context.read<FirebaseRemoteConfigRepository>().showCityCrowdLevel)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: crowdLevelColor.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: crowdLevelColor, width: 1),
            ),
            child: Text(
              "${l10n.crowdLevelLabel} ${Formatters.crowdLevel(city.crowdLevel, l10n.localeName)}",
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    offset: const Offset(1, 1),
                    blurRadius: 2,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCityNameAndTime(BuildContext context) {
    return Wrap(
      direction: Axis.horizontal,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      children: [
        Expanded(
          child: Text(
            Formatters.cityCountry(city.name, city.country),
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        if (city.time != null) _buildTimeDifference(context),
      ],
    );
  }

  Widget _buildTimeDifference(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final difference = city.time!.differenceInHours;
    final departureTime = now.toLocal();
    final arrivalTime = departureTime.add(Duration(hours: difference));
    final dayDifference = departureTime.day.compareTo(arrivalTime.day);
    final departureColor = dayDifference < 0 ? Colors.red : null;
    final arrivalColor = dayDifference > 0 ? Colors.red : null;

    return Tooltip(
      message: Formatters.timeDifference(city.time!.differenceInHours, l10n),
      child: Chip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            Text(
              Formatters.timezoneTime(
                departureTime,
                city.time!.departureTimezone,
              ),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: departureColor),
            ),
            Icon(Icons.arrow_right_alt, size: 16),
            Text(
              Formatters.timezoneTime(arrivalTime, city.time!.arrivalTimezone),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: arrivalColor),
            ),
          ],
        ),
        avatar: Icon(Icons.access_time, size: 16),
      ),
    );
  }
}

class _WeatherCards extends StatelessWidget {
  const _WeatherCards({required this.weathers});

  final List<Weather> weathers;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final height =
            screenWidth < _Constants.smallScreenWidth
                ? _Constants.weatherCardHeight
                : (screenWidth < _Constants.mediumScreenWidth
                    ? _Constants.weatherCardMaxHeight
                    : _Constants.weatherCardMinHeight);

        return SizedBox(
          height: height,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: weathers.length,
            itemBuilder: (context, index) => _WeatherCard(weather: weathers[index]),
          ),
        );
      },
    );
  }
}

class _WeatherCard extends StatelessWidget {
  const _WeatherCard({required this.weather});

  final Weather weather;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              Formatters.shortDate(DateTime.parse(weather.date)),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Icon(
              icon,
              size: 28,
              color: Theme.of(context).colorScheme.secondary,
            ),
            Text(
              '${weather.temperature}°C',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  IconData get icon => switch (weather.weather.toLowerCase()) {
    'sunny' => Icons.wb_sunny,
    'cloudy' => Icons.cloud,
    'rainy' => Icons.water_drop,
    'snowy' => Icons.ac_unit,
    _ => Icons.cloud,
  };
}
