import 'package:captain/core/api/football_api_client.dart';
import 'package:captain/features/leagues/data/leagues_cache_store.dart';
import 'package:captain/features/leagues/domain/league.dart';
import 'package:captain/features/leagues/domain/league_regions.dart';
import 'package:captain/features/leagues/domain/match_fixture.dart';
import 'package:captain/features/leagues/domain/standing.dart';
import 'package:captain/features/leagues/domain/team.dart';

class LeaguesRepository {
  LeaguesRepository({
    required FootballApiClient client,
    required LeaguesCacheStore cache,
  })  : _client = client,
        _cache = cache;

  final FootballApiClient _client;
  final LeaguesCacheStore _cache;

  Future<List<League>> getLeaguesByRegion(String regionCode) async {
    final cached = _cache.readLeagues(regionCode);
    if (cached != null) return cached;

    final ids = LeagueRegions.leagueIdsByRegion[regionCode] ?? [];
    final leagues = <League>[];

    for (final id in ids) {
      try {
        final league = await _client.getLeagueById(id);
        if (league != null) leagues.add(league);
      } catch (_) {
        // Skip unavailable leagues to keep partial results usable offline later.
      }
    }

    if (leagues.isNotEmpty) {
      await _cache.writeLeagues(regionCode, leagues);
    }

    return leagues;
  }

  Future<List<Standing>> getStandings({
    required int leagueId,
    required int season,
  }) {
    return _client.getStandings(leagueId, season);
  }

  Future<List<MatchFixture>> getFixtures({
    required int leagueId,
    required int season,
  }) {
    return _client.getFixtures(leagueId: leagueId, season: season);
  }

  Future<List<Team>> getTeams({
    required int leagueId,
    required int season,
  }) {
    return _client.getTeams(leagueId, season);
  }

  Future<League?> getLeagueById(int leagueId) {
    return _client.getLeagueById(leagueId);
  }
}
