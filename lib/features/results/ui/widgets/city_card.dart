import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travel_assistant/common/models/response/city.dart';
import 'package:travel_assistant/common/ui/travel_card.dart';

class CityCard extends StatelessWidget {
  const CityCard({required this.city, super.key});

  final City city;

  @override
  Widget build(BuildContext context) {
    return TravelCard(
      icon: Icons.location_on,
      title: 'City',
      header: _buildCityImage(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // City Name and Time
          _buildCityNameAndTime(context),

          const SizedBox(height: 8),

          // Crowd Level
          _buildCrowdLevel(context),

          // Weather information if available
          if (city.weather.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            Text('Weather Forecast', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _WeatherCards(weathers: city.weather),
          ],
        ],
      ),
    );
  }

  Widget _buildCityImage(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: city.imageUrl,
      height: 180,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
      errorWidget: (context, url, error) {
        return Container(
          height: 180,
          width: double.infinity,
          color: Colors.grey[300],
          child: const Center(child: Icon(Icons.image_not_supported, size: 48)),
        );
      },
    );
  }

  Widget _buildCityNameAndTime(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text('${city.name}, ${city.country}', style: Theme.of(context).textTheme.titleLarge)),
        if (city.time != null) _buildTimeDifference(context),
      ],
    );
  }

  Widget _buildTimeDifference(BuildContext context) {
    final now = DateTime.now();
    final difference = city.time!.differenceInHours;
    final departureTime = now.toLocal();
    final arrivalTime = departureTime.add(Duration(hours: difference));
    final dayDifference = departureTime.day.compareTo(arrivalTime.day);
    final departureColor = dayDifference < 0 ? Colors.red : null;
    final arrivalColor = dayDifference > 0 ? Colors.red : null;

    return Tooltip(
      message: 'Time difference: ${city.time!.differenceInHours} hours',
      child: Chip(
        label: Row(
          spacing: 4,
          children: [
            Text(
              "${DateFormat('HH:mm').format(departureTime)} (${city.time!.departureTimezone})",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: departureColor),
            ),
            Icon(Icons.arrow_right_alt, size: 16),
            Text(
              "${DateFormat('HH:mm').format(arrivalTime)} (${city.time!.arrivalTimezone})",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: arrivalColor),
            ),
          ],
        ),
        avatar: Icon(Icons.access_time, size: 16),
      ),
    );
  }

  Widget _buildCrowdLevel(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.people, size: 18),
        const SizedBox(width: 8),
        Text('Crowd Level: ', style: Theme.of(context).textTheme.bodyMedium),
        Expanded(
          child: LinearProgressIndicator(
            value: city.crowdLevel / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              city.crowdLevel < 30
                  ? Colors.green
                  : city.crowdLevel < 70
                  ? Colors.orange
                  : Colors.red,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('${city.crowdLevel}%'),
      ],
    );
  }
}

class _WeatherCards extends StatelessWidget {
  const _WeatherCards({required this.weathers});

  final List<Weather> weathers;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.width / 5;

    return SizedBox(
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: weathers.length,
        itemBuilder: (context, index) => _WeatherCard(weather: weathers[index]),
      ),
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
              DateFormat('MMM d').format(DateTime.parse(weather.date)),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Icon(icon, size: 28, color: Theme.of(context).colorScheme.secondary),
            Text('${weather.temperature}°C', style: Theme.of(context).textTheme.bodyMedium),
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
