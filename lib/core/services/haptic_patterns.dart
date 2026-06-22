import 'package:captain/core/services/haptic_service.dart';

extension HapticPatterns on HapticService {
  Future<void> successPulse() async {
    for (var i = 0; i < 3; i++) {
      mediumImpact();
      await Future<void>.delayed(const Duration(milliseconds: 120));
    }
  }
}

Future<void> reportGeneratedHaptic(HapticService haptics) {
  return haptics.successPulse();
}

Future<void> formationSnapHaptic(HapticService haptics) {
  haptics.heavyImpact();
  return Future<void>.value();
}

Future<void> playerPlacedHaptic(HapticService haptics) {
  haptics.mediumImpact();
  return Future<void>.value();
}

Future<void> deleteActionHaptic(HapticService haptics) {
  haptics.selectionClick();
  return Future<void>.value();
}
