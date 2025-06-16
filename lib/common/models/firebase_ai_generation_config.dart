import 'dart:math';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:travel_assistant/common/utils/logger/logger.dart';

part 'firebase_ai_generation_config.freezed.dart';
part 'firebase_ai_generation_config.g.dart';

abstract class _Constants {
  // Gemini 2.0 Max Output Tokens
  static const int _availableGemini2MaxOutputTokens = 8_192;

  // Gemini 2.5 Max Output Tokens
  static const int _availableGemini25MaxOutputTokens = 65_536;

  static const int _defaultMaxOutputTokens = 4000;
}

/// Model for Firebase AI Generation Config.
@freezed
abstract class FirebaseAIGenerationConfig with _$FirebaseAIGenerationConfig {
  const FirebaseAIGenerationConfig._();

  const factory FirebaseAIGenerationConfig({
    double? temperature,
    @JsonKey(name: 'top_p') double? topP,
    @JsonKey(name: 'max_output_tokens') int? maxOutputTokens,
    @JsonKey(name: 'response_mime_type') String? responseMimeType,
  }) = _FirebaseAIGenerationConfig;

  factory FirebaseAIGenerationConfig.fromJson(Map<String, dynamic> json) =>
      _$FirebaseAIGenerationConfigFromJson(json);

  GenerationConfig toGenerationConfig(String model) {
    return GenerationConfig(
      temperature: temperature,
      topP: topP,
      maxOutputTokens: maxOutputTokens != null ? min(maxOutputTokens!, _getAvailableMaxOutputTokens(model)) : null,
      responseMimeType: responseMimeType,
    );
  }

  static int _getAvailableMaxOutputTokens(String model) {
    if (model.contains('gemini-2.0')) {
      return _Constants._availableGemini2MaxOutputTokens;
    } else if (model.contains('gemini-2.5')) {
      return _Constants._availableGemini25MaxOutputTokens;
    }
    appLogger.e('Unknown model: $model, using default max output tokens: ${_Constants._defaultMaxOutputTokens}');
    return _Constants._defaultMaxOutputTokens;
  }
}
