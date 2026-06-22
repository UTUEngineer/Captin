import 'dart:convert';

import 'package:captain/features/timeline/data/timeline_snapshot_store.dart';
import 'package:captain/features/timeline/domain/match_timeline.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimelineRepository {
  TimelineRepository(this._prefs);

  final SharedPreferences _prefs;

  static Future<TimelineRepository> create() async {
    final prefs = await SharedPreferences.getInstance();
    return TimelineRepository(prefs);
  }

  Future<MatchTimeline?> loadTimeline(String matchId) async {
    final raw = jsonDecode(_prefs.getString(matchTimelinesStorageKey) ?? '{}')
        as Map<String, dynamic>;
    final entry = raw[matchId];
    if (entry is! Map<String, dynamic>) return null;
    return MatchTimeline.fromJson(entry);
  }

  Future<void> saveTimeline(MatchTimeline timeline) async {
    final raw = Map<String, dynamic>.from(
      jsonDecode(_prefs.getString(matchTimelinesStorageKey) ?? '{}')
          as Map<String, dynamic>,
    );
    raw[timeline.matchId] = timeline.toJson();
    await _prefs.setString(matchTimelinesStorageKey, jsonEncode(raw));
  }
}
