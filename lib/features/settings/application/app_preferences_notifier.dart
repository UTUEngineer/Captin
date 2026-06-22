import 'package:captain/features/settings/data/app_preferences_store.dart';
import 'package:captain/features/settings/domain/app_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppPreferencesNotifier extends AsyncNotifier<AppPreferences> {
  AppPreferencesStore? _store;

  @override
  Future<AppPreferences> build() async {
    _store = await AppPreferencesStore.create();
    return _store!.load();
  }

  Future<void> savePreferences(AppPreferences preferences) async {
    final store = _store ?? await AppPreferencesStore.create();
    _store = store;
    await store.save(preferences);
    state = AsyncData(preferences);
  }

  Future<void> patch(AppPreferences Function(AppPreferences current) updater) {
    final current = state.value ?? const AppPreferences();
    return savePreferences(updater(current));
  }
}

final appPreferencesStoreProvider =
    FutureProvider<AppPreferencesStore>((ref) async {
  return AppPreferencesStore.create();
});

final appPreferencesProvider =
    AsyncNotifierProvider<AppPreferencesNotifier, AppPreferences>(
  AppPreferencesNotifier.new,
);
