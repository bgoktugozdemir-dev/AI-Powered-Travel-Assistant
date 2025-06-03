// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'travel_purpose.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TravelPurpose _$TravelPurposeFromJson(Map<String, dynamic> json) =>
    _TravelPurpose(
      id: json['id'] as String,
      name: json['name'] as String,
      localizationKey: json['localizationKey'] as String,
      icon: json['icon'] as String?,
    );

Map<String, dynamic> _$TravelPurposeToJson(_TravelPurpose instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'localizationKey': instance.localizationKey,
      'icon': instance.icon,
    };
