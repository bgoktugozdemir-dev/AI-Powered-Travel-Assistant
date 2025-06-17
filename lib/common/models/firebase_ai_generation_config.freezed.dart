// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'firebase_ai_generation_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FirebaseAIGenerationConfig {

 double? get temperature; double? get topP; int? get maxOutputTokens; String? get responseMimeType;
/// Create a copy of FirebaseAIGenerationConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FirebaseAIGenerationConfigCopyWith<FirebaseAIGenerationConfig> get copyWith => _$FirebaseAIGenerationConfigCopyWithImpl<FirebaseAIGenerationConfig>(this as FirebaseAIGenerationConfig, _$identity);

  /// Serializes this FirebaseAIGenerationConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FirebaseAIGenerationConfig&&(identical(other.temperature, temperature) || other.temperature == temperature)&&(identical(other.topP, topP) || other.topP == topP)&&(identical(other.maxOutputTokens, maxOutputTokens) || other.maxOutputTokens == maxOutputTokens)&&(identical(other.responseMimeType, responseMimeType) || other.responseMimeType == responseMimeType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,temperature,topP,maxOutputTokens,responseMimeType);

@override
String toString() {
  return 'FirebaseAIGenerationConfig(temperature: $temperature, topP: $topP, maxOutputTokens: $maxOutputTokens, responseMimeType: $responseMimeType)';
}


}

/// @nodoc
abstract mixin class $FirebaseAIGenerationConfigCopyWith<$Res>  {
  factory $FirebaseAIGenerationConfigCopyWith(FirebaseAIGenerationConfig value, $Res Function(FirebaseAIGenerationConfig) _then) = _$FirebaseAIGenerationConfigCopyWithImpl;
@useResult
$Res call({
 double? temperature, double? topP, int? maxOutputTokens, String? responseMimeType
});




}
/// @nodoc
class _$FirebaseAIGenerationConfigCopyWithImpl<$Res>
    implements $FirebaseAIGenerationConfigCopyWith<$Res> {
  _$FirebaseAIGenerationConfigCopyWithImpl(this._self, this._then);

  final FirebaseAIGenerationConfig _self;
  final $Res Function(FirebaseAIGenerationConfig) _then;

/// Create a copy of FirebaseAIGenerationConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? temperature = freezed,Object? topP = freezed,Object? maxOutputTokens = freezed,Object? responseMimeType = freezed,}) {
  return _then(_self.copyWith(
temperature: freezed == temperature ? _self.temperature : temperature // ignore: cast_nullable_to_non_nullable
as double?,topP: freezed == topP ? _self.topP : topP // ignore: cast_nullable_to_non_nullable
as double?,maxOutputTokens: freezed == maxOutputTokens ? _self.maxOutputTokens : maxOutputTokens // ignore: cast_nullable_to_non_nullable
as int?,responseMimeType: freezed == responseMimeType ? _self.responseMimeType : responseMimeType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _FirebaseAIGenerationConfig extends FirebaseAIGenerationConfig {
  const _FirebaseAIGenerationConfig({required this.temperature, required this.topP, required this.maxOutputTokens, required this.responseMimeType}): super._();
  factory _FirebaseAIGenerationConfig.fromJson(Map<String, dynamic> json) => _$FirebaseAIGenerationConfigFromJson(json);

@override final  double? temperature;
@override final  double? topP;
@override final  int? maxOutputTokens;
@override final  String? responseMimeType;

/// Create a copy of FirebaseAIGenerationConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FirebaseAIGenerationConfigCopyWith<_FirebaseAIGenerationConfig> get copyWith => __$FirebaseAIGenerationConfigCopyWithImpl<_FirebaseAIGenerationConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FirebaseAIGenerationConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FirebaseAIGenerationConfig&&(identical(other.temperature, temperature) || other.temperature == temperature)&&(identical(other.topP, topP) || other.topP == topP)&&(identical(other.maxOutputTokens, maxOutputTokens) || other.maxOutputTokens == maxOutputTokens)&&(identical(other.responseMimeType, responseMimeType) || other.responseMimeType == responseMimeType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,temperature,topP,maxOutputTokens,responseMimeType);

@override
String toString() {
  return 'FirebaseAIGenerationConfig(temperature: $temperature, topP: $topP, maxOutputTokens: $maxOutputTokens, responseMimeType: $responseMimeType)';
}


}

/// @nodoc
abstract mixin class _$FirebaseAIGenerationConfigCopyWith<$Res> implements $FirebaseAIGenerationConfigCopyWith<$Res> {
  factory _$FirebaseAIGenerationConfigCopyWith(_FirebaseAIGenerationConfig value, $Res Function(_FirebaseAIGenerationConfig) _then) = __$FirebaseAIGenerationConfigCopyWithImpl;
@override @useResult
$Res call({
 double? temperature, double? topP, int? maxOutputTokens, String? responseMimeType
});




}
/// @nodoc
class __$FirebaseAIGenerationConfigCopyWithImpl<$Res>
    implements _$FirebaseAIGenerationConfigCopyWith<$Res> {
  __$FirebaseAIGenerationConfigCopyWithImpl(this._self, this._then);

  final _FirebaseAIGenerationConfig _self;
  final $Res Function(_FirebaseAIGenerationConfig) _then;

/// Create a copy of FirebaseAIGenerationConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? temperature = freezed,Object? topP = freezed,Object? maxOutputTokens = freezed,Object? responseMimeType = freezed,}) {
  return _then(_FirebaseAIGenerationConfig(
temperature: freezed == temperature ? _self.temperature : temperature // ignore: cast_nullable_to_non_nullable
as double?,topP: freezed == topP ? _self.topP : topP // ignore: cast_nullable_to_non_nullable
as double?,maxOutputTokens: freezed == maxOutputTokens ? _self.maxOutputTokens : maxOutputTokens // ignore: cast_nullable_to_non_nullable
as int?,responseMimeType: freezed == responseMimeType ? _self.responseMimeType : responseMimeType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
