import 'package:freezed_annotation/freezed_annotation.dart';

part 'open_meteo_response.freezed.dart';
part 'open_meteo_response.g.dart';

@freezed
abstract class OpenMeteoResponse with _$OpenMeteoResponse {
  const factory OpenMeteoResponse({
    required double latitude,
    required double longitude,
    required String timezone,
    required CurrentWeather current,
    required Hourly hourly,
  }) = _OpenMeteoResponse;

  factory OpenMeteoResponse.fromJson(Map<String, dynamic> json) =>
      _$OpenMeteoResponseFromJson(json);
}

@freezed
abstract class CurrentWeather with _$CurrentWeather {
  const factory CurrentWeather({
    required double temperature,
    @JsonKey(name: 'weather_code') required int weatherCode,
    @JsonKey(name: 'relative_humidity_2m') required int relativeHumidity,
  }) = _CurrentWeather;

  factory CurrentWeather.fromJson(Map<String, dynamic> json) =>
      _$CurrentWeatherFromJson(json);
}

@freezed
abstract class Hourly with _$Hourly {
  const factory Hourly({
    required List<String> time,
    @JsonKey(name: 'temperature_2m') required List<double> temperature2m,
    @JsonKey(name: 'weather_code') required List<int> weatherCode,
    @JsonKey(name: 'relative_humidity_2m')
    required List<int> relativeHumidity2m,
  }) = _Hourly;

  factory Hourly.fromJson(Map<String, dynamic> json) => _$HourlyFromJson(json);
}
