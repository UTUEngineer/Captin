import 'package:captain/core/api/football_api_client.dart';
import 'package:captain/features/leagues/data/football_api_key_store.dart';
import 'package:captain/features/leagues/data/leagues_cache_store.dart';
import 'package:captain/features/leagues/data/leagues_repository.dart';
import 'package:captain/features/leagues/domain/league.dart';
import 'package:captain/features/leagues/domain/match_fixture.dart';
import 'package:captain/features/leagues/domain/standing.dart';
import 'package:captain/features/leagues/domain/team.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final footballApiKeyStoreProvider = Provider<FootballApiKeyStore>((ref) {
  return FootballApiKeyStore();
});

final footballApiKeyConfiguredProvider = FutureProvider<bool>((ref) async {
  return ref.watch(footballApiKeyStoreProvider).hasApiKey();
});

final footballApiKeyProvider = FutureProvider<String?>((ref) async {
  return ref.watch(footballApiKeyStoreProvider).readApiKey();
});

final footballApiClientProvider = Provider<FootballApiClient?>((ref) {
  final apiKey = ref.watch(footballApiKeyProvider).valueOrNull;
  if (apiKey == null || apiKey.isEmpty) return null;
  return FootballApiClient(apiKey);
});

final leaguesCacheStoreProvider = FutureProvider<LeaguesCacheStore>((ref) async {
  return LeaguesCacheStore.create();
});

final leaguesRepositoryProvider = FutureProvider<LeaguesRepository?>((ref) async {
  final client = ref.watch(footballApiClientProvider);
  if (client == null) return null;
  final cache = await ref.watch(leaguesCacheStoreProvider.future);
  return LeaguesRepository(client: client, cache: cache);
});

final leaguesByRegionProvider =
    FutureProvider.family<List<League>, String>((ref, regionCode) async {
  final repository = await ref.watch(leaguesRepositoryProvider.future);
  if (repository == null) {
    throw StateError('Football API key is not configured.');
  }
  return repository.getLeaguesByRegion(regionCode);
});

typedef LeagueSeasonParams = ({int leagueId, int season});

final standingsProvider =
    FutureProvider.family<List<Standing>, LeagueSeasonParams>((ref, params) async {
  final repository = await ref.watch(leaguesRepositoryProvider.future);
  if (repository == null) {
    throw StateError('Football API key is not configured.');
  }
  return repository.getStandings(
    leagueId: params.leagueId,
    season: params.season,
  );
});

final fixturesProvider =
    FutureProvider.family<List<MatchFixture>, LeagueSeasonParams>((ref, params) async {
  final repository = await ref.watch(leaguesRepositoryProvider.future);
  if (repository == null) {
    throw StateError('Football API key is not configured.');
  }
  return repository.getFixtures(
    leagueId: params.leagueId,
    season: params.season,
  );
});

final teamsProvider =
    FutureProvider.family<List<Team>, LeagueSeasonParams>((ref, params) async {
  final repository = await ref.watch(leaguesRepositoryProvider.future);
  if (repository == null) {
    throw StateError('Football API key is not configured.');
  }
  return repository.getTeams(
    leagueId: params.leagueId,
    season: params.season,
  );
});
