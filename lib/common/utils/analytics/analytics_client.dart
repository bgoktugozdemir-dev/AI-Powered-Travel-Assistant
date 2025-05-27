import 'dart:async';

abstract class AnalyticsClient {
  FutureOr<void> logSearchDepartureAirport(String query);
  FutureOr<void> logChooseDepartureAirport(String airport);
  FutureOr<void> logSearchArrivalAirport(String query);
  FutureOr<void> logChooseArrivalAirport(String airport);
  FutureOr<void> logChooseTravelDates(String departureDate, String returnDate);
  FutureOr<void> logSearchNationality(String query);
  FutureOr<void> logChooseNationality(String nationality);
  FutureOr<void> logSelectTravelPurpose(String purpose);
  FutureOr<void> logUnselectTravelPurpose(String purpose);
  FutureOr<void> logSubmitTravelDetails();
  FutureOr<void> logMoveToNextStep(String step);
  FutureOr<void> logMoveToPreviousStep(String step);
  FutureOr<void> logPlanAnotherTrip();
}
