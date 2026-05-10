// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'open_meteo_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OpenMeteoResponse _$OpenMeteoResponseFromJson(Map<String, dynamic> json) =>
    _OpenMeteoResponse(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timezone: json['timezone'] as String,
      current: CurrentWeather.fromJson(json['current'] as Map<String, dynamic>),
      hourly: Hourly.fromJson(json['hourly'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OpenMeteoResponseToJson(_OpenMeteoResponse instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'timezone': instance.timezone,
      'current': instance.current,
      'hourly': instance.hourly,
    };

_CurrentWeather _$CurrentWeatherFromJson(Map<String, dynamic> json) =>
    _CurrentWeather(
      temperature: (json['temperature_2m'] as num).toDouble(),
      weatherCode: (json['weather_code'] as num).toInt(),
      relativeHumidity: (json['relative_humidity_2m'] as num).toInt(),
    );

Map<String, dynamic> _$CurrentWeatherToJson(_CurrentWeather instance) =>
    <String, dynamic>{
      'temperature_2m': instance.temperature,
      'weather_code': instance.weatherCode,
      'relative_humidity_2m': instance.relativeHumidity,
    };

_Hourly _$HourlyFromJson(Map<String, dynamic> json) => _Hourly(
  time: (json['time'] as List<dynamic>).map((e) => e as String).toList(),
  temperature2m:
      (json['temperature_2m'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
  weatherCode:
      (json['weather_code'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
  relativeHumidity2m:
      (json['relative_humidity_2m'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
);

Map<String, dynamic> _$HourlyToJson(_Hourly instance) => <String, dynamic>{
  'time': instance.time,
  'temperature_2m': instance.temperature2m,
  'weather_code': instance.weatherCode,
  'relative_humidity_2m': instance.relativeHumidity2m,
};
