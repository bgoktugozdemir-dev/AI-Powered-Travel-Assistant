import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_assistant/common/utils/logger/logger.dart';
import 'package:travel_assistant/features/travel_form/ui/dialog/travel_form_error_dialog.dart';
import 'package:travel_assistant/features/travel_form/ui/steps/steps.dart';
import 'package:travel_assistant/features/travel_form/bloc/travel_form_bloc.dart';
import 'package:travel_assistant/features/results/ui/results_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

abstract class _Constants {
  static const pageTransitionDuration = Duration(milliseconds: 300);
  static const pageTransitionCurve = Curves.easeInOut;
  static const progressIndicatorHeight = 4.0;
}

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
  final _pageController = PageController();

  late final List<Widget> _travelFormSteps = [
    TravelFormDepartureAirportStep(departureAirportController: _departureAirportController),
    TravelFormArrivalAirportStep(arrivalAirportController: _arrivalAirportController),
    const TravelFormTravelDatesStep(),
    const TravelFormNationalityStep(),
    const TravelPurposeStep(),
    const TravelSummaryStep(),
  ];

  @override
  void initState() {
    super.initState();
    appLogger.i("TravelFormScreen initialized. Current step: ${context.read<TravelFormBloc>().state.currentStep}");
    // context.read<TravelFormBloc>().add(TravelFormStarted()); // Moved to MyApp

    // Listen to BLoC state changes to update TextEditingControllers and handle navigation
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

      // Navigate to results screen if form submission is successful
      if (state.formSubmissionStatus == FormSubmissionStatus.success && mounted) {
        appLogger.i("Form submission successful, navigating to results screen");
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const ResultsScreen()));
      }
    });
  }

  @override
  void dispose() {
    _departureAirportController.dispose();
    _arrivalAirportController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocListener<TravelFormBloc, TravelFormState>(
      listenWhen: (previous, current) => previous.currentStep != current.currentStep,
      listener: (context, state) {
        _pageController.animateToPage(
          state.currentStep,
          duration: _Constants.pageTransitionDuration,
          curve: _Constants.pageTransitionCurve,
        );
      },
      child: BlocConsumer<TravelFormBloc, TravelFormState>(
        listenWhen: (previous, current) => previous.error != current.error,
        listener: (context, state) {
          if (state.error != null) {
            appLogger.w("Validation failed for step ${state.currentStep}: ${state.error}");

            showGeneralDialog(
              context: context,
              pageBuilder: (context, animation, secondaryAnimation) {
                return TravelFormErrorDialog(error: state.error!);
              },
            );
          }
        },
        buildWhen: (previous, current) => previous.currentStep != current.currentStep,
        builder: (context, state) {
          // Update text controller if search term changed from outside (e.g. after selection)
          // This ensures the text field reflects the BLoC state if BLoC directly changes searchTerm.
          if (_departureAirportController.text != state.departureAirportSearchTerm && state.currentStep == 0) {
            // To avoid listener loop if typing, only update if it's different and relevant
            // A more robust way might be to only set this when an item is *selected*.
            // For now, this is a simplified sync.
          }

          // Show loading indicator when submitting
          final bool isSubmitting = state.formSubmissionStatus == FormSubmissionStatus.submitting;
          return Scaffold(
            appBar: AppBar(
              leading:
                  state.currentStep > 0
                      ? IconButton(
                        tooltip: l10n.navigationPrevious,
                        onPressed:
                            isSubmitting
                                ? null
                                : () {
                                  appLogger.i(
                                    "'Previous' button pressed. Current step: ${state.currentStep}, moving to ${state.currentStep - 1}",
                                  );
                                  context.read<TravelFormBloc>().add(TravelFormPreviousStepRequested());
                                },
                        icon: const Icon(Icons.arrow_back),
                      )
                      : null,
              title: Text(l10n.travelFormStepTitle(state.currentStep + 1)),
              actions: [
                if (state.currentStep < state.totalSteps - 1)
                  IconButton(
                    tooltip: l10n.navigationNext,
                    onPressed: _onNextButtonPressed(context, state, l10n),
                    icon: const Icon(Icons.arrow_forward),
                  )
                else if (state.currentStep == state.totalSteps - 1)
                  IconButton(
                    tooltip: l10n.navigationSubmit,
                    onPressed:
                        isSubmitting
                            ? null
                            : () {
                              appLogger.i("'Get Travel Plan' (Submit) button pressed.");
                              // Check form validity one more time before submission
                              if (state.isFormValid) {
                                context.read<TravelFormBloc>().add(const SubmitTravelFormEvent());
                              } else {
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(SnackBar(content: Text("TODO"), backgroundColor: Colors.red));
                              }
                            },
                    icon: const Icon(Icons.search),
                  ),
              ],
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(_Constants.progressIndicatorHeight),
                child: LinearProgressIndicator(
                  value: state.currentStep / state.totalSteps,
                  minHeight: _Constants.progressIndicatorHeight,
                ),
              ),
            ),
            resizeToAvoidBottomInset: true,
            body: PageView(
              controller: _pageController,
              pageSnapping: false,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                appLogger.i("Page changed to $index");
              },
              children: _travelFormSteps,
            ),
            /*
                  Stack(
                    children: [
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: <Widget>[
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      if (state.currentStep == 0)
                                        TravelFormDepartureAirportStep(departureAirportController: _departureAirportController),
                                      if (state.currentStep == 1)
                                        TravelFormArrivalAirportStep(arrivalAirportController: _arrivalAirportController),
                                      if (state.currentStep == 2) const TravelFormTravelDatesStep(),
                                      if (state.currentStep == 3) const TravelFormNationalityStep(),
                                      if (state.currentStep == 4) const TravelPurposeStep(),
                                      if (state.currentStep == 5) const TravelSummaryStep(),
                                    ],
                                  ),
                                ),
                              ),
                              _buildNavigationButtons(context, state, l10n),
                            ],
                          ),
                        ),
                      ),
                      if (isSubmitting)
                        Container(
                          color: Colors.black.withOpacity(0.3),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CircularProgressIndicator(),
                                const SizedBox(height: 16),
                                Text(
                                  l10n.submittingForm,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  */
          );
        },
      ),
    );
  }

  void Function()? _onNextButtonPressed(BuildContext context, TravelFormState state, AppLocalizations l10n) {
    final bool isSubmitting = state.formSubmissionStatus == FormSubmissionStatus.submitting;

    return isSubmitting
        ? null
        : () {
          appLogger.i(
            "'Next' button pressed. Current step: ${state.currentStep}, attempting to move to ${state.currentStep + 1}",
          );
          context.read<TravelFormBloc>().add(TravelFormNextStepRequested());
        };
  }
}
