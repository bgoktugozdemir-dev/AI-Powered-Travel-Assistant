import 'dart:async'; // For Future

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart'; // For Dio and DioError
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:flutter/foundation.dart'; // For ValueGetter
import 'package:flutter/material.dart'; // For DateTimeRange
import 'package:travel_assistant/common/models/airport.dart'; // Import Airport model
import 'package:travel_assistant/common/repositories/airport_repository.dart'; // Import repository
import 'package:travel_assistant/common/services/airport_api_service.dart'; // Import service for direct instantiation (temp)
import 'package:travel_assistant/common/services/api_logger_interceptor.dart'; // Import the interceptor

import 'package:rxdart/rxdart.dart'; // Added
import 'package:bloc_concurrency/bloc_concurrency.dart'; // Added

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
  final AirportRepository _airportRepository;

  // TODO: Use proper Dependency Injection for AirportRepository and Dio instance
  TravelFormBloc()
      : _airportRepository = AirportRepository(
            apiService: AirportApiService(
              Dio()..interceptors.add(ApiLoggerInterceptor()),
            )
          ),
        super(const TravelFormState()) {
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
  }

  void _onStarted(
    TravelFormStarted event,
    Emitter<TravelFormState> emit,
  ) {
    emit(state.copyWith());
  }

  void _onNextStepRequested(
    TravelFormNextStepRequested event,
    Emitter<TravelFormState> emit,
  ) {
    // TODO: Add validation for current step before proceeding
    if (state.currentStep < state.totalSteps - 1) {
      emit(state.copyWith(currentStep: state.currentStep + 1));
    }
  }

  void _onPreviousStepRequested(
    TravelFormPreviousStepRequested event,
    Emitter<TravelFormState> emit,
  ) {
    if (state.currentStep > 0) {
      emit(state.copyWith(currentStep: state.currentStep - 1));
    }
  }

  // --- Departure Airport Handlers ---
  // The transformer handles debouncing and cancellation of previous requests.
  Future<void> _onDepartureAirportSearchTermChanged(
    TravelFormDepartureAirportSearchTermChanged event,
    Emitter<TravelFormState> emit,
  ) async { // Made async
    emit(state.copyWith(departureAirportSearchTerm: event.searchTerm, selectedDepartureAirport: () => null));

    if (event.searchTerm.length < 3) {
      emit(state.copyWith(departureAirportSuggestions: [], isDepartureAirportLoading: false));
      return;
    }
    emit(state.copyWith(isDepartureAirportLoading: true));

    try {
      final suggestions = await _airportRepository.searchAirports(event.searchTerm);
      emit(state.copyWith(
        departureAirportSuggestions: suggestions,
        isDepartureAirportLoading: false,
        errorMessage: () => null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isDepartureAirportLoading: false,
        departureAirportSuggestions: [],
        errorMessage: () => e.toString(),
      ));
    }
  }

  void _onDepartureAirportSelected(
    TravelFormDepartureAirportSelected event,
    Emitter<TravelFormState> emit,
  ) {
    emit(state.copyWith(
      selectedDepartureAirport: () => event.airport,
      departureAirportSearchTerm: event.airport.name,
      departureAirportSuggestions: [],
    ));
  }

  // --- Arrival Airport Handlers ---
  // The transformer handles debouncing and cancellation of previous requests.
  Future<void> _onArrivalAirportSearchTermChanged(
    TravelFormArrivalAirportSearchTermChanged event,
    Emitter<TravelFormState> emit,
  ) async { // Made async
    emit(state.copyWith(arrivalAirportSearchTerm: event.searchTerm, selectedArrivalAirport: () => null));

    if (event.searchTerm.length < 3) {
      emit(state.copyWith(arrivalAirportSuggestions: [], isArrivalAirportLoading: false));
      return;
    }
    emit(state.copyWith(isArrivalAirportLoading: true));

    try {
      final suggestions = await _airportRepository.searchAirports(event.searchTerm);
      emit(state.copyWith(
        arrivalAirportSuggestions: suggestions,
        isArrivalAirportLoading: false,
        errorMessage: () => null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isArrivalAirportLoading: false,
        arrivalAirportSuggestions: [],
        errorMessage: () => e.toString(),
      ));
    }
  }

  void _onArrivalAirportSelected(
    TravelFormArrivalAirportSelected event,
    Emitter<TravelFormState> emit,
  ) {
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
    if (event.dateRange.end.isBefore(event.dateRange.start)) {
      emit(state.copyWith(errorMessage: () => "End date cannot be before start date. See AppLocalizations.errorInvalidDateRange"));
      return;
    }
    emit(state.copyWith(
      selectedDateRange: () => event.dateRange,
      errorMessage: () => null,
    ));
  }
} 