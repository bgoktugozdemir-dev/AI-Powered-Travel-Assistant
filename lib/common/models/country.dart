import 'package:freezed_annotation/freezed_annotation.dart';

part 'country.freezed.dart';
part 'country.g.dart';

/// Represents a country with name and code.
@freezed
abstract class Country with _$Country {
  /// Private constructor needed for custom methods
  const Country._();

  /// Creates a [Country] instance.
  ///
  /// Requires [code] and [name].
  const factory Country({
    required String code, // ISO 3166-1 alpha-2 country code
    required String name, // Full country name
    String? nationality, // Nationality name (e.g., American, Turkish)
    String? flagEmoji, // Optional flag emoji
  }) = _Country;

  /// Creates a [Country] instance from a JSON object.
  factory Country.fromJson(Map<String, dynamic> json) =>
      _$CountryFromJson(json);
}
