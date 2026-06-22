import 'dart:convert';

import 'package:captain/features/video_analysis/domain/recent_video_analysis.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _storageKey = 'captain_recent_analyses_v1';
const _maxEntries = 20;

class LocalRecentAnalysesStore {
  LocalRecentAnalysesStore(this._prefs);

  final SharedPreferences _prefs;

  static Future<LocalRecentAnalysesStore> create() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalRecentAnalysesStore(prefs);
  }

  Future<List<RecentVideoAnalysis>> loadAll() async {
    final raw = _prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return const [];

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((entry) => RecentVideoAnalysis.fromJson(entry as Map<String, dynamic>))
        .toList();
  }

  Future<void> recordCompleted({
    required String videoId,
    required String label,
  }) async {
    final existing = await loadAll();
    final updated = [
      RecentVideoAnalysis(
        videoId: videoId,
        label: label,
        completedAt: DateTime.now(),
      ),
      ...existing.where((entry) => entry.videoId != videoId),
    ].take(_maxEntries).toList();

    await _prefs.setString(
      _storageKey,
      jsonEncode(updated.map((entry) => entry.toJson()).toList()),
    );
  }

  Future<void> clearAll() async {
    await _prefs.remove(_storageKey);
  }
}

final localRecentAnalysesStoreProvider =
    FutureProvider<LocalRecentAnalysesStore>((ref) async {
  return LocalRecentAnalysesStore.create();
});
