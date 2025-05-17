import 'package:freezed_annotation/freezed_annotation.dart';

part 'travel_purpose.freezed.dart';
part 'travel_purpose.g.dart';

/// Represents a travel purpose with id, name, and icon.
@freezed
abstract class TravelPurpose with _$TravelPurpose {
  /// Private constructor needed for custom methods
  const TravelPurpose._();
  
  /// Creates a [TravelPurpose] instance.
  ///
  /// Requires [id] and [name].
  const factory TravelPurpose({
    required String id,
    required String name,
    String? icon,
  }) = _TravelPurpose;

  /// Creates a [TravelPurpose] instance from a JSON object.
  factory TravelPurpose.fromJson(Map<String, dynamic> json) => _$TravelPurposeFromJson(json);
} 