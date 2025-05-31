import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travel_assistant/l10n/app_localizations.dart';

/// Centralized formatting utilities for the travel assistant app.
/// This class provides consistent formatting for dates, currency, durations, etc.
abstract class Formatters {
  /// Private constructor to prevent instantiation.
  Formatters._();

  // Date Formatters

  /// Formats a date as "MMM d" (e.g., "Dec 25").
  static String shortDate(DateTime date) => DateFormat('MMM d').format(date);

  /// Formats a date as "MMM d, HH:mm" (e.g., "Dec 25, 14:30").
  static String dateWithTime(DateTime date) =>
      DateFormat('MMM d, HH:mm').format(date);

  /// Formats a date as "EEEE, MMMM d, yyyy" (e.g., "Monday, December 25, 2023").
  static String fullDate(DateTime date) =>
      DateFormat('EEEE, MMMM d, yyyy').format(date);

  /// Formats time as "HH:mm" (e.g., "14:30").
  static String timeOnly(DateTime date) => DateFormat('HH:mm').format(date);

  /// Formats date range with localization support.
  static String dateRange(DateTimeRange? dateRange, BuildContext context) {
    if (dateRange == null) {
      return AppLocalizations.of(context).noDatesSelected;
    }

    final l10n = AppLocalizations.of(context);
    final dateFormat = DateFormat.yMMMd(l10n.localeName);
    final startDate = dateFormat.format(dateRange.start);
    final endDate = dateFormat.format(dateRange.end);
    return '$startDate - $endDate';
  }

  /// Formats date range for selected dates label with localization.
  static String selectedDatesLabel(
    DateTimeRange dateRange,
    BuildContext context,
  ) {
    final l10n = AppLocalizations.of(context);
    final dateFormat = DateFormat.yMMMd(l10n.localeName);
    final startDate = dateFormat.format(dateRange.start);
    final endDate = dateFormat.format(dateRange.end);
    return l10n.selectedDatesLabel(startDate, endDate);
  }

  /// Formats date for logging purposes as "yMd" (e.g., "12/25/2023").
  static String logDate(DateTime date) => DateFormat.yMd().format(date);

  // Currency Formatters

  /// Formats currency with proper locale and symbol.
  static String currency({
    required double amount,
    required String currencyCode,
    required String locale,
    int decimalDigits = 2,
  }) {
    return NumberFormat.currency(
      locale: locale,
      symbol: currencyCode,
      decimalDigits: decimalDigits,
    ).format(amount);
  }

  /// Formats currency for flight prices using l10n.
  static String flightPrice({
    required double price,
    required String currencyCode,
    required AppLocalizations l10n,
  }) {
    return NumberFormat.currency(
      locale: l10n.localeName,
      symbol: currencyCode,
    ).format(price);
  }

  // Number Formatters

  /// Formats percentage (e.g., "75%").
  static String percentage(double value) =>
      NumberFormat.percentPattern().format(value);

  /// Formats crowd level as percentage.
  static String crowdLevel(int level) =>
      NumberFormat.percentPattern().format(level / 100);

  /// Formats number with thousand separators.
  static String number(num value, [String? locale]) {
    return NumberFormat.decimalPattern(locale).format(value);
  }

  // Duration Formatters

  /// Formats flight duration using localized format.
  static String flightDuration(Duration duration, AppLocalizations l10n) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return l10n.flightDurationFormat(hours, minutes);
  }

  /// Formats duration as "Xh Ym" format.
  static String duration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  // Airport and Location Formatters

  /// Formats airport display as "Name (Code)".
  static String airport(String name, String code) => '$name ($code)';

  /// Formats city and country as "City, Country".
  static String cityCountry(String city, String country) => '$city, $country';

  /// Formats selected airport label with localization.
  static String selectedAirportLabel({
    required String airportName,
    required String airportCode,
    required AppLocalizations l10n,
  }) {
    return l10n.selectedAirportLabel(airportName, airportCode);
  }

  // Time Zone and Time Difference Formatters

  /// Formats timezone time as "HH:mm (TZ)".
  static String timezoneTime(DateTime time, String timezone) {
    return '${timeOnly(time)} ($timezone)';
  }

  /// Formats time difference tooltip.
  static String timeDifference(int hours, AppLocalizations l10n) {
    return l10n.timeDifferenceTooltip(hours);
  }

  // Special Formatters

  /// Formats photo attribution.
  static String photoAttribution(
    String photographerName,
    AppLocalizations l10n,
  ) {
    return l10n.photoAttributionFormat(photographerName);
  }

  /// Formats stops count for flights.
  static String stopsCount(int count, AppLocalizations l10n) {
    return l10n.stopsLabel(count);
  }

  /// Formats stops count with label.
  static String stopsCountLabel(int count, AppLocalizations l10n) {
    return l10n.stopsCountLabel(count);
  }

  /// Formats nationality with flag emoji.
  static String nationalityWithFlag(String nationality, String? flagEmoji) {
    return '${flagEmoji ?? ''} $nationality'.trim();
  }
}
