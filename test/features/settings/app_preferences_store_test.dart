import 'package:captain/features/settings/data/app_preferences_store.dart';
import 'package:captain/features/settings/domain/app_language.dart';
import 'package:captain/features/settings/domain/app_preferences.dart';
import 'package:captain/features/settings/domain/app_theme_variant.dart';
import 'package:captain/features/settings/domain/coach_role.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('AppPreferencesStore round-trips preferences json', () async {
    SharedPreferences.setMockInitialValues({});
    final store = await AppPreferencesStore.create();
    const preferences = AppPreferences(
      onboardingCompleted: true,
      language: AppLanguage.english,
      themeVariant: AppThemeVariant.pitchBlack,
      displayName: 'Coach Ali',
      teamName: 'Al Nasr',
      teamColorValue: 0xFFE53935,
      avatarEmoji: '🦁',
      coachRole: CoachRole.tacticalAnalyst,
      defaultSessionName: 'Training Room',
      autoJoinLastSession: true,
      backendBaseUrl: 'http://10.0.2.2:8000',
    );

    await store.save(preferences);
    final loaded = await store.load();

    expect(loaded.onboardingCompleted, isTrue);
    expect(loaded.language, AppLanguage.english);
    expect(loaded.themeVariant, AppThemeVariant.pitchBlack);
    expect(loaded.displayName, 'Coach Ali');
    expect(loaded.teamName, 'Al Nasr');
    expect(loaded.avatarEmoji, '🦁');
    expect(loaded.coachRole, CoachRole.tacticalAnalyst);
    expect(loaded.defaultSessionName, 'Training Room');
    expect(loaded.autoJoinLastSession, isTrue);
    expect(loaded.backendBaseUrl, 'http://10.0.2.2:8000');
  });

  test('AppPreferences defaults to Arabic onboarding incomplete', () async {
    SharedPreferences.setMockInitialValues({});
    final store = await AppPreferencesStore.create();
    final loaded = await store.load();

    expect(loaded.onboardingCompleted, isFalse);
    expect(loaded.language, AppLanguage.arabic);
    expect(loaded.isArabic, isTrue);
  });
}
