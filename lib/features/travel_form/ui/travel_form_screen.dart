import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:travel_assistant/common/models/airport.dart'; // Import the Airport model
import 'package:travel_assistant/common/models/country.dart'; // Import the Country model
import 'package:travel_assistant/common/utils/logger.dart'; // Import appLogger
import 'package:travel_assistant/features/travel_form/bloc/travel_form_bloc.dart';
import 'package:travel_assistant/features/travel_form/ui/travel_purpose_step.dart'; // Import the TravelPurposeStep
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Screen for users to input their travel details using a multi-step form.
class TravelFormScreen extends StatefulWidget {
  /// Creates a [TravelFormScreen].
  const TravelFormScreen({super.key});

  @override
  State<TravelFormScreen> createState() => _TravelFormScreenState();
}

class _TravelFormScreenState extends State<TravelFormScreen> {
  final _departureAirportController = TextEditingController();
  final _arrivalAirportController = TextEditingController();

  @override
  void initState() {
    super.initState();
    appLogger.i("TravelFormScreen initialized. Current step: ${context.read<TravelFormBloc>().state.currentStep}");
    // context.read<TravelFormBloc>().add(TravelFormStarted()); // Moved to MyApp

    // Listen to BLoC state changes to update TextEditingControllers if needed
    context.read<TravelFormBloc>().stream.listen((state) {
      // Departure airport controller update
      if (state.selectedDepartureAirport != null &&
          _departureAirportController.text != state.departureAirportSearchTerm) {
        _departureAirportController.text = state.departureAirportSearchTerm;
        _departureAirportController.selection = TextSelection.fromPosition(
          TextPosition(offset: _departureAirportController.text.length),
        );
      }
      // Arrival airport controller update
      if (state.selectedArrivalAirport != null && _arrivalAirportController.text != state.arrivalAirportSearchTerm) {
        _arrivalAirportController.text = state.arrivalAirportSearchTerm;
        _arrivalAirportController.selection = TextSelection.fromPosition(
          TextPosition(offset: _arrivalAirportController.text.length),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<TravelFormBloc, TravelFormState>(
      builder: (context, state) {
        // Update text controller if search term changed from outside (e.g. after selection)
        // This ensures the text field reflects the BLoC state if BLoC directly changes searchTerm.
        if (_departureAirportController.text != state.departureAirportSearchTerm && state.currentStep == 0) {
          // To avoid listener loop if typing, only update if it's different and relevant
          // A more robust way might be to only set this when an item is *selected*.
          // For now, this is a simplified sync.
        }

        return Scaffold(
          appBar: AppBar(title: Text(l10n.travelFormStepTitle(state.currentStep + 1))),
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          if (state.currentStep == 0) _buildDepartureAirportStep(context, state, l10n),
                          if (state.currentStep == 1) _buildArrivalAirportStep(context, state, l10n),
                          if (state.currentStep == 2) _buildTravelDatesStep(context, state, l10n),
                          if (state.currentStep == 3) _buildNationalityStep(context, state, l10n),
                          if (state.currentStep == 4) const TravelPurposeStep(),
                        ],
                      ),
                    ),
                  ),
                  _buildNavigationButtons(context, state, l10n),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDepartureAirportStep(BuildContext context, TravelFormState state, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(l10n.departureAirportStepTitle, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        TextField(
          controller: _departureAirportController,
          decoration: InputDecoration(
            hintText: l10n.departureAirportHintText,
            border: const OutlineInputBorder(),
            suffixIcon: state.isDepartureAirportLoading ? const CircularProgressIndicator() : null,
          ),
          onChanged: (query) {
            appLogger.d("Departure airport search changed: $query");
            context.read<TravelFormBloc>().add(TravelFormDepartureAirportSearchTermChanged(query));
          },
        ),
        if (state.departureAirportSuggestions.isNotEmpty)
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.3,
            ),
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
          ),
        if (state.selectedDepartureAirport != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              l10n.selectedAirportLabel(state.selectedDepartureAirport!.name, state.selectedDepartureAirport!.iataCode),
              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
          ),
        if (state.errorMessage != null && state.currentStep == 0) // Show error relevant to this step
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(state.errorMessage!, style: const TextStyle(color: Colors.red)),
          ),
      ],
    );
  }

  Widget _buildArrivalAirportStep(BuildContext context, TravelFormState state, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(l10n.arrivalAirportStepTitle, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        TextField(
          controller: _arrivalAirportController,
          decoration: InputDecoration(
            hintText: l10n.arrivalAirportHintText,
            border: const OutlineInputBorder(),
            suffixIcon: state.isArrivalAirportLoading ? const CircularProgressIndicator() : null,
          ),
          onChanged: (query) {
            appLogger.d("Arrival airport search changed: $query");
            context.read<TravelFormBloc>().add(TravelFormArrivalAirportSearchTermChanged(query));
          },
        ),
        if (state.arrivalAirportSuggestions.isNotEmpty)
          ConstrainedBox(
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
                  onTap: () {
                    appLogger.i("Arrival airport selected: ${airport.name} (${airport.iataCode})");
                    context.read<TravelFormBloc>().add(TravelFormArrivalAirportSelected(airport));
                  },
                );
              },
            ),
          ),
        if (state.selectedArrivalAirport != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              l10n.selectedAirportLabel(state.selectedArrivalAirport!.name, state.selectedArrivalAirport!.iataCode),
              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
          ),
        if (state.errorMessage != null && state.currentStep == 1) // Show error relevant to this step
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(state.errorMessage!, style: const TextStyle(color: Colors.red)),
          ),
      ],
    );
  }

  Widget _buildTravelDatesStep(BuildContext context, TravelFormState state, AppLocalizations l10n) {
    final dateFormat = DateFormat.yMMMd(l10n.localeName); // Use locale for date format
    String selectedDatesText;
    if (state.selectedDateRange == null) {
      selectedDatesText = l10n.noDatesSelected;
    } else {
      final startDate = dateFormat.format(state.selectedDateRange!.start);
      final endDate = dateFormat.format(state.selectedDateRange!.end);
      selectedDatesText = l10n.selectedDatesLabel(startDate, endDate);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(l10n.travelDatesStepTitle, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 24),
        Center(
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

              if (!mounted) {
                appLogger.w("Widget not mounted after date picker closed");
                return;
              }

              if (pickedDateRange != null) {
                appLogger.i(
                  "Date range selected: ${DateFormat.yMd().format(pickedDateRange.start)} - ${DateFormat.yMd().format(pickedDateRange.end)}",
                );
                this.context.read<TravelFormBloc>().add(TravelFormDateRangeSelected(pickedDateRange));
              } else {
                appLogger.i("Date range picker cancelled.");
              }
            },
          ),
        ),
        const SizedBox(height: 24),
        Center(child: Text(selectedDatesText, style: Theme.of(context).textTheme.titleMedium)),
        if (state.errorMessage != null && state.currentStep == 2)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Center(child: Text(state.errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 16))),
          ),
      ],
    );
  }

  Widget _buildNationalityStep(BuildContext context, TravelFormState state, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(l10n.nationalityStepTitle, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            hintText: l10n.nationalityHintText,
            border: const OutlineInputBorder(),
            suffixIcon: state.isNationalityLoading ? const CircularProgressIndicator() : null,
          ),
          onChanged: (query) {
            this.context.read<TravelFormBloc>().add(TravelFormNationalitySearchTermChanged(query));
          },
        ),
        if (state.nationalitySuggestions.isNotEmpty)
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.3,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: state.nationalitySuggestions.length,
              itemBuilder: (context, index) {
                final country = state.nationalitySuggestions[index];
                return ListTile(
                  leading: country.flagEmoji != null ? Text(country.flagEmoji!, style: const TextStyle(fontSize: 24)) : null,
                  title: Text(country.name),
                  subtitle: country.nationality != null ? Text(country.nationality!) : Text(country.code),
                  onTap: () {
                    this.context.read<TravelFormBloc>().add(TravelFormNationalitySelected(country));
                  },
                );
              },
            ),
          ),
        if (state.selectedNationality != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                if (state.selectedNationality!.flagEmoji != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      state.selectedNationality!.flagEmoji!,
                      style: const TextStyle(fontSize: 24),
                    ),
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
                        Text(
                          state.selectedNationality!.nationality!,
                          style: const TextStyle(color: Colors.grey),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        if (state.errorMessage != null && state.currentStep == 3)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(state.errorMessage!, style: const TextStyle(color: Colors.red)),
          ),
      ],
    );
  }

  Widget _buildNavigationButtons(BuildContext context, TravelFormState state, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        if (state.currentStep > 0)
          ElevatedButton(
            onPressed: () {
              appLogger.i(
                "'Previous' button pressed. Current step: ${state.currentStep}, moving to ${state.currentStep - 1}",
              );
              context.read<TravelFormBloc>().add(TravelFormPreviousStepRequested());
            },
            child: Text(l10n.navigationPrevious),
          )
        else
          const SizedBox(),
        if (state.currentStep < state.totalSteps - 1)
          ElevatedButton(
            onPressed: () {
              appLogger.i(
                "'Next' button pressed. Current step: ${state.currentStep}, attempting to move to ${state.currentStep + 1}",
              );
              bool canProceed = true;
              String? validationError;
              if (state.currentStep == 0 && state.selectedDepartureAirport == null) {
                canProceed = false;
                validationError = l10n.validationErrorDepartureAirportMissing;
              } else if (state.currentStep == 1 && state.selectedArrivalAirport == null) {
                canProceed = false;
                validationError = l10n.validationErrorArrivalAirportMissing;
              } else if (state.currentStep == 2 && state.selectedDateRange == null) {
                canProceed = false;
                validationError = l10n.validationErrorDateRangeMissing;
              } else if (state.currentStep == 3 && state.selectedNationality == null) {
                canProceed = false;
                validationError = l10n.validationErrorNationalityMissing;
              } else if (state.currentStep == 4 && state.selectedTravelPurposes.isEmpty) {
                canProceed = false;
                validationError = l10n.validationErrorTravelPurposeMissing;
              }

              if (canProceed) {
                appLogger.i("Validation passed, moving to next step.");
                context.read<TravelFormBloc>().add(TravelFormNextStepRequested());
              } else if (validationError != null) {
                appLogger.w("Validation failed for step ${state.currentStep}: $validationError");
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(validationError), backgroundColor: Colors.red));
              }
            },
            child: Text(l10n.navigationNext),
          )
        else if (state.currentStep == state.totalSteps - 1)
          ElevatedButton(
            onPressed: () {
              appLogger.i("'Get Travel Plan' (Submit) button pressed.");
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.submittingForm)));
            },
            child: Text(l10n.navigationSubmit),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _departureAirportController.dispose();
    _arrivalAirportController.dispose();
    super.dispose();
  }
}
