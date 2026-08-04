import 'package:flutter/material.dart';

/// Color constants derived from Solaris Refined Design Tokens.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF855300);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFF59E0B);
  static const Color onPrimaryContainer = Color(0xFF613B00);
  static const Color inversePrimary = Color(0xFFFFB95F);

  static const Color secondary = Color(0xFF904D00);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFFE932C);
  static const Color onSecondaryContainer = Color(0xFF663500);

  static const Color tertiary = Color(0xFF565E74);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFA9B0C9);
  static const Color onTertiaryContainer = Color(0xFF3B4358);

  static const Color background = Color(0xFFF8F9FF);
  static const Color onBackground = Color(0xFF0B1C30);

  static const Color surface = Color(0xFFF8F9FF);
  static const Color onSurface = Color(0xFF0B1C30);
  static const Color onSurfaceVariant = Color(0xFF534434);

  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFEFF4FF);
  static const Color surfaceContainer = Color(0xFFE5EEFF);
  static const Color surfaceContainerHigh = Color(0xFFDCE9FF);
  static const Color surfaceContainerHighest = Color(0xFFD3E4FE);

  static const Color outline = Color(0xFF867461);
  static const Color outlineVariant = Color(0xFFD8C3AD);

  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  // Confidence Status Colors
  static const Color confidenceHigh = Color(0xFF16A34A); // Green
  static const Color confidenceMedium = Color(0xFFD97706); // Amber
  static const Color confidenceLow = Color(0xFFDC2626); // Red
}
