import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_assistant/common/models/airport.dart';
import 'package:travel_assistant/features/travel_form/bloc/travel_form_bloc.dart';
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
    // context.read<TravelFormBloc>().add(TravelFormStarted()); // Moved to MyApp

    // Listen to BLoC state changes to update TextEditingControllers if needed
    context.read<TravelFormBloc>().stream.listen((state) {
      // Departure airport controller update
      if (state.selectedDepartureAirport != null &&
          _departureAirportController.text != state.departureAirportSearchTerm) {
        _departureAirportController.text = state.departureAirportSearchTerm;
        _departureAirportController.selection = TextSelection.fromPosition(TextPosition(offset: _departureAirportController.text.length));
      }
      // Arrival airport controller update
      if (state.selectedArrivalAirport != null &&
          _arrivalAirportController.text != state.arrivalAirportSearchTerm) {
        _arrivalAirportController.text = state.arrivalAirportSearchTerm;
        _arrivalAirportController.selection = TextSelection.fromPosition(TextPosition(offset: _arrivalAirportController.text.length));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
          appBar: AppBar(
            title: Text(l10n.travelFormStepTitle(state.currentStep + 1)),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                if (state.currentStep == 0) _buildDepartureAirportStep(context, state, l10n),
                if (state.currentStep == 1) _buildArrivalAirportStep(context, state, l10n),
                // TODO: Add widgets for other steps (2 to 4)
                const Spacer(), // Pushes navigation to bottom
                _buildNavigationButtons(context, state, l10n),
              ],
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
            context.read<TravelFormBloc>().add(TravelFormDepartureAirportSearchTermChanged(query));
          },
        ),
        if (state.departureAirportSuggestions.isNotEmpty)
          SizedBox(
            height: 200, // Limit suggestion box height
            child: ListView.builder(
              itemCount: state.departureAirportSuggestions.length,
              itemBuilder: (context, index) {
                final airport = state.departureAirportSuggestions[index];
                return ListTile(
                  title: Text("${airport.name} (${airport.iataCode})"),
                  subtitle: Text(airport.country),
                  onTap: () {
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
          )
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
            context.read<TravelFormBloc>().add(TravelFormArrivalAirportSearchTermChanged(query));
          },
        ),
        if (state.arrivalAirportSuggestions.isNotEmpty)
          SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: state.arrivalAirportSuggestions.length,
              itemBuilder: (context, index) {
                final airport = state.arrivalAirportSuggestions[index];
                return ListTile(
                  title: Text("${airport.name} (${airport.iataCode})"),
                  subtitle: Text(airport.country),
                  onTap: () {
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
          )
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
              context.read<TravelFormBloc>().add(TravelFormPreviousStepRequested());
            },
            child: Text(l10n.navigationPrevious),
          ),
        if (state.currentStep < state.totalSteps - 1)
          ElevatedButton(
            onPressed: () {
              // TODO: Add validation before allowing next step
              context.read<TravelFormBloc>().add(TravelFormNextStepRequested());
            },
            child: Text(l10n.navigationNext),
          )
        else if (state.currentStep == state.totalSteps - 1)
          ElevatedButton(
            onPressed: () {
              // TODO: Add validation and then submit form / call AI
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.submittingForm))
              );
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