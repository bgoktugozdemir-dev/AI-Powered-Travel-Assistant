import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:travel_assistant/common/utils/logger/logger.dart';
import 'package:travel_assistant/features/travel_form/bloc/travel_form_bloc.dart';
import 'package:travel_assistant/features/travel_form/ui/widgets/travel_form_step_layout.dart';
import 'package:travel_assistant/l10n/app_localizations.dart';

class TravelFormTravelDatesStep extends StatelessWidget {
  const TravelFormTravelDatesStep({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dateFormat = DateFormat.yMMMd(l10n.localeName); // Use locale for date format
    final bloc = context.read<TravelFormBloc>();
    String selectedDatesText = '';

    return TravelFormStepLayout(
      children: <Widget>[
        Text(l10n.travelDatesStepTitle, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 24),
        BlocBuilder<TravelFormBloc, TravelFormState>(
          buildWhen: (previous, current) => previous.selectedDateRange != current.selectedDateRange,
          builder: (context, state) {
            final today = DateTime.now();
            return Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.calendar_month),
                label: Text(l10n.selectDatesButtonLabel),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                onPressed: () async {
                  appLogger.i("'Select Travel Dates' button pressed.");
                  final pickedDateRange = await showDateRangePicker(
                    context: context,
                    firstDate: today,
                    lastDate: today.add(const Duration(days: 365 * 2)),
                    initialDateRange: state.selectedDateRange,
                    helpText: l10n.selectDatesButtonLabel,
                  );

                  if (!context.mounted) {
                    appLogger.w("Widget not mounted after date picker closed");
                    return;
                  }

                  if (pickedDateRange != null) {
                    final dateFormatter = DateFormat.yMd();
                    appLogger.i(
                      "Date range selected: ${dateFormatter.format(pickedDateRange.start)} - ${dateFormatter.format(pickedDateRange.end)}",
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
        BlocBuilder<TravelFormBloc, TravelFormState>(
          buildWhen: (previous, current) => previous.selectedDateRange != current.selectedDateRange,
          builder: (context, state) {
            if (bloc.state.selectedDateRange == null) {
              selectedDatesText = l10n.noDatesSelected;
            } else {
              final startDate = dateFormat.format(bloc.state.selectedDateRange!.start);
              final endDate = dateFormat.format(bloc.state.selectedDateRange!.end);
              selectedDatesText = l10n.selectedDatesLabel(startDate, endDate);
            }
            return Center(child: Text(selectedDatesText, style: Theme.of(context).textTheme.titleMedium));
          },
        ),
      ],
    );
  }
}
