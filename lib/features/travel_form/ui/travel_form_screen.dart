import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_assistant/common/constants/app_assets.dart';
import 'package:travel_assistant/common/utils/analytics/analytics_facade.dart';
import 'package:travel_assistant/common/utils/analytics/data/submit_travel_details_source.dart';
import 'package:travel_assistant/common/utils/helpers/loading_overlay_helper.dart';
import 'package:travel_assistant/features/travel_form/ui/dialog/travel_form_error_dialog.dart';
import 'package:travel_assistant/features/travel_form/ui/steps/steps.dart';
import 'package:travel_assistant/features/travel_form/ui/widgets/country_service_error_screen.dart';
import 'package:travel_assistant/features/travel_form/bloc/travel_form_bloc.dart';
import 'package:travel_assistant/features/results/ui/results_screen.dart';
import 'package:travel_assistant/l10n/app_localizations.dart';

abstract class _Constants {
  static const pageTransitionDuration = Duration(milliseconds: 300);
  static const pageTransitionCurve = Curves.easeInOut;

  // Button Keys
  static const String buttonPreviousStep = 'button_previous_step';
  static const String buttonNextStep = 'button_next_step';
  static const String buttonSubmitAppbar = 'button_submit_appbar';
  static const String buttonSubmitFab = 'button_submit_fab';
}

/// Screen for users to input their travel details using a multi-step form.
class TravelFormScreen extends StatefulWidget {
  /// Creates a [TravelFormScreen].
  const TravelFormScreen({super.key});

  @override
  State<TravelFormScreen> createState() => _TravelFormScreenState();
}

class _TravelFormScreenState extends State<TravelFormScreen>
    with LoadingOverlayHelper {
  final _departureAirportController = TextEditingController();
  final _arrivalAirportController = TextEditingController();
  final _pageController = PageController();

  late final List<Widget> _travelFormSteps = [
    TravelFormDepartureAirportStep(
      departureAirportController: _departureAirportController,
    ),
    TravelFormArrivalAirportStep(
      arrivalAirportController: _arrivalAirportController,
    ),
    const TravelFormTravelDatesStep(),
    const TravelFormNationalityStep(),
    const TravelPurposeStep(),
    const TravelSummaryStep(),
  ];

  @override
  void initState() {
    super.initState();
    // context.read<TravelFormBloc>().add(TravelFormStarted()); // Moved to MyApp

    // Listen to BLoC state changes to update TextEditingControllers and handle navigation
    context.read<TravelFormBloc>().stream.listen((state) {
      // Departure airport controller update
      if (state.selectedDepartureAirport != null &&
          _departureAirportController.text !=
              state.departureAirportSearchTerm) {
        _departureAirportController.text = state.departureAirportSearchTerm;
        _departureAirportController.selection = TextSelection.fromPosition(
          TextPosition(offset: _departureAirportController.text.length),
        );
      }
      // Arrival airport controller update
      if (state.selectedArrivalAirport != null &&
          _arrivalAirportController.text != state.arrivalAirportSearchTerm) {
        _arrivalAirportController.text = state.arrivalAirportSearchTerm;
        _arrivalAirportController.selection = TextSelection.fromPosition(
          TextPosition(offset: _arrivalAirportController.text.length),
        );
      }

      // Navigate to results screen if form submission is successful
      if (state.formSubmissionStatus == FormSubmissionStatus.success &&
          mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const ResultsScreen()),
        );
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
      listenWhen:
          (previous, current) => previous.currentStep != current.currentStep,
      listener: (context, state) {
        _pageController.animateToPage(
          state.currentStep,
          duration: _Constants.pageTransitionDuration,
          curve: _Constants.pageTransitionCurve,
        );
      },
      child: BlocListener<TravelFormBloc, TravelFormState>(
        listenWhen:
            (previous, current) =>
                previous.formSubmissionStatus != current.formSubmissionStatus,
        listener: (context, state) {
          if (state.formSubmissionStatus == FormSubmissionStatus.submitting) {
            showLoadingOverlay(
              context,
              loadingAsset: AppAssets.flightSearchIndicatorLottie,
              label: l10n.submittingForm,
            );
          } else {
            hideLoadingOverlay();
          }
        },
        child: BlocConsumer<TravelFormBloc, TravelFormState>(
          listenWhen: (previous, current) => previous.error != current.error,
          listener: (context, state) {
            context.read<AnalyticsFacade>().logTravelFormError(
              state.error?.toString() ?? "Error occurred",
              state.currentStep.toString(),
            );
            if (state.error != null) {
              showGeneralDialog(
                context: context,
                pageBuilder: (context, animation, secondaryAnimation) {
                  return TravelFormErrorDialog(error: state.error!);
                },
              );
            }
          },
          buildWhen:
              (previous, current) =>
                  previous.currentStep != current.currentStep ||
                  previous.countryServiceStatus != current.countryServiceStatus,
          builder: (context, state) {
            // Show error screen if country service failed
            if (state.countryServiceStatus == CountryServiceStatus.failure) {
              return const CountryServiceErrorScreen();
            }

            // Update text controller if search term changed from outside (e.g. after selection)
            // This ensures the text field reflects the BLoC state if BLoC directly changes searchTerm.
            if (_departureAirportController.text !=
                    state.departureAirportSearchTerm &&
                state.currentStep == 0) {
              // To avoid listener loop if typing, only update if it's different and relevant
              // A more robust way might be to only set this when an item is *selected*.
              // For now, this is a simplified sync.
            }

            // Show loading indicator when submitting
            final bool isSubmitting =
                state.formSubmissionStatus == FormSubmissionStatus.submitting;
            return Scaffold(
              appBar: AppBar(
                leading:
                    state.currentStep > 0
                        ? IconButton(
                          key: const Key(_Constants.buttonPreviousStep),
                          tooltip: l10n.navigationPrevious,
                          onPressed:
                              isSubmitting
                                  ? null
                                  : () {
                                    context.read<TravelFormBloc>().add(
                                      TravelFormPreviousStepRequested(
                                        source:
                                            SubmitTravelDetailsSource.appBar,
                                      ),
                                    );
                                  },
                          icon: const Icon(Icons.arrow_back),
                        )
                        : null,
                title: Text(l10n.travelFormStepTitle(state.currentStep + 1)),
                actions: [
                  if (state.currentStep < state.totalSteps - 1)
                    IconButton(
                      key: const Key(_Constants.buttonNextStep),
                      tooltip: l10n.navigationNext,
                      onPressed: _onNextButtonPressed(context, state, l10n),
                      icon: const Icon(Icons.arrow_forward),
                    )
                  else if (state.currentStep == state.totalSteps - 1)
                    IconButton(
                      key: const Key(_Constants.buttonSubmitAppbar),
                      tooltip: l10n.navigationSubmit,
                      onPressed:
                          isSubmitting
                              ? null
                              : () => _onSubmitButtonPressed(
                                context,
                                state,
                                l10n,
                                SubmitTravelDetailsSource.appBar,
                              ),
                      icon: const Icon(Icons.send),
                    ),
                ],
              ),
              resizeToAvoidBottomInset: true,
              body: PageView(
                controller: _pageController,
                pageSnapping: false,
                physics: const NeverScrollableScrollPhysics(),
                children: _travelFormSteps,
              ),
              floatingActionButton: _buildFloatingActionButton(
                context,
                state,
                l10n,
                isSubmitting,
              ),
            );
          },
        ),
      ),
    );
  }

  void Function()? _onNextButtonPressed(
    BuildContext context,
    TravelFormState state,
    AppLocalizations l10n,
  ) {
    final bool isSubmitting =
        state.formSubmissionStatus == FormSubmissionStatus.submitting;

    return isSubmitting
        ? null
        : () =>
            context.read<TravelFormBloc>().add(TravelFormNextStepRequested());
  }

  Widget? _buildFloatingActionButton(
    BuildContext context,
    TravelFormState state,
    AppLocalizations l10n,
    bool isSubmitting,
  ) {
    if (state.currentStep != state.totalSteps - 1) {
      return null;
    }

    return FloatingActionButton.extended(
      key: const Key(_Constants.buttonSubmitFab),
      onPressed:
          isSubmitting
              ? null
              : () => _onSubmitButtonPressed(
                context,
                state,
                l10n,
                SubmitTravelDetailsSource.fab,
              ),
      icon: const Icon(Icons.send),
      label: Text(l10n.submitTravelPlan),
    );
  }

  void _onSubmitButtonPressed(
    BuildContext context,
    TravelFormState state,
    AppLocalizations l10n,
    SubmitTravelDetailsSource source,
  ) {
    if (state.isFormValid) {
      context.read<TravelFormBloc>().add(
        SubmitTravelFormEvent(locale: l10n.localeName, source: source),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(l10n.formValidationError),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
