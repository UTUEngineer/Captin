import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/settings/domain/app_theme_variant.dart';
import 'package:flutter/material.dart';

abstract final class AppTheme {
  /// Resolves the palette for a variant, using [platformBrightness] when the
  /// user picked "Auto".
  static CaptainPalette paletteFor(
    AppThemeVariant variant, {
    Brightness platformBrightness = Brightness.dark,
  }) {
    return switch (variant) {
      AppThemeVariant.light => CaptainPalette.light,
      AppThemeVariant.dark => CaptainPalette.dark,
      AppThemeVariant.pitchBlack => CaptainPalette.pitchBlack,
      AppThemeVariant.system => platformBrightness == Brightness.light
          ? CaptainPalette.light
          : CaptainPalette.dark,
    };
  }

  static ThemeData themeFor(
    AppThemeVariant variant, {
    Brightness platformBrightness = Brightness.dark,
  }) {
    return fromPalette(
      paletteFor(variant, platformBrightness: platformBrightness),
    );
  }

  static ThemeData fromPalette(CaptainPalette p) {
    final colorScheme = ColorScheme(
      brightness: p.brightness,
      primary: p.primary,
      onPrimary: p.onPrimary,
      primaryContainer: p.primarySoft,
      onPrimaryContainer: p.textPrimary,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      tertiary: AppColors.gold,
      onTertiary: Colors.black,
      error: AppColors.danger,
      onError: Colors.white,
      surface: p.surface,
      onSurface: p.textPrimary,
      onSurfaceVariant: p.textSecondary,
      surfaceContainerLowest: p.surfaceSunken,
      surfaceContainerLow: p.background,
      surfaceContainer: p.surface,
      surfaceContainerHigh: p.surfaceElevated,
      surfaceContainerHighest: p.surfaceElevated,
      outline: p.border,
      outlineVariant: p.border,
      shadow: Colors.black,
      inverseSurface: p.textPrimary,
      onInverseSurface: p.background,
    );

    final radius12 = BorderRadius.circular(12);
    final baseText = Typography.material2021(
      platform: TargetPlatform.android,
    ).englishLike;

    return ThemeData(
      useMaterial3: true,
      brightness: p.brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: p.background,
      canvasColor: p.background,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        backgroundColor: p.surface,
        foregroundColor: p.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        shape: Border(bottom: BorderSide(color: p.border, width: 0.6)),
        titleTextStyle: TextStyle(
          color: p.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: p.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: p.border),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: p.textMuted,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: p.isDark ? p.surfaceElevated : p.textPrimary,
        contentTextStyle: TextStyle(
          color: p.isDark ? p.textPrimary : p.background,
        ),
        shape: RoundedRectangleBorder(borderRadius: radius12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: p.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: radius12),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: p.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: radius12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.textPrimary,
          side: BorderSide(color: p.border),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: radius12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: p.primary),
      ),
      iconTheme: IconThemeData(color: p.textSecondary),
      chipTheme: ChipThemeData(
        backgroundColor: p.surfaceElevated,
        selectedColor: p.primarySoft,
        side: BorderSide(color: p.border),
        labelStyle: TextStyle(color: p.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: p.primarySoft,
          selectedForegroundColor: p.textPrimary,
          foregroundColor: p.textSecondary,
          side: BorderSide(color: p.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surfaceSunken,
        hintStyle: TextStyle(color: p.textMuted),
        border: OutlineInputBorder(
          borderRadius: radius12,
          borderSide: BorderSide(color: p.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius12,
          borderSide: BorderSide(color: p.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius12,
          borderSide: BorderSide(color: p.primary, width: 1.6),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: p.primary,
        unselectedLabelColor: p.textSecondary,
        indicatorColor: p.primary,
        dividerColor: p.border,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.white
              : p.textMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? p.primary
              : p.surfaceSunken,
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: p.textSecondary,
        textColor: p.textPrimary,
      ),
      dividerTheme: DividerThemeData(color: p.border, thickness: 0.8),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: p.primary),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: p.isDark ? p.surfaceElevated : p.textPrimary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: p.border),
        ),
        textStyle: TextStyle(color: p.isDark ? p.textPrimary : p.background),
      ),
      textTheme: baseText.copyWith(
        headlineLarge: TextStyle(
          color: p.textPrimary,
          fontWeight: FontWeight.w800,
        ),
        headlineMedium: TextStyle(
          color: p.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        headlineSmall: TextStyle(
          color: p.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: TextStyle(
          color: p.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: p.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: TextStyle(
          color: p.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: p.textPrimary),
        bodyMedium: TextStyle(color: p.textSecondary),
        bodySmall: TextStyle(color: p.textMuted),
        labelLarge: TextStyle(
          color: p.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        labelMedium: TextStyle(color: p.textSecondary),
        labelSmall: TextStyle(color: p.textMuted),
      ),
    );
  }

  static ThemeData get dark => fromPalette(CaptainPalette.dark);
  static ThemeData get light => fromPalette(CaptainPalette.light);
}
