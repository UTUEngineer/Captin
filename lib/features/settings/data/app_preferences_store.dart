import 'dart:convert';

import 'package:captain/features/settings/domain/app_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _storageKey = 'captain_app_preferences_v1';

class AppPreferencesStore {
  AppPreferencesStore(this._prefs);

  final SharedPreferences _prefs;

  static Future<AppPreferencesStore> create() async {
    final prefs = await SharedPreferences.getInstance();
    return AppPreferencesStore(prefs);
  }

  Future<AppPreferences> load() async {
    final raw = _prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return const AppPreferences();
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return AppPreferences.fromJson(json);
    } catch (_) {
      return const AppPreferences();
    }
  }

  Future<void> save(AppPreferences preferences) async {
    await _prefs.setString(
      _storageKey,
      jsonEncode(preferences.toJson()),
    );
  }
}
