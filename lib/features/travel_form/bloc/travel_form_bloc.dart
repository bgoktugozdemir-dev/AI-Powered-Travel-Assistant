import 'dart:async'; // For Future and Timer

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart'; // For Dio and DioError
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:flutter/foundation.dart'; // For ValueGetter
import 'package:flutter/material.dart'; // For DateTimeRange
import 'package:travel_assistant/common/models/airport.dart'; // Import Airport model
import 'package:travel_assistant/common/repositories/airport_repository.dart'; // Import repository
import 'package:travel_assistant/common/services/airport_api_service.dart'; // Import service for direct instantiation (temp)

part 'travel_form_event.dart';
part 'travel_form_state.dart';

/// {@template travel_form_bloc}
/// Manages the state for the travel input form.
/// {@endtemplate}
class TravelFormBloc extends Bloc<TravelFormEvent, TravelFormState> {
  Timer? _departureAirportDebounce;
  Timer? _arrivalAirportDebounce;
  
  final AirportRepository _airportRepository;

  // TODO: Use proper Dependency Injection for AirportRepository
  TravelFormBloc() 
      : _airportRepository = AirportRepository(apiService: AirportApiService(Dio())), // Direct instantiation (temp)
        super(const TravelFormState()) {
    on<TravelFormStarted>(_onStarted);
    on<TravelFormNextStepRequested>(_onNextStepRequested);
    on<TravelFormPreviousStepRequested>(_onPreviousStepRequested);
    // Departure Airport
    on<TravelFormDepartureAirportSearchTermChanged>(_onDepartureAirportSearchTermChanged);
    on<TravelFormDepartureAirportSelected>(_onDepartureAirportSelected);
    // Arrival Airport
    on<TravelFormArrivalAirportSearchTermChanged>(_onArrivalAirportSearchTermChanged);
    on<TravelFormArrivalAirportSelected>(_onArrivalAirportSelected);
    // Travel Dates
    on<TravelFormDateRangeSelected>(_onDateRangeSelected);
  }

  void _onStarted(
    TravelFormStarted event,
    Emitter<TravelFormState> emit,
  ) {
    if (emit.isDone) return;
    emit(state.copyWith()); 
  }

  void _onNextStepRequested(
    TravelFormNextStepRequested event,
    Emitter<TravelFormState> emit,
  ) {
    if (emit.isDone) return;
    // TODO: Add validation for current step before proceeding
    if (state.currentStep < state.totalSteps - 1) {
      emit(state.copyWith(currentStep: state.currentStep + 1));
    }
  }

  void _onPreviousStepRequested(
    TravelFormPreviousStepRequested event,
    Emitter<TravelFormState> emit,
  ) {
    if (emit.isDone) return;
    if (state.currentStep > 0) {
      emit(state.copyWith(currentStep: state.currentStep - 1));
    }
  }

  // --- Departure Airport Handlers ---
  void _onDepartureAirportSearchTermChanged(
    TravelFormDepartureAirportSearchTermChanged event,
    Emitter<TravelFormState> emit,
  ) {
    if (emit.isDone) return;
    emit(state.copyWith(departureAirportSearchTerm: event.searchTerm, selectedDepartureAirport: () => null)); // Clear selection on new search

    if (_departureAirportDebounce?.isActive ?? false) _departureAirportDebounce!.cancel();
    _departureAirportDebounce = Timer(const Duration(milliseconds: 500), () async {
      if (emit.isDone) return;
      if (event.searchTerm.length < 2) {
        if (emit.isDone) return;
        emit(state.copyWith(departureAirportSuggestions: [], isDepartureAirportLoading: false));
        return;
      }
      if (emit.isDone) return;
      emit(state.copyWith(isDepartureAirportLoading: true));
      
      try {
        final suggestions = await _airportRepository.searchAirports(event.searchTerm);
        if (emit.isDone) return;
        emit(state.copyWith(
          departureAirportSuggestions: suggestions,
          isDepartureAirportLoading: false,
          errorMessage: () => null, // Clear error on success
        ));
      } catch (e) {
        if (emit.isDone) return;
        emit(state.copyWith(
          isDepartureAirportLoading: false,
          departureAirportSuggestions: [], // Clear suggestions on error
          errorMessage: () => e.toString(), // Show error message
        ));
      }
    });
  }

  void _onDepartureAirportSelected(
    TravelFormDepartureAirportSelected event,
    Emitter<TravelFormState> emit,
  ) {
    if (emit.isDone) return;
    emit(state.copyWith(
      selectedDepartureAirport: () => event.airport,
      departureAirportSearchTerm: event.airport.name, 
      departureAirportSuggestions: [], 
    ));
  }

  // --- Arrival Airport Handlers ---
  void _onArrivalAirportSearchTermChanged(
    TravelFormArrivalAirportSearchTermChanged event,
    Emitter<TravelFormState> emit,
  ) {
    if (emit.isDone) return;
    emit(state.copyWith(arrivalAirportSearchTerm: event.searchTerm, selectedArrivalAirport: () => null)); // Clear selection

    if (_arrivalAirportDebounce?.isActive ?? false) _arrivalAirportDebounce!.cancel();
    _arrivalAirportDebounce = Timer(const Duration(milliseconds: 500), () async {
      if (emit.isDone) return;
      if (event.searchTerm.length < 2) {
        if (emit.isDone) return;
        emit(state.copyWith(arrivalAirportSuggestions: [], isArrivalAirportLoading: false));
        return;
      }
      if (emit.isDone) return;
      emit(state.copyWith(isArrivalAirportLoading: true));
      
      try {
        final suggestions = await _airportRepository.searchAirports(event.searchTerm);
        if (emit.isDone) return;
        emit(state.copyWith(
          arrivalAirportSuggestions: suggestions,
          isArrivalAirportLoading: false,
          errorMessage: () => null, // Clear error on success
        ));
      } catch (e) {
        if (emit.isDone) return;
        emit(state.copyWith(
          isArrivalAirportLoading: false,
          arrivalAirportSuggestions: [], // Clear suggestions on error
          errorMessage: () => e.toString(), // Show error message
        ));
      }
    });
  }

  void _onArrivalAirportSelected(
    TravelFormArrivalAirportSelected event,
    Emitter<TravelFormState> emit,
  ) {
    if (emit.isDone) return;
    emit(state.copyWith(
      selectedArrivalAirport: () => event.airport,
      arrivalAirportSearchTerm: event.airport.name,
      arrivalAirportSuggestions: [], 
    ));
  }

  // --- Travel Dates Handler ---
  void _onDateRangeSelected(
    TravelFormDateRangeSelected event,
    Emitter<TravelFormState> emit,
  ) {
    if (emit.isDone) return;
    if (event.dateRange.end.isBefore(event.dateRange.start)) {
      // TODO: This error message is set directly. Consider if it should come from AppLocalizations.
      // For BLoC-level errors that are not directly tied to a specific UI build context,
      // it might be acceptable to have the string here, or pass a localized string from UI if preferred.
      // For now, leaving as is, but it will not be automatically localized based on current AppLocalizations instance.
      // A better approach might be to emit an error *code* or specific error state, and let UI decide localization.
      emit(state.copyWith(errorMessage: () => "End date cannot be before start date. See AppLocalizations.errorInvalidDateRange")); // Placeholder for actual localization strategy
      return;
    }
    emit(state.copyWith(
      selectedDateRange: () => event.dateRange,
      errorMessage: () => null, 
    ));
  }

  @override
  Future<void> close() {
    _departureAirportDebounce?.cancel();
    _arrivalAirportDebounce?.cancel();
    return super.close();
  }
} 