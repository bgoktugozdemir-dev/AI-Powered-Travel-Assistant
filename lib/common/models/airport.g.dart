// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'airport.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Airport _$AirportFromJson(Map<String, dynamic> json) => _Airport(
  iataCode: json['iataCode'] as String,
  name: json['name'] as String,
  country: json['country'] as String,
);

Map<String, dynamic> _$AirportToJson(_Airport instance) => <String, dynamic>{
  'iataCode': instance.iataCode,
  'name': instance.name,
  'country': instance.country,
};
