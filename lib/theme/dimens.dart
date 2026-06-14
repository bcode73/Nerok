/// Spacing, radii and motion tokens. No hardcoded sizes outside the theme.
abstract final class AppRadii {
  static const double card = 20;
  static const double input = 14;
  static const double pill = 999; // chips + buttons fully rounded
}

abstract final class AppSpace {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

abstract final class AppMotion {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 250);
  static const double pressScale = 0.97;
}
