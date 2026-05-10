import 'package:json_annotation/json_annotation.dart';
import 'package:firebase_ai/firebase_ai.dart';

part 'city.g.dart';

@JsonSerializable(createToJson: false)
class City {
  const City({
    required this.name,
    required this.country,
    required this.crowdLevel,
    required this.time,
    required this.weather,
  });

  factory City.fromJson(Map<String, dynamic> json) => _$CityFromJson(json);

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'country')
  final String country;

  @JsonKey(name: 'crowd_level')
  final int crowdLevel;

  @JsonKey(name: 'time')
  final TimeDetails? time;

  @JsonKey(name: 'weather')
  final List<Weather> weather;

  static Schema get aiSchema => Schema.object(
    properties: {
      'name': Schema.string(),
      'country': Schema.string(),
      'crowd_level': Schema.integer(),
      'time': TimeDetails.aiSchema..nullable = true,
      'weather': Schema.array(items: Weather.aiSchema),
    },
    optionalProperties: ['time'],
  );
}

@JsonSerializable(createToJson: false)
class TimeDetails {
  const TimeDetails({
    required this.departureTimezone,
    required this.arrivalTimezone,
    required this.differenceInHours,
  });

  factory TimeDetails.fromJson(Map<String, dynamic> json) =>
      _$TimeDetailsFromJson(json);

  @JsonKey(name: 'departure_timezone')
  final String departureTimezone;

  @JsonKey(name: 'arrival_timezone')
  final String arrivalTimezone;

  @JsonKey(name: 'difference_in_hours')
  final int differenceInHours;

  static Schema get aiSchema => Schema.object(
    properties: {
      'departure_timezone': Schema.string(),
      'arrival_timezone': Schema.string(),
      'difference_in_hours': Schema.integer(),
    },
  );
}

@JsonSerializable(createToJson: false)
class Weather {
  const Weather({
    required this.date,
    required this.weather,
    required this.temperature,
  });

  factory Weather.fromJson(Map<String, dynamic> json) =>
      _$WeatherFromJson(json);

  @JsonKey(name: 'date')
  final String date;

  @JsonKey(name: 'weather')
  final String weather;

  @JsonKey(name: 'temperature')
  final double temperature;

  static Schema get aiSchema => Schema.object(
    properties: {
      'date': Schema.string(),
      'weather': Schema.string(),
      'temperature': Schema.number(),
    },
  );
}
