import 'dart:convert';

import 'package:captain/features/video_analysis/domain/pending_video_job.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _storageKey = 'captain_pending_video_job_v1';

class LocalVideoJobStore {
  LocalVideoJobStore(this._prefs);

  final SharedPreferences _prefs;

  static Future<LocalVideoJobStore> create() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalVideoJobStore(prefs);
  }

  Future<PendingVideoJob?> loadPendingJob() async {
    final raw = _prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return null;
    return PendingVideoJob.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> savePendingJob(PendingVideoJob job) async {
    await _prefs.setString(_storageKey, jsonEncode(job.toJson()));
  }

  Future<void> clearPendingJob() async {
    await _prefs.remove(_storageKey);
  }
}

final localVideoJobStoreProvider =
    FutureProvider<LocalVideoJobStore>((ref) async {
  return LocalVideoJobStore.create();
});

final pendingVideoJobProvider = FutureProvider<PendingVideoJob?>((ref) async {
  final store = await ref.watch(localVideoJobStoreProvider.future);
  final job = await store.loadPendingJob();
  if (job != null && !job.isActive) {
    await store.clearPendingJob();
    return null;
  }
  return job;
});
