import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_assistant/common/utils/analytics/analytics_facade.dart';
import 'package:travel_assistant/common/utils/error_monitoring/error_monitoring_facade.dart';
import 'package:travel_assistant/common/utils/helpers/formatters.dart';
import 'package:travel_assistant/features/travel_form/bloc/travel_form_bloc.dart';
import 'package:travel_assistant/features/travel_form/ui/widgets/travel_form_step_layout.dart';
import 'package:travel_assistant/l10n/app_localizations.dart';

abstract class _Constants {
  // Button Keys
  static const String buttonSelectDates = 'button_select_dates';
}

class TravelFormTravelDatesStep extends StatelessWidget {
  const TravelFormTravelDatesStep({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bloc = context.read<TravelFormBloc>();
    String selectedDatesText = '';

    return TravelFormStepLayout(
      children: <Widget>[
        Text(
          l10n.travelDatesStepTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 24),
        BlocBuilder<TravelFormBloc, TravelFormState>(
          buildWhen:
              (previous, current) =>
                  previous.selectedDateRange != current.selectedDateRange,
          builder: (context, state) {
            final today = DateTime.now();
            return Center(
              child: ElevatedButton.icon(
                key: const Key(_Constants.buttonSelectDates),
                icon: const Icon(Icons.calendar_month),
                label: Text(l10n.selectDatesButtonLabel),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                onPressed: () async {
                  final errorMonitoring = context.read<ErrorMonitoringFacade>();
                  final pickedDateRange = await showDateRangePicker(
                    context: context,
                    locale: Locale(l10n.localeName),
                    firstDate: today,
                    lastDate: today.add(const Duration(days: 365 * 2)),
                    initialDateRange: state.selectedDateRange,
                    helpText: l10n.selectDatesButtonLabel,
                  );

                  if (!context.mounted) {
                    errorMonitoring.reportError(
                      'Widget not mounted after date picker closed',
                      stackTrace: StackTrace.current,
                    );
                    return;
                  }

                  if (pickedDateRange != null) {
                    bloc.add(TravelFormDateRangeSelected(pickedDateRange));
                  }
                },
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        BlocBuilder<TravelFormBloc, TravelFormState>(
          buildWhen:
              (previous, current) =>
                  previous.selectedDateRange != current.selectedDateRange,
          builder: (context, state) {
            if (bloc.state.selectedDateRange == null) {
              selectedDatesText = l10n.noDatesSelected;
            } else {
              selectedDatesText = Formatters.selectedDatesLabel(
                bloc.state.selectedDateRange!,
                context,
              );
            }
            return Center(
              child: Text(
                selectedDatesText,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            );
          },
        ),
      ],
    );
  }
}
