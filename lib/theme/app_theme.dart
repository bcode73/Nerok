import 'package:flutter/material.dart';

import 'colors.dart';
import 'dimens.dart';
import 'typography.dart';

/// The single dark theme for Nerok.
abstract final class AppTheme {
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);

    final colorScheme = const ColorScheme.dark(
      brightness: Brightness.dark,
      primary: AppColors.accent,
      onPrimary: AppColors.page,
      secondary: AppColors.accentDeep,
      onSecondary: AppColors.textHi,
      surface: AppColors.surface,
      onSurface: AppColors.textHi,
      error: AppColors.accentDeep,
      onError: AppColors.textHi,
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: colorScheme,
      textTheme: AppType.textTheme,
      splashColor: AppColors.accentSoft,
      highlightColor: AppColors.accentSoft,
      dividerColor: AppColors.line,
      iconTheme: const IconThemeData(color: AppColors.textMid),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppType.title,
        iconTheme: const IconThemeData(color: AppColors.textHi),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: AppType.body.copyWith(color: AppColors.textLow),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpace.lg,
          vertical: AppSpace.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.input),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.input),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.input),
          borderSide: const BorderSide(color: AppColors.accent),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.accent,
        inactiveTrackColor: AppColors.surface2,
        thumbColor: AppColors.accent,
        overlayColor: AppColors.accentSoft,
        trackHeight: 6,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.bg,
        surfaceTintColor: Colors.transparent,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surface2,
        contentTextStyle: AppType.bodyHi,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.input),
        ),
      ),
    );
  }
}
