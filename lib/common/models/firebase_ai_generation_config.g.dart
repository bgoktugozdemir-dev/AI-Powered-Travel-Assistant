// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firebase_ai_generation_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FirebaseAIGenerationConfig _$FirebaseAIGenerationConfigFromJson(
  Map<String, dynamic> json,
) => _FirebaseAIGenerationConfig(
  temperature: (json['temperature'] as num?)?.toDouble(),
  topP: (json['top_p'] as num?)?.toDouble(),
  maxOutputTokens: (json['max_output_tokens'] as num?)?.toInt(),
  responseMimeType: json['response_mime_type'] as String?,
);

Map<String, dynamic> _$FirebaseAIGenerationConfigToJson(
  _FirebaseAIGenerationConfig instance,
) => <String, dynamic>{
  'temperature': instance.temperature,
  'top_p': instance.topP,
  'max_output_tokens': instance.maxOutputTokens,
  'response_mime_type': instance.responseMimeType,
};
