// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'travel_purpose.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TravelPurpose {

 String get id; String get name; String? get icon;
/// Create a copy of TravelPurpose
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TravelPurposeCopyWith<TravelPurpose> get copyWith => _$TravelPurposeCopyWithImpl<TravelPurpose>(this as TravelPurpose, _$identity);

  /// Serializes this TravelPurpose to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TravelPurpose&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.icon, icon) || other.icon == icon));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,icon);

@override
String toString() {
  return 'TravelPurpose(id: $id, name: $name, icon: $icon)';
}


}

/// @nodoc
abstract mixin class $TravelPurposeCopyWith<$Res>  {
  factory $TravelPurposeCopyWith(TravelPurpose value, $Res Function(TravelPurpose) _then) = _$TravelPurposeCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? icon
});




}
/// @nodoc
class _$TravelPurposeCopyWithImpl<$Res>
    implements $TravelPurposeCopyWith<$Res> {
  _$TravelPurposeCopyWithImpl(this._self, this._then);

  final TravelPurpose _self;
  final $Res Function(TravelPurpose) _then;

/// Create a copy of TravelPurpose
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? icon = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _TravelPurpose extends TravelPurpose {
  const _TravelPurpose({required this.id, required this.name, this.icon}): super._();
  factory _TravelPurpose.fromJson(Map<String, dynamic> json) => _$TravelPurposeFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? icon;

/// Create a copy of TravelPurpose
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TravelPurposeCopyWith<_TravelPurpose> get copyWith => __$TravelPurposeCopyWithImpl<_TravelPurpose>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TravelPurposeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TravelPurpose&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.icon, icon) || other.icon == icon));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,icon);

@override
String toString() {
  return 'TravelPurpose(id: $id, name: $name, icon: $icon)';
}


}

/// @nodoc
abstract mixin class _$TravelPurposeCopyWith<$Res> implements $TravelPurposeCopyWith<$Res> {
  factory _$TravelPurposeCopyWith(_TravelPurpose value, $Res Function(_TravelPurpose) _then) = __$TravelPurposeCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? icon
});




}
/// @nodoc
class __$TravelPurposeCopyWithImpl<$Res>
    implements _$TravelPurposeCopyWith<$Res> {
  __$TravelPurposeCopyWithImpl(this._self, this._then);

  final _TravelPurpose _self;
  final $Res Function(_TravelPurpose) _then;

/// Create a copy of TravelPurpose
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? icon = freezed,}) {
  return _then(_TravelPurpose(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
