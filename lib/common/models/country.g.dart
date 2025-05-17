// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'country.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Country _$CountryFromJson(Map<String, dynamic> json) => _Country(
  code: json['code'] as String,
  name: json['name'] as String,
  nationality: json['nationality'] as String?,
  flagEmoji: json['flagEmoji'] as String?,
);

Map<String, dynamic> _$CountryToJson(_Country instance) => <String, dynamic>{
  'code': instance.code,
  'name': instance.name,
  'nationality': instance.nationality,
  'flagEmoji': instance.flagEmoji,
};
