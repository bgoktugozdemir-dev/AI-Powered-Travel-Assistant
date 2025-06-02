import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_assistant/common/repositories/firebase_remote_config_repository.dart';
import 'package:travel_assistant/common/ui/disclaimer_card.dart';
import 'package:travel_assistant/common/ui/alert_card.dart';
import 'package:travel_assistant/common/utils/helpers/formatters.dart';
import 'package:travel_assistant/features/results/ui/widgets/info_row.dart';
import 'package:travel_assistant/features/travel_form/bloc/travel_form_bloc.dart';
import 'package:travel_assistant/features/travel_form/ui/widgets/travel_form_step_layout.dart';
import 'package:travel_assistant/l10n/app_localizations.dart';

class TravelSummaryStep extends StatefulWidget {
  /// Creates a [TravelSummaryStep].
  const TravelSummaryStep({super.key});

  @override
  State<TravelSummaryStep> createState() => _TravelSummaryStepState();
}

class _TravelSummaryStepState extends State<TravelSummaryStep> {
  Timer? _helpTimer;
  bool _showHelpCard = false;

  @override
  void initState() {
    super.initState();

    final delay = context.read<FirebaseRemoteConfigRepository>().travelSummaryHelpCardDelay;

    // Start the timer to show help card after 15 seconds
    _helpTimer = Timer(
      Duration(seconds: delay),
      () {
        if (mounted) {
          setState(() {
            _showHelpCard = true;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _helpTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<TravelFormBloc, TravelFormState>(
      builder: (context, state) {
        return TravelFormStepLayout(
          children: [
            if (_showHelpCard) ...[
              AlertCard.info(
                content: Text(l10n.summaryStepIntroduction),
              ),
              const SizedBox(height: 24),
            ],
            _buildTravelSummaryCard(context, state, l10n),
            const SizedBox(height: 24),
            DisclaimerCard(
              title: l10n.disclaimerAIMistakesTitle,
              content: l10n.disclaimerAIMistakesContent,
              icon: Icons.warning_amber_rounded,
              iconColor: Colors.orangeAccent,
            ),
            const SizedBox(height: 16),
            DisclaimerCard(
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
              value: '${state.selectedDepartureAirport?.name} (${state.selectedDepartureAirport?.iataCode})',
            ),
            InfoRow(
              icon: Icons.flight_land,
              label: l10n.toLabel,
              value: '${state.selectedArrivalAirport?.name} (${state.selectedArrivalAirport?.iataCode})',
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
}
