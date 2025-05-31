import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travel_assistant/common/models/response/flight_options.dart';
import 'package:travel_assistant/common/ui/travel_card.dart';
import 'package:travel_assistant/l10n/app_localizations.dart';

class FlightOptionsCard extends StatelessWidget {
  const FlightOptionsCard({required this.flightOptions, super.key});

  final FlightOptions flightOptions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return TravelCard(
      icon: Icons.flight,
      title: l10n.flightOptionsTitle,
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
        Expanded(
          child: Text(
            flight.airline,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildFlightBody(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryColor = colorScheme.primary;
    final captionColor = colorScheme.onSurface.withValues(alpha: 0.6);
    final textTheme = theme.textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFlightTimeAndAirport(context, flight.departureTime, flight.departureAirport),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 4,
          children: [
            if (flight.stops > 0)
              Text(
                l10n.stopsLabel(flight.stops),
                style: textTheme.bodyMedium?.copyWith(color: captionColor),
              ),
            Icon(
              Icons.flight,
              color: primaryColor,
            ),
            Text(
              _formatFlightDuration(context, flight.duration, l10n),
              style: textTheme.bodySmall?.copyWith(color: captionColor),
            ),
          ],
        ),
        _buildFlightTimeAndAirport(context, flight.arrivalTime, flight.arrivalAirport, false),
      ],
    );
  }

  Widget _buildFlightTimeAndAirport(BuildContext context, DateTime time, String airport, [bool isDeparture = true]) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme.bodyMedium;

    return Column(
      crossAxisAlignment: isDeparture ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(
          _formatFlightTime(time),
          style: textTheme,
        ),
        Text(
          airport,
          style: textTheme?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
        ),
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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Row(
      spacing: 8,
      children: [
        Expanded(
          child: Text(
            flight.flightNumber,
            style: textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary),
          ),
        ),
        Text(
          _formatMoney(flight.price, flight.currency, l10n),
          textAlign: TextAlign.end,
          style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  String _formatMoney(double price, String currency, AppLocalizations l10n) =>
      NumberFormat.currency(locale: l10n.localeName, symbol: currency).format(price);
}
