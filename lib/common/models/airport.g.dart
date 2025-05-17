// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'airport.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Airport _$AirportFromJson(Map<String, dynamic> json) => _Airport(
  iataCode: json['iataCode'] as String,
  name: json['name'] as String,
  countryCode: json['countryCode'] as String,
  countryName: json['countryName'] as String,
  cityName: json['cityName'] as String,
);

Map<String, dynamic> _$AirportToJson(_Airport instance) => <String, dynamic>{
  'iataCode': instance.iataCode,
  'name': instance.name,
  'countryCode': instance.countryCode,
  'countryName': instance.countryName,
  'cityName': instance.cityName,
};
