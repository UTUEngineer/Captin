import 'dart:convert';

import 'package:captain/features/formations/domain/tactic_board_repository.dart';
import 'package:captain/features/formations/domain/tactic_board_template.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _storageKey = 'captain_saved_boards_v1';

class LocalTacticBoardRepository implements TacticBoardRepository {
  LocalTacticBoardRepository(this._prefs);

  final SharedPreferences _prefs;

  static Future<LocalTacticBoardRepository> create() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalTacticBoardRepository(prefs);
  }

  @override
  Future<List<TacticBoardTemplate>> getSavedTemplates() async {
    final raw = _prefs.getStringList(_storageKey) ?? [];
    return raw
        .map(
          (entry) => TacticBoardTemplate.fromJson(
            jsonDecode(entry) as Map<String, dynamic>,
          ),
        )
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  @override
  Future<void> saveTemplate(TacticBoardTemplate template) async {
    final templates = await getSavedTemplates();
    final index = templates.indexWhere((item) => item.id == template.id);
    if (index >= 0) {
      templates[index] = template;
    } else {
      templates.add(template);
    }
    await _persist(templates);
  }

  @override
  Future<void> deleteTemplate(String id) async {
    final templates = await getSavedTemplates()
      ..removeWhere((template) => template.id == id);
    await _persist(templates);
  }

  @override
  Future<void> renameTemplate({
    required String id,
    required String name,
    String? description,
  }) async {
    final templates = await getSavedTemplates();
    final index = templates.indexWhere((template) => template.id == id);
    if (index < 0) return;

    templates[index] = templates[index].copyWith(
      name: name,
      description: description,
      updatedAt: DateTime.now(),
    );
    await _persist(templates);
  }

  Future<void> _persist(List<TacticBoardTemplate> templates) async {
    final encoded = templates
        .map((template) => jsonEncode(template.toJson()))
        .toList();
    await _prefs.setStringList(_storageKey, encoded);
  }
}
