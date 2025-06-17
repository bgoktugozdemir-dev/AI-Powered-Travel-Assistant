import 'dart:developer';

import 'package:travel_assistant/common/utils/analytics/analytics_client.dart';
import 'package:travel_assistant/common/utils/analytics/data/submit_travel_details_source.dart';

class LoggerAnalyticsClient implements AnalyticsClient {
  const LoggerAnalyticsClient();

  void _log(String message) {
    log(message, name: 'LoggerAnalyticsClient');
  }

  @override
  void identifyUser(String userId) async {
    _log('Identifying user: $userId');
  }

  @override
  void setAnalyticsCollectionEnabled(bool enabled) {
    _log('Setting analytics collection enabled: $enabled');
  }

  @override
  void logSearchDepartureAirport(String query) {
    _log('Logging search departure airport: $query');
  }

  @override
  void logChooseDepartureAirport(String airport) {
    _log('Logging choose departure airport: $airport');
  }

  @override
  void logSearchArrivalAirport(String query) {
    _log('Logging search arrival airport: $query');
  }

  @override
  void logChooseArrivalAirport(String airport) {
    _log('Logging choose arrival airport: $airport');
  }

  @override
  void logChooseTravelDates(String departureDate, String returnDate) {
    _log('Logging choose travel dates: $departureDate, $returnDate');
  }

  @override
  void logSearchNationality(String query) {
    _log('Logging search nationality: $query');
  }

  @override
  void logChooseNationality(String nationality) {
    _log('Logging choose nationality: $nationality');
  }

  @override
  void logSelectTravelPurpose(String purpose) {
    _log('Logging select travel purpose: $purpose');
  }

  @override
  void logUnselectTravelPurpose(String purpose) {
    _log('Logging unselect travel purpose: $purpose');
  }

  @override
  void logSubmitTravelDetails(SubmitTravelDetailsSource source) {
    _log('Logging submit travel details: ${source.name}');
  }

  @override
  void logTravelFormError(String error, String step) {
    _log('Logging submit travel details error: $error on step: $step');
  }

  @override
  void logMoveToNextStep(String step) {
    _log('Logging move to next step: $step');
  }

  @override
  void logMoveToPreviousStep(String step) {
    _log('Logging move to previous step: $step');
  }

  @override
  void logPlanAnotherTrip() {
    _log('Logging plan another trip');
  }

  @override
  void logLLMPrompt(String model, String prompt) {
    _log('<-- Model: $model\nPrompt: $prompt -->');
  }

  @override
  void logLLMResponse(String model, String prompt, String response, int durationMs) {
    _log('--> Model: $model\nPrompt: $prompt\nResponse: $response\nDuration: $durationMs <--');
  }
}
