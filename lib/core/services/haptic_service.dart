import 'package:captain/features/settings/application/app_preferences_notifier.dart';
import 'package:captain/features/settings/domain/app_preferences.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HapticService {
  HapticService(this._readPreferences);

  final AppPreferences Function() _readPreferences;

  void mediumImpact() {
    if (_readPreferences().hapticFeedbackEnabled) {
      HapticFeedback.mediumImpact();
    }
  }

  void heavyImpact() {
    if (_readPreferences().hapticFeedbackEnabled) {
      HapticFeedback.heavyImpact();
    }
  }

  void selectionClick() {
    if (_readPreferences().hapticFeedbackEnabled) {
      HapticFeedback.selectionClick();
    }
  }
}

final hapticServiceProvider = Provider<HapticService>((ref) {
  return HapticService(
    () => ref.read(appPreferencesProvider).value ?? const AppPreferences(),
  );
});
