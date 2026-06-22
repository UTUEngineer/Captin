import 'package:captain/features/scouting/data/claude_api_key_store.dart';
import 'package:captain/features/scouting/data/scouting_report_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final claudeApiKeyStoreProvider = Provider<ClaudeApiKeyStore>((ref) {
  return ClaudeApiKeyStore();
});

final scoutingReportRepositoryProvider = Provider<ScoutingReportRepository>((ref) {
  final repository = ScoutingReportRepository(
    apiKeyStore: ref.watch(claudeApiKeyStoreProvider),
  );
  ref.onDispose(repository.dispose);
  return repository;
});

final claudeApiKeyConfiguredProvider = FutureProvider<bool>((ref) async {
  return ref.watch(claudeApiKeyStoreProvider).hasApiKey();
});
