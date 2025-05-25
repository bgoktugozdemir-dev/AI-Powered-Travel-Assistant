import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:travel_assistant/common/utils/logger/logger.dart';
import 'package:travel_assistant/features/travel_form/bloc/travel_form_bloc.dart';

class TravelFormTravelDatesStep extends StatelessWidget {
  const TravelFormTravelDatesStep({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dateFormat = DateFormat.yMMMd(l10n.localeName); // Use locale for date format
    final bloc = context.read<TravelFormBloc>();
    String selectedDatesText = '';

    if (bloc.state.selectedDateRange == null) {
      selectedDatesText = l10n.noDatesSelected;
    } else {
      final startDate = dateFormat.format(bloc.state.selectedDateRange!.start);
      final endDate = dateFormat.format(bloc.state.selectedDateRange!.end);
      selectedDatesText = l10n.selectedDatesLabel(startDate, endDate);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(l10n.travelDatesStepTitle, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 24),
        BlocBuilder<TravelFormBloc, TravelFormState>(
          buildWhen: (previous, current) => previous.selectedDateRange != current.selectedDateRange,
          builder: (context, state) {
            return Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.calendar_month),
                label: Text(l10n.selectDatesButtonLabel),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                onPressed: () async {
                  appLogger.i("'Select Travel Dates' button pressed.");
                  final initialDateRange =
                      state.selectedDateRange ??
                      DateTimeRange(start: DateTime.now(), end: DateTime.now().add(const Duration(days: 7)));
                  final pickedDateRange = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime.now().subtract(const Duration(days: 30)), // Allow past 30 days for flexibility
                    lastDate: DateTime.now().add(const Duration(days: 365 * 2)), // Allow up to 2 years in future
                    initialDateRange: initialDateRange,
                    // helpText: l10n.selectDatesButtonLabel, // Can customize further
                  );

                  if (!context.mounted) {
                    appLogger.w("Widget not mounted after date picker closed");
                    return;
                  }

                  if (pickedDateRange != null) {
                    appLogger.i(
                      "Date range selected: ${DateFormat.yMd().format(pickedDateRange.start)} - ${DateFormat.yMd().format(pickedDateRange.end)}",
                    );
                    bloc.add(TravelFormDateRangeSelected(pickedDateRange));
                  } else {
                    appLogger.i("Date range picker cancelled.");
                  }
                },
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        Center(child: Text(selectedDatesText, style: Theme.of(context).textTheme.titleMedium)),
        BlocBuilder<TravelFormBloc, TravelFormState>(
          buildWhen:
              (previous, current) =>
                  previous.errorMessage != current.errorMessage || previous.currentStep != current.currentStep,
          builder: (context, state) {
            return Visibility(
              visible: state.errorMessage != null && state.currentStep == 2,
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Center(
                  child: Text(state.errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 16)),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
