import 'dart:convert';

import 'package:captain/features/training/domain/training_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

const trainingSessionsStorageKey = 'training_sessions_v1';

class TrainingSessionRepository {
  TrainingSessionRepository(this._prefs);

  final SharedPreferences _prefs;

  static Future<TrainingSessionRepository> create() async {
    final prefs = await SharedPreferences.getInstance();
    return TrainingSessionRepository(prefs);
  }

  Future<List<TrainingSession>> getSavedSessions() async {
    final raw = _prefs.getStringList(trainingSessionsStorageKey) ?? [];
    return raw
        .map(
          (entry) => TrainingSession.fromJson(
            jsonDecode(entry) as Map<String, dynamic>,
          ),
        )
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<void> saveSession(TrainingSession session) async {
    final sessions = await getSavedSessions();
    final index = sessions.indexWhere((item) => item.id == session.id);
    if (index >= 0) {
      sessions[index] = session;
    } else {
      sessions.add(session);
    }
    await _persist(sessions);
  }

  Future<void> deleteSession(String id) async {
    final sessions = await getSavedSessions()
      ..removeWhere((session) => session.id == id);
    await _persist(sessions);
  }

  Future<void> _persist(List<TrainingSession> sessions) async {
    final encoded =
        sessions.map((session) => jsonEncode(session.toJson())).toList();
    await _prefs.setStringList(trainingSessionsStorageKey, encoded);
  }
}
