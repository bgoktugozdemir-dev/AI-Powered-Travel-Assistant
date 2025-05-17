import 'dart:async'; // For Future and Timer

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:flutter/foundation.dart'; // For ValueGetter
import 'package:travel_assistant/common/models/airport.dart'; // Import Airport model

part 'travel_form_event.dart';
part 'travel_form_state.dart';

/// {@template travel_form_bloc}
/// Manages the state for the travel input form.
/// {@endtemplate}
class TravelFormBloc extends Bloc<TravelFormEvent, TravelFormState> {
  Timer? _debounce;
  // TODO: Inject an AirportRepository or similar service for actual API calls

  /// {@macro travel_form_bloc}
  TravelFormBloc() : super(const TravelFormState()) {
    on<TravelFormStarted>(_onStarted);
    on<TravelFormNextStepRequested>(_onNextStepRequested);
    on<TravelFormPreviousStepRequested>(_onPreviousStepRequested);
    on<TravelFormDepartureAirportSearchTermChanged>(_onDepartureAirportSearchTermChanged);
    on<TravelFormDepartureAirportSelected>(_onDepartureAirportSelected);
  }

  void _onStarted(
    TravelFormStarted event,
    Emitter<TravelFormState> emit,
  ) {
    // Optionally load any initial data common to the whole form here
    emit(state.copyWith()); // Emit current state or a slightly modified one
  }

  void _onNextStepRequested(
    TravelFormNextStepRequested event,
    Emitter<TravelFormState> emit,
  ) {
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

  void _onDepartureAirportSearchTermChanged(
    TravelFormDepartureAirportSearchTermChanged event,
    Emitter<TravelFormState> emit,
  ) {
    emit(state.copyWith(departureAirportSearchTerm: event.searchTerm));

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (event.searchTerm.length < 2) {
        emit(state.copyWith(departureAirportSuggestions: [], isDepartureAirportLoading: false));
        return;
      }
      emit(state.copyWith(isDepartureAirportLoading: true));
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 750));
      final suggestions = _getMockAirportSuggestions(event.searchTerm);
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
    emit(state.copyWith(
      selectedDepartureAirport: () => event.airport,
      departureAirportSearchTerm: event.airport.name,
      departureAirportSuggestions: [],
    ));
  }

  List<Airport> _getMockAirportSuggestions(String query) {
    // Mock implementation - replace with actual API call
    final allAirports = [
      const Airport(iataCode: 'IST', name: 'Istanbul Airport', country: 'Turkey'),
      const Airport(iataCode: 'SAW', name: 'Sabiha Gokcen Airport', country: 'Turkey'),
      const Airport(iataCode: 'ESB', name: 'Ankara Esenboga Airport', country: 'Turkey'),
      const Airport(iataCode: 'JFK', name: 'John F. Kennedy International Airport', country: 'USA'),
      const Airport(iataCode: 'LAX', name: 'Los Angeles International Airport', country: 'USA'),
      const Airport(iataCode: 'LHR', name: 'London Heathrow Airport', country: 'UK'),
      const Airport(iataCode: 'CDG', name: 'Charles de Gaulle Airport', country: 'France'),
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
    _debounce?.cancel();
    return super.close();
  }
} 