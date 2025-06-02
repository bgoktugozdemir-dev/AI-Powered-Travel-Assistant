// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'travel_information.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TravelInformation {

 Airport get departureAirport; Airport get arrivalAirport; DateTimeRange get dateRange; Country get nationality; List<TravelPurpose> get travelPurposes; String get locale;
/// Create a copy of TravelInformation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TravelInformationCopyWith<TravelInformation> get copyWith => _$TravelInformationCopyWithImpl<TravelInformation>(this as TravelInformation, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TravelInformation&&(identical(other.departureAirport, departureAirport) || other.departureAirport == departureAirport)&&(identical(other.arrivalAirport, arrivalAirport) || other.arrivalAirport == arrivalAirport)&&(identical(other.dateRange, dateRange) || other.dateRange == dateRange)&&(identical(other.nationality, nationality) || other.nationality == nationality)&&const DeepCollectionEquality().equals(other.travelPurposes, travelPurposes)&&(identical(other.locale, locale) || other.locale == locale));
}


@override
int get hashCode => Object.hash(runtimeType,departureAirport,arrivalAirport,dateRange,nationality,const DeepCollectionEquality().hash(travelPurposes),locale);

@override
String toString() {
  return 'TravelInformation(departureAirport: $departureAirport, arrivalAirport: $arrivalAirport, dateRange: $dateRange, nationality: $nationality, travelPurposes: $travelPurposes, locale: $locale)';
}


}

/// @nodoc
abstract mixin class $TravelInformationCopyWith<$Res>  {
  factory $TravelInformationCopyWith(TravelInformation value, $Res Function(TravelInformation) _then) = _$TravelInformationCopyWithImpl;
@useResult
$Res call({
 Airport departureAirport, Airport arrivalAirport, DateTimeRange dateRange, Country nationality, List<TravelPurpose> travelPurposes, String locale
});


$AirportCopyWith<$Res> get departureAirport;$AirportCopyWith<$Res> get arrivalAirport;$CountryCopyWith<$Res> get nationality;

}
/// @nodoc
class _$TravelInformationCopyWithImpl<$Res>
    implements $TravelInformationCopyWith<$Res> {
  _$TravelInformationCopyWithImpl(this._self, this._then);

  final TravelInformation _self;
  final $Res Function(TravelInformation) _then;

/// Create a copy of TravelInformation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? departureAirport = null,Object? arrivalAirport = null,Object? dateRange = null,Object? nationality = null,Object? travelPurposes = null,Object? locale = null,}) {
  return _then(_self.copyWith(
departureAirport: null == departureAirport ? _self.departureAirport : departureAirport // ignore: cast_nullable_to_non_nullable
as Airport,arrivalAirport: null == arrivalAirport ? _self.arrivalAirport : arrivalAirport // ignore: cast_nullable_to_non_nullable
as Airport,dateRange: null == dateRange ? _self.dateRange : dateRange // ignore: cast_nullable_to_non_nullable
as DateTimeRange,nationality: null == nationality ? _self.nationality : nationality // ignore: cast_nullable_to_non_nullable
as Country,travelPurposes: null == travelPurposes ? _self.travelPurposes : travelPurposes // ignore: cast_nullable_to_non_nullable
as List<TravelPurpose>,locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of TravelInformation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AirportCopyWith<$Res> get departureAirport {
  
  return $AirportCopyWith<$Res>(_self.departureAirport, (value) {
    return _then(_self.copyWith(departureAirport: value));
  });
}/// Create a copy of TravelInformation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AirportCopyWith<$Res> get arrivalAirport {
  
  return $AirportCopyWith<$Res>(_self.arrivalAirport, (value) {
    return _then(_self.copyWith(arrivalAirport: value));
  });
}/// Create a copy of TravelInformation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CountryCopyWith<$Res> get nationality {
  
  return $CountryCopyWith<$Res>(_self.nationality, (value) {
    return _then(_self.copyWith(nationality: value));
  });
}
}


/// @nodoc


class _TravelInformation extends TravelInformation {
  const _TravelInformation({required this.departureAirport, required this.arrivalAirport, required this.dateRange, required this.nationality, required final  List<TravelPurpose> travelPurposes, required this.locale}): _travelPurposes = travelPurposes,super._();
  

@override final  Airport departureAirport;
@override final  Airport arrivalAirport;
@override final  DateTimeRange dateRange;
@override final  Country nationality;
 final  List<TravelPurpose> _travelPurposes;
@override List<TravelPurpose> get travelPurposes {
  if (_travelPurposes is EqualUnmodifiableListView) return _travelPurposes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_travelPurposes);
}

@override final  String locale;

/// Create a copy of TravelInformation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TravelInformationCopyWith<_TravelInformation> get copyWith => __$TravelInformationCopyWithImpl<_TravelInformation>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TravelInformation&&(identical(other.departureAirport, departureAirport) || other.departureAirport == departureAirport)&&(identical(other.arrivalAirport, arrivalAirport) || other.arrivalAirport == arrivalAirport)&&(identical(other.dateRange, dateRange) || other.dateRange == dateRange)&&(identical(other.nationality, nationality) || other.nationality == nationality)&&const DeepCollectionEquality().equals(other._travelPurposes, _travelPurposes)&&(identical(other.locale, locale) || other.locale == locale));
}


@override
int get hashCode => Object.hash(runtimeType,departureAirport,arrivalAirport,dateRange,nationality,const DeepCollectionEquality().hash(_travelPurposes),locale);

@override
String toString() {
  return 'TravelInformation(departureAirport: $departureAirport, arrivalAirport: $arrivalAirport, dateRange: $dateRange, nationality: $nationality, travelPurposes: $travelPurposes, locale: $locale)';
}


}

/// @nodoc
abstract mixin class _$TravelInformationCopyWith<$Res> implements $TravelInformationCopyWith<$Res> {
  factory _$TravelInformationCopyWith(_TravelInformation value, $Res Function(_TravelInformation) _then) = __$TravelInformationCopyWithImpl;
@override @useResult
$Res call({
 Airport departureAirport, Airport arrivalAirport, DateTimeRange dateRange, Country nationality, List<TravelPurpose> travelPurposes, String locale
});


@override $AirportCopyWith<$Res> get departureAirport;@override $AirportCopyWith<$Res> get arrivalAirport;@override $CountryCopyWith<$Res> get nationality;

}
/// @nodoc
class __$TravelInformationCopyWithImpl<$Res>
    implements _$TravelInformationCopyWith<$Res> {
  __$TravelInformationCopyWithImpl(this._self, this._then);

  final _TravelInformation _self;
  final $Res Function(_TravelInformation) _then;

/// Create a copy of TravelInformation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? departureAirport = null,Object? arrivalAirport = null,Object? dateRange = null,Object? nationality = null,Object? travelPurposes = null,Object? locale = null,}) {
  return _then(_TravelInformation(
departureAirport: null == departureAirport ? _self.departureAirport : departureAirport // ignore: cast_nullable_to_non_nullable
as Airport,arrivalAirport: null == arrivalAirport ? _self.arrivalAirport : arrivalAirport // ignore: cast_nullable_to_non_nullable
as Airport,dateRange: null == dateRange ? _self.dateRange : dateRange // ignore: cast_nullable_to_non_nullable
as DateTimeRange,nationality: null == nationality ? _self.nationality : nationality // ignore: cast_nullable_to_non_nullable
as Country,travelPurposes: null == travelPurposes ? _self._travelPurposes : travelPurposes // ignore: cast_nullable_to_non_nullable
as List<TravelPurpose>,locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of TravelInformation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AirportCopyWith<$Res> get departureAirport {
  
  return $AirportCopyWith<$Res>(_self.departureAirport, (value) {
    return _then(_self.copyWith(departureAirport: value));
  });
}/// Create a copy of TravelInformation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AirportCopyWith<$Res> get arrivalAirport {
  
  return $AirportCopyWith<$Res>(_self.arrivalAirport, (value) {
    return _then(_self.copyWith(arrivalAirport: value));
  });
}/// Create a copy of TravelInformation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CountryCopyWith<$Res> get nationality {
  
  return $CountryCopyWith<$Res>(_self.nationality, (value) {
    return _then(_self.copyWith(nationality: value));
  });
}
}

// dart format on
