import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:travel_assistant/common/models/airport.dart';
import 'package:travel_assistant/common/models/country.dart';
import 'package:travel_assistant/common/models/travel_purpose.dart';

part 'travel_information.freezed.dart';

@freezed
abstract class TravelInformation with _$TravelInformation {
  const TravelInformation._();

  @Assert(
    'travelPurposes.length > 0',
    'Travel purposes must be a non-empty list',
  )
  const factory TravelInformation({
    required Airport departureAirport,
    required Airport arrivalAirport,
    required DateTimeRange dateRange,
    required Country nationality,
    required List<TravelPurpose> travelPurposes,
  }) = _TravelInformation;

  /// Custom JSON conversion for Airport to JSON
  static String _airportToJson(Airport airport) => airport.iataCode;

  /// Custom JSON conversion for DateTimeRange to JSON
  static Map<String, String> _dateRangeToJson(DateTimeRange dateRange) => {
    'start': dateRange.start.toIso8601String(),
    'end': dateRange.end.toIso8601String(),
  };

  /// Custom JSON conversion for Country to JSON
  static String _countryToJson(Country country) => country.code;

  /// Custom JSON conversion for TravelPurpose list to JSON
  static List<String> _travelPurposesToJson(
    List<TravelPurpose> travelPurposes,
  ) => travelPurposes.map((e) => e.name).toList();

  /// Convert to JSON map using custom conversion methods
  Map<String, dynamic> toJson() {
    return {
      'departure_airport': _airportToJson(departureAirport),
      'arrival_airport': _airportToJson(arrivalAirport),
      'travel_date_range': _dateRangeToJson(dateRange),
      'nationality': _countryToJson(nationality),
      'travel_purposes': _travelPurposesToJson(travelPurposes),
    };
  }
}
