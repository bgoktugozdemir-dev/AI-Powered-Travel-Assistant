import 'dart:math';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'firebase_ai_generation_config.freezed.dart';
part 'firebase_ai_generation_config.g.dart';

abstract class _Constants {
  // Gemini 2.0 Max Output Tokens
  static const int _availableGemini2MaxOutputTokens = 8_192;

  // Gemini 2.5 Max Output Tokens
  static const int _availableGemini25MaxOutputTokens = 65_536;

  // Default Max Output Tokens
  static const int _defaultMaxOutputTokens = 4_000;
}

/// Model for Firebase AI Generation Config.
@freezed
abstract class FirebaseAIGenerationConfig with _$FirebaseAIGenerationConfig {
  const FirebaseAIGenerationConfig._();

  const factory FirebaseAIGenerationConfig({
    required double? temperature,
    required double? topP,
    required int? maxOutputTokens,
    required String? responseMimeType,
  }) = _FirebaseAIGenerationConfig;

  static const FirebaseAIGenerationConfig defaultConfig = FirebaseAIGenerationConfig(
    temperature: null,
    topP: null,
    maxOutputTokens: null,
    responseMimeType: 'application/json',
  );

  /// Creates a [FirebaseAIGenerationConfig] from a JSON object.
  factory FirebaseAIGenerationConfig.fromJson(Map<String, dynamic> json) => _$FirebaseAIGenerationConfigFromJson(json);

  /// Returns the available max output tokens for the given model.
  static int _getAvailableMaxOutputTokens(String model) {
    if (model.contains('gemini-2.0')) {
      return _Constants._availableGemini2MaxOutputTokens;
    } else if (model.contains('gemini-2.5')) {
      return _Constants._availableGemini25MaxOutputTokens;
    }


    return _Constants._defaultMaxOutputTokens;
  }

  /// Converts the [FirebaseAIGenerationConfig] to a [GenerationConfig].
  GenerationConfig toGenerationConfig(String model) {
    return GenerationConfig(
      temperature: temperature,
      topP: topP,
      maxOutputTokens: maxOutputTokens != null ? min(maxOutputTokens!, _getAvailableMaxOutputTokens(model)) : null,
      responseMimeType: responseMimeType,
    );
  }
}
