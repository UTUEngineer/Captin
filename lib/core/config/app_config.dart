import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Runtime configuration for the Captain app.
///
/// Override the vision API URL at build time:
/// `flutter run --dart-define=VISION_API_BASE_URL=http://10.0.2.2:8000`
///
/// Supabase credentials can be supplied via `.env` or dart-define:
/// `flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`
///
/// TODO(release): Do not ship production secrets inside the release `.env` asset.
/// Use CI dart-defines or remote config instead.
abstract final class AppConfig {
  static const String visionApiBaseUrl = String.fromEnvironment(
    'VISION_API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  static const int maxVideoDurationMinutes = int.fromEnvironment(
    'MAX_VIDEO_DURATION_MINUTES',
    defaultValue: 10,
  );

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static String get supabaseUrl {
    final fromEnv = dotenv.maybeGet('SUPABASE_URL')?.trim();
    if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;
    return const String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  }

  static String get supabaseAnonKey {
    final fromEnv = dotenv.maybeGet('SUPABASE_ANON_KEY')?.trim();
    if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;
    return const String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: '',
    );
  }

  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static String get footballApiKey {
    final fromEnv = dotenv.maybeGet('FOOTBALL_API_KEY')?.trim();
    if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;
    return const String.fromEnvironment('FOOTBALL_API_KEY', defaultValue: '');
  }

  static bool get isFootballApiConfigured => footballApiKey.isNotEmpty;
}
