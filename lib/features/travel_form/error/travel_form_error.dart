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
