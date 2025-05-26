import 'package:flutter/material.dart';
import 'package:travel_assistant/common/theme/app_colors.dart';

abstract class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        primary: AppColors.primaryBlue,
        secondary: AppColors.accentTeal,
        surface: AppColors.neutralWhite,
        error: AppColors.semanticError,
        onPrimary: AppColors.neutralWhite,
        onSecondary: AppColors.neutralWhite,
        onSurface: AppColors.neutralBlack,
        onError: AppColors.neutralWhite,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.neutralWhite,
      appBarTheme: const AppBarTheme(backgroundColor: AppColors.primaryBlue, foregroundColor: AppColors.neutralWhite),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        color: AppColors.neutralWhite,
        surfaceTintColor: AppColors.neutralWhite,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.primaryLightBlue.withValues(alpha: 0.2),
        selectedColor: AppColors.primaryBlue,
        secondarySelectedColor: AppColors.accentTeal,
        labelStyle: const TextStyle(color: AppColors.neutralBlack),
        secondaryLabelStyle: const TextStyle(color: AppColors.neutralWhite),
        iconTheme: const IconThemeData(color: AppColors.primaryDarkBlue, size: 18),
        checkmarkColor: AppColors.neutralWhite,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.neutralWhite,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: AppColors.primaryBlue)),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.neutralLightGrey.withValues(alpha: 0.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
        hintStyle: const TextStyle(color: AppColors.neutralDarkGrey),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: AppColors.primaryDarkBlue, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: AppColors.primaryDarkBlue, fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(color: AppColors.neutralBlack),
        labelLarge: TextStyle(color: AppColors.neutralWhite, fontWeight: FontWeight.bold),
      ),
    );
  }

  // TODO: Define a darkTheme if needed in the future
  // static ThemeData get darkTheme { ... }
}
