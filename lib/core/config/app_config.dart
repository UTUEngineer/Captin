import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Runtime configuration for the Captain app.
///
/// Values resolve in order: `.env` file → `--dart-define` → built-in default.
///
/// ```bash
/// flutter run \
///   --dart-define=SUPABASE_URL=https://xxx.supabase.co \
///   --dart-define=SUPABASE_ANON_KEY=eyJ... \
///   --dart-define=ANTHROPIC_API_KEY=sk-ant-... \
///   --dart-define=API_FOOTBALL_KEY=xxx \
///   --dart-define=VISION_BACKEND_URL=http://10.0.2.2:8000
/// ```
///
/// TODO(release): Do not ship production secrets inside the release `.env` asset.
/// Use CI dart-defines or remote config instead.
abstract final class AppConfig {
  static const int maxVideoDurationMinutes = int.fromEnvironment(
    'MAX_VIDEO_DURATION_MINUTES',
    defaultValue: 10,
  );

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const String defaultVisionApiBaseUrl = 'http://127.0.0.1:8000';
  static const String defaultFootballApiHost = 'v3.football.api-sports.io';

  static String get visionApiBaseUrl => _firstNonEmpty(
        envKeys: const ['VISION_BACKEND_URL', 'VISION_API_BASE_URL'],
        defineKeys: const ['VISION_BACKEND_URL', 'VISION_API_BASE_URL'],
        defaultValue: defaultVisionApiBaseUrl,
      );

  static String get supabaseUrl => _firstNonEmpty(
        envKeys: const ['SUPABASE_URL'],
        defineKeys: const ['SUPABASE_URL'],
      );

  static String get supabaseAnonKey => _firstNonEmpty(
        envKeys: const ['SUPABASE_ANON_KEY'],
        defineKeys: const ['SUPABASE_ANON_KEY'],
      );

  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static String get anthropicApiKey => _firstNonEmpty(
        envKeys: const ['ANTHROPIC_API_KEY'],
        defineKeys: const ['ANTHROPIC_API_KEY'],
      );

  static bool get isAnthropicApiConfigured => anthropicApiKey.isNotEmpty;

  static String get footballApiKey => _firstNonEmpty(
        envKeys: const ['API_FOOTBALL_KEY', 'FOOTBALL_API_KEY'],
        defineKeys: const ['API_FOOTBALL_KEY', 'FOOTBALL_API_KEY'],
      );

  static String get apiFootballKey => footballApiKey;

  static String get footballApiHost => _firstNonEmpty(
        envKeys: const ['API_FOOTBALL_HOST'],
        defineKeys: const ['API_FOOTBALL_HOST'],
        defaultValue: defaultFootballApiHost,
      );

  static String get apiFootballHost => footballApiHost;

  static bool get isFootballApiConfigured => footballApiKey.isNotEmpty;

  static String get appEnv => _firstNonEmpty(
        envKeys: const ['APP_ENV'],
        defineKeys: const ['APP_ENV'],
        defaultValue: 'development',
      );

  static bool get isProduction =>
      appEnv.trim().toLowerCase() == 'production';

  static bool get isDevelopment => !isProduction;

  static String _firstNonEmpty({
    required List<String> envKeys,
    required List<String> defineKeys,
    String defaultValue = '',
  }) {
    for (final key in envKeys) {
      final fromEnv = _readEnv(key);
      if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;
    }

    for (final key in defineKeys) {
      final fromDefine = String.fromEnvironment(key, defaultValue: '');
      if (fromDefine.isNotEmpty) return fromDefine;
    }

    return defaultValue;
  }

  static String? _readEnv(String key) {
    try {
      return dotenv.maybeGet(key)?.trim();
    } catch (_) {
      return null;
    }
  }
}
