part of 'travel_form_bloc.dart';

/// Status of form submission
enum FormSubmissionStatus {
  /// Initial status, form not submitted
  initial,

  /// Form submission in progress
  submitting,

  /// Form successfully submitted
  success,

  /// Form submission failed
  failure,
}

enum TravelFormStep {
  welcome,
  departureAirport,
  arrivalAirport,
  dates,
  nationality,
  purpose,
}

/// Represents the state of the travel form.
@immutable
class TravelFormState extends Equatable {
  /// Creates a [TravelFormState].
  /// This also serves as the 'initial' state.
  const TravelFormState({
    this.currentStep = 0,
    this.departureAirportSearchTerm = '',
    this.departureAirportSuggestions = const [],
    this.selectedDepartureAirport,
    this.isDepartureAirportLoading = false,
    this.arrivalAirportSearchTerm = '',
    this.arrivalAirportSuggestions = const [],
    this.selectedArrivalAirport,
    this.isArrivalAirportLoading = false,
    this.selectedDateRange,
    this.nationalitySearchTerm = '',
    this.nationalitySuggestions = const [],
    this.selectedNationality,
    this.isNationalityLoading = false,
    this.availableTravelPurposes = const [],
    this.selectedTravelPurposes = const [],
    this.isTravelPurposesLoading = false,
    this.formSubmissionStatus = FormSubmissionStatus.initial,
    this.travelPlan,
    this.cityImageInBytes,
    this.exchangeRate,
    this.error,
  });

  /// The current step in the multi-step form (0-indexed).
  final int currentStep;

  /// Search term entered by the user for departure airport.
  final String departureAirportSearchTerm;

  /// List of airport suggestions for the departure airport.
  final List<Airport> departureAirportSuggestions;

  /// The currently selected departure airport.
  final Airport? selectedDepartureAirport;

  /// Flag indicating if departure airport suggestions are being loaded.
  final bool isDepartureAirportLoading;

  /// Search term entered by the user for arrival airport.
  final String arrivalAirportSearchTerm;

  /// List of airport suggestions for the arrival airport.
  final List<Airport> arrivalAirportSuggestions;

  /// The currently selected arrival airport.
  final Airport? selectedArrivalAirport;

  /// Flag indicating if arrival airport suggestions are being loaded.
  final bool isArrivalAirportLoading;

  /// Travel dates selected by the user.
  final DateTimeRange? selectedDateRange;

  /// Search term entered by the user for nationality.
  final String nationalitySearchTerm;

  /// List of country suggestions for nationality selection.
  final List<Country> nationalitySuggestions;

  /// The currently selected nationality (country).
  final Country? selectedNationality;

  /// Flag indicating if nationality suggestions are being loaded.
  final bool isNationalityLoading;

  /// List of available travel purposes.
  final List<TravelPurpose> availableTravelPurposes;

  /// List of selected travel purposes.
  final List<TravelPurpose> selectedTravelPurposes;

  /// Flag indicating if travel purposes are being loaded.
  final bool isTravelPurposesLoading;

  /// The status of form submission.
  final FormSubmissionStatus formSubmissionStatus;

  /// The generated travel plan.
  final TravelDetails? travelPlan;

  /// The city image in bytes.
  final String? cityImageInBytes;

  /// The exchange rate.
  final double? exchangeRate;

  /// An optional error  if something went wrong.
  final TravelFormError? error;

  /// Returns true if the form is valid and can be submitted.
  bool get isFormValid =>
      selectedDepartureAirport != null &&
      selectedArrivalAirport != null &&
      selectedDateRange != null &&
      selectedNationality != null &&
      selectedTravelPurposes.isNotEmpty;

  /// The total number of steps in the form.
  int get totalSteps => TravelFormStep.values.length;

  /// Creates a copy of the current state with updated values.
  TravelFormState copyWith({
    int? currentStep,
    String? departureAirportSearchTerm,
    List<Airport>? departureAirportSuggestions,
    ValueGetter<Airport?>?
    selectedDepartureAirport, // Use ValueGetter for explicit null setting
    bool? isDepartureAirportLoading,
    String? arrivalAirportSearchTerm,
    List<Airport>? arrivalAirportSuggestions,
    ValueGetter<Airport?>? selectedArrivalAirport,
    bool? isArrivalAirportLoading,
    ValueGetter<DateTimeRange?>?
    selectedDateRange, // Use ValueGetter for explicit null setting
    String? nationalitySearchTerm,
    List<Country>? nationalitySuggestions,
    ValueGetter<Country?>? selectedNationality,
    bool? isNationalityLoading,
    List<TravelPurpose>? availableTravelPurposes,
    List<TravelPurpose>? selectedTravelPurposes,
    bool? isTravelPurposesLoading,
    FormSubmissionStatus? formSubmissionStatus,
    ValueGetter<TravelDetails?>? travelPlan,
    ValueGetter<String?>? cityImageInBytes,
    ValueGetter<double?>? exchangeRate,
    ValueGetter<TravelFormError?>?
    error, // Use ValueGetter for explicit null setting
  }) {
    return TravelFormState(
      currentStep: currentStep ?? this.currentStep,
      departureAirportSearchTerm:
          departureAirportSearchTerm ?? this.departureAirportSearchTerm,
      departureAirportSuggestions:
          departureAirportSuggestions ?? this.departureAirportSuggestions,
      selectedDepartureAirport:
          selectedDepartureAirport != null
              ? selectedDepartureAirport()
              : this.selectedDepartureAirport,
      isDepartureAirportLoading:
          isDepartureAirportLoading ?? this.isDepartureAirportLoading,
      arrivalAirportSearchTerm:
          arrivalAirportSearchTerm ?? this.arrivalAirportSearchTerm,
      arrivalAirportSuggestions:
          arrivalAirportSuggestions ?? this.arrivalAirportSuggestions,
      selectedArrivalAirport:
          selectedArrivalAirport != null
              ? selectedArrivalAirport()
              : this.selectedArrivalAirport,
      isArrivalAirportLoading:
          isArrivalAirportLoading ?? this.isArrivalAirportLoading,
      selectedDateRange:
          selectedDateRange != null
              ? selectedDateRange()
              : this.selectedDateRange,
      nationalitySearchTerm:
          nationalitySearchTerm ?? this.nationalitySearchTerm,
      nationalitySuggestions:
          nationalitySuggestions ?? this.nationalitySuggestions,
      selectedNationality:
          selectedNationality != null
              ? selectedNationality()
              : this.selectedNationality,
      isNationalityLoading: isNationalityLoading ?? this.isNationalityLoading,
      availableTravelPurposes:
          availableTravelPurposes ?? this.availableTravelPurposes,
      selectedTravelPurposes:
          selectedTravelPurposes ?? this.selectedTravelPurposes,
      isTravelPurposesLoading:
          isTravelPurposesLoading ?? this.isTravelPurposesLoading,
      formSubmissionStatus: formSubmissionStatus ?? this.formSubmissionStatus,
      travelPlan: travelPlan != null ? travelPlan() : this.travelPlan,
      cityImageInBytes:
          cityImageInBytes != null ? cityImageInBytes() : this.cityImageInBytes,
      exchangeRate: exchangeRate != null ? exchangeRate() : this.exchangeRate,
      error: error != null ? error() : this.error,
    );
  }

  @override
  List<Object?> get props => [
    currentStep,
    departureAirportSearchTerm,
    departureAirportSuggestions,
    selectedDepartureAirport,
    isDepartureAirportLoading,
    arrivalAirportSearchTerm,
    arrivalAirportSuggestions,
    selectedArrivalAirport,
    isArrivalAirportLoading,
    selectedDateRange,
    nationalitySearchTerm,
    nationalitySuggestions,
    selectedNationality,
    isNationalityLoading,
    availableTravelPurposes,
    selectedTravelPurposes,
    isTravelPurposesLoading,
    formSubmissionStatus,
    travelPlan,
    cityImageInBytes,
    exchangeRate,
    error,
  ];
}
