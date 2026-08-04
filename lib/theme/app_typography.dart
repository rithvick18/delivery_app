import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography styles matching Solaris Refined design tokens.
class AppTypography {
  AppTypography._();

  static TextStyle headlineXl = GoogleFonts.manrope(
    fontSize: 36.0,
    fontWeight: FontWeight.w800,
    height: 1.2,
    letterSpacing: -0.02,
    color: AppColors.onSurface,
  );

  static TextStyle headlineLg = GoogleFonts.manrope(
    fontSize: 28.0,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.01,
    color: AppColors.onSurface,
  );

  static TextStyle headlineMobile = GoogleFonts.manrope(
    fontSize: 22.0,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: AppColors.onSurface,
  );

  static TextStyle titleMd = GoogleFonts.manrope(
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.onSurface,
  );

  static TextStyle bodyMd = GoogleFonts.workSans(
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.onSurface,
  );

  static TextStyle bodySm = GoogleFonts.workSans(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.onSurfaceVariant,
  );

  static TextStyle labelCaps = GoogleFonts.jetBrainsMono(
    fontSize: 12.0,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.onSurfaceVariant,
  );

  static TextStyle badgeText = GoogleFonts.jetBrainsMono(
    fontSize: 11.0,
    fontWeight: FontWeight.w700,
    color: AppColors.onPrimaryContainer,
  );
}
