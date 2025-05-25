import 'package:flutter/material.dart';

abstract class AppColors {
  // Primary Colors - Evoking trust and travel (sky, sea)
  static const Color primaryBlue = Color(0xFF0077B6); // A strong, professional blue
  static const Color primaryLightBlue = Color(0xFF90E0EF); // A lighter, airy blue for accents or backgrounds
  static const Color primaryDarkBlue = Color(0xFF023E8A); // A deeper blue for text or important elements

  // Accent Colors - For calls to action, highlights (energy, excitement)
  static const Color accentOrange = Color(0xFFFFA500); // A vibrant orange, reminiscent of sunsets or adventure
  static const Color accentTeal = Color(0xFF00BFA6);   // A refreshing teal, for a modern touch

  // Neutral Colors - For backgrounds, text, and borders
  static const Color neutralWhite = Color(0xFFFFFFFF);
  static const Color neutralLightGrey = Color(0xFFF5F5F5); // Very light grey for backgrounds
  static const Color neutralMediumGrey = Color(0xFFE0E0E0); // Light grey for dividers, borders
  static const Color neutralDarkGrey = Color(0xFF757575);   // Medium grey for secondary text
  static const Color neutralBlack = Color(0xFF212121);     // Dark grey/off-black for primary text

  // Semantic Colors - For conveying meaning (success, error, warning)
  static const Color semanticSuccess = Color(0xFF4CAF50);  // Green for success messages
  static const Color semanticError = Color(0xFFF44336);    // Red for error messages
  static const Color semanticWarning = Color(0xFFFFC107);  // Amber/Yellow for warnings

  // Additional Travel-Inspired Colors (Optional, for specific themes or UI elements)
  static const Color sandBeige = Color(0xFFF0E68C);      // Warm beige, like a sandy beach
  static const Color forestGreen = Color(0xFF228B22);    // Deep green, for nature or eco-travel
  static const Color sunsetPink = Color(0xFFFF7F50);      // A softer, warm pink for highlights
} 