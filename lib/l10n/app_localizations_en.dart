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
  String get errorServer => 'Server error occurred. Please try again later.';

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
  String get submitTravelPlan => 'Get My Travel Plan';

  @override
  String get summaryStepIntroduction =>
      'Review your travel details and click \'Get My Travel Plan\' to receive personalized recommendations.';

  @override
  String get submittingForm => 'Crafting your perfect adventure...';

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
  String flightDurationHoursOnly(int hours) {
    return '${hours}h';
  }

  @override
  String flightDurationMinutesOnly(int minutes) {
    return '${minutes}m';
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

  @override
  String get stepTitleWelcome => 'Let\'s plan your next adventure!';

  @override
  String get stepTitleArrival => 'Where will your adventure take you?';

  @override
  String get stepTitleDates => 'When does the magic happen?';

  @override
  String get stepTitleNationality => 'Tell us about yourself!';

  @override
  String get stepTitlePurpose => 'What\'s calling you to explore?';

  @override
  String get stepTitleReview => 'Almost there!';

  @override
  String get stepDescriptionDeparture =>
      'Where will your journey begin? Enter your departure airport to get started.';

  @override
  String get stepDescriptionArrival =>
      'Where are you headed? Choose your arrival destination from our airport suggestions.';

  @override
  String get stepDescriptionDates =>
      'When would you like to travel? Select your departure and return dates for the trip.';

  @override
  String get stepDescriptionNationality =>
      'What\'s your nationality? This helps us provide accurate visa and travel requirements.';

  @override
  String get stepDescriptionPurpose =>
      'What\'s the purpose of your trip? Select all that apply to get personalized recommendations.';

  @override
  String get stepDescriptionReview =>
      'Review your travel details below and get your AI-generated travel plan!';

  @override
  String get currencyInformationTitle => 'Currency Information';

  @override
  String get currencyLabel => 'Currency';

  @override
  String get exchangeRateLabel => 'Exchange Rate';

  @override
  String get averageDailyCostLabel => 'Average Daily Living Cost';

  @override
  String get taxInformationTitle => 'Tax Information';

  @override
  String get taxRateLabel => 'Tax Rate';

  @override
  String get taxFreeShoppingLabel => 'Tax-Free Shopping';

  @override
  String get refundableTaxRateLabel => 'Refundable Tax Rate';

  @override
  String get availableLabel => 'Available';

  @override
  String get notAvailableLabel => 'Not Available';

  @override
  String get placesToVisitTitle => 'Places to Visit';

  @override
  String get requirementsLabel => 'Requirements:';

  @override
  String get closeLabel => 'Close';

  @override
  String get travelItineraryTitle => 'Travel Itinerary';

  @override
  String get crowdLevelLabel => 'Crowd:';

  @override
  String timeDifferenceTooltip(int hours) {
    return 'Time difference: $hours hours';
  }

  @override
  String get requiredDocumentsTitle => 'Required Documents';

  @override
  String get requiredStepsLabel => 'Required Steps:';

  @override
  String get formValidationError =>
      'Please check your form inputs and try again.';

  @override
  String get countryServiceErrorTitle => 'Unable to Load Countries';

  @override
  String get countryServiceErrorMessage =>
      'We\'re having trouble loading the list of countries. Please check your internet connection and try again.';

  @override
  String get tryAgainButton => 'Try Again';

  @override
  String get serviceUnavailableError =>
      'This feature is temporarily unavailable. Please try again later.';

  @override
  String get preparingTravelPlan => 'Preparing travel plan...';

  @override
  String shareText(String destination, String dates) {
    return 'Check out my travel plan for $destination$dates!';
  }

  @override
  String shareSubject(String destination, String dates) {
    return 'Travel Plan: $destination$dates';
  }

  @override
  String errorSharingTravelPlan(String error) {
    return 'Error sharing travel plan: $error';
  }

  @override
  String get pdfShareFallback =>
      'PDF could not be shared, but travel details were shared as text';

  @override
  String get copiedToClipboard =>
      'Travel plan copied to clipboard! You can paste it anywhere to share.';

  @override
  String get clipboardError => 'Could not copy to clipboard. Please try again.';

  @override
  String get sharingFallbackClipboard =>
      'Sharing failed, but travel plan was copied to clipboard';
}
