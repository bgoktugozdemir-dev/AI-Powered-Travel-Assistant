import 'package:travel_assistant/common/utils/analytics/analytics_client.dart';

class AnalyticsFacade implements AnalyticsClient {
  const AnalyticsFacade(this._clients);

  final List<AnalyticsClient> _clients;

  @override
  void identifyUser(String userId) {
    _dispatch(
      (client) async => client.identifyUser(userId),
    );
  }

  @override
  void setAnalyticsCollectionEnabled(bool enabled) {
    _dispatch(
      (client) async => client.setAnalyticsCollectionEnabled(enabled),
    );
  }

  @override
  void logSearchDepartureAirport(String query) {
    _dispatch(
      (client) async => client.logSearchDepartureAirport(query.trim()),
    );
  }

  @override
  void logChooseDepartureAirport(String airport) {
    _dispatch(
      (client) async => client.logChooseDepartureAirport(airport),
    );
  }

  @override
  void logSearchArrivalAirport(String query) {
    _dispatch(
      (client) async => client.logSearchArrivalAirport(query.trim()),
    );
  }

  @override
  void logChooseArrivalAirport(String airport) {
    _dispatch(
      (client) async => client.logChooseArrivalAirport(airport),
    );
  }

  @override
  void logChooseTravelDates(String departureDate, String returnDate) {
    _dispatch(
      (client) async => client.logChooseTravelDates(departureDate, returnDate),
    );
  }

  @override
  void logSearchNationality(String query) {
    _dispatch(
      (client) async => client.logSearchNationality(query.trim()),
    );
  }

  @override
  void logChooseNationality(String nationality) {
    _dispatch(
      (client) async => client.logChooseNationality(nationality),
    );
  }

  @override
  void logSelectTravelPurpose(String purpose) {
    _dispatch(
      (client) async => client.logSelectTravelPurpose(purpose),
    );
  }

  @override
  void logUnselectTravelPurpose(String purpose) {
    _dispatch(
      (client) async => client.logUnselectTravelPurpose(purpose),
    );
  }

  @override
  void logSubmitTravelDetails() {
    _dispatch(
      (client) async => client.logSubmitTravelDetails(),
    );
  }

  @override
  void logMoveToNextStep(String step) {
    _dispatch(
      (client) async => client.logMoveToNextStep(step),
    );
  }

  @override
  void logMoveToPreviousStep(String step) {
    _dispatch(
      (client) async => client.logMoveToPreviousStep(step),
    );
  }

  @override
  void logPlanAnotherTrip() {
    _dispatch(
      (client) async => client.logPlanAnotherTrip(),
    );
  }

  Future<void> _dispatch(Future<void> Function(AnalyticsClient client) work) async {
    for (var client in _clients) {
      await work(client);
    }
  }
}
