import 'dart:convert';

import 'package:captain/features/video_analysis/domain/analysis_result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local JSON cache for completed video analysis results.
/// Server-side source videos are deleted via DELETE /api/v1/videos/{id}
/// after results are cached, with a backend retention fallback (VIDEO_RETENTION_HOURS).
const _storageKey = 'captain_analysis_results_cache_v1';

class LocalAnalysisResultCache {
  LocalAnalysisResultCache(this._prefs);

  final SharedPreferences _prefs;

  static Future<LocalAnalysisResultCache> create() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalAnalysisResultCache(prefs);
  }

  Future<AnalysisResult?> load(String videoId) async {
    final map = _readMap();
    final entry = map[videoId];
    if (entry is! Map<String, dynamic>) return null;
    return AnalysisResult.fromJson(entry);
  }

  Future<void> save(AnalysisResult result) async {
    final map = _readMap();
    map[result.videoId] = result.toJson();
    await _prefs.setString(_storageKey, jsonEncode(map));
  }

  Future<void> clearAll() async {
    await _prefs.remove(_storageKey);
  }

  Future<int> entryCount() async => _readMap().length;

  List<String> listVideoIds() => _readMap().keys.cast<String>().toList();

  Map<String, dynamic> _readMap() {
    final raw = _prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return {};
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return {};
    return Map<String, dynamic>.from(decoded);
  }
}

final localAnalysisResultCacheProvider =
    FutureProvider<LocalAnalysisResultCache>((ref) async {
  return LocalAnalysisResultCache.create();
});
