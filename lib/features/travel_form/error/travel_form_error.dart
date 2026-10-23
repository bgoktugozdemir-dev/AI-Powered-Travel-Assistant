import 'package:travel_assistant/common/error/firebase_error.dart';

sealed class TravelFormError {
  const TravelFormError();
}

class GeneralTravelFormError extends TravelFormError {
  const GeneralTravelFormError();
}

class DepartureAirportMissingError extends TravelFormError {
  const DepartureAirportMissingError();
}

class ArrivalAirportMissingError extends TravelFormError {
  const ArrivalAirportMissingError();
}

class DateRangeMissingError extends TravelFormError {
  const DateRangeMissingError();
}

class DateRangeInvalidError extends TravelFormError {
  const DateRangeInvalidError();
}

class NationalityMissingError extends TravelFormError {
  const NationalityMissingError();
}

class TravelPurposeMissingError extends TravelFormError {
  const TravelPurposeMissingError(
    this.selectedTravelPurposes,
    this.minimumTravelPurposes,
  );

  final int selectedTravelPurposes;
  final int minimumTravelPurposes;
}

class TravelPurposeTooManyError extends TravelFormError {
  const TravelPurposeTooManyError(
    this.selectedTravelPurposes,
    this.maximumTravelPurposes,
  );

  final int selectedTravelPurposes;
  final int maximumTravelPurposes;
}

class ServerError extends TravelFormError {
  const ServerError();
}

class CountryServiceError extends TravelFormError {
  const CountryServiceError();
}

class PlatformOrBrowserError extends TravelFormError {
  const PlatformOrBrowserError();
}

/// The request to the AI backend was interrupted (offline, or the browser
/// suspended the backgrounded tab), as opposed to the backend failing.
class ConnectionInterruptedError extends TravelFormError {
  const ConnectionInterruptedError({this.wentToBackground = false});

  /// Whether the app was in the background when the request was interrupted.
  /// Only then is the user told to keep the tab open.
  final bool wentToBackground;
}

/// Maps an error thrown while submitting the form to what the user is told.
TravelFormError travelFormErrorFor(Object error) => switch (error) {
  FirebaseConnectionError(:final wentToBackground) =>
    ConnectionInterruptedError(
      wentToBackground: wentToBackground,
    ),
  FirebaseError() => const ServerError(),
  _ => const GeneralTravelFormError(),
};
