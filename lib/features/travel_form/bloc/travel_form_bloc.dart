import 'dart:async'; // For Future

// Added
import 'package:flutter_bloc/flutter_bloc.dart';
// For Dio and DioError
import 'package:equatable/equatable.dart'; // For ValueGetter
import 'package:flutter/material.dart'; // For DateTimeRange
import 'package:travel_assistant/common/models/airport.dart'; // Import Airport model
import 'package:travel_assistant/common/models/country.dart'; // Import Country model
import 'package:travel_assistant/common/models/response/travel_details.dart';
import 'package:travel_assistant/common/models/travel_information.dart';
import 'package:travel_assistant/common/models/travel_purpose.dart'; // Import TravelPurpose model
import 'package:travel_assistant/common/repositories/airport_repository.dart'; // Import repository
import 'package:travel_assistant/common/repositories/gemini_repository.dart';
// Import service for direct instantiation (temp)
// Import the interceptor
import 'package:travel_assistant/common/services/country_service.dart'; // Import CountryService
import 'package:travel_assistant/common/services/travel_purpose_service.dart'; // Import TravelPurposeService
import 'package:rxdart/rxdart.dart'; // Added

part 'travel_form_event.dart';
part 'travel_form_state.dart';

// Helper event transformer
EventTransformer<E> _debounceRestartable<E>(Duration duration) {
  return (events, mapper) => events.debounceTime(duration).switchMap(mapper);
}

/// {@template travel_form_bloc}
/// Manages the state for the travel input form.
/// {@endtemplate}
class TravelFormBloc extends Bloc<TravelFormEvent, TravelFormState> {
  final CountryService _countryService;
  final TravelPurposeService _travelPurposeService;
  final GeminiRepository _geminiRepository;
  final AirportRepository _airportRepository;

  // TODO: Use proper Dependency Injection for services
  TravelFormBloc({required GeminiRepository geminiRepository, required AirportRepository airportRepository})
    : _geminiRepository = geminiRepository,
      _airportRepository = airportRepository,
      _countryService = CountryService(),
      _travelPurposeService = TravelPurposeService(),
      super(const TravelFormState()) {
    // Initialize services
    _initializeServices();

    // Register event handlers
    on<TravelFormStarted>(_onStarted);
    on<TravelFormNextStepRequested>(_onNextStepRequested);
    on<TravelFormPreviousStepRequested>(_onPreviousStepRequested);
    // Departure Airport
    on<TravelFormDepartureAirportSearchTermChanged>(
      _onDepartureAirportSearchTermChanged,
      transformer: _debounceRestartable(const Duration(milliseconds: 500)), // Use transformer
    );
    on<TravelFormDepartureAirportSelected>(_onDepartureAirportSelected);
    // Arrival Airport
    on<TravelFormArrivalAirportSearchTermChanged>(
      _onArrivalAirportSearchTermChanged,
      transformer: _debounceRestartable(const Duration(milliseconds: 500)), // Use transformer
    );
    on<TravelFormArrivalAirportSelected>(_onArrivalAirportSelected);
    // Travel Dates
    on<TravelFormDateRangeSelected>(_onDateRangeSelected);
    // Nationality
    on<TravelFormNationalitySearchTermChanged>(
      _onNationalitySearchTermChanged,
      transformer: _debounceRestartable(const Duration(milliseconds: 500)),
    );
    on<TravelFormNationalitySelected>(_onNationalitySelected);
    // Travel Purposes
    on<LoadTravelPurposesEvent>(_onLoadTravelPurposes);
    on<ToggleTravelPurposeEvent>(_onToggleTravelPurpose);
    // Form Submission
    on<SubmitTravelFormEvent>(_onSubmitTravelForm);
  }

  /// Initialize all required services
  Future<void> _initializeServices() async {
    try {
      await _countryService.initialize();
    } catch (e) {
      // Service has fallback mechanism, so we can continue even if initialization fails
      // But we should log the error
    }
  }

  void _onStarted(TravelFormStarted event, Emitter<TravelFormState> emit) {
    emit(state.copyWith());
  }

  void _onNextStepRequested(TravelFormNextStepRequested event, Emitter<TravelFormState> emit) {
    // TODO: Add validation for current step before proceeding
    if (state.currentStep < state.totalSteps - 1) {
      emit(state.copyWith(currentStep: state.currentStep + 1));
    }
  }

  void _onPreviousStepRequested(TravelFormPreviousStepRequested event, Emitter<TravelFormState> emit) {
    if (state.currentStep > 0) {
      emit(state.copyWith(currentStep: state.currentStep - 1));
    }
  }

  // --- Departure Airport Handlers ---
  // The transformer handles debouncing and cancellation of previous requests.
  Future<void> _onDepartureAirportSearchTermChanged(
    TravelFormDepartureAirportSearchTermChanged event,
    Emitter<TravelFormState> emit,
  ) async {
    // Made async
    emit(state.copyWith(departureAirportSearchTerm: event.searchTerm, selectedDepartureAirport: () => null));

    if (event.searchTerm.length < 3) {
      emit(state.copyWith(departureAirportSuggestions: [], isDepartureAirportLoading: false));
      return;
    }
    emit(state.copyWith(isDepartureAirportLoading: true));

    try {
      final suggestions = await _airportRepository.searchAirports(event.searchTerm);
      emit(
        state.copyWith(
          departureAirportSuggestions: suggestions,
          isDepartureAirportLoading: false,
          errorMessage: () => null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isDepartureAirportLoading: false,
          departureAirportSuggestions: [],
          errorMessage: () => e.toString(),
        ),
      );
    }
  }

  void _onDepartureAirportSelected(TravelFormDepartureAirportSelected event, Emitter<TravelFormState> emit) {
    emit(
      state.copyWith(
        selectedDepartureAirport: () => event.airport,
        departureAirportSearchTerm: event.airport.name,
        departureAirportSuggestions: [],
      ),
    );
  }

  // --- Arrival Airport Handlers ---
  // The transformer handles debouncing and cancellation of previous requests.
  Future<void> _onArrivalAirportSearchTermChanged(
    TravelFormArrivalAirportSearchTermChanged event,
    Emitter<TravelFormState> emit,
  ) async {
    // Made async
    emit(state.copyWith(arrivalAirportSearchTerm: event.searchTerm, selectedArrivalAirport: () => null));

    if (event.searchTerm.length < 3) {
      emit(state.copyWith(arrivalAirportSuggestions: [], isArrivalAirportLoading: false));
      return;
    }
    emit(state.copyWith(isArrivalAirportLoading: true));

    try {
      final suggestions = await _airportRepository.searchAirports(event.searchTerm);
      emit(
        state.copyWith(
          arrivalAirportSuggestions: suggestions,
          isArrivalAirportLoading: false,
          errorMessage: () => null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(isArrivalAirportLoading: false, arrivalAirportSuggestions: [], errorMessage: () => e.toString()),
      );
    }
  }

  void _onArrivalAirportSelected(TravelFormArrivalAirportSelected event, Emitter<TravelFormState> emit) {
    emit(
      state.copyWith(
        selectedArrivalAirport: () => event.airport,
        arrivalAirportSearchTerm: event.airport.name,
        arrivalAirportSuggestions: [],
      ),
    );
  }

  // --- Travel Dates Handler ---
  void _onDateRangeSelected(TravelFormDateRangeSelected event, Emitter<TravelFormState> emit) {
    if (event.dateRange.end.isBefore(event.dateRange.start)) {
      emit(
        state.copyWith(
          errorMessage: () => "End date cannot be before start date. See AppLocalizations.errorInvalidDateRange",
        ),
      );
      return;
    }
    emit(state.copyWith(selectedDateRange: () => event.dateRange, errorMessage: () => null));
  }

  // --- Nationality Handlers ---
  Future<void> _onNationalitySearchTermChanged(
    TravelFormNationalitySearchTermChanged event,
    Emitter<TravelFormState> emit,
  ) async {
    emit(state.copyWith(nationalitySearchTerm: event.searchTerm, selectedNationality: () => null));

    if (event.searchTerm.length < 2) {
      emit(state.copyWith(nationalitySuggestions: [], isNationalityLoading: false));
      return;
    }
    emit(state.copyWith(isNationalityLoading: true));

    try {
      final suggestions = await _countryService.searchCountries(event.searchTerm);
      emit(state.copyWith(nationalitySuggestions: suggestions, isNationalityLoading: false, errorMessage: () => null));
    } catch (e) {
      emit(state.copyWith(isNationalityLoading: false, nationalitySuggestions: [], errorMessage: () => e.toString()));
    }
  }

  void _onNationalitySelected(TravelFormNationalitySelected event, Emitter<TravelFormState> emit) {
    emit(
      state.copyWith(
        selectedNationality: () => event.country,
        nationalitySearchTerm: event.country.name,
        nationalitySuggestions: [],
      ),
    );
  }

  // --- Travel Purpose Handlers ---
  Future<void> _onLoadTravelPurposes(LoadTravelPurposesEvent event, Emitter<TravelFormState> emit) async {
    emit(state.copyWith(isTravelPurposesLoading: true));

    try {
      final purposes = await _travelPurposeService.getTravelPurposes();
      emit(state.copyWith(availableTravelPurposes: purposes, isTravelPurposesLoading: false, errorMessage: () => null));
    } catch (e) {
      emit(state.copyWith(isTravelPurposesLoading: false, errorMessage: () => e.toString()));
    }
  }

  void _onToggleTravelPurpose(ToggleTravelPurposeEvent event, Emitter<TravelFormState> emit) {
    final currentPurposes = List<TravelPurpose>.from(state.selectedTravelPurposes);

    if (event.isSelected) {
      // Add purpose if not already in the list
      if (!currentPurposes.any((p) => p.id == event.purpose.id)) {
        currentPurposes.add(event.purpose);
      }
    } else {
      // Remove purpose if it exists in the list
      currentPurposes.removeWhere((p) => p.id == event.purpose.id);
    }

    emit(state.copyWith(selectedTravelPurposes: currentPurposes));
  }

  // --- Form Submission Handler ---
  Future<void> _onSubmitTravelForm(SubmitTravelFormEvent event, Emitter<TravelFormState> emit) async {
    // Check if form is valid before submission
    if (!state.isFormValid) {
      emit(
        state.copyWith(
          formSubmissionStatus: FormSubmissionStatus.failure,
          errorMessage: () => "Please complete all required fields before submitting.",
        ),
      );
      return;
    }

    // Start submission process
    emit(state.copyWith(formSubmissionStatus: FormSubmissionStatus.submitting));

    try {
      if (state.selectedDepartureAirport == null ||
          state.selectedArrivalAirport == null ||
          state.selectedDateRange == null ||
          state.selectedNationality == null) {
        throw Exception('Missing required fields');
      }

      final travelInformation = TravelInformation(
        departureAirport: state.selectedDepartureAirport!,
        arrivalAirport: state.selectedArrivalAirport!,
        dateRange: state.selectedDateRange!,
        nationality: state.selectedNationality!,
        travelPurposes: state.selectedTravelPurposes,
      );
      // Simulate API call with delay
      final travelPlan = await _geminiRepository.generateTravelPlan(travelInformation);

      // Successful form submission
      emit(
        state.copyWith(
          formSubmissionStatus: FormSubmissionStatus.success,
          travelPlan: () => travelPlan,
          errorMessage: () => null,
        ),
      );
    } catch (e) {
      // Handle submission error
      emit(state.copyWith(formSubmissionStatus: FormSubmissionStatus.failure, errorMessage: () => e.toString()));
    }
  }
}
