import 'dart:convert';

import 'package:captain/features/formations/domain/tactic_board_template.dart';
import 'package:shared_preferences/shared_preferences.dart';

const timelineSnapshotsStorageKey = 'timeline_snapshots_v1';
const matchTimelinesStorageKey = 'match_timelines_v1';

class TimelineSnapshotStore {
  TimelineSnapshotStore(this._prefs);

  final SharedPreferences _prefs;

  static Future<TimelineSnapshotStore> create() async {
    final prefs = await SharedPreferences.getInstance();
    return TimelineSnapshotStore(prefs);
  }

  Future<void> saveSnapshot({
    required String snapshotId,
    required TacticBoardTemplate template,
  }) async {
    final raw = Map<String, dynamic>.from(
      jsonDecode(_prefs.getString(timelineSnapshotsStorageKey) ?? '{}')
          as Map<String, dynamic>,
    );
    raw[snapshotId] = template.toJson();
    await _prefs.setString(timelineSnapshotsStorageKey, jsonEncode(raw));
  }

  Future<TacticBoardTemplate?> loadSnapshot(String snapshotId) async {
    final raw = jsonDecode(_prefs.getString(timelineSnapshotsStorageKey) ?? '{}')
        as Map<String, dynamic>;
    final entry = raw[snapshotId];
    if (entry is! Map<String, dynamic>) return null;
    return TacticBoardTemplate.fromJson(entry);
  }

  Future<void> deleteSnapshot(String snapshotId) async {
    final raw = Map<String, dynamic>.from(
      jsonDecode(_prefs.getString(timelineSnapshotsStorageKey) ?? '{}')
          as Map<String, dynamic>,
    );
    raw.remove(snapshotId);
    await _prefs.setString(timelineSnapshotsStorageKey, jsonEncode(raw));
  }
}
