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
      // Extract JSON from the response using the proper method
      final jsonText = _extractJsonFromMarkdown(text);
      final jsonData = jsonDecode(jsonText) as Map<String, dynamic>;

      return TravelDetails.fromJson(jsonData);
    } catch (e) {
      debugPrint('Error parsing travel details response: $e');
      return null;
    }
  }

  static String _extractJsonFromMarkdown(String text) {
    // Extract JSON from markdown code blocks if present
    final jsonMatch = RegExp(_Constants.jsonInMarkdownPattern, dotAll: true).firstMatch(text);
    if (jsonMatch != null) {
      return jsonMatch.group(1)!;
    }

    // Try to find JSON object in the text
    final directJsonMatch = RegExp(_Constants.directJsonPattern, dotAll: true).firstMatch(text);
    if (directJsonMatch != null) {
      return directJsonMatch.group(0)!;
    }

    throw const FormatException('No valid JSON found in text');
  }
}
