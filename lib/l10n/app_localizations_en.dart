// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Travel Assistant';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String travelFormStepTitle(int stepNumber) {
    return 'Step $stepNumber';
  }

  @override
  String get departureAirportStepTitle => 'Where are you flying from?';

  @override
  String get departureAirportHintText =>
      'Search departure airport (e.g., IST, Istanbul)';

  @override
  String get arrivalAirportStepTitle => 'Where are you flying to?';

  @override
  String get arrivalAirportHintText =>
      'Search arrival airport (e.g., JFK, New York)';

  @override
  String get travelDatesStepTitle => 'When are you travelling?';

  @override
  String get selectDatesButtonLabel => 'Select Travel Dates';

  @override
  String selectedDatesLabel(String startDate, String endDate) {
    return 'Selected: $startDate - $endDate';
  }

  @override
  String get noDatesSelected => 'No dates selected';

  @override
  String get nationalityStepTitle => 'What is your nationality?';

  @override
  String get nationalityHintText =>
      'Search your nationality (e.g., US, Turkey)';

  @override
  String selectedNationalityLabel(String nationalityName) {
    return 'Selected: $nationalityName';
  }

  @override
  String get travelPurposeStepTitle => 'What are your travel purposes?';

  @override
  String get selectTravelPurposes => 'Select Travel Purposes';

  @override
  String get selectTravelPurposesDescription =>
      'Choose one or more reasons for your trip. This helps us provide better recommendations.';

  @override
  String get selectedPurposes => 'Selected Purposes';

  @override
  String get noPurposesAvailable =>
      'No travel purposes available. Please try again later.';

  @override
  String get travelFormErrorTitle => 'Error Occurred';

  @override
  String validationErrorTravelPurposeMissing(
    int selectedTravelPurposes,
    int minimumTravelPurposes,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      minimumTravelPurposes,
      locale: localeName,
      other:
          'Please select at least $minimumTravelPurposes travel purposes. You have selected $selectedTravelPurposes.',
      one:
          'Please select at least 1 travel purpose. You have selected $selectedTravelPurposes.',
    );
    return '$_temp0';
  }

  @override
  String validationErrorTravelPurposeTooMany(
    int selectedTravelPurposes,
    int maximumTravelPurposes,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      maximumTravelPurposes,
      locale: localeName,
      other:
          'Please select no more than $maximumTravelPurposes travel purposes. You have selected $selectedTravelPurposes.',
      one:
          'Please select no more than 1 travel purpose. You have selected $selectedTravelPurposes.',
    );
    return '$_temp0';
  }

  @override
  String get validationErrorNationalityMissing =>
      'Please select your nationality.';

  @override
  String get errorInvalidDateRange => 'End date cannot be before start date.';

  @override
  String get validationErrorDepartureAirportMissing =>
      'Please select a departure airport.';

  @override
  String get validationErrorArrivalAirportMissing =>
      'Please select an arrival airport.';

  @override
  String get validationErrorDateRangeMissing => 'Please select travel dates.';

  @override
  String get errorGeneralTravelForm =>
      'An unexpected error occurred. Please try again.';

  @override
  String selectedAirportLabel(String airportName, String airportCode) {
    return 'Selected: $airportName ($airportCode)';
  }

  @override
  String get navigationPrevious => 'Previous';

  @override
  String get navigationNext => 'Next';

  @override
  String get navigationSubmit => 'Get Travel Plan';

  @override
  String get submittingForm => 'Submitting form...';

  @override
  String get yourTravelPlan => 'Your Travel Plan';

  @override
  String get fromLabel => 'From';

  @override
  String get toLabel => 'To';

  @override
  String get datesLabel => 'Dates';

  @override
  String get nationalityLabel => 'Nationality';

  @override
  String get travelPurposesLabel => 'Travel Purposes';

  @override
  String get recommendationsTitle => 'Recommendations';

  @override
  String get planAnotherTrip => 'Plan Another Trip';

  @override
  String flightDurationFormat(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String get flightOptionsTitle => 'Flight Options';

  @override
  String get cheapestOptionTitle => 'Cheapest Option';

  @override
  String get comfortableOptionTitle => 'Comfortable Option';

  @override
  String get recommendedOptionTitle => 'Recommended Option';

  @override
  String get outboundFlightLabel => 'Outbound Flight';

  @override
  String get returnFlightLabel => 'Return Flight';

  @override
  String stopsLabel(int count) {
    return '$count stops';
  }

  @override
  String stopsCountLabel(int count) {
    return 'Stops: $count';
  }

  @override
  String get cityInformationTitle => 'City Information';

  @override
  String get cityCardCrowdLevelLabel => 'Crowd Level';

  @override
  String get cityCardWeatherForecastTitle => 'Weather Forecast';

  @override
  String photoAttributionFormat(String photographerName) {
    return 'Photo by $photographerName on Unsplash';
  }

  @override
  String get disclaimerAIMistakesTitle => 'Important Disclaimer';

  @override
  String get disclaimerAIMistakesContent =>
      'The travel information provided is generated by AI and may contain inaccuracies or be incomplete. Always verify critical details like visa requirements, flight schedules, and safety advisories from official sources before making any travel plans.';

  @override
  String get disclaimerLegalTitle => 'Legal Notice';

  @override
  String get disclaimerLegalContent =>
      'This application provides travel assistance and information for general guidance only. We are not responsible for any errors, omissions, or issues arising from the use of this information. Users are solely responsible for their travel decisions and for verifying all information with official and reliable sources.';
}
