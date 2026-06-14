import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

/// Typography tokens.
///
/// Fraunces (weight 500) is reserved for emotional/display moments: onboarding
/// and paywall headlines, big stat numbers, and the PDF report title.
/// Plus Jakarta Sans carries all standard UI, body, labels and buttons.
abstract final class AppType {
  // --- Display (Fraunces) ---
  static TextStyle display = GoogleFonts.fraunces(
    fontSize: 34,
    fontWeight: FontWeight.w500,
    height: 1.12,
    letterSpacing: -0.5,
    color: AppColors.textHi,
  );

  static TextStyle displaySmall = GoogleFonts.fraunces(
    fontSize: 26,
    fontWeight: FontWeight.w500,
    height: 1.15,
    letterSpacing: -0.3,
    color: AppColors.textHi,
  );

  /// Big stat number, e.g. the intensity value and Home ring count.
  static TextStyle statNumber = GoogleFonts.fraunces(
    fontSize: 56,
    fontWeight: FontWeight.w500,
    height: 1.0,
    letterSpacing: -1,
    color: AppColors.textHi,
  );

  // --- UI (Plus Jakarta Sans) ---
  static TextStyle titleLarge = GoogleFonts.plusJakartaSans(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textHi,
  );

  static TextStyle title = GoogleFonts.plusJakartaSans(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textHi,
  );

  static TextStyle body = GoogleFonts.plusJakartaSans(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.textMid,
  );

  static TextStyle bodyHi = GoogleFonts.plusJakartaSans(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.textHi,
  );

  static TextStyle label = GoogleFonts.plusJakartaSans(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textMid,
  );

  static TextStyle caption = GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textLow,
  );

  static TextStyle button = GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textHi,
  );

  /// TextTheme wired into ThemeData so default widgets pick up Plus Jakarta Sans.
  static TextTheme textTheme = TextTheme(
    displayLarge: display,
    displayMedium: displaySmall,
    titleLarge: titleLarge,
    titleMedium: title,
    bodyLarge: bodyHi,
    bodyMedium: body,
    labelLarge: label,
    bodySmall: caption,
  );
}
