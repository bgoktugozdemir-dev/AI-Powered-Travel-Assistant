part of 'travel_form_bloc.dart';

/// Base class for all events related to the travel form.
@immutable
abstract class TravelFormEvent extends Equatable {
  /// Creates a [TravelFormEvent].
  const TravelFormEvent();

  @override
  List<Object?> get props => [];
}

/// Event to initialize or load initial form data.
class TravelFormStarted extends TravelFormEvent {}

/// Event triggered when the user wants to go to the next step.
class TravelFormNextStepRequested extends TravelFormEvent {}

/// Event triggered when the user wants to go to the previous step.
class TravelFormPreviousStepRequested extends TravelFormEvent {}

/// Event triggered when the departure airport search term changes.
class TravelFormDepartureAirportSearchTermChanged extends TravelFormEvent {
  /// The new search term.
  final String searchTerm;

  /// Creates a [TravelFormDepartureAirportSearchTermChanged] event.
  const TravelFormDepartureAirportSearchTermChanged(this.searchTerm);

  @override
  List<Object?> get props => [searchTerm];
}

/// Event triggered when a departure airport is selected from suggestions.
class TravelFormDepartureAirportSelected extends TravelFormEvent {
  /// The selected airport.
  final Airport airport;

  /// Creates a [TravelFormDepartureAirportSelected] event.
  const TravelFormDepartureAirportSelected(this.airport);

  @override
  List<Object?> get props => [airport];
}

// TODO: Add events for arrival airport, dates, nationality, purposes, submission, etc. 