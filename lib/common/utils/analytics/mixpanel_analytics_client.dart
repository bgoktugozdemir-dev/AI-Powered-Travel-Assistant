import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:travel_assistant/common/utils/analytics/analytics_client.dart';

abstract class _Constants {
  static const String searchDepartureAirportEventName = 'Search Departure Airport';
  static const String chooseDepartureAirportEventName = 'Choose Departure Airport';
  static const String searchArrivalAirportEventName = 'Search Arrival Airport';
  static const String chooseArrivalAirportEventName = 'Choose Arrival Airport';
  static const String chooseTravelDatesEventName = 'Choose Travel Dates';
  static const String searchNationalityEventName = 'Search Nationality';
  static const String chooseNationalityEventName = 'Choose Nationality';
  static const String selectTravelPurposeEventName = 'Select Travel Purpose';
  static const String unselectTravelPurposeEventName = 'Unselect Travel Purpose';
  static const String submitTravelDetailsEventName = 'Submit Travel Details';
  static const String moveToNextStepEventName = 'Move to Next Step';
  static const String moveToPreviousStepEventName = 'Move to Previous Step';
  static const String planAnotherTripEventName = 'Plan Another Trip';

  static const String searchQueryParameterName = 'search_query';
  static const String airportParameterName = 'airport';
  static const String departureDateParameterName = 'departure_date';
  static const String returnDateParameterName = 'return_date';
  static const String nationalityParameterName = 'nationality';
  static const String purposeParameterName = 'purpose';
  static const String stepParameterName = 'step';
}

class MixpanelAnalyticsClient implements AnalyticsClient {
  const MixpanelAnalyticsClient({required Mixpanel mixpanel}) : _mixpanel = mixpanel;

  final Mixpanel _mixpanel;

  @override
  Future<void> identifyUser(String userId) async {
    await _mixpanel.identify(userId);
  }

  @override
  void setAnalyticsCollectionEnabled(bool enabled) {
    if (enabled) {
      _mixpanel.optInTracking();
    } else {
      _mixpanel.optOutTracking();
    }
  }

  @override
  Future<void> logSearchDepartureAirport(String query) async {
    await _mixpanel.track(
      _Constants.searchDepartureAirportEventName,
      properties: {
        _Constants.searchQueryParameterName: query,
      },
    );
  }

  @override
  Future<void> logChooseDepartureAirport(String airport) async {
    await _mixpanel.track(
      _Constants.chooseDepartureAirportEventName,
      properties: {
        _Constants.airportParameterName: airport,
      },
    );
  }

  @override
  Future<void> logSearchArrivalAirport(String query) async {
    await _mixpanel.track(
      _Constants.searchArrivalAirportEventName,
      properties: {
        _Constants.searchQueryParameterName: query,
      },
    );
  }

  @override
  Future<void> logChooseArrivalAirport(String airport) async {
    await _mixpanel.track(
      _Constants.chooseArrivalAirportEventName,
      properties: {
        _Constants.airportParameterName: airport,
      },
    );
  }

  @override
  Future<void> logChooseTravelDates(String departureDate, String returnDate) async {
    await _mixpanel.track(
      _Constants.chooseTravelDatesEventName,
      properties: {
        _Constants.departureDateParameterName: departureDate,
        _Constants.returnDateParameterName: returnDate,
      },
    );
  }

  @override
  Future<void> logSearchNationality(String query) async {
    await _mixpanel.track(
      _Constants.searchNationalityEventName,
      properties: {
        _Constants.searchQueryParameterName: query,
      },
    );
  }

  @override
  Future<void> logChooseNationality(String nationality) async {
    await _mixpanel.track(
      _Constants.chooseNationalityEventName,
      properties: {
        _Constants.nationalityParameterName: nationality,
      },
    );
  }

  @override
  Future<void> logSelectTravelPurpose(String purpose) async {
    await _mixpanel.track(
      _Constants.selectTravelPurposeEventName,
      properties: {
        _Constants.purposeParameterName: purpose,
      },
    );
  }

  @override
  Future<void> logUnselectTravelPurpose(String purpose) async {
    await _mixpanel.track(
      _Constants.unselectTravelPurposeEventName,
      properties: {
        _Constants.purposeParameterName: purpose,
      },
    );
  }

  @override
  Future<void> logSubmitTravelDetails() async {
    await _mixpanel.track(_Constants.submitTravelDetailsEventName);
  }

  @override
  Future<void> logMoveToNextStep(String step) async {
    await _mixpanel.track(
      _Constants.moveToNextStepEventName,
      properties: {
        _Constants.stepParameterName: step,
      },
    );
  }

  @override
  Future<void> logMoveToPreviousStep(String step) async {
    await _mixpanel.track(
      _Constants.moveToPreviousStepEventName,
      properties: {
        _Constants.stepParameterName: step,
      },
    );
  }

  @override
  Future<void> logPlanAnotherTrip() async {
    await _mixpanel.track(_Constants.planAnotherTripEventName);
  }
}
