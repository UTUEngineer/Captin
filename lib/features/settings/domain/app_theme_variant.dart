import 'package:flutter/material.dart';

enum AppThemeVariant {
  system('Auto', 'تلقائي', Icons.brightness_auto_outlined),
  light('Light', 'فاتح', Icons.light_mode_outlined),
  dark('Dark', 'داكن', Icons.dark_mode_outlined),
  pitchBlack('Black', 'أسود', Icons.contrast_outlined);

  const AppThemeVariant(this.englishLabel, this.arabicLabel, this.icon);

  final String englishLabel;
  final String arabicLabel;
  final IconData icon;

  static AppThemeVariant fromWire(String? value) {
    // `darker` existed in older builds — fold it into `dark`.
    if (value == 'darker') return AppThemeVariant.dark;
    return AppThemeVariant.values.firstWhere(
      (variant) => variant.name == value,
      orElse: () => AppThemeVariant.dark,
    );
  }
}
