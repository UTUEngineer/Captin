import 'dart:convert';

import 'package:captain/features/formations/domain/tactic_board_template.dart';
import 'package:shared_preferences/shared_preferences.dart';

const boardAutosaveStorageKey = 'captain_board_autosave_v1';

class LocalBoardAutosaveStore {
  LocalBoardAutosaveStore(this._prefs);

  final SharedPreferences _prefs;

  static Future<LocalBoardAutosaveStore> create() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalBoardAutosaveStore(prefs);
  }

  Future<TacticBoardTemplate?> load() async {
    final raw = _prefs.getString(boardAutosaveStorageKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return TacticBoardTemplate.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> save(TacticBoardTemplate template) async {
    await _prefs.setString(
      boardAutosaveStorageKey,
      jsonEncode(template.toJson()),
    );
  }

  Future<void> clear() async {
    await _prefs.remove(boardAutosaveStorageKey);
  }
}
