import 'package:captain/core/config/app_config.dart';
import 'package:captain/features/leagues/domain/league.dart';
import 'package:captain/features/leagues/domain/match_fixture.dart';
import 'package:captain/features/leagues/domain/player.dart';
import 'package:captain/features/leagues/domain/standing.dart';
import 'package:captain/features/leagues/domain/team.dart';
import 'package:dio/dio.dart';

class FootballApiClient {
  FootballApiClient(
    String apiKey, {
    String host = AppConfig.defaultFootballApiHost,
  }) : _dio = Dio(
          BaseOptions(
            baseUrl: 'https://$host',
            headers: {
              'x-apisports-key': apiKey,
              'x-rapidapi-host': host,
            },
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 15),
          ),
        );

  final Dio _dio;

  Future<List<League>> getLeagues({String? countryCode}) async {
    final params = <String, dynamic>{'current': 'true'};
    if (countryCode != null) params['code'] = countryCode;

    final response = await _dio.get<Map<String, dynamic>>(
      '/leagues',
      queryParameters: params,
    );
    final items = response.data?['response'] as List<dynamic>? ?? [];
    return items
        .map((item) => League.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<League?> getLeagueById(int leagueId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/leagues',
      queryParameters: {'id': leagueId},
    );
    final items = response.data?['response'] as List<dynamic>? ?? [];
    if (items.isEmpty) return null;
    return League.fromJson(items.first as Map<String, dynamic>);
  }

  Future<List<Team>> getTeams(int leagueId, int season) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/teams',
      queryParameters: {
        'league': leagueId,
        'season': season,
      },
    );
    final items = response.data?['response'] as List<dynamic>? ?? [];
    return items
        .map(
          (item) => Team.fromJson(
            (item as Map<String, dynamic>)['team'] as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<List<Player>> getPlayers(int teamId, int season) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/players',
      queryParameters: {
        'team': teamId,
        'season': season,
      },
    );
    final items = response.data?['response'] as List<dynamic>? ?? [];
    return items
        .map((item) => Player.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<Standing>> getStandings(int leagueId, int season) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/standings',
      queryParameters: {
        'league': leagueId,
        'season': season,
      },
    );
    final responseItems = response.data?['response'] as List<dynamic>? ?? [];
    if (responseItems.isEmpty) return [];

    final leagueData =
        (responseItems.first as Map<String, dynamic>)['league'] as Map<String, dynamic>;
    final groups = leagueData['standings'] as List<dynamic>? ?? [];
    if (groups.isEmpty) return [];

    final standings = groups.first as List<dynamic>;
    return standings
        .map((item) => Standing.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<MatchFixture>> getFixtures({
    required int leagueId,
    required int season,
    String? status,
  }) async {
    final params = <String, dynamic>{
      'league': leagueId,
      'season': season,
    };
    if (status != null) params['status'] = status;

    final response = await _dio.get<Map<String, dynamic>>(
      '/fixtures',
      queryParameters: params,
    );
    final items = response.data?['response'] as List<dynamic>? ?? [];
    return items
        .map((item) => MatchFixture.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<PlayerStats> getPlayerStats(int playerId, int season) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/players',
      queryParameters: {
        'id': playerId,
        'season': season,
      },
    );
    final items = response.data?['response'] as List<dynamic>? ?? [];
    if (items.isEmpty) {
      throw StateError('Player stats not found.');
    }
    return PlayerStats.fromJson(items.first as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> getTacticalLineups(int fixtureId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/fixtures/lineups',
      queryParameters: {'fixture': fixtureId},
    );
    final items = response.data?['response'] as List<dynamic>? ?? [];
    return {'raw_response': items};
  }

  /// Top scorers (`kind` = 'topscorers' | 'topassists').
  Future<List<PlayerStats>> getLeaders({
    required int leagueId,
    required int season,
    String kind = 'topscorers',
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/players/$kind',
      queryParameters: {'league': leagueId, 'season': season},
    );
    final items = response.data?['response'] as List<dynamic>? ?? [];
    return items
        .map((item) => PlayerStats.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<SquadPlayer>> getSquad(int teamId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/players/squads',
      queryParameters: {'team': teamId},
    );
    final items = response.data?['response'] as List<dynamic>? ?? [];
    if (items.isEmpty) return [];
    final players =
        (items.first as Map<String, dynamic>)['players'] as List<dynamic>? ?? [];
    return players
        .map((p) => SquadPlayer.fromJson(p as Map<String, dynamic>))
        .toList();
  }
}
