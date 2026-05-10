// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'open_meteo_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OpenMeteoResponse {

 double get latitude; double get longitude; String get timezone; CurrentWeather get current; Hourly get hourly;
/// Create a copy of OpenMeteoResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OpenMeteoResponseCopyWith<OpenMeteoResponse> get copyWith => _$OpenMeteoResponseCopyWithImpl<OpenMeteoResponse>(this as OpenMeteoResponse, _$identity);

  /// Serializes this OpenMeteoResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OpenMeteoResponse&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.current, current) || other.current == current)&&(identical(other.hourly, hourly) || other.hourly == hourly));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,latitude,longitude,timezone,current,hourly);

@override
String toString() {
  return 'OpenMeteoResponse(latitude: $latitude, longitude: $longitude, timezone: $timezone, current: $current, hourly: $hourly)';
}


}

/// @nodoc
abstract mixin class $OpenMeteoResponseCopyWith<$Res>  {
  factory $OpenMeteoResponseCopyWith(OpenMeteoResponse value, $Res Function(OpenMeteoResponse) _then) = _$OpenMeteoResponseCopyWithImpl;
@useResult
$Res call({
 double latitude, double longitude, String timezone, CurrentWeather current, Hourly hourly
});


$CurrentWeatherCopyWith<$Res> get current;$HourlyCopyWith<$Res> get hourly;

}
/// @nodoc
class _$OpenMeteoResponseCopyWithImpl<$Res>
    implements $OpenMeteoResponseCopyWith<$Res> {
  _$OpenMeteoResponseCopyWithImpl(this._self, this._then);

  final OpenMeteoResponse _self;
  final $Res Function(OpenMeteoResponse) _then;

/// Create a copy of OpenMeteoResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? latitude = null,Object? longitude = null,Object? timezone = null,Object? current = null,Object? hourly = null,}) {
  return _then(_self.copyWith(
latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as CurrentWeather,hourly: null == hourly ? _self.hourly : hourly // ignore: cast_nullable_to_non_nullable
as Hourly,
  ));
}
/// Create a copy of OpenMeteoResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CurrentWeatherCopyWith<$Res> get current {
  
  return $CurrentWeatherCopyWith<$Res>(_self.current, (value) {
    return _then(_self.copyWith(current: value));
  });
}/// Create a copy of OpenMeteoResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HourlyCopyWith<$Res> get hourly {
  
  return $HourlyCopyWith<$Res>(_self.hourly, (value) {
    return _then(_self.copyWith(hourly: value));
  });
}
}


/// @nodoc
@JsonSerializable()

class _OpenMeteoResponse implements OpenMeteoResponse {
  const _OpenMeteoResponse({required this.latitude, required this.longitude, required this.timezone, required this.current, required this.hourly});
  factory _OpenMeteoResponse.fromJson(Map<String, dynamic> json) => _$OpenMeteoResponseFromJson(json);

@override final  double latitude;
@override final  double longitude;
@override final  String timezone;
@override final  CurrentWeather current;
@override final  Hourly hourly;

/// Create a copy of OpenMeteoResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OpenMeteoResponseCopyWith<_OpenMeteoResponse> get copyWith => __$OpenMeteoResponseCopyWithImpl<_OpenMeteoResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OpenMeteoResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OpenMeteoResponse&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.current, current) || other.current == current)&&(identical(other.hourly, hourly) || other.hourly == hourly));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,latitude,longitude,timezone,current,hourly);

@override
String toString() {
  return 'OpenMeteoResponse(latitude: $latitude, longitude: $longitude, timezone: $timezone, current: $current, hourly: $hourly)';
}


}

/// @nodoc
abstract mixin class _$OpenMeteoResponseCopyWith<$Res> implements $OpenMeteoResponseCopyWith<$Res> {
  factory _$OpenMeteoResponseCopyWith(_OpenMeteoResponse value, $Res Function(_OpenMeteoResponse) _then) = __$OpenMeteoResponseCopyWithImpl;
@override @useResult
$Res call({
 double latitude, double longitude, String timezone, CurrentWeather current, Hourly hourly
});


@override $CurrentWeatherCopyWith<$Res> get current;@override $HourlyCopyWith<$Res> get hourly;

}
/// @nodoc
class __$OpenMeteoResponseCopyWithImpl<$Res>
    implements _$OpenMeteoResponseCopyWith<$Res> {
  __$OpenMeteoResponseCopyWithImpl(this._self, this._then);

  final _OpenMeteoResponse _self;
  final $Res Function(_OpenMeteoResponse) _then;

/// Create a copy of OpenMeteoResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? latitude = null,Object? longitude = null,Object? timezone = null,Object? current = null,Object? hourly = null,}) {
  return _then(_OpenMeteoResponse(
latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as CurrentWeather,hourly: null == hourly ? _self.hourly : hourly // ignore: cast_nullable_to_non_nullable
as Hourly,
  ));
}

/// Create a copy of OpenMeteoResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CurrentWeatherCopyWith<$Res> get current {
  
  return $CurrentWeatherCopyWith<$Res>(_self.current, (value) {
    return _then(_self.copyWith(current: value));
  });
}/// Create a copy of OpenMeteoResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HourlyCopyWith<$Res> get hourly {
  
  return $HourlyCopyWith<$Res>(_self.hourly, (value) {
    return _then(_self.copyWith(hourly: value));
  });
}
}


/// @nodoc
mixin _$CurrentWeather {

 double get temperature;@JsonKey(name: 'weather_code') int get weatherCode;@JsonKey(name: 'relative_humidity_2m') int get relativeHumidity;
/// Create a copy of CurrentWeather
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CurrentWeatherCopyWith<CurrentWeather> get copyWith => _$CurrentWeatherCopyWithImpl<CurrentWeather>(this as CurrentWeather, _$identity);

  /// Serializes this CurrentWeather to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CurrentWeather&&(identical(other.temperature, temperature) || other.temperature == temperature)&&(identical(other.weatherCode, weatherCode) || other.weatherCode == weatherCode)&&(identical(other.relativeHumidity, relativeHumidity) || other.relativeHumidity == relativeHumidity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,temperature,weatherCode,relativeHumidity);

@override
String toString() {
  return 'CurrentWeather(temperature: $temperature, weatherCode: $weatherCode, relativeHumidity: $relativeHumidity)';
}


}

/// @nodoc
abstract mixin class $CurrentWeatherCopyWith<$Res>  {
  factory $CurrentWeatherCopyWith(CurrentWeather value, $Res Function(CurrentWeather) _then) = _$CurrentWeatherCopyWithImpl;
@useResult
$Res call({
 double temperature,@JsonKey(name: 'weather_code') int weatherCode,@JsonKey(name: 'relative_humidity_2m') int relativeHumidity
});




}
/// @nodoc
class _$CurrentWeatherCopyWithImpl<$Res>
    implements $CurrentWeatherCopyWith<$Res> {
  _$CurrentWeatherCopyWithImpl(this._self, this._then);

  final CurrentWeather _self;
  final $Res Function(CurrentWeather) _then;

/// Create a copy of CurrentWeather
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? temperature = null,Object? weatherCode = null,Object? relativeHumidity = null,}) {
  return _then(_self.copyWith(
temperature: null == temperature ? _self.temperature : temperature // ignore: cast_nullable_to_non_nullable
as double,weatherCode: null == weatherCode ? _self.weatherCode : weatherCode // ignore: cast_nullable_to_non_nullable
as int,relativeHumidity: null == relativeHumidity ? _self.relativeHumidity : relativeHumidity // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _CurrentWeather implements CurrentWeather {
  const _CurrentWeather({required this.temperature, @JsonKey(name: 'weather_code') required this.weatherCode, @JsonKey(name: 'relative_humidity_2m') required this.relativeHumidity});
  factory _CurrentWeather.fromJson(Map<String, dynamic> json) => _$CurrentWeatherFromJson(json);

@override final  double temperature;
@override@JsonKey(name: 'weather_code') final  int weatherCode;
@override@JsonKey(name: 'relative_humidity_2m') final  int relativeHumidity;

/// Create a copy of CurrentWeather
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CurrentWeatherCopyWith<_CurrentWeather> get copyWith => __$CurrentWeatherCopyWithImpl<_CurrentWeather>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CurrentWeatherToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CurrentWeather&&(identical(other.temperature, temperature) || other.temperature == temperature)&&(identical(other.weatherCode, weatherCode) || other.weatherCode == weatherCode)&&(identical(other.relativeHumidity, relativeHumidity) || other.relativeHumidity == relativeHumidity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,temperature,weatherCode,relativeHumidity);

@override
String toString() {
  return 'CurrentWeather(temperature: $temperature, weatherCode: $weatherCode, relativeHumidity: $relativeHumidity)';
}


}

/// @nodoc
abstract mixin class _$CurrentWeatherCopyWith<$Res> implements $CurrentWeatherCopyWith<$Res> {
  factory _$CurrentWeatherCopyWith(_CurrentWeather value, $Res Function(_CurrentWeather) _then) = __$CurrentWeatherCopyWithImpl;
@override @useResult
$Res call({
 double temperature,@JsonKey(name: 'weather_code') int weatherCode,@JsonKey(name: 'relative_humidity_2m') int relativeHumidity
});




}
/// @nodoc
class __$CurrentWeatherCopyWithImpl<$Res>
    implements _$CurrentWeatherCopyWith<$Res> {
  __$CurrentWeatherCopyWithImpl(this._self, this._then);

  final _CurrentWeather _self;
  final $Res Function(_CurrentWeather) _then;

/// Create a copy of CurrentWeather
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? temperature = null,Object? weatherCode = null,Object? relativeHumidity = null,}) {
  return _then(_CurrentWeather(
temperature: null == temperature ? _self.temperature : temperature // ignore: cast_nullable_to_non_nullable
as double,weatherCode: null == weatherCode ? _self.weatherCode : weatherCode // ignore: cast_nullable_to_non_nullable
as int,relativeHumidity: null == relativeHumidity ? _self.relativeHumidity : relativeHumidity // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$Hourly {

 List<String> get time;@JsonKey(name: 'temperature_2m') List<double> get temperature2m;@JsonKey(name: 'weather_code') List<int> get weatherCode;@JsonKey(name: 'relative_humidity_2m') List<int> get relativeHumidity2m;
/// Create a copy of Hourly
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HourlyCopyWith<Hourly> get copyWith => _$HourlyCopyWithImpl<Hourly>(this as Hourly, _$identity);

  /// Serializes this Hourly to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Hourly&&const DeepCollectionEquality().equals(other.time, time)&&const DeepCollectionEquality().equals(other.temperature2m, temperature2m)&&const DeepCollectionEquality().equals(other.weatherCode, weatherCode)&&const DeepCollectionEquality().equals(other.relativeHumidity2m, relativeHumidity2m));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(time),const DeepCollectionEquality().hash(temperature2m),const DeepCollectionEquality().hash(weatherCode),const DeepCollectionEquality().hash(relativeHumidity2m));

@override
String toString() {
  return 'Hourly(time: $time, temperature2m: $temperature2m, weatherCode: $weatherCode, relativeHumidity2m: $relativeHumidity2m)';
}


}

/// @nodoc
abstract mixin class $HourlyCopyWith<$Res>  {
  factory $HourlyCopyWith(Hourly value, $Res Function(Hourly) _then) = _$HourlyCopyWithImpl;
@useResult
$Res call({
 List<String> time,@JsonKey(name: 'temperature_2m') List<double> temperature2m,@JsonKey(name: 'weather_code') List<int> weatherCode,@JsonKey(name: 'relative_humidity_2m') List<int> relativeHumidity2m
});




}
/// @nodoc
class _$HourlyCopyWithImpl<$Res>
    implements $HourlyCopyWith<$Res> {
  _$HourlyCopyWithImpl(this._self, this._then);

  final Hourly _self;
  final $Res Function(Hourly) _then;

/// Create a copy of Hourly
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? time = null,Object? temperature2m = null,Object? weatherCode = null,Object? relativeHumidity2m = null,}) {
  return _then(_self.copyWith(
time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as List<String>,temperature2m: null == temperature2m ? _self.temperature2m : temperature2m // ignore: cast_nullable_to_non_nullable
as List<double>,weatherCode: null == weatherCode ? _self.weatherCode : weatherCode // ignore: cast_nullable_to_non_nullable
as List<int>,relativeHumidity2m: null == relativeHumidity2m ? _self.relativeHumidity2m : relativeHumidity2m // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _Hourly implements Hourly {
  const _Hourly({required final  List<String> time, @JsonKey(name: 'temperature_2m') required final  List<double> temperature2m, @JsonKey(name: 'weather_code') required final  List<int> weatherCode, @JsonKey(name: 'relative_humidity_2m') required final  List<int> relativeHumidity2m}): _time = time,_temperature2m = temperature2m,_weatherCode = weatherCode,_relativeHumidity2m = relativeHumidity2m;
  factory _Hourly.fromJson(Map<String, dynamic> json) => _$HourlyFromJson(json);

 final  List<String> _time;
@override List<String> get time {
  if (_time is EqualUnmodifiableListView) return _time;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_time);
}

 final  List<double> _temperature2m;
@override@JsonKey(name: 'temperature_2m') List<double> get temperature2m {
  if (_temperature2m is EqualUnmodifiableListView) return _temperature2m;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_temperature2m);
}

 final  List<int> _weatherCode;
@override@JsonKey(name: 'weather_code') List<int> get weatherCode {
  if (_weatherCode is EqualUnmodifiableListView) return _weatherCode;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_weatherCode);
}

 final  List<int> _relativeHumidity2m;
@override@JsonKey(name: 'relative_humidity_2m') List<int> get relativeHumidity2m {
  if (_relativeHumidity2m is EqualUnmodifiableListView) return _relativeHumidity2m;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_relativeHumidity2m);
}


/// Create a copy of Hourly
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HourlyCopyWith<_Hourly> get copyWith => __$HourlyCopyWithImpl<_Hourly>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HourlyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Hourly&&const DeepCollectionEquality().equals(other._time, _time)&&const DeepCollectionEquality().equals(other._temperature2m, _temperature2m)&&const DeepCollectionEquality().equals(other._weatherCode, _weatherCode)&&const DeepCollectionEquality().equals(other._relativeHumidity2m, _relativeHumidity2m));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_time),const DeepCollectionEquality().hash(_temperature2m),const DeepCollectionEquality().hash(_weatherCode),const DeepCollectionEquality().hash(_relativeHumidity2m));

@override
String toString() {
  return 'Hourly(time: $time, temperature2m: $temperature2m, weatherCode: $weatherCode, relativeHumidity2m: $relativeHumidity2m)';
}


}

/// @nodoc
abstract mixin class _$HourlyCopyWith<$Res> implements $HourlyCopyWith<$Res> {
  factory _$HourlyCopyWith(_Hourly value, $Res Function(_Hourly) _then) = __$HourlyCopyWithImpl;
@override @useResult
$Res call({
 List<String> time,@JsonKey(name: 'temperature_2m') List<double> temperature2m,@JsonKey(name: 'weather_code') List<int> weatherCode,@JsonKey(name: 'relative_humidity_2m') List<int> relativeHumidity2m
});




}
/// @nodoc
class __$HourlyCopyWithImpl<$Res>
    implements _$HourlyCopyWith<$Res> {
  __$HourlyCopyWithImpl(this._self, this._then);

  final _Hourly _self;
  final $Res Function(_Hourly) _then;

/// Create a copy of Hourly
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? time = null,Object? temperature2m = null,Object? weatherCode = null,Object? relativeHumidity2m = null,}) {
  return _then(_Hourly(
time: null == time ? _self._time : time // ignore: cast_nullable_to_non_nullable
as List<String>,temperature2m: null == temperature2m ? _self._temperature2m : temperature2m // ignore: cast_nullable_to_non_nullable
as List<double>,weatherCode: null == weatherCode ? _self._weatherCode : weatherCode // ignore: cast_nullable_to_non_nullable
as List<int>,relativeHumidity2m: null == relativeHumidity2m ? _self._relativeHumidity2m : relativeHumidity2m // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}


}

// dart format on
