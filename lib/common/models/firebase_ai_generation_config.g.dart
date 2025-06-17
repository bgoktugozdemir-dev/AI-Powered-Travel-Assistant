// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firebase_ai_generation_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FirebaseAIGenerationConfig _$FirebaseAIGenerationConfigFromJson(
  Map<String, dynamic> json,
) => _FirebaseAIGenerationConfig(
  temperature: (json['temperature'] as num?)?.toDouble(),
  topP: (json['topP'] as num?)?.toDouble(),
  maxOutputTokens: (json['maxOutputTokens'] as num?)?.toInt(),
  responseMimeType: json['responseMimeType'] as String?,
);

Map<String, dynamic> _$FirebaseAIGenerationConfigToJson(
  _FirebaseAIGenerationConfig instance,
) => <String, dynamic>{
  'temperature': instance.temperature,
  'topP': instance.topP,
  'maxOutputTokens': instance.maxOutputTokens,
  'responseMimeType': instance.responseMimeType,
};
