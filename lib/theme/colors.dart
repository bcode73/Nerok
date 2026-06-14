import 'package:flutter/material.dart';

/// Nerok color tokens. Single dark theme: warm and dim, intentionally calm for
/// a light-sensitive audience. One ember accent. Never pure black or white.
abstract final class AppColors {
  // Backgrounds
  static const Color bg = Color(0xFF14110D);
  static const Color page = Color(0xFF0E0C09); // gradient base behind content
  static const Color surface = Color(0xFF1F1A14);
  static const Color surface2 = Color(0xFF2A231B);

  // Hairlines (warm white at low opacity)
  static const Color line = Color(0x14F4EDE3); // ~8%
  static const Color line2 = Color(0x24F4EDE3); // ~14%

  // Text
  static const Color textHi = Color(0xFFF4EDE3);
  static const Color textMid = Color(0xFFBDB2A1);
  static const Color textLow = Color(0xFF857B6C);

  // Accent (ember)
  static const Color accent = Color(0xFFE0935E);
  static const Color accentDeep = Color(0xFFC9794A);
  static const Color accentSoft = Color(0x24E0935E); // ~14%

  // Positive trend only — never a traffic-light scale.
  static const Color good = Color(0xFF9FB7A0);

  /// Single-hue ember ramp for intensity 1..10. Light/desaturated at low,
  /// [accentDeep] at high. Deliberately not green-to-red.
  static Color intensity(int value) {
    final v = value.clamp(1, 10);
    final t = (v - 1) / 9.0; // 0..1
    // From a soft, desaturated ember up to the deep ember.
    const low = Color(0xFFE9C7A8);
    const high = accentDeep;
    return Color.lerp(low, high, t) ?? accent;
  }

  /// Background gradient used behind page content.
  static const LinearGradient pageGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [bg, page],
  );
}
