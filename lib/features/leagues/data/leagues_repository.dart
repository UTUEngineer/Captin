import 'package:captain/core/api/football_api_client.dart';
import 'package:captain/features/leagues/data/leagues_cache_store.dart';
import 'package:captain/features/leagues/domain/league.dart';
import 'package:captain/features/leagues/domain/league_regions.dart';
import 'package:captain/features/leagues/domain/match_fixture.dart';
import 'package:captain/features/leagues/domain/player.dart';
import 'package:captain/features/leagues/domain/preset_leagues_data.dart';
import 'package:captain/features/leagues/domain/sample_season.dart';
import 'package:captain/features/leagues/domain/standing.dart';
import 'package:captain/features/leagues/domain/team.dart';

class LeaguesRepository {
  LeaguesRepository({
    this._client,
    required this._cache,
  });

  final FootballApiClient? _client;
  final LeaguesCacheStore _cache;

  Future<List<League>> getLeaguesByRegion(String regionCode) async {
    final cached = _cache.readLeagues(regionCode);
    if (cached != null && cached.isNotEmpty) return cached;

    final client = _client;
    final leagues = <League>[];

    if (client != null) {
      final ids = LeagueRegions.leagueIdsByRegion[regionCode] ?? [];
      for (final id in ids) {
        try {
          final league = await client.getLeagueById(id);
          if (league != null) leagues.add(league);
        } catch (_) {
          // Skip unavailable leagues to keep partial results usable.
        }
      }
    }

    if (leagues.isEmpty) {
      leagues.addAll(PresetLeaguesData.getLeaguesByRegion(regionCode));
    }

    if (leagues.isNotEmpty) {
      await _cache.writeLeagues(regionCode, leagues);
    }

    return leagues;
  }

  Future<List<Standing>> getStandings({
    required int leagueId,
    required int season,
  }) async {
    final client = _client;
    if (client != null) {
      try {
        final result = await client.getStandings(leagueId, season);
        if (result.isNotEmpty) return result;
      } catch (_) {
        // Fall back to preset standings on network/auth error.
      }
    }
    return _sample(leagueId).standings;
  }

  Future<List<MatchFixture>> getFixtures({
    required int leagueId,
    required int season,
  }) async {
    final client = _client;
    if (client != null) {
      try {
        final result = await client.getFixtures(leagueId: leagueId, season: season);
        if (result.isNotEmpty) return result;
      } catch (_) {
        // Fall back to preset fixtures on network/auth error.
      }
    }
    return _sample(leagueId).fixtures;
  }

  Future<List<Team>> getTeams({
    required int leagueId,
    required int season,
  }) async {
    final client = _client;
    if (client != null) {
      try {
        final result = await client.getTeams(leagueId, season);
        if (result.isNotEmpty) return result;
      } catch (_) {
        // Fall back to preset teams on network/auth error.
      }
    }
    return PresetLeaguesData.getTeams(leagueId);
  }

  Future<League?> getLeagueById(int leagueId) async {
    final client = _client;
    if (client != null) {
      try {
        final league = await client.getLeagueById(leagueId);
        if (league != null) return league;
      } catch (_) {
        // Fallback to preset
      }
    }
    return PresetLeaguesData.getLeagueById(leagueId);
  }

  /// True when data comes from API-Football (otherwise sample data).
  bool get isLive => _client != null;

  SampleSeason _sample(int leagueId) =>
      SampleSeason.forLeague(leagueId, PresetLeaguesData.getTeams(leagueId));

  Future<List<PlayerStats>> getLeaders({
    required int leagueId,
    required int season,
    String kind = 'topscorers',
  }) async {
    final client = _client;
    if (client == null) return const [];
    try {
      return await client.getLeaders(
        leagueId: leagueId,
        season: season,
        kind: kind,
      );
    } catch (_) {
      return const [];
    }
  }

  Future<List<SquadPlayer>> getSquad(int teamId) async {
    final client = _client;
    if (client == null || teamId >= 900000) return const [];
    try {
      return await client.getSquad(teamId);
    } catch (_) {
      return const [];
    }
  }
}
