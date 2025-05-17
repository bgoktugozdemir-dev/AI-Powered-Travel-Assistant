// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'city.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

City _$CityFromJson(Map<String, dynamic> json) => City(
  name: json['name'] as String,
  country: json['country'] as String,
  imageUrl: json['image_url'] as String,
  crowdLevel: (json['crowd_level'] as num).toInt(),
  time:
      json['time'] == null
          ? null
          : TimeDetails.fromJson(json['time'] as Map<String, dynamic>),
  weather:
      (json['weather'] as List<dynamic>)
          .map((e) => Weather.fromJson(e as Map<String, dynamic>))
          .toList(),
);

TimeDetails _$TimeDetailsFromJson(Map<String, dynamic> json) => TimeDetails(
  departureTimezone: json['departure_timezone'] as String,
  arrivalTimezone: json['arrival_timezone'] as String,
  differenceInHours: (json['difference_in_hours'] as num).toInt(),
);

Weather _$WeatherFromJson(Map<String, dynamic> json) => Weather(
  date: json['date'] as String,
  weather: json['weather'] as String,
  temperature: (json['temperature'] as num).toDouble(),
  humidity: (json['humidity'] as num).toInt(),
  windSpeed: (json['wind_speed'] as num).toDouble(),
  windDirection: json['wind_direction'] as String,
  windGust: (json['wind_gust'] as num).toDouble(),
);
