enum AppThemeVariant {
  dark('Dark', 'داكن'),
  darker('Darker', 'أغمق'),
  pitchBlack('Pitch black', 'أسود الملعب');

  const AppThemeVariant(this.englishLabel, this.arabicLabel);
  final String englishLabel;
  final String arabicLabel;

  static AppThemeVariant fromWire(String? value) {
    return AppThemeVariant.values.firstWhere(
      (variant) => variant.name == value,
      orElse: () => AppThemeVariant.dark,
    );
  }
}
