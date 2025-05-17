import 'package:json_annotation/json_annotation.dart';

part 'travel_spot.g.dart';

@JsonSerializable(createToJson: false)
class TravelSpot {
  const TravelSpot({
    required this.place,
    required this.description,
    required this.imageUrl,
    required this.requirements,
  });

  factory TravelSpot.fromJson(Map<String, dynamic> json) => _$TravelSpotFromJson(json);

  @JsonKey(name: 'place')
  final String place;

  @JsonKey(name: 'description')
  final String description;

  @JsonKey(name: 'image_url')
  final String imageUrl;

  @JsonKey(name: 'requirements')
  final String? requirements;
}
