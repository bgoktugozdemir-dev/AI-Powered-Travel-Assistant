import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_assistant/common/utils/logger/logger.dart';
import 'package:travel_assistant/features/travel_form/bloc/travel_form_bloc.dart';
import 'package:travel_assistant/features/travel_form/ui/widgets/travel_form_step_layout.dart';
import 'package:travel_assistant/l10n/app_localizations.dart';

class TravelFormDepartureAirportStep extends StatelessWidget {
  const TravelFormDepartureAirportStep({super.key, required this.departureAirportController});

  final TextEditingController departureAirportController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return TravelFormStepLayout(
      children: <Widget>[
        Text(l10n.departureAirportStepTitle, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        BlocBuilder<TravelFormBloc, TravelFormState>(
          buildWhen: (previous, current) => previous.isDepartureAirportLoading != current.isDepartureAirportLoading,
          builder: (context, state) {
            return TextField(
              controller: departureAirportController,
              decoration: InputDecoration(
                hintText: l10n.departureAirportHintText,
                border: const OutlineInputBorder(),
                suffixIcon:
                    state.isDepartureAirportLoading
                        ? const CircularProgressIndicator(padding: EdgeInsets.all(8))
                        : null,
              ),
              onChanged: (query) {
                appLogger.d("Departure airport search changed: $query");
                context.read<TravelFormBloc>().add(TravelFormDepartureAirportSearchTermChanged(query));
              },
            );
          },
        ),
        BlocBuilder<TravelFormBloc, TravelFormState>(
          buildWhen: (previous, current) => previous.departureAirportSuggestions != current.departureAirportSuggestions,
          builder: (context, state) {
            if (state.departureAirportSuggestions.isEmpty) {
              return const SizedBox.shrink();
            }

            return ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.3),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: state.departureAirportSuggestions.length,
                itemBuilder: (context, index) {
                  final airport = state.departureAirportSuggestions[index];
                  return ListTile(
                    title: Text("${airport.name} (${airport.iataCode})"),
                    subtitle: Text(airport.cityAndCountry),
                    onTap: () {
                      appLogger.i("Departure airport selected: ${airport.name} (${airport.iataCode})");
                      context.read<TravelFormBloc>().add(TravelFormDepartureAirportSelected(airport));
                    },
                  );
                },
              ),
            );
          },
        ),
        BlocBuilder<TravelFormBloc, TravelFormState>(
          buildWhen: (previous, current) => previous.selectedDepartureAirport != current.selectedDepartureAirport,
          builder: (context, state) {
            if (state.selectedDepartureAirport == null) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                l10n.selectedAirportLabel(
                  state.selectedDepartureAirport!.name,
                  state.selectedDepartureAirport!.iataCode,
                ),
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            );
          },
        ),
      ],
    );
  }
}
