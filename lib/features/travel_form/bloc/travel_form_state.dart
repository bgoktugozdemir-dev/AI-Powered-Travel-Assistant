part of 'travel_form_bloc.dart';

/// Represents the state of the travel form.
@immutable
class TravelFormState extends Equatable {
  /// The current step in the multi-step form (0-indexed).
  final int currentStep;
  /// The total number of steps in the form.
  final int totalSteps;

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

  /// An optional error message if something went wrong.
  final String? errorMessage;

  // TODO: Add fields for dates, nationality, purposes, etc.

  /// Creates a [TravelFormState].
  /// This also serves as the 'initial' state.
  const TravelFormState({
    this.currentStep = 0,
    this.totalSteps = 5, // Departure, Arrival, Dates, Nationality, Purpose
    this.departureAirportSearchTerm = '',
    this.departureAirportSuggestions = const [],
    this.selectedDepartureAirport,
    this.isDepartureAirportLoading = false,
    this.arrivalAirportSearchTerm = '',
    this.arrivalAirportSuggestions = const [],
    this.selectedArrivalAirport,
    this.isArrivalAirportLoading = false,
    this.errorMessage,
  });

  /// Creates a copy of the current state with updated values.
  TravelFormState copyWith({
    int? currentStep,
    String? departureAirportSearchTerm,
    List<Airport>? departureAirportSuggestions,
    ValueGetter<Airport?>? selectedDepartureAirport, // Use ValueGetter for explicit null setting
    bool? isDepartureAirportLoading,
    String? arrivalAirportSearchTerm,
    List<Airport>? arrivalAirportSuggestions,
    ValueGetter<Airport?>? selectedArrivalAirport,
    bool? isArrivalAirportLoading,
    ValueGetter<String?>? errorMessage, // Use ValueGetter for explicit null setting
  }) {
    return TravelFormState(
      currentStep: currentStep ?? this.currentStep,
      totalSteps: totalSteps, // totalSteps is fixed for now
      departureAirportSearchTerm: departureAirportSearchTerm ?? this.departureAirportSearchTerm,
      departureAirportSuggestions: departureAirportSuggestions ?? this.departureAirportSuggestions,
      selectedDepartureAirport: selectedDepartureAirport != null ? selectedDepartureAirport() : this.selectedDepartureAirport,
      isDepartureAirportLoading: isDepartureAirportLoading ?? this.isDepartureAirportLoading,
      arrivalAirportSearchTerm: arrivalAirportSearchTerm ?? this.arrivalAirportSearchTerm,
      arrivalAirportSuggestions: arrivalAirportSuggestions ?? this.arrivalAirportSuggestions,
      selectedArrivalAirport: selectedArrivalAirport != null ? selectedArrivalAirport() : this.selectedArrivalAirport,
      isArrivalAirportLoading: isArrivalAirportLoading ?? this.isArrivalAirportLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        currentStep,
        totalSteps,
        departureAirportSearchTerm,
        departureAirportSuggestions,
        selectedDepartureAirport,
        isDepartureAirportLoading,
        arrivalAirportSearchTerm,
        arrivalAirportSuggestions,
        selectedArrivalAirport,
        isArrivalAirportLoading,
        errorMessage,
      ];
} 