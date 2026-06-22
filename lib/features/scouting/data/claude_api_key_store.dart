import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ClaudeApiKeyStore {
  ClaudeApiKeyStore({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  static const storageKey = 'claude_api_key';

  final FlutterSecureStorage _storage;

  Future<String?> readApiKey() => _storage.read(key: storageKey);

  Future<void> saveApiKey(String apiKey) =>
      _storage.write(key: storageKey, value: apiKey.trim());

  Future<void> clearApiKey() => _storage.delete(key: storageKey);

  Future<bool> hasApiKey() async {
    final value = await readApiKey();
    return value != null && value.trim().isNotEmpty;
  }
}
