import 'package:travel_assistant/common/utils/analytics/analytics_client.dart';

class AnalyticsFacade implements AnalyticsClient {
  const AnalyticsFacade(this._clients);

  final List<AnalyticsClient> _clients;

  @override
  void identifyUser(String userId) async {
    await _dispatch(
      (client) async => client.identifyUser(userId),
    );
  }

  @override
  void setAnalyticsCollectionEnabled(bool enabled) async {
    await _dispatch(
      (client) async => client.setAnalyticsCollectionEnabled(enabled),
    );
  }

  @override
  void logSearchDepartureAirport(String query) async {
    await _dispatch(
      (client) async => client.logSearchDepartureAirport(query),
    );
  }

  @override
  void logChooseDepartureAirport(String airport) async {
    await _dispatch(
      (client) async => client.logChooseDepartureAirport(airport),
    );
  }

  @override
  void logSearchArrivalAirport(String query) async {
    await _dispatch(
      (client) async => client.logSearchArrivalAirport(query),
    );
  }

  @override
  void logChooseArrivalAirport(String airport) async {
    await _dispatch(
      (client) async => client.logChooseArrivalAirport(airport),
    );
  }

  @override
  void logChooseTravelDates(String departureDate, String returnDate) async {
    await _dispatch(
      (client) async => client.logChooseTravelDates(departureDate, returnDate),
    );
  }

  @override
  void logSearchNationality(String query) async {
    await _dispatch(
      (client) async => client.logSearchNationality(query),
    );
  }

  @override
  void logChooseNationality(String nationality) async {
    await _dispatch(
      (client) async => client.logChooseNationality(nationality),
    );
  }

  @override
  void logSelectTravelPurpose(String purpose) async {
    await _dispatch(
      (client) async => client.logSelectTravelPurpose(purpose),
    );
  }

  @override
  void logUnselectTravelPurpose(String purpose) async {
    await _dispatch(
      (client) async => client.logUnselectTravelPurpose(purpose),
    );
  }

  @override
  void logSubmitTravelDetails() async {
    await _dispatch(
      (client) async => client.logSubmitTravelDetails(),
    );
  }

  @override
  void logMoveToNextStep(String step) async {
    await _dispatch(
      (client) async => client.logMoveToNextStep(step),
    );
  }

  @override
  void logMoveToPreviousStep(String step) async {
    await _dispatch(
      (client) async => client.logMoveToPreviousStep(step),
    );
  }

  @override
  void logPlanAnotherTrip() async {
    await _dispatch(
      (client) async => client.logPlanAnotherTrip(),
    );
  }

  Future<void> _dispatch(Future<void> Function(AnalyticsClient client) work) async {
    for (var client in _clients) {
      await work(client);
    }
  }
}
