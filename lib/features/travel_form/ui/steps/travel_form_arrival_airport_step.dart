import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_assistant/common/utils/analytics/analytics_facade.dart';
import 'package:travel_assistant/features/travel_form/bloc/travel_form_bloc.dart';
import 'package:travel_assistant/features/travel_form/ui/widgets/travel_form_step_layout.dart';
import 'package:travel_assistant/l10n/app_localizations.dart';

class TravelFormArrivalAirportStep extends StatelessWidget {
  const TravelFormArrivalAirportStep({
    super.key,
    required this.arrivalAirportController,
  });

  final TextEditingController arrivalAirportController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return TravelFormStepLayout(
      children: <Widget>[
        Text(
          l10n.arrivalAirportStepTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        BlocBuilder<TravelFormBloc, TravelFormState>(
          buildWhen: (previous, current) => previous.isArrivalAirportLoading != current.isArrivalAirportLoading,
          builder: (context, state) {
            return TextField(
              controller: arrivalAirportController,
              decoration: InputDecoration(
                hintText: l10n.arrivalAirportHintText,
                border: const OutlineInputBorder(),
                suffixIcon:
                    state.isArrivalAirportLoading
                        ? const CircularProgressIndicator(
                          padding: EdgeInsets.all(8),
                        )
                        : null,
              ),
              onChanged:
                  (query) => context.read<TravelFormBloc>().add(
                    TravelFormArrivalAirportSearchTermChanged(query),
                  ),
            );
          },
        ),
        BlocBuilder<TravelFormBloc, TravelFormState>(
          buildWhen: (previous, current) => previous.arrivalAirportSuggestions != current.arrivalAirportSuggestions,
          builder: (context, state) {
            if (state.arrivalAirportSuggestions.isEmpty) {
              return const SizedBox.shrink();
            }

            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.3,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: state.arrivalAirportSuggestions.length,
                itemBuilder: (context, index) {
                  final airport = state.arrivalAirportSuggestions[index];
                  return ListTile(
                    title: Text("${airport.name} (${airport.iataCode})"),
                    subtitle: Text(airport.cityAndCountry),
                    onTap:
                        () => context.read<TravelFormBloc>().add(
                          TravelFormArrivalAirportSelected(airport),
                        ),
                  );
                },
              ),
            );
          },
        ),
        BlocBuilder<TravelFormBloc, TravelFormState>(
          buildWhen: (previous, current) => previous.selectedArrivalAirport != current.selectedArrivalAirport,
          builder: (context, state) {
            if (state.selectedArrivalAirport == null) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                l10n.selectedAirportLabel(
                  state.selectedArrivalAirport!.name,
                  state.selectedArrivalAirport!.iataCode,
                ),
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
