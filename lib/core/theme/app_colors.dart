import 'package:flutter/material.dart';

/// Semantic palette for one brightness. Every screen reads colors through
/// [AppColors], which forwards to the active palette, so switching between
/// light and dark only needs [AppColors.apply] + a rebuild.
@immutable
class CaptainPalette {
  const CaptainPalette({
    required this.brightness,
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.surfaceSunken,
    required this.border,
    required this.subtle,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.primary,
    required this.onPrimary,
    required this.primarySoft,
  });

  final Brightness brightness;
  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color surfaceSunken;
  final Color border;
  final Color subtle;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color primary;
  final Color onPrimary;
  final Color primarySoft;

  bool get isDark => brightness == Brightness.dark;

  /// Calm navy "broadcast studio" dark palette.
  static const dark = CaptainPalette(
    brightness: Brightness.dark,
    background: Color(0xFF0B1220),
    surface: Color(0xFF111A2C),
    surfaceElevated: Color(0xFF17233A),
    surfaceSunken: Color(0xFF080E1A),
    border: Color(0xFF243352),
    subtle: Color(0x14FFFFFF),
    textPrimary: Color(0xFFF1F5F9),
    textSecondary: Color(0xFF9AA8BD),
    textMuted: Color(0xFF66758C),
    primary: Color(0xFF10B981),
    onPrimary: Color(0xFFFFFFFF),
    primarySoft: Color(0xFF0E3B33),
  );

  /// True-black OLED variant of [dark].
  static const pitchBlack = CaptainPalette(
    brightness: Brightness.dark,
    background: Color(0xFF000000),
    surface: Color(0xFF0A0A0B),
    surfaceElevated: Color(0xFF141416),
    surfaceSunken: Color(0xFF000000),
    border: Color(0xFF26262B),
    subtle: Color(0x12FFFFFF),
    textPrimary: Color(0xFFF5F5F5),
    textSecondary: Color(0xFFA1A1AA),
    textMuted: Color(0xFF71717A),
    primary: Color(0xFF10B981),
    onPrimary: Color(0xFFFFFFFF),
    primarySoft: Color(0xFF0B2E27),
  );

  /// Clean daylight palette for outdoor training sessions.
  static const light = CaptainPalette(
    brightness: Brightness.light,
    background: Color(0xFFF3F5F9),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFFFFFFF),
    surfaceSunken: Color(0xFFE9EDF3),
    border: Color(0xFFD9E0EA),
    subtle: Color(0x0F0F172A),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF475569),
    textMuted: Color(0xFF7A8699),
    primary: Color(0xFF059669),
    onPrimary: Color(0xFFFFFFFF),
    primarySoft: Color(0xFFD1FAE5),
  );
}

abstract final class AppColors {
  static CaptainPalette _palette = CaptainPalette.dark;

  static CaptainPalette get palette => _palette;
  static bool get isDark => _palette.isDark;

  /// Switches the active palette. Call before building the themed subtree.
  static void apply(CaptainPalette palette) => _palette = palette;

  // ── Theme-dependent surfaces & text ─────────────────────────────────────
  static Color get background => _palette.background;
  static Color get surface => _palette.surface;
  static Color get surfaceElevated => _palette.surfaceElevated;
  static Color get surfaceSunken => _palette.surfaceSunken;
  static Color get border => _palette.border;
  static Color get subtle => _palette.subtle;
  static Color get textPrimary => _palette.textPrimary;
  static Color get textSecondary => _palette.textSecondary;
  static Color get textMuted => _palette.textMuted;
  static Color get primary => _palette.primary;
  static Color get onPrimary => _palette.onPrimary;
  static Color get primarySoft => _palette.primarySoft;

  // Legacy variant names kept for older call sites.
  static Color get backgroundDarker => _palette.surfaceSunken;
  static Color get surfaceDarker => _palette.surface;
  static Color get surfaceElevatedDarker => _palette.surfaceElevated;
  static const Color pitchBlackBackground = Color(0xFF000000);
  static const Color pitchBlackSurface = Color(0xFF0A0A0B);
  static const Color pitchBlackElevated = Color(0xFF141416);

  // ── Fixed brand / semantic colors (same in light & dark) ────────────────
  static const Color brand = Color(0xFF10B981);
  static const Color secondary = Color(0xFF3B82F6);
  static const Color info = Color(0xFF0EA5E9);
  static const Color gold = Color(0xFFF59E0B);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFE11D48);

  // Team kits used across boards.
  static const Color homeTeam = Color(0xFF2563EB);
  static const Color homeTeamDark = Color(0xFF1E3A8A);
  static const Color awayTeam = Color(0xFFDC2626);
  static const Color awayTeamDark = Color(0xFF7F1D1D);
  static const Color ball = Color(0xFFFFFFFF);

  // Pitch (always green, independent of app brightness).
  static const Color pitchGreen = Color(0xFF2E7D32);
  static const Color pitchGreenLight = Color(0xFF388E3C);
  static const Color pitchGreenDeep = Color(0xFF1B5E20);
  static const Color pitchLine = Color(0xE6FFFFFF);

  // Tactical accents.
  static const Color accentOrange = Color(0xFFF97316);
  static const Color accentRed = Color(0xFFE53935);

  /// Pure white/black for content that sits on photos, pitch or video.
  static const Color onMedia = Color(0xFFFFFFFF);
}
