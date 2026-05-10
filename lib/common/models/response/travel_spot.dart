import 'package:json_annotation/json_annotation.dart';
import 'package:firebase_ai/firebase_ai.dart';

part 'travel_spot.g.dart';

@JsonSerializable(createToJson: false)
class TravelSpot {
  const TravelSpot({
    required this.place,
    required this.description,
    required this.requirements,
  });

  factory TravelSpot.fromJson(Map<String, dynamic> json) =>
      _$TravelSpotFromJson(json);

  @JsonKey(name: 'place')
  final String place;

  @JsonKey(name: 'description')
  final String description;

  @JsonKey(name: 'requirements')
  final String? requirements;

  static Schema get aiSchema => Schema.object(
    properties: {
      'place': Schema.string(),
      'description': Schema.string(),
      'requirements': Schema.string(nullable: true),
    },
    optionalProperties: ['requirements'],
  );
}
