import 'package:travel_assistant/common/utils/analytics/analytics_client.dart';
import 'package:travel_assistant/common/utils/logger/logger.dart';

class LoggerAnalyticsClient implements AnalyticsClient {
  const LoggerAnalyticsClient();

  @override
  Future<void> identifyUser(String userId) async {
     appLogger.d('Identifying user: $userId');
   }

  @override
  void setAnalyticsCollectionEnabled(bool enabled) {
    appLogger.d('Setting analytics collection enabled: $enabled');
  }

  @override
  void logSearchDepartureAirport(String query) {
    appLogger.d('Logging search departure airport: $query');
  }

  @override
  void logChooseDepartureAirport(String airport) {
    appLogger.d('Logging choose departure airport: $airport');
  }

  @override
  void logSearchArrivalAirport(String query) {
    appLogger.d('Logging search arrival airport: $query');
  }

  @override
  void logChooseArrivalAirport(String airport) {
    appLogger.d('Logging choose arrival airport: $airport');
  }

  @override
  void logChooseTravelDates(String departureDate, String returnDate) {
    appLogger.d('Logging choose travel dates: $departureDate, $returnDate');
  }

  @override
  void logSearchNationality(String query) {
    appLogger.d('Logging search nationality: $query');
  }

  @override
  void logChooseNationality(String nationality) {
    appLogger.d('Logging choose nationality: $nationality');
  }

  @override
  void logSelectTravelPurpose(String purpose) {
    appLogger.d('Logging select travel purpose: $purpose');
  }

  @override
  void logUnselectTravelPurpose(String purpose) {
    appLogger.d('Logging unselect travel purpose: $purpose');
  }

  @override
  void logSubmitTravelDetails() {
    appLogger.d('Logging submit travel details');
  }

  @override
  void logMoveToNextStep(String step) {
    appLogger.d('Logging move to next step: $step');
  }

  @override
  void logMoveToPreviousStep(String step) {
    appLogger.d('Logging move to previous step: $step');
  }

  @override
  void logPlanAnotherTrip() {
    appLogger.d('Logging plan another trip');
  }
}
