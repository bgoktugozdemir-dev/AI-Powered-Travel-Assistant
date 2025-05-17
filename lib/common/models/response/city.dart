import 'package:json_annotation/json_annotation.dart';

part 'city.g.dart';

@JsonSerializable(createToJson: false)
class City {
  const City({
    required this.name,
    required this.country,
    required this.imageUrl,
    required this.crowdLevel,
    required this.time,
    required this.weather,
  });

  factory City.fromJson(Map<String, dynamic> json) => _$CityFromJson(json);

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'country')
  final String country;

  @JsonKey(name: 'image_url')
  final String imageUrl;

  @JsonKey(name: 'crowd_level')
  final int crowdLevel;

  @JsonKey(name: 'time')
  final TimeDetails? time;

  @JsonKey(name: 'weather')
  final List<Weather> weather;
}

@JsonSerializable(createToJson: false)
class TimeDetails {
  const TimeDetails({required this.departureTimezone, required this.arrivalTimezone, required this.differenceInHours});

  factory TimeDetails.fromJson(Map<String, dynamic> json) => _$TimeDetailsFromJson(json);

  @JsonKey(name: 'departure_timezone')
  final String departureTimezone;

  @JsonKey(name: 'arrival_timezone')
  final String arrivalTimezone;

  @JsonKey(name: 'difference_in_hours')
  final int differenceInHours;
}

@JsonSerializable(createToJson: false)
class Weather {
  const Weather({
    required this.date,
    required this.weather,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.windGust,
  });

  factory Weather.fromJson(Map<String, dynamic> json) => _$WeatherFromJson(json);

  @JsonKey(name: 'date')
  final String date;

  @JsonKey(name: 'weather')
  final String weather;

  @JsonKey(name: 'temperature')
  final double temperature;

  @JsonKey(name: 'humidity')
  final int humidity;

  @JsonKey(name: 'wind_speed')
  final double windSpeed;

  @JsonKey(name: 'wind_direction')
  final String windDirection;

  @JsonKey(name: 'wind_gust')
  final double windGust;
}
