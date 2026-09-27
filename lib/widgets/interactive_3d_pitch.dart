import 'package:flutter/material.dart';
import 'tactical_3d_pitch.dart';
import '../services/tracking_player_engine.dart';

class Interactive3DPitchScreen extends StatelessWidget {
  final ValueChanged<TrackingPlaybackEngine>? onEngineReady;

  const Interactive3DPitchScreen({
    super.key,
    this.onEngineReady,
  });

  @override
  Widget build(BuildContext context) {
    return Tactical3DPitchWidget(onEngineReady: onEngineReady);
  }
}

class Interactive3DPitchCanvas extends StatelessWidget {
  final ValueChanged<TrackingPlaybackEngine>? onEngineReady;

  const Interactive3DPitchCanvas({
    super.key,
    this.onEngineReady,
  });

  @override
  Widget build(BuildContext context) {
    return Tactical3DPitchWidget(onEngineReady: onEngineReady);
  }
}
