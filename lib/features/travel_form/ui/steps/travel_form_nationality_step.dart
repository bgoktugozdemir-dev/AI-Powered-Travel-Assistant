import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:travel_assistant/features/travel_form/bloc/travel_form_bloc.dart';

class TravelFormNationalityStep extends StatelessWidget {
  const TravelFormNationalityStep({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(l10n.nationalityStepTitle, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        BlocBuilder<TravelFormBloc, TravelFormState>(
          buildWhen: (previous, current) => previous.isNationalityLoading != current.isNationalityLoading,
          builder: (context, state) {
            return TextField(
              decoration: InputDecoration(
                hintText: l10n.nationalityHintText,
                border: const OutlineInputBorder(),
                suffixIcon:
                    state.isNationalityLoading ? const CircularProgressIndicator(padding: EdgeInsets.all(8)) : null,
              ),
              onChanged: (query) {
                context.read<TravelFormBloc>().add(TravelFormNationalitySearchTermChanged(query));
              },
            );
          },
        ),
        BlocBuilder<TravelFormBloc, TravelFormState>(
          buildWhen: (previous, current) => previous.nationalitySuggestions != current.nationalitySuggestions,
          builder: (context, state) {
            return Visibility(
              visible: state.nationalitySuggestions.isNotEmpty,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.3),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: state.nationalitySuggestions.length,
                  itemBuilder: (context, index) {
                    final country = state.nationalitySuggestions[index];
                    return ListTile(
                      leading:
                          country.flagEmoji != null
                              ? Text(country.flagEmoji!, style: const TextStyle(fontSize: 24))
                              : null,
                      title: Text(country.name),
                      subtitle: country.nationality != null ? Text(country.nationality!) : Text(country.code),
                      onTap: () {
                        context.read<TravelFormBloc>().add(TravelFormNationalitySelected(country));
                      },
                    );
                  },
                ),
              ),
            );
          },
        ),
        BlocBuilder<TravelFormBloc, TravelFormState>(
          buildWhen: (previous, current) => previous.selectedNationality != current.selectedNationality,
          builder: (context, state) {
            return Visibility(
              visible: state.selectedNationality != null,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    if (state.selectedNationality!.flagEmoji != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(state.selectedNationality!.flagEmoji!, style: const TextStyle(fontSize: 24)),
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.selectedNationalityLabel(state.selectedNationality!.name),
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                          ),
                          if (state.selectedNationality!.nationality != null)
                            Text(state.selectedNationality!.nationality!, style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        BlocBuilder<TravelFormBloc, TravelFormState>(
          buildWhen:
              (previous, current) =>
                  previous.errorMessage != current.errorMessage || previous.currentStep != current.currentStep,
          builder: (context, state) {
            return Visibility(
              visible: state.errorMessage != null && state.currentStep == 3,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(state.errorMessage!, style: const TextStyle(color: Colors.red)),
              ),
            );
          },
        ),
      ],
    );
  }
}
