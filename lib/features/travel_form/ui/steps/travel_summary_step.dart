import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_assistant/common/utils/helpers/formatters.dart';
import 'package:travel_assistant/features/results/ui/widgets/info_row.dart';
import 'package:travel_assistant/features/travel_form/bloc/travel_form_bloc.dart';
import 'package:travel_assistant/features/travel_form/ui/widgets/travel_form_step_layout.dart';
import 'package:travel_assistant/l10n/app_localizations.dart';

class TravelSummaryStep extends StatelessWidget {
  /// Creates a [TravelSummaryStep].
  const TravelSummaryStep({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<TravelFormBloc, TravelFormState>(
      builder: (context, state) {
        return TravelFormStepLayout(
          children: [
            _buildTravelSummaryCard(context, state, l10n),
            const SizedBox(height: 24),
            _buildDisclaimerCard(
              context,
              title: l10n.disclaimerAIMistakesTitle,
              content: l10n.disclaimerAIMistakesContent,
              icon: Icons.warning_amber_rounded,
              iconColor: Colors.orangeAccent,
            ),
            const SizedBox(height: 16),
            _buildDisclaimerCard(
              context,
              title: l10n.disclaimerLegalTitle,
              content: l10n.disclaimerLegalContent,
              icon: Icons.gavel_rounded,
            ),
          ],
        );
      },
    );
  }

  // Travel Input Summary Card
  Widget _buildTravelSummaryCard(
    BuildContext context,
    TravelFormState state,
    AppLocalizations l10n,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.yourTravelPlan,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            const SizedBox(height: 8),
            InfoRow(
              icon: Icons.flight_takeoff,
              label: l10n.fromLabel,
              value:
                  '${state.selectedDepartureAirport?.name} (${state.selectedDepartureAirport?.iataCode})',
            ),
            InfoRow(
              icon: Icons.flight_land,
              label: l10n.toLabel,
              value:
                  '${state.selectedArrivalAirport?.name} (${state.selectedArrivalAirport?.iataCode})',
            ),
            InfoRow(
              icon: Icons.calendar_today,
              label: l10n.datesLabel,
              value: Formatters.dateRange(state.selectedDateRange, context),
            ),
            InfoRow(
              icon: Icons.flag,
              label: l10n.nationalityLabel,
              value: Formatters.nationalityWithFlag(
                state.selectedNationality?.name ?? '',
                state.selectedNationality?.flagEmoji,
              ),
            ),
            const SizedBox(height: 16),
            if (state.selectedTravelPurposes.isNotEmpty) ...[
              Text(
                l10n.travelPurposesLabel,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children:
                    state.selectedTravelPurposes.map((purpose) {
                      return Chip(
                        label: Text(purpose.name),
                        avatar: const Icon(
                          Icons.check_circle,
                          size: 18,
                          color: Colors.green,
                        ),
                      );
                    }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDisclaimerCard(
    BuildContext context, {
    required String title,
    required String content,
    required IconData icon,
    Color? iconColor,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: Theme.of(context).dividerColor, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color:
                      iconColor ??
                      Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
