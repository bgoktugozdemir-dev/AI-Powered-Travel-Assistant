import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travel_assistant/common/models/response/flight_options.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:travel_assistant/common/ui/travel_card.dart';

class FlightOptionsCard extends StatelessWidget {
  const FlightOptionsCard({required this.flightOptions, super.key});

  final FlightOptions flightOptions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return TravelCard(
      icon: Icons.flight,
      title: 'Flight Options',
      child: Column(
        spacing: 16,
        children: [
          // Cheapest Option
          _buildFlightOptions(context, l10n.cheapestOptionTitle, flightOptions.cheapest, l10n),

          // Comfortable Option
          _buildFlightOptions(context, l10n.comfortableOptionTitle, flightOptions.comfortable, l10n),

          // Recommended Option
          if (flightOptions.recommended != null)
            _buildFlightOptions(context, l10n.recommendedOptionTitle, flightOptions.recommended!, l10n),
        ],
      ),
    );
  }

  Widget _buildFlightOptions(BuildContext context, String title, FlightOption flightOption, AppLocalizations l10n) {
    return Column(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        _FlightCard(flight: flightOption.departure, isOutbound: true),
        _FlightCard(flight: flightOption.arrival, isOutbound: false),
      ],
    );
  }
}

class _FlightCard extends StatelessWidget {
  const _FlightCard({required this.flight, required this.isOutbound});

  final Flight flight;
  final bool isOutbound;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      elevation: 2,
      color: Theme.of(context).cardColor.withValues(alpha: 0.8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            _buildFlightHeader(context, l10n),
            const Divider(),
            _buildFlightBody(context, l10n),
            const Divider(),
            _buildFlightFooter(context, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildFlightHeader(BuildContext context, AppLocalizations l10n) {
    final icon = isOutbound ? Icons.flight_takeoff : Icons.flight_land;
    final text = isOutbound ? l10n.outboundFlightLabel : l10n.returnFlightLabel;
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: 18),
        const SizedBox(width: 8),
        Text(text, style: Theme.of(context).textTheme.titleSmall),
        const Spacer(),
        Text(
          '${flight.airline} - ${flight.flightNumber}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildFlightBody(BuildContext context, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_formatFlightTime(flight.departureTime)),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.flight),
            Text(
              _formatFlightDuration(context, flight.duration, l10n),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.secondary),
            ),
          ],
        ),
        Text(_formatFlightTime(flight.arrivalTime)),
      ],
    );
  }

  String _formatFlightTime(DateTime time) => DateFormat('MMM d, HH:mm').format(time);

  String _formatFlightDuration(BuildContext context, Duration duration, AppLocalizations l10n) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    return l10n.flightDurationFormat(hours, minutes);
  }

  Widget _buildFlightFooter(BuildContext context, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Visibility(visible: flight.stops > 0, child: Text(l10n.stopsLabel(flight.stops))),
        Text(
          _formatMoney(flight.price, flight.currency, l10n),
          textAlign: TextAlign.end,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  String _formatMoney(double price, String currency, AppLocalizations l10n) {
    final format = NumberFormat.currency(locale: l10n.localeName, symbol: currency);
    return format.format(price);
  }
}
