import 'package:travel_assistant/common/utils/analytics/analytics_client.dart';
import 'package:travel_assistant/common/utils/logger/logger.dart';

class LoggerAnalyticsClient implements AnalyticsClient {
  const LoggerAnalyticsClient();

  @override
  void identifyUser(String userId) async {
    appLogger.d('Identifying user: $userId');
  }

  @override
  void setAnalyticsCollectionEnabled(bool enabled) async {
    appLogger.d('Setting analytics collection enabled: $enabled');
  }

  @override
  void logSearchDepartureAirport(String query) async {
    appLogger.d('Logging search departure airport: $query');
  }

  @override
  void logChooseDepartureAirport(String airport) async {
    appLogger.d('Logging choose departure airport: $airport');
  }

  @override
  void logSearchArrivalAirport(String query) async {
    appLogger.d('Logging search arrival airport: $query');
  }

  @override
  void logChooseArrivalAirport(String airport) async {
    appLogger.d('Logging choose arrival airport: $airport');
  }

  @override
  void logChooseTravelDates(String departureDate, String returnDate) async {
    appLogger.d('Logging choose travel dates: $departureDate, $returnDate');
  }

  @override
  void logSearchNationality(String query) async {
    appLogger.d('Logging search nationality: $query');
  }

  @override
  void logChooseNationality(String nationality) async {
    appLogger.d('Logging choose nationality: $nationality');
  }

  @override
  void logSelectTravelPurpose(String purpose) async {
    appLogger.d('Logging select travel purpose: $purpose');
  }

  @override
  void logUnselectTravelPurpose(String purpose) async {
    appLogger.d('Logging unselect travel purpose: $purpose');
  }

  @override
  void logSubmitTravelDetails() async {
    appLogger.d('Logging submit travel details');
  }

  @override
  void logMoveToNextStep(String step) async {
    appLogger.d('Logging move to next step: $step');
  }

  @override
  void logMoveToPreviousStep(String step) async {
    appLogger.d('Logging move to previous step: $step');
  }

  @override
  void logPlanAnotherTrip() async {
    appLogger.d('Logging plan another trip');
  }
}
