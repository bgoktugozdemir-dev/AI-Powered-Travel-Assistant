import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:travel_assistant/features/travel_form/bloc/travel_form_bloc.dart';

class TravelSummaryStep extends StatelessWidget {
  /// Creates a [TravelSummaryStep].
  const TravelSummaryStep({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<TravelFormBloc, TravelFormState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildTravelSummaryCard(context, state, l10n),
              // TODO: Add disclaimer
            ],
          ),
        );
      },
    );
  }

  // Travel Input Summary Card
  Widget _buildTravelSummaryCard(BuildContext context, TravelFormState state, AppLocalizations l10n) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.yourTravelPlan, style: Theme.of(context).textTheme.titleLarge),
            const Divider(),
            const SizedBox(height: 8),
            _buildInfoRow(
              context,
              l10n.fromLabel,
              '${state.selectedDepartureAirport?.name} (${state.selectedDepartureAirport?.iataCode})',
              Icons.flight_takeoff,
            ),
            _buildInfoRow(
              context,
              l10n.toLabel,
              '${state.selectedArrivalAirport?.name} (${state.selectedArrivalAirport?.iataCode})',
              Icons.flight_land,
            ),
            _buildInfoRow(
              context,
              l10n.datesLabel,
              _formatDateRange(state.selectedDateRange, context),
              Icons.calendar_today,
            ),
            _buildInfoRow(
              context,
              l10n.nationalityLabel,
              '${state.selectedNationality?.flagEmoji ?? ''} ${state.selectedNationality?.name}',
              Icons.flag,
            ),
            const SizedBox(height: 16),
            Text(l10n.travelPurposesLabel, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children:
                  state.selectedTravelPurposes.map((purpose) {
                    return Chip(
                      label: Text(purpose.name),
                      avatar: const Icon(Icons.check_circle, size: 18, color: Colors.green),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build an info row with icon
  Widget _buildInfoRow(BuildContext context, String label, String value, IconData icon, {Color? iconColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: iconColor ?? Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text(label, style: const TextStyle(fontWeight: FontWeight.bold)), Text(value)],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to format date range
  String _formatDateRange(DateTimeRange? dateRange, BuildContext context) {
    if (dateRange == null) {
      return 'No dates selected';
    }

    final dateFormat = DateFormat.yMMMd(Localizations.localeOf(context).languageCode);
    final startDate = dateFormat.format(dateRange.start);
    final endDate = dateFormat.format(dateRange.end);
    return '$startDate - $endDate';
  }
}
