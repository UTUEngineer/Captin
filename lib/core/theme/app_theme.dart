import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/settings/domain/app_theme_variant.dart';
import 'package:flutter/material.dart';

abstract final class AppTheme {
  static ThemeData themeFor(AppThemeVariant variant) {
    final palette = _paletteFor(variant);
    final colorScheme = ColorScheme.dark(
      brightness: Brightness.dark,
      primary: AppColors.pitchGreenLight,
      onPrimary: AppColors.textPrimary,
      secondary: AppColors.accentOrange,
      onSecondary: AppColors.textPrimary,
      tertiary: AppColors.accentRed,
      onTertiary: AppColors.textPrimary,
      surface: palette.surface,
      onSurface: AppColors.textPrimary,
      error: AppColors.accentRed,
      onError: AppColors.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: palette.background,
      appBarTheme: AppBarTheme(
        backgroundColor: palette.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: palette.surfaceElevated,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.pitchGreenLight,
          foregroundColor: AppColors.textPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: AppColors.textPrimary),
        bodyMedium: TextStyle(color: AppColors.textSecondary),
        labelLarge: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static ThemeData get dark => themeFor(AppThemeVariant.dark);

  static _ThemePalette _paletteFor(AppThemeVariant variant) {
    return switch (variant) {
      AppThemeVariant.dark => const _ThemePalette(
          background: AppColors.background,
          surface: AppColors.surface,
          surfaceElevated: AppColors.surfaceElevated,
        ),
      AppThemeVariant.darker => const _ThemePalette(
          background: AppColors.backgroundDarker,
          surface: AppColors.surfaceDarker,
          surfaceElevated: AppColors.surfaceElevatedDarker,
        ),
      AppThemeVariant.pitchBlack => const _ThemePalette(
          background: AppColors.pitchBlackBackground,
          surface: AppColors.pitchBlackSurface,
          surfaceElevated: AppColors.pitchBlackElevated,
        ),
    };
  }
}

class _ThemePalette {
  const _ThemePalette({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
  });

  final Color background;
  final Color surface;
  final Color surfaceElevated;
}
