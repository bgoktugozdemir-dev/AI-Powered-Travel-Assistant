import 'package:freezed_annotation/freezed_annotation.dart';

part 'airport.freezed.dart';
part 'airport.g.dart';

/// Represents an airport with its IATA code, name, and country.
@freezed
abstract class Airport with _$Airport {
  /// Creates an [Airport] instance.
  ///
  /// Requires [iataCode], [name], and [country].
  const factory Airport({
    required String iataCode,
    required String name,
    required String country, // Could be country code or full name
    // String? flagUrl, // Placeholder for future flag icon integration
  }) = _Airport;

  /// Creates an [Airport] instance from a JSON object.
  factory Airport.fromJson(Map<String, dynamic> json) => _$AirportFromJson(json);
} 