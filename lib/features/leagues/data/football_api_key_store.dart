import 'package:captain/core/config/app_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FootballApiKeyStore {
  FootballApiKeyStore({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  static const storageKey = 'football_api_key';

  final FlutterSecureStorage _storage;

  Future<String?> readApiKey() async {
    final stored = await _storage.read(key: storageKey);
    if (stored != null && stored.trim().isNotEmpty) return stored.trim();
    return AppConfig.footballApiKey.isEmpty ? null : AppConfig.footballApiKey;
  }

  Future<void> saveApiKey(String apiKey) =>
      _storage.write(key: storageKey, value: apiKey.trim());

  Future<void> clearApiKey() => _storage.delete(key: storageKey);

  Future<bool> hasApiKey() async {
    final value = await readApiKey();
    return value != null && value.isNotEmpty;
  }
}
