import 'package:flutter_riverpod/flutter_riverpod.dart';

class PresentationModeState {
  const PresentationModeState({
    this.spotlightPlayerId,
    this.laserEnabled = false,
    this.isZoomed = false,
  });

  final String? spotlightPlayerId;
  final bool laserEnabled;
  final bool isZoomed;

  PresentationModeState copyWith({
    String? spotlightPlayerId,
    bool clearSpotlight = false,
    bool? laserEnabled,
    bool? isZoomed,
  }) {
    return PresentationModeState(
      spotlightPlayerId:
          clearSpotlight ? null : (spotlightPlayerId ?? this.spotlightPlayerId),
      laserEnabled: laserEnabled ?? this.laserEnabled,
      isZoomed: isZoomed ?? this.isZoomed,
    );
  }
}

class PresentationModeNotifier extends StateNotifier<PresentationModeState> {
  PresentationModeNotifier() : super(const PresentationModeState());

  void toggleSpotlight(String playerId) {
    if (state.spotlightPlayerId == playerId) {
      state = state.copyWith(clearSpotlight: true);
      return;
    }
    state = state.copyWith(spotlightPlayerId: playerId);
  }

  void clearSpotlight() {
    if (state.spotlightPlayerId == null) return;
    state = state.copyWith(clearSpotlight: true);
  }

  void toggleLaser() {
    state = state.copyWith(laserEnabled: !state.laserEnabled);
  }

  void setZoomed(bool value) {
    state = state.copyWith(isZoomed: value);
  }

  void reset() {
    state = const PresentationModeState();
  }
}

final presentationModeProvider =
    StateNotifierProvider<PresentationModeNotifier, PresentationModeState>(
  (ref) => PresentationModeNotifier(),
);
