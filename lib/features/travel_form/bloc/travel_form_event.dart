part of 'travel_form_bloc.dart';

/// Base class for all events related to the travel form.
@immutable
abstract class TravelFormEvent extends Equatable {
  /// Creates a [TravelFormEvent].
  const TravelFormEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered to initialize services.
class TravelFormInitializeServices extends TravelFormEvent {
  /// Creates a [TravelFormInitializeServices] event.
  const TravelFormInitializeServices();
}

/// Event to initialize or load initial form data.
class TravelFormStarted extends TravelFormEvent {}

/// Event triggered when the user wants to go to the next step.
class TravelFormNextStepRequested extends TravelFormEvent {}

/// Event triggered when the user wants to go to the previous step.
class TravelFormPreviousStepRequested extends TravelFormEvent {
  /// The source of the event.
  final SubmitTravelDetailsSource source;

  /// Creates a [TravelFormPreviousStepRequested] event.
  const TravelFormPreviousStepRequested({required this.source});

  @override
  List<Object?> get props => [source];
}

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

/// Event triggered when the arrival airport search term changes.
class TravelFormArrivalAirportSearchTermChanged extends TravelFormEvent {
  /// The new search term.
  final String searchTerm;

  /// Creates a [TravelFormArrivalAirportSearchTermChanged] event.
  const TravelFormArrivalAirportSearchTermChanged(this.searchTerm);

  @override
  List<Object?> get props => [searchTerm];
}

/// Event triggered when an arrival airport is selected from suggestions.
class TravelFormArrivalAirportSelected extends TravelFormEvent {
  /// The selected airport.
  final Airport airport;

  /// Creates a [TravelFormArrivalAirportSelected] event.
  const TravelFormArrivalAirportSelected(this.airport);

  @override
  List<Object?> get props => [airport];
}

/// Event triggered when a date range is selected.
class TravelFormDateRangeSelected extends TravelFormEvent {
  /// The selected date range.
  final DateTimeRange dateRange;

  /// Creates a [TravelFormDateRangeSelected] event.
  const TravelFormDateRangeSelected(this.dateRange);

  @override
  List<Object?> get props => [dateRange];
}

/// Event triggered when the nationality search term changes.
class TravelFormNationalitySearchTermChanged extends TravelFormEvent {
  /// The new search term.
  final String searchTerm;

  /// Creates a [TravelFormNationalitySearchTermChanged] event.
  const TravelFormNationalitySearchTermChanged(this.searchTerm);

  @override
  List<Object?> get props => [searchTerm];
}

/// Event triggered when a nationality (country) is selected from suggestions.
class TravelFormNationalitySelected extends TravelFormEvent {
  /// The selected country.
  final Country country;

  /// Creates a [TravelFormNationalitySelected] event.
  const TravelFormNationalitySelected(this.country);

  @override
  List<Object?> get props => [country];
}

/// Event triggered to load available travel purposes.
class LoadTravelPurposesEvent extends TravelFormEvent {
  /// Creates a [LoadTravelPurposesEvent] event.
  const LoadTravelPurposesEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered when a travel purpose is toggled (selected or unselected).
class ToggleTravelPurposeEvent extends TravelFormEvent {
  /// The travel purpose being toggled.
  final TravelPurpose purpose;

  /// Whether the purpose is being selected (true) or unselected (false).
  final bool isSelected;

  /// Creates a [ToggleTravelPurposeEvent] event.
  const ToggleTravelPurposeEvent({
    required this.purpose,
    required this.isSelected,
  });

  @override
  List<Object?> get props => [purpose, isSelected];
}

/// Event triggered when the form is submitted to generate a travel plan.
class SubmitTravelFormEvent extends TravelFormEvent {
  /// The locale for the response language.
  final String locale;

  /// The source of the event.
  final SubmitTravelDetailsSource source;

  /// Creates a [SubmitTravelFormEvent] event.
  const SubmitTravelFormEvent({required this.locale, required this.source});

  @override
  List<Object?> get props => [locale, source];
}

/// Event triggered to retry country service initialization.
class RetryCountryServiceEvent extends TravelFormEvent {
  /// Creates a [RetryCountryServiceEvent] event.
  const RetryCountryServiceEvent();
}
