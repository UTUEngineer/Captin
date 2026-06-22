import 'package:captain/features/leagues/application/leagues_providers.dart';
import 'package:captain/features/scouting/application/scouting_providers.dart';
import 'package:captain/features/settings/application/app_preferences_notifier.dart';
import 'package:captain/features/settings/domain/app_preferences.dart';
import 'package:captain/features/video_analysis/application/analysis_cache_providers.dart';
import 'package:captain/features/video_analysis/application/recent_analyses_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Clears all on-device user data for store privacy / account-deletion flows.
class LocalDataController {
  LocalDataController(this._ref);

  final Ref _ref;

  Future<void> clearAllLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _ref.read(claudeApiKeyStoreProvider).clearApiKey();
    await _ref.read(footballApiKeyStoreProvider).clearApiKey();
    await _ref
        .read(appPreferencesProvider.notifier)
        .savePreferences(const AppPreferences());
    _ref.invalidate(claudeApiKeyConfiguredProvider);
    _ref.invalidate(footballApiKeyConfiguredProvider);
    _ref.invalidate(footballApiKeyProvider);
    _ref.invalidate(leaguesRepositoryProvider);
    _ref.invalidate(analysisCacheEntryCountProvider);
    _ref.invalidate(recentAnalysesProvider);
  }
}

final localDataControllerProvider = Provider<LocalDataController>((ref) {
  return LocalDataController(ref);
});
