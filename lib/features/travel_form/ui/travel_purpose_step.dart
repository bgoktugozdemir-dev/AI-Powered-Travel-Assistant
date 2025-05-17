import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_assistant/common/models/travel_purpose.dart';
import 'package:travel_assistant/common/services/travel_purpose_service.dart';
import 'package:travel_assistant/features/travel_form/bloc/travel_form_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// A step in the travel form that allows users to select their travel purposes.
class TravelPurposeStep extends StatefulWidget {
  /// Creates a [TravelPurposeStep] widget.
  const TravelPurposeStep({Key? key}) : super(key: key);

  @override
  State<TravelPurposeStep> createState() => _TravelPurposeStepState();
}

class _TravelPurposeStepState extends State<TravelPurposeStep> {
  @override
  void initState() {
    super.initState();
    // Load travel purposes when the step is initialized
    context.read<TravelFormBloc>().add(const LoadTravelPurposesEvent());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return BlocBuilder<TravelFormBloc, TravelFormState>(
      builder: (context, state) {
        if (state.isTravelPurposesLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        if (state.availableTravelPurposes.isEmpty) {
          return Center(
            child: Text(l10n.noPurposesAvailable),
          );
        }
        
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: state.availableTravelPurposes.map((purpose) {
                    final isSelected = state.selectedTravelPurposes
                        .any((selected) => selected.id == purpose.id);
                    
                    return FilterChip(
                      label: Text(purpose.name),
                      selected: isSelected,
                      avatar: Icon(
                        TravelPurposeService.getIconForPurpose(purpose.icon),
                        size: 18,
                      ),
                      onSelected: (selected) {
                        context.read<TravelFormBloc>().add(
                          ToggleTravelPurposeEvent(purpose: purpose, isSelected: selected)
                        );
                      },
                    );
                  }).toList(),
                ),
                if (state.selectedTravelPurposes.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    l10n.selectedPurposes,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: state.selectedTravelPurposes.map((purpose) {
                      return Chip(
                        label: Text(purpose.name),
                        avatar: Icon(
                          TravelPurposeService.getIconForPurpose(purpose.icon),
                          size: 18,
                        ),
                        onDeleted: () {
                          context.read<TravelFormBloc>().add(
                            ToggleTravelPurposeEvent(purpose: purpose, isSelected: false)
                          );
                        },
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
} 