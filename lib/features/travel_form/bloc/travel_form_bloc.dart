import 'dart:async'; // For Future and Timer

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:flutter/foundation.dart'; // For ValueGetter
import 'package:flutter/material.dart'; // For DateTimeRange
import 'package:travel_assistant/common/models/airport.dart'; // Import Airport model

part 'travel_form_event.dart';
part 'travel_form_state.dart';

/// {@template travel_form_bloc}
/// Manages the state for the travel input form.
/// {@endtemplate}
class TravelFormBloc extends Bloc<TravelFormEvent, TravelFormState> {
  Timer? _departureAirportDebounce;
  Timer? _arrivalAirportDebounce;
  // TODO: Inject an AirportRepository or similar service for actual API calls

  /// {@macro travel_form_bloc}
  TravelFormBloc() : super(const TravelFormState()) {
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
    emit(state.copyWith(departureAirportSearchTerm: event.searchTerm));

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
      
      await Future.delayed(const Duration(milliseconds: 750)); // Simulate API call
      
      if (emit.isDone) return;
      final suggestions = _getMockAirportSuggestions(event.searchTerm);
      if (emit.isDone) return;
      emit(state.copyWith(
        departureAirportSuggestions: suggestions,
        isDepartureAirportLoading: false,
      ));
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
    emit(state.copyWith(arrivalAirportSearchTerm: event.searchTerm));

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
      
      await Future.delayed(const Duration(milliseconds: 750)); // Simulate API call
      
      if (emit.isDone) return;
      final suggestions = _getMockAirportSuggestions(event.searchTerm);
      final currentState = this.state; 
      if (emit.isDone) return;
      emit(currentState.copyWith(
        arrivalAirportSuggestions: suggestions,
        isArrivalAirportLoading: false,
      ));
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

  List<Airport> _getMockAirportSuggestions(String query) {
    final allAirports = [
      const Airport(iataCode: 'IST', name: 'Istanbul Airport', country: 'Turkey'),
      const Airport(iataCode: 'SAW', name: 'Sabiha Gokcen Airport', country: 'Turkey'),
      const Airport(iataCode: 'ESB', name: 'Ankara Esenboga Airport', country: 'Turkey'),
      const Airport(iataCode: 'JFK', name: 'John F. Kennedy International Airport', country: 'USA'),
      const Airport(iataCode: 'LAX', name: 'Los Angeles International Airport', country: 'USA'),
      const Airport(iataCode: 'LHR', name: 'London Heathrow Airport', country: 'UK'),
      const Airport(iataCode: 'CDG', name: 'Charles de Gaulle Airport', country: 'France'),
      const Airport(iataCode: 'AMS', name: 'Amsterdam Schiphol', country: 'Netherlands'),
      const Airport(iataCode: 'FRA', name: 'Frankfurt Airport', country: 'Germany'),
      const Airport(iataCode: 'BCN', name: 'Barcelona El Prat Airport', country: 'Spain'),
    ];
    if (query.isEmpty) return [];
    return allAirports
        .where((airport) =>
            airport.name.toLowerCase().contains(query.toLowerCase()) ||
            airport.iataCode.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Future<void> close() {
    _departureAirportDebounce?.cancel();
    _arrivalAirportDebounce?.cancel();
    return super.close();
  }
} 