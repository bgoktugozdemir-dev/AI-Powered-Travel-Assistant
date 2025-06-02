import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:travel_assistant/common/utils/analytics/analytics_client.dart';

abstract class _Constants {
  static const String searchDepartureAirportEventName = 'search_departure_airport';
  static const String chooseDepartureAirportEventName = 'choose_departure_airport';
  static const String searchArrivalAirportEventName = 'search_arrival_airport';
  static const String chooseArrivalAirportEventName = 'choose_arrival_airport';
  static const String chooseTravelDatesEventName = 'choose_travel_dates';
  static const String searchNationalityEventName = 'search_nationality';
  static const String chooseNationalityEventName = 'choose_nationality';
  static const String selectTravelPurposeEventName = 'select_travel_purpose';
  static const String unselectTravelPurposeEventName = 'unselect_travel_purpose';
  static const String submitTravelDetailsEventName = 'submit_travel_details';
  static const String submitTravelDetailsErrorEventName = 'submit_travel_details_error';
  static const String moveToNextStepEventName = 'move_to_next_step';
  static const String moveToPreviousStepEventName = 'move_to_previous_step';
  static const String planAnotherTripEventName = 'plan_another_trip';

  static const String searchQueryParameterName = 'search_query';
  static const String airportParameterName = 'airport';
  static const String departureDateParameterName = 'departure_date';
  static const String returnDateParameterName = 'return_date';
  static const String nationalityParameterName = 'nationality';
  static const String purposeParameterName = 'purpose';
  static const String stepParameterName = 'step';
  static const String errorParameterName = 'error';
}

class FirebaseAnalyticsClient implements AnalyticsClient {
  const FirebaseAnalyticsClient({required FirebaseAnalytics analytics}) : _analytics = analytics;

  final FirebaseAnalytics _analytics;

  @override
  Future<void> identifyUser(String userId) async {
    await _analytics.setUserId(id: userId);
  }

  @override
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    await _analytics.setAnalyticsCollectionEnabled(enabled);
  }

  @override
  Future<void> logSearchDepartureAirport(String query) async {
    await _analytics.logEvent(
      name: _Constants.searchDepartureAirportEventName,
      parameters: {
        _Constants.searchQueryParameterName: query,
      },
    );
  }

  @override
  Future<void> logChooseDepartureAirport(String airport) async {
    await _analytics.logEvent(
      name: _Constants.chooseDepartureAirportEventName,
      parameters: {
        _Constants.airportParameterName: airport,
      },
    );
  }

  @override
  Future<void> logSearchArrivalAirport(String query) async {
    await _analytics.logEvent(
      name: _Constants.searchArrivalAirportEventName,
      parameters: {
        _Constants.searchQueryParameterName: query,
      },
    );
  }

  @override
  Future<void> logChooseArrivalAirport(String airport) async {
    await _analytics.logEvent(
      name: _Constants.chooseArrivalAirportEventName,
      parameters: {
        _Constants.airportParameterName: airport,
      },
    );
  }

  @override
  Future<void> logChooseTravelDates(String departureDate, String returnDate) async {
    await _analytics.logEvent(
      name: _Constants.chooseTravelDatesEventName,
      parameters: {
        _Constants.departureDateParameterName: departureDate,
        _Constants.returnDateParameterName: returnDate,
      },
    );
  }

  @override
  Future<void> logSearchNationality(String query) async {
    await _analytics.logEvent(
      name: _Constants.searchNationalityEventName,
      parameters: {
        _Constants.searchQueryParameterName: query,
      },
    );
  }

  @override
  Future<void> logChooseNationality(String nationality) async {
    await _analytics.logEvent(
      name: _Constants.chooseNationalityEventName,
      parameters: {
        _Constants.nationalityParameterName: nationality,
      },
    );
  }

  @override
  Future<void> logSelectTravelPurpose(String purpose) async {
    await _analytics.logEvent(
      name: _Constants.selectTravelPurposeEventName,
      parameters: {
        _Constants.purposeParameterName: purpose,
      },
    );
  }

  @override
  Future<void> logUnselectTravelPurpose(String purpose) async {
    await _analytics.logEvent(
      name: _Constants.unselectTravelPurposeEventName,
      parameters: {
        _Constants.purposeParameterName: purpose,
      },
    );
  }

  @override
  Future<void> logSubmitTravelDetails() async {
    await _analytics.logEvent(
      name: _Constants.submitTravelDetailsEventName,
    );
  }

  @override
  Future<void> logTravelFormError(String error, String step) async {
    await _analytics.logEvent(
      name: _Constants.submitTravelDetailsErrorEventName,
      parameters: {
        _Constants.errorParameterName: error,
        _Constants.stepParameterName: step,
      },
    );
  }

  @override
  Future<void> logMoveToNextStep(String step) async {
    await _analytics.logEvent(
      name: _Constants.moveToNextStepEventName,
      parameters: {
        _Constants.stepParameterName: step,
      },
    );
  }

  @override
  Future<void> logMoveToPreviousStep(String step) async {
    await _analytics.logEvent(
      name: _Constants.moveToPreviousStepEventName,
      parameters: {
        _Constants.stepParameterName: step,
      },
    );
  }

  @override
  Future<void> logPlanAnotherTrip() async {
    await _analytics.logEvent(
      name: _Constants.planAnotherTripEventName,
    );
  }
}
