import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:travel_assistant/common/utils/analytics/analytics_client.dart';
import 'package:travel_assistant/common/utils/analytics/data/submit_travel_details_source.dart';

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
  static const String submitTravelDetailsErrorEventName = 'Submit Travel Details Error';
  static const String moveToNextStepEventName = 'Move to Next Step';
  static const String moveToPreviousStepEventName = 'Move to Previous Step';
  static const String planAnotherTripEventName = 'Plan Another Trip';
  static const String llmPromptEventName = 'LLM Prompt';
  static const String llmResponseEventName = 'LLM Response';

  static const String searchQueryParameterName = 'search_query';
  static const String airportParameterName = 'airport';
  static const String departureDateParameterName = 'departure_date';
  static const String returnDateParameterName = 'return_date';
  static const String nationalityParameterName = 'nationality';
  static const String purposeParameterName = 'purpose';
  static const String stepParameterName = 'step';
  static const String errorParameterName = 'error';
  static const String sourceParameterName = 'source';
  static const String modelParameterName = 'model';
  static const String promptParameterName = 'prompt';
  static const String responseParameterName = 'response';
  static const String durationMsParameterName = 'duration_ms';
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
  Future<void> logSubmitTravelDetails(SubmitTravelDetailsSource source) async {
    await _mixpanel.track(
      _Constants.submitTravelDetailsEventName,
      properties: {
        _Constants.sourceParameterName: source.name,
      },
    );
  }

  @override
  Future<void> logTravelFormError(String error, String step) async {
    await _mixpanel.track(
      _Constants.submitTravelDetailsErrorEventName,
      properties: {
        _Constants.errorParameterName: error,
        _Constants.stepParameterName: step,
      },
    );
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

  @override
  void logLLMPrompt(String model, String prompt) {
    _mixpanel.track(
      _Constants.llmPromptEventName,
      properties: {
        _Constants.modelParameterName: model,
        _Constants.promptParameterName: prompt,
      },
    );
  }

  @override
  void logLLMResponse(String model, String prompt, String response, int durationMs) {
    _mixpanel.track(
      _Constants.llmResponseEventName,
      properties: {
        _Constants.modelParameterName: model,
        _Constants.promptParameterName: prompt,
        _Constants.responseParameterName: response,
        _Constants.durationMsParameterName: durationMs,
      },
    );
  }
}
