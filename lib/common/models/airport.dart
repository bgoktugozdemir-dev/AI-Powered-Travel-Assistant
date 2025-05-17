import 'package:freezed_annotation/freezed_annotation.dart';

part 'airport.freezed.dart';
part 'airport.g.dart';

/// Represents an airport with its IATA code, name, and country.
@freezed
abstract class Airport with _$Airport {
  // Add private constructor for freezed methods/getters
  const Airport._();

  /// Creates an [Airport] instance.
  ///
  /// Requires [iataCode], [name], [countryCode], [countryName], and [cityName].
  const factory Airport({
    required String iataCode,
    required String name,
    required String countryCode,
    required String countryName,
    required String cityName,
  }) = _Airport;

  /// Creates an [Airport] instance from a JSON object.
  factory Airport.fromJson(Map<String, dynamic> json) => _$AirportFromJson(json);

  /// Returns city and country name as a single string.
  String get cityAndCountry => '$cityName, $countryName';
}
