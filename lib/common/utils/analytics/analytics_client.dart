import 'dart:async';

import 'package:travel_assistant/common/utils/analytics/data/submit_travel_details_source.dart';

abstract class AnalyticsClient {
  /// Identifies a user in analytics with the given [userId].
  FutureOr<void> identifyUser(String userId);

  /// Sets the analytics collection enabled flag.
  FutureOr<void> setAnalyticsCollectionEnabled(bool enabled);

  /// Logs when a user searches for a departure airport with the given [query].
  FutureOr<void> logSearchDepartureAirport(String query);

  /// Logs when a user selects a departure [airport].
  FutureOr<void> logChooseDepartureAirport(String airport);

  /// Logs when a user searches for an arrival airport with the given [query].
  FutureOr<void> logSearchArrivalAirport(String query);

  /// Logs when a user selects an arrival [airport].
  FutureOr<void> logChooseArrivalAirport(String airport);

  /// Logs when a user selects travel dates with [departureDate] and [returnDate].
  FutureOr<void> logChooseTravelDates(String departureDate, String returnDate);

  /// Logs when a user searches for a nationality with the given [query].
  FutureOr<void> logSearchNationality(String query);

  /// Logs when a user selects a [nationality].
  FutureOr<void> logChooseNationality(String nationality);

  /// Logs when a user selects a travel [purpose].
  FutureOr<void> logSelectTravelPurpose(String purpose);

  /// Logs when a user unselects a travel [purpose].
  FutureOr<void> logUnselectTravelPurpose(String purpose);

  /// Logs when a user submits their travel details with the given [source].
  FutureOr<void> logSubmitTravelDetails(SubmitTravelDetailsSource source);

  /// Logs when a user submits their travel details with an [error] on the given [step].
  FutureOr<void> logTravelFormError(String error, String step);

  /// Logs when a user moves to the next [step] in the travel form.
  FutureOr<void> logMoveToNextStep(String step);

  /// Logs when a user moves to the previous [step] in the travel form.
  FutureOr<void> logMoveToPreviousStep(String step);

  /// Logs when a user chooses to plan another trip.
  FutureOr<void> logPlanAnotherTrip();

  /// Logs when a user sends a [prompt] to the [model].
  FutureOr<void> logLLMPrompt(String model, String prompt);

  /// Logs when a user receives a [response] from the [model].
  FutureOr<void> logLLMResponse(
    String model,
    String prompt,
    String response,
    int durationMs,
  );
}
