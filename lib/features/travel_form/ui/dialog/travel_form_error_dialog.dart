import 'package:flutter/material.dart';
import 'package:travel_assistant/features/travel_form/error/travel_form_error.dart';
import 'package:travel_assistant/l10n/app_localizations.dart';

abstract class _Constants {
  // Button Keys
  static const String buttonOkErrorDialog = 'button_ok_error_dialog';
}

class TravelFormErrorDialog extends StatelessWidget {
  const TravelFormErrorDialog({required this.error, super.key});

  final TravelFormError error;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n.travelFormErrorTitle),
      titleTextStyle: Theme.of(context).textTheme.titleLarge,
      content: Text(_getErrorMessage(l10n)),
      contentTextStyle: Theme.of(context).textTheme.bodyMedium,
      contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      actionsPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      actions: [
        TextButton(
          key: const Key(_Constants.buttonOkErrorDialog),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.ok),
        ),
      ],
    );
  }

  String _getErrorMessage(AppLocalizations l10n) => switch (error) {
    GeneralTravelFormError() => l10n.errorGeneralTravelForm,
    DepartureAirportMissingError() =>
      l10n.validationErrorDepartureAirportMissing,
    ArrivalAirportMissingError() => l10n.validationErrorArrivalAirportMissing,
    DateRangeMissingError() => l10n.validationErrorDateRangeMissing,
    DateRangeInvalidError() => l10n.errorInvalidDateRange,
    NationalityMissingError() => l10n.validationErrorNationalityMissing,
    TravelPurposeMissingError(
      selectedTravelPurposes: final selectedTravelPurposes,
      minimumTravelPurposes: final minimumTravelPurposes,
    ) =>
      l10n.validationErrorTravelPurposeMissing(
        selectedTravelPurposes,
        minimumTravelPurposes,
      ),
    TravelPurposeTooManyError(
      selectedTravelPurposes: final selectedTravelPurposes,
      maximumTravelPurposes: final maximumTravelPurposes,
    ) =>
      l10n.validationErrorTravelPurposeTooMany(
        selectedTravelPurposes,
        maximumTravelPurposes,
      ),
    CountryServiceError() => l10n.countryServiceErrorMessage,
    ServerError() => l10n.errorServer,
    PlatformOrBrowserError() => l10n.errorPlatformOrBrowser,
  };
}
