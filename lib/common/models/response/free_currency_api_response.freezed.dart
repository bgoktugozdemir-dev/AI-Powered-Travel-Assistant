// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'free_currency_api_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FreeCurrencyApiResponse {

 Map<String, double> get data;
/// Create a copy of FreeCurrencyApiResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FreeCurrencyApiResponseCopyWith<FreeCurrencyApiResponse> get copyWith => _$FreeCurrencyApiResponseCopyWithImpl<FreeCurrencyApiResponse>(this as FreeCurrencyApiResponse, _$identity);

  /// Serializes this FreeCurrencyApiResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FreeCurrencyApiResponse&&const DeepCollectionEquality().equals(other.data, data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'FreeCurrencyApiResponse(data: $data)';
}


}

/// @nodoc
abstract mixin class $FreeCurrencyApiResponseCopyWith<$Res>  {
  factory $FreeCurrencyApiResponseCopyWith(FreeCurrencyApiResponse value, $Res Function(FreeCurrencyApiResponse) _then) = _$FreeCurrencyApiResponseCopyWithImpl;
@useResult
$Res call({
 Map<String, double> data
});




}
/// @nodoc
class _$FreeCurrencyApiResponseCopyWithImpl<$Res>
    implements $FreeCurrencyApiResponseCopyWith<$Res> {
  _$FreeCurrencyApiResponseCopyWithImpl(this._self, this._then);

  final FreeCurrencyApiResponse _self;
  final $Res Function(FreeCurrencyApiResponse) _then;

/// Create a copy of FreeCurrencyApiResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = null,}) {
  return _then(_self.copyWith(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as Map<String, double>,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _FreeCurrencyApiResponse extends FreeCurrencyApiResponse {
  const _FreeCurrencyApiResponse({required final  Map<String, double> data}): _data = data,super._();
  factory _FreeCurrencyApiResponse.fromJson(Map<String, dynamic> json) => _$FreeCurrencyApiResponseFromJson(json);

 final  Map<String, double> _data;
@override Map<String, double> get data {
  if (_data is EqualUnmodifiableMapView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_data);
}


/// Create a copy of FreeCurrencyApiResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FreeCurrencyApiResponseCopyWith<_FreeCurrencyApiResponse> get copyWith => __$FreeCurrencyApiResponseCopyWithImpl<_FreeCurrencyApiResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FreeCurrencyApiResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FreeCurrencyApiResponse&&const DeepCollectionEquality().equals(other._data, _data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_data));

@override
String toString() {
  return 'FreeCurrencyApiResponse(data: $data)';
}


}

/// @nodoc
abstract mixin class _$FreeCurrencyApiResponseCopyWith<$Res> implements $FreeCurrencyApiResponseCopyWith<$Res> {
  factory _$FreeCurrencyApiResponseCopyWith(_FreeCurrencyApiResponse value, $Res Function(_FreeCurrencyApiResponse) _then) = __$FreeCurrencyApiResponseCopyWithImpl;
@override @useResult
$Res call({
 Map<String, double> data
});




}
/// @nodoc
class __$FreeCurrencyApiResponseCopyWithImpl<$Res>
    implements _$FreeCurrencyApiResponseCopyWith<$Res> {
  __$FreeCurrencyApiResponseCopyWithImpl(this._self, this._then);

  final _FreeCurrencyApiResponse _self;
  final $Res Function(_FreeCurrencyApiResponse) _then;

/// Create a copy of FreeCurrencyApiResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = null,}) {
  return _then(_FreeCurrencyApiResponse(
data: null == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as Map<String, double>,
  ));
}


}

// dart format on
