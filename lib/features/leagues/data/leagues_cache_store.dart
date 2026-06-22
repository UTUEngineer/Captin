import 'dart:convert';

import 'package:captain/features/leagues/domain/league.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _cachePrefix = 'captain_leagues_cache_v1';

class LeaguesCacheStore {
  LeaguesCacheStore(this._prefs);

  final SharedPreferences _prefs;

  static Future<LeaguesCacheStore> create() async {
    final prefs = await SharedPreferences.getInstance();
    return LeaguesCacheStore(prefs);
  }

  List<League>? readLeagues(String regionCode) {
    final cacheKey = '$_cachePrefix\_$regionCode';
    final raw = _prefs.getString(cacheKey);
    final timestamp = _prefs.getInt('${cacheKey}_ts');
    if (raw == null || timestamp == null) return null;

    final ageMs = DateTime.now().millisecondsSinceEpoch - timestamp;
    if (ageMs >= const Duration(hours: 24).inMilliseconds) return null;

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => League.fromCache(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> writeLeagues(String regionCode, List<League> leagues) async {
    final cacheKey = '$_cachePrefix\_$regionCode';
    await _prefs.setString(
      cacheKey,
      jsonEncode(leagues.map((league) => league.toJson()).toList()),
    );
    await _prefs.setInt('${cacheKey}_ts', DateTime.now().millisecondsSinceEpoch);
  }
}
