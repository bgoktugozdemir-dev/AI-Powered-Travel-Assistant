import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:travel_assistant/common/models/response/city.dart';
import 'package:travel_assistant/common/repositories/unsplash_repository_provider.dart';
import 'package:travel_assistant/common/services/unsplash_service.dart';
import 'package:travel_assistant/common/ui/travel_card.dart';
import 'package:travel_assistant/common/utils/logger/logger.dart';

/// A widget that displays information about a city.
class CityCard extends StatefulWidget {
  /// Creates a [CityCard].
  const CityCard({required this.city, super.key});

  /// The city to display information for.
  final City city;

  @override
  State<CityCard> createState() => _CityCardState();
}

class _CityCardState extends State<CityCard> {
  CityImage? _cityImage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCityImage();
  }

  /// Fetches a city image from Unsplash.
  Future<void> _fetchCityImage() async {
    try {
      // Use the existing image URL as a fallback
      if (widget.city.imageUrl.isNotEmpty && !widget.city.imageUrl.contains('placeholder')) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final repository = UnsplashRepositoryProvider.of(context);
      final cityImage = await repository.getCityImage(widget.city.name);
      
      if (mounted) {
        setState(() {
          _cityImage = cityImage;
          _isLoading = false;
        });
      }
    } catch (e) {
      appLogger.e('Error fetching city image: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return TravelCard(
      icon: Icons.location_on,
      title: l10n.cityInformationTitle,
      header: _buildCityImage(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // City Name and Time
          _buildCityNameAndTime(context),

          const SizedBox(height: 8),

          // Crowd Level
          _buildCrowdLevel(context, l10n),

          // Photo attribution if available
          if (_cityImage != null) _buildPhotoAttribution(context, l10n),

          // Weather information if available
          if (widget.city.weather.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            Text(l10n.cityCardWeatherForecastTitle, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _WeatherCards(weathers: widget.city.weather),
          ],
        ],
      ),
    );
  }

  Widget _buildCityImage(BuildContext context) {
    // Use Unsplash image if available, otherwise use the original image URL
    final String imageUrl = _cityImage?.imageUrl ?? widget.city.imageUrl;

    return CachedNetworkImage(
      imageUrl: imageUrl,
      height: 180,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        height: 180,
        width: double.infinity,
        color: Colors.grey[300],
        child: const Center(child: CircularProgressIndicator()),
      ),
      errorWidget: (context, url, error) {
        appLogger.e('Error loading image: $error, URL: $url');
        return Container(
          height: 180,
          width: double.infinity,
          color: Colors.grey[300],
          child: const Center(child: Icon(Icons.image_not_supported, size: 48)),
        );
      },
    );
  }

  Widget _buildPhotoAttribution(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: GestureDetector(
        onTap: () {
          // Open photographer page when clicked
          // In a real app, you would launch a URL here
        },
        child: Text(
          l10n.photoAttributionFormat(
            _cityImage!.photographerName,
          ),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
        ),
      ),
    );
  }

  Widget _buildCityNameAndTime(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text('${widget.city.name}, ${widget.city.country}', style: Theme.of(context).textTheme.titleLarge)),
        if (widget.city.time != null) _buildTimeDifference(context),
      ],
    );
  }

  Widget _buildTimeDifference(BuildContext context) {
    final now = DateTime.now();
    final difference = widget.city.time!.differenceInHours;
    final departureTime = now.toLocal();
    final arrivalTime = departureTime.add(Duration(hours: difference));
    final dayDifference = departureTime.day.compareTo(arrivalTime.day);
    final departureColor = dayDifference < 0 ? Colors.red : null;
    final arrivalColor = dayDifference > 0 ? Colors.red : null;

    return Tooltip(
      message: 'Time difference: ${widget.city.time!.differenceInHours} hours',
      child: Chip(
        label: Row(
          spacing: 4,
          children: [
            Text(
              "${DateFormat('HH:mm').format(departureTime)} (${widget.city.time!.departureTimezone})",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: departureColor),
            ),
            Icon(Icons.arrow_right_alt, size: 16),
            Text(
              "${DateFormat('HH:mm').format(arrivalTime)} (${widget.city.time!.arrivalTimezone})",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: arrivalColor),
            ),
          ],
        ),
        avatar: Icon(Icons.access_time, size: 16),
      ),
    );
  }

  Widget _buildCrowdLevel(BuildContext context, AppLocalizations l10n) {
    return Row(
      children: [
        const Icon(Icons.people, size: 18),
        const SizedBox(width: 8),
        Text('${l10n.cityCardCrowdLevelLabel}: ', style: Theme.of(context).textTheme.bodyMedium),
        Expanded(
          child: LinearProgressIndicator(
            value: widget.city.crowdLevel / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              widget.city.crowdLevel < 30
                  ? Colors.green
                  : widget.city.crowdLevel < 70
                  ? Colors.orange
                  : Colors.red,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('${widget.city.crowdLevel}%'),
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
