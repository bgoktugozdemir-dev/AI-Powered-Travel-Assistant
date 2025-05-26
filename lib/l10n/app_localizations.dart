import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Travel Assistant'**
  String get appTitle;

  /// OK button text
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Title for a step in the travel form, includes step number placeholder
  ///
  /// In en, this message translates to:
  /// **'Step {stepNumber}'**
  String travelFormStepTitle(int stepNumber);

  /// Title for the departure airport selection step
  ///
  /// In en, this message translates to:
  /// **'Where are you flying from?'**
  String get departureAirportStepTitle;

  /// Hint text for the departure airport search field
  ///
  /// In en, this message translates to:
  /// **'Search departure airport (e.g., IST, Istanbul)'**
  String get departureAirportHintText;

  /// Title for the arrival airport selection step
  ///
  /// In en, this message translates to:
  /// **'Where are you flying to?'**
  String get arrivalAirportStepTitle;

  /// Hint text for the arrival airport search field
  ///
  /// In en, this message translates to:
  /// **'Search arrival airport (e.g., JFK, New York)'**
  String get arrivalAirportHintText;

  /// Title for the travel dates selection step
  ///
  /// In en, this message translates to:
  /// **'When are you travelling?'**
  String get travelDatesStepTitle;

  /// Button label to open the date range picker
  ///
  /// In en, this message translates to:
  /// **'Select Travel Dates'**
  String get selectDatesButtonLabel;

  /// Label displaying the selected start and end dates
  ///
  /// In en, this message translates to:
  /// **'Selected: {startDate} - {endDate}'**
  String selectedDatesLabel(String startDate, String endDate);

  /// Text shown when no travel dates have been selected yet
  ///
  /// In en, this message translates to:
  /// **'No dates selected'**
  String get noDatesSelected;

  /// Title for the nationality selection step
  ///
  /// In en, this message translates to:
  /// **'What is your nationality?'**
  String get nationalityStepTitle;

  /// Hint text for the nationality search field
  ///
  /// In en, this message translates to:
  /// **'Search your nationality (e.g., US, Turkey)'**
  String get nationalityHintText;

  /// Label displaying the selected nationality
  ///
  /// In en, this message translates to:
  /// **'Selected: {nationalityName}'**
  String selectedNationalityLabel(String nationalityName);

  /// Title for the travel purposes selection step
  ///
  /// In en, this message translates to:
  /// **'What are your travel purposes?'**
  String get travelPurposeStepTitle;

  /// Title for the travel purposes selection area
  ///
  /// In en, this message translates to:
  /// **'Select Travel Purposes'**
  String get selectTravelPurposes;

  /// Description for the travel purposes selection
  ///
  /// In en, this message translates to:
  /// **'Choose one or more reasons for your trip. This helps us provide better recommendations.'**
  String get selectTravelPurposesDescription;

  /// Title for the selected travel purposes section
  ///
  /// In en, this message translates to:
  /// **'Selected Purposes'**
  String get selectedPurposes;

  /// Message shown when no travel purposes are available
  ///
  /// In en, this message translates to:
  /// **'No travel purposes available. Please try again later.'**
  String get noPurposesAvailable;

  /// Title for error dialog in the travel form
  ///
  /// In en, this message translates to:
  /// **'Error Occurred'**
  String get travelFormErrorTitle;

  /// Validation error if not enough travel purposes are selected.
  ///
  /// In en, this message translates to:
  /// **'{minimumTravelPurposes, plural, =1{Please select at least 1 travel purpose. You have selected {selectedTravelPurposes}.} other{Please select at least {minimumTravelPurposes} travel purposes. You have selected {selectedTravelPurposes}.}}'**
  String validationErrorTravelPurposeMissing(
    int selectedTravelPurposes,
    int minimumTravelPurposes,
  );

  /// Validation error if too many travel purposes are selected.
  ///
  /// In en, this message translates to:
  /// **'{maximumTravelPurposes, plural, =1{Please select no more than 1 travel purpose. You have selected {selectedTravelPurposes}.} other{Please select no more than {maximumTravelPurposes} travel purposes. You have selected {selectedTravelPurposes}.}}'**
  String validationErrorTravelPurposeTooMany(
    int selectedTravelPurposes,
    int maximumTravelPurposes,
  );

  /// Validation error if nationality is not selected
  ///
  /// In en, this message translates to:
  /// **'Please select your nationality.'**
  String get validationErrorNationalityMissing;

  /// Error message for invalid date range selection
  ///
  /// In en, this message translates to:
  /// **'End date cannot be before start date.'**
  String get errorInvalidDateRange;

  /// Validation error if departure airport is not selected
  ///
  /// In en, this message translates to:
  /// **'Please select a departure airport.'**
  String get validationErrorDepartureAirportMissing;

  /// Validation error if arrival airport is not selected
  ///
  /// In en, this message translates to:
  /// **'Please select an arrival airport.'**
  String get validationErrorArrivalAirportMissing;

  /// Validation error if travel dates are not selected
  ///
  /// In en, this message translates to:
  /// **'Please select travel dates.'**
  String get validationErrorDateRangeMissing;

  /// Generic error message for travel form errors
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get errorGeneralTravelForm;

  /// Error message for server errors
  ///
  /// In en, this message translates to:
  /// **'Server error occurred. Please try again later.'**
  String get errorServer;

  /// Label displayed when an airport is selected, showing its name and code
  ///
  /// In en, this message translates to:
  /// **'Selected: {airportName} ({airportCode})'**
  String selectedAirportLabel(String airportName, String airportCode);

  /// Button text to go to the previous step
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get navigationPrevious;

  /// Button text to go to the next step
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get navigationNext;

  /// Button text to submit the form and get travel plan
  ///
  /// In en, this message translates to:
  /// **'Get Travel Plan'**
  String get navigationSubmit;

  /// Message shown when the form is being submitted
  ///
  /// In en, this message translates to:
  /// **'✈️ Crafting your perfect adventure...'**
  String get submittingForm;

  /// Title for the travel plan section in the results screen
  ///
  /// In en, this message translates to:
  /// **'Your Travel Plan'**
  String get yourTravelPlan;

  /// Label for departure location in results
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get fromLabel;

  /// Label for arrival location in results
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get toLabel;

  /// Label for travel dates in results
  ///
  /// In en, this message translates to:
  /// **'Dates'**
  String get datesLabel;

  /// Label for nationality in results
  ///
  /// In en, this message translates to:
  /// **'Nationality'**
  String get nationalityLabel;

  /// Label for travel purposes in results
  ///
  /// In en, this message translates to:
  /// **'Travel Purposes'**
  String get travelPurposesLabel;

  /// Title for the recommendations section
  ///
  /// In en, this message translates to:
  /// **'Recommendations'**
  String get recommendationsTitle;

  /// Button text to start planning another trip
  ///
  /// In en, this message translates to:
  /// **'Plan Another Trip'**
  String get planAnotherTrip;

  /// Format for displaying flight duration
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String flightDurationFormat(int hours, int minutes);

  /// Title for the flight options section
  ///
  /// In en, this message translates to:
  /// **'Flight Options'**
  String get flightOptionsTitle;

  /// Title for the cheapest flight option
  ///
  /// In en, this message translates to:
  /// **'Cheapest Option'**
  String get cheapestOptionTitle;

  /// Title for the comfortable flight option
  ///
  /// In en, this message translates to:
  /// **'Comfortable Option'**
  String get comfortableOptionTitle;

  /// Title for the recommended flight option
  ///
  /// In en, this message translates to:
  /// **'Recommended Option'**
  String get recommendedOptionTitle;

  /// Label for the outbound/departure flight
  ///
  /// In en, this message translates to:
  /// **'Outbound Flight'**
  String get outboundFlightLabel;

  /// Label for the return flight
  ///
  /// In en, this message translates to:
  /// **'Return Flight'**
  String get returnFlightLabel;

  /// Label for the number of stops in a flight
  ///
  /// In en, this message translates to:
  /// **'{count} stops'**
  String stopsLabel(int count);

  /// Label showing the count of stops
  ///
  /// In en, this message translates to:
  /// **'Stops: {count}'**
  String stopsCountLabel(int count);

  /// Title for the city information card in results
  ///
  /// In en, this message translates to:
  /// **'City Information'**
  String get cityInformationTitle;

  /// Label for the crowd level in the city card
  ///
  /// In en, this message translates to:
  /// **'Crowd Level'**
  String get cityCardCrowdLevelLabel;

  /// Title for the weather forecast section in the city card
  ///
  /// In en, this message translates to:
  /// **'Weather Forecast'**
  String get cityCardWeatherForecastTitle;

  /// Format for photo attribution text
  ///
  /// In en, this message translates to:
  /// **'Photo by {photographerName} on Unsplash'**
  String photoAttributionFormat(String photographerName);

  /// Title for the AI mistakes disclaimer
  ///
  /// In en, this message translates to:
  /// **'Important Disclaimer'**
  String get disclaimerAIMistakesTitle;

  /// Content for the AI mistakes disclaimer, advising users to verify information
  ///
  /// In en, this message translates to:
  /// **'The travel information provided is generated by AI and may contain inaccuracies or be incomplete. Always verify critical details like visa requirements, flight schedules, and safety advisories from official sources before making any travel plans.'**
  String get disclaimerAIMistakesContent;

  /// Title for the legal notice
  ///
  /// In en, this message translates to:
  /// **'Legal Notice'**
  String get disclaimerLegalTitle;

  /// Content for the general legal notice
  ///
  /// In en, this message translates to:
  /// **'This application provides travel assistance and information for general guidance only. We are not responsible for any errors, omissions, or issues arising from the use of this information. Users are solely responsible for their travel decisions and for verifying all information with official and reliable sources.'**
  String get disclaimerLegalContent;

  /// Title for the welcome/departure airport step
  ///
  /// In en, this message translates to:
  /// **'Let\'s plan your next adventure!'**
  String get stepTitleWelcome;

  /// Title for the arrival airport step
  ///
  /// In en, this message translates to:
  /// **'Where will your adventure take you?'**
  String get stepTitleArrival;

  /// Title for the travel dates step
  ///
  /// In en, this message translates to:
  /// **'When does the magic happen?'**
  String get stepTitleDates;

  /// Title for the nationality step
  ///
  /// In en, this message translates to:
  /// **'Tell us about yourself!'**
  String get stepTitleNationality;

  /// Title for the travel purpose step
  ///
  /// In en, this message translates to:
  /// **'What\'s calling you to explore?'**
  String get stepTitlePurpose;

  /// Title for the review step
  ///
  /// In en, this message translates to:
  /// **'Almost there!'**
  String get stepTitleReview;

  /// Description for the departure airport step
  ///
  /// In en, this message translates to:
  /// **'Where will your journey begin? Enter your departure airport to get started.'**
  String get stepDescriptionDeparture;

  /// Description for the arrival airport step
  ///
  /// In en, this message translates to:
  /// **'Where are you headed? Choose your arrival destination from our airport suggestions.'**
  String get stepDescriptionArrival;

  /// Description for the travel dates step
  ///
  /// In en, this message translates to:
  /// **'When would you like to travel? Select your departure and return dates for the trip.'**
  String get stepDescriptionDates;

  /// Description for the nationality step
  ///
  /// In en, this message translates to:
  /// **'What\'s your nationality? This helps us provide accurate visa and travel requirements.'**
  String get stepDescriptionNationality;

  /// Description for the travel purpose step
  ///
  /// In en, this message translates to:
  /// **'What\'s the purpose of your trip? Select all that apply to get personalized recommendations.'**
  String get stepDescriptionPurpose;

  /// Description for the review step
  ///
  /// In en, this message translates to:
  /// **'Review your travel details below and get your AI-generated travel plan!'**
  String get stepDescriptionReview;

  /// Title for the currency information card
  ///
  /// In en, this message translates to:
  /// **'Currency Information'**
  String get currencyInformationTitle;

  /// Label for currency field
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currencyLabel;

  /// Label for exchange rate field
  ///
  /// In en, this message translates to:
  /// **'Exchange Rate'**
  String get exchangeRateLabel;

  /// Label for average daily cost field
  ///
  /// In en, this message translates to:
  /// **'Average Daily Cost'**
  String get averageDailyCostLabel;

  /// Title for the tax information card
  ///
  /// In en, this message translates to:
  /// **'Tax Information'**
  String get taxInformationTitle;

  /// Label for tax rate field
  ///
  /// In en, this message translates to:
  /// **'Tax Rate'**
  String get taxRateLabel;

  /// Label for tax-free shopping availability
  ///
  /// In en, this message translates to:
  /// **'Tax-Free Shopping'**
  String get taxFreeShoppingLabel;

  /// Text for when something is available
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get availableLabel;

  /// Text for when something is not available
  ///
  /// In en, this message translates to:
  /// **'Not Available'**
  String get notAvailableLabel;

  /// Title for the places to visit card
  ///
  /// In en, this message translates to:
  /// **'Places to Visit'**
  String get placesToVisitTitle;

  /// Label for requirements section
  ///
  /// In en, this message translates to:
  /// **'Requirements:'**
  String get requirementsLabel;

  /// Close button text
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeLabel;

  /// Title for the travel itinerary card
  ///
  /// In en, this message translates to:
  /// **'Travel Itinerary'**
  String get travelItineraryTitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
