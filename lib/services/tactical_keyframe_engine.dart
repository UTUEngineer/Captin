import 'package:three_js/three_js.dart' as three;

class PlayerPositionSnapshot {
  final String id;
  final double x;
  final double z;

  PlayerPositionSnapshot({
    required this.id,
    required this.x,
    required this.z,
  });

  Map<String, dynamic> toJson() => {'id': id, 'x': x, 'z': z};
}

class TacticalKeyframe {
  final int stepIndex;
  final String stepLabel;
  final List<PlayerPositionSnapshot> players;
  final three.Vector3 ballPosition;

  TacticalKeyframe({
    required this.stepIndex,
    required this.stepLabel,
    required this.players,
    required this.ballPosition,
  });
}

class TacticalKeyframeEngine {
  final List<TacticalKeyframe> keyframes = [];
  bool isPlayingSequence = false;
  int currentStepIndex = 0;
  double animationProgress = 0.0;
  final double stepDuration = 1.5; // Seconds per keyframe transition

  void recordKeyframe({
    required three.Group playersGroup,
    required three.Mesh ballMesh,
    String? label,
  }) {
    final List<PlayerPositionSnapshot> playerSnapshots = [];
    for (int i = 0; i < playersGroup.children.length; i++) {
      final child = playersGroup.children[i];
      playerSnapshots.add(PlayerPositionSnapshot(
        id: child.name.isNotEmpty ? child.name : 'player_$i',
        x: child.position.x,
        z: child.position.z,
      ));
    }

    final newStepIndex = keyframes.length + 1;
    keyframes.add(TacticalKeyframe(
      stepIndex: newStepIndex,
      stepLabel: label ?? 'خطوة $newStepIndex',
      players: playerSnapshots,
      ballPosition: ballMesh.position.clone(),
    ));
  }

  void clearSequence() {
    keyframes.clear();
    isPlayingSequence = false;
    currentStepIndex = 0;
    animationProgress = 0.0;
  }

  void playSequence() {
    if (keyframes.length >= 2) {
      isPlayingSequence = true;
      currentStepIndex = 0;
      animationProgress = 0.0;
    }
  }

  void pauseSequence() {
    isPlayingSequence = false;
  }

  void update(double deltaTime, three.Group playersGroup, three.Mesh ballMesh) {
    if (!isPlayingSequence || keyframes.length < 2) return;

    animationProgress += deltaTime / stepDuration;

    if (animationProgress >= 1.0) {
      animationProgress = 0.0;
      currentStepIndex++;

      if (currentStepIndex >= keyframes.length - 1) {
        currentStepIndex = 0; // Loop keyframe sequence playback
      }
    }

    final fromFrame = keyframes[currentStepIndex];
    final toFrame = keyframes[currentStepIndex + 1];

    final easedT = _easeInOutCubic(animationProgress);

    // Interpolate Player Positions
    for (int i = 0; i < playersGroup.children.length && i < fromFrame.players.length && i < toFrame.players.length; i++) {
      final playerMesh = playersGroup.children[i];
      final fromP = fromFrame.players[i];
      final toP = toFrame.players[i];

      playerMesh.position.x = fromP.x + (toP.x - fromP.x) * easedT;
      playerMesh.position.z = fromP.z + (toP.z - fromP.z) * easedT;
    }

    // Interpolate Ball Position
    ballMesh.position.x = fromFrame.ballPosition.x + (toFrame.ballPosition.x - fromFrame.ballPosition.x) * easedT;
    ballMesh.position.y = fromFrame.ballPosition.y + (toFrame.ballPosition.y - fromFrame.ballPosition.y) * easedT;
    ballMesh.position.z = fromFrame.ballPosition.z + (toFrame.ballPosition.z - fromFrame.ballPosition.z) * easedT;
  }

  double _easeInOutCubic(double t) {
    return t < 0.5 ? 4 * t * t * t : 1 - ((-2 * t + 2) * (-2 * t + 2) * (-2 * t + 2)) / 2;
  }
}
