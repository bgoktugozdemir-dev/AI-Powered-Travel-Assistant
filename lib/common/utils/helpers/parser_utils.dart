import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:travel_assistant/common/models/response/travel_details.dart';

abstract class _Constants {
  // Regex patterns for JSON extraction
  static const String jsonInMarkdownPattern = r'```(?:json)?\s*(\{.*?\})\s*```';
  static const String directJsonPattern = r'\{.*\}';
}

abstract class ParserUtils {
  static TravelDetails? parseTravelDetails(String text) {
    try {
      return parseTravelDetailsOrThrow(text);
    } catch (e) {
      debugPrint('Error parsing travel details response: $e');
      return null;
    }
  }

  static TravelDetails parseTravelDetailsOrThrow(String text) {
    try {
      final jsonText = extractJsonFromText(text);
      final decodedJson = jsonDecode(jsonText);
      if (decodedJson is! Map<String, dynamic>) {
        throw const FormatException('Travel details JSON must be an object');
      }
      return TravelDetails.fromJson(decodedJson);
    } on FormatException {
      rethrow;
    } catch (e) {
      throw FormatException('Failed to parse travel details JSON: $e');
    }
  }

  static String extractJsonFromText(String text) {
    // Extract JSON from markdown code blocks if present
    final jsonMatch = RegExp(
      _Constants.jsonInMarkdownPattern,
      dotAll: true,
    ).firstMatch(text);
    if (jsonMatch != null) {
      return jsonMatch.group(1)!;
    }

    // Try to find JSON object in the text
    final directJsonMatch = RegExp(
      _Constants.directJsonPattern,
      dotAll: true,
    ).firstMatch(text);
    if (directJsonMatch != null) {
      return directJsonMatch.group(0)!;
    }

    throw const FormatException('No valid JSON found in text');
  }
}
