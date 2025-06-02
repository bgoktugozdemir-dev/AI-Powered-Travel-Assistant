import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_assistant/common/models/travel_purpose.dart';
import 'package:travel_assistant/common/repositories/firebase_remote_config_repository.dart';
import 'package:travel_assistant/common/utils/analytics/analytics_facade.dart';
import 'package:travel_assistant/features/travel_form/bloc/travel_form_bloc.dart';
import 'package:travel_assistant/features/travel_form/ui/widgets/travel_form_step_layout.dart';
import 'package:travel_assistant/l10n/app_localizations.dart';

/// A step in the travel form that allows users to select their travel purposes.
class TravelPurposeStep extends StatelessWidget {
  /// Creates a [TravelPurposeStep] widget.
  const TravelPurposeStep({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final maximumTravelPurposesCount = context.read<FirebaseRemoteConfigRepository>().maximumTravelPurposes;

    return BlocBuilder<TravelFormBloc, TravelFormState>(
      buildWhen:
          (previous, current) =>
              previous.isTravelPurposesLoading != current.isTravelPurposesLoading ||
              previous.availableTravelPurposes != current.availableTravelPurposes ||
              previous.selectedTravelPurposes != current.selectedTravelPurposes,
      builder: (context, state) {
        if (state.isTravelPurposesLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.availableTravelPurposes.isEmpty) {
          return Center(child: Text(l10n.noPurposesAvailable));
        }

        final isSelectable = state.selectedTravelPurposes.length < maximumTravelPurposesCount;

        return TravelFormStepLayout(
          children: [
            Text(
              l10n.selectTravelPurposes,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.selectTravelPurposesDescription,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  state.availableTravelPurposes.map((purpose) {
                    final isSelected = state.selectedTravelPurposes.any(
                      (selected) => selected.id == purpose.id,
                    );

                    return FilterChip(
                      label: Text(purpose.getLocalizedName(l10n)),
                      selected: isSelected,
                      avatar: Icon(
                        purpose.getIconData(),
                        size: 18,
                      ),
                      showCheckmark: false,
                      onSelected:
                          !isSelected && !isSelectable
                              ? null
                              : (selected) {
                                if (selected) {
                                  context.read<AnalyticsFacade>().logSelectTravelPurpose(purpose.name);
                                } else {
                                  context.read<AnalyticsFacade>().logUnselectTravelPurpose(purpose.name);
                                }

                                context.read<TravelFormBloc>().add(
                                  ToggleTravelPurposeEvent(
                                    purpose: purpose,
                                    isSelected: selected,
                                  ),
                                );
                              },
                      selectedColor: Theme.of(context).colorScheme.primary.withAlpha(160),
                    );
                  }).toList(),
            ),
          ],
        );
      },
    );
  }
}
