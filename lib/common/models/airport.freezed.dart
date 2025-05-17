// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'airport.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Airport {

 String get iataCode; String get name; String get countryCode; String get countryName; String get cityName;
/// Create a copy of Airport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AirportCopyWith<Airport> get copyWith => _$AirportCopyWithImpl<Airport>(this as Airport, _$identity);

  /// Serializes this Airport to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Airport&&(identical(other.iataCode, iataCode) || other.iataCode == iataCode)&&(identical(other.name, name) || other.name == name)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode)&&(identical(other.countryName, countryName) || other.countryName == countryName)&&(identical(other.cityName, cityName) || other.cityName == cityName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,iataCode,name,countryCode,countryName,cityName);

@override
String toString() {
  return 'Airport(iataCode: $iataCode, name: $name, countryCode: $countryCode, countryName: $countryName, cityName: $cityName)';
}


}

/// @nodoc
abstract mixin class $AirportCopyWith<$Res>  {
  factory $AirportCopyWith(Airport value, $Res Function(Airport) _then) = _$AirportCopyWithImpl;
@useResult
$Res call({
 String iataCode, String name, String countryCode, String countryName, String cityName
});




}
/// @nodoc
class _$AirportCopyWithImpl<$Res>
    implements $AirportCopyWith<$Res> {
  _$AirportCopyWithImpl(this._self, this._then);

  final Airport _self;
  final $Res Function(Airport) _then;

/// Create a copy of Airport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? iataCode = null,Object? name = null,Object? countryCode = null,Object? countryName = null,Object? cityName = null,}) {
  return _then(_self.copyWith(
iataCode: null == iataCode ? _self.iataCode : iataCode // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,countryCode: null == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String,countryName: null == countryName ? _self.countryName : countryName // ignore: cast_nullable_to_non_nullable
as String,cityName: null == cityName ? _self.cityName : cityName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _Airport extends Airport {
  const _Airport({required this.iataCode, required this.name, required this.countryCode, required this.countryName, required this.cityName}): super._();
  factory _Airport.fromJson(Map<String, dynamic> json) => _$AirportFromJson(json);

@override final  String iataCode;
@override final  String name;
@override final  String countryCode;
@override final  String countryName;
@override final  String cityName;

/// Create a copy of Airport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AirportCopyWith<_Airport> get copyWith => __$AirportCopyWithImpl<_Airport>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AirportToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Airport&&(identical(other.iataCode, iataCode) || other.iataCode == iataCode)&&(identical(other.name, name) || other.name == name)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode)&&(identical(other.countryName, countryName) || other.countryName == countryName)&&(identical(other.cityName, cityName) || other.cityName == cityName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,iataCode,name,countryCode,countryName,cityName);

@override
String toString() {
  return 'Airport(iataCode: $iataCode, name: $name, countryCode: $countryCode, countryName: $countryName, cityName: $cityName)';
}


}

/// @nodoc
abstract mixin class _$AirportCopyWith<$Res> implements $AirportCopyWith<$Res> {
  factory _$AirportCopyWith(_Airport value, $Res Function(_Airport) _then) = __$AirportCopyWithImpl;
@override @useResult
$Res call({
 String iataCode, String name, String countryCode, String countryName, String cityName
});




}
/// @nodoc
class __$AirportCopyWithImpl<$Res>
    implements _$AirportCopyWith<$Res> {
  __$AirportCopyWithImpl(this._self, this._then);

  final _Airport _self;
  final $Res Function(_Airport) _then;

/// Create a copy of Airport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? iataCode = null,Object? name = null,Object? countryCode = null,Object? countryName = null,Object? cityName = null,}) {
  return _then(_Airport(
iataCode: null == iataCode ? _self.iataCode : iataCode // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,countryCode: null == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String,countryName: null == countryName ? _self.countryName : countryName // ignore: cast_nullable_to_non_nullable
as String,cityName: null == cityName ? _self.cityName : cityName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
