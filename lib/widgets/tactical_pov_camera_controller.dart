import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:three_js/three_js.dart' as three;

enum CameraMode { orbit, firstPersonPov, ballFollow }

class TacticalPovCameraController {
  final three.PerspectiveCamera camera;
  final three.Object3D pitchCenterTarget;

  CameraMode mode = CameraMode.orbit;
  three.Object3D? attachedPlayer;
  three.Object3D? targetBall;

  // Eye-level camera offset above player feet (in pitch units/meters)
  final double eyeHeight = 1.75;
  final double firstPersonFov = 75.0; // Wider FOV for human peripheral vision
  final double defaultOrbitFov = 45.0;

  // Head orientation angles (Euler radians)
  double headYaw = 0.0;
  double headPitch = 0.0;

  // Interpolation targets for smooth transition
  final three.Vector3 _targetCamPos = three.Vector3.zero();
  final three.Vector3 _targetLookAt = three.Vector3.zero();
  final three.Vector3 _currentLookAt = three.Vector3.zero();

  bool isTransitioning = false;
  double transitionAlpha = 0.0;

  TacticalPovCameraController({
    required this.camera,
    required this.pitchCenterTarget,
  });

  /// Snaps camera to a specific player's eye level
  void enterPlayerPov(three.Object3D playerNode, {three.Object3D? ball}) {
    attachedPlayer = playerNode;
    targetBall = ball;
    mode = CameraMode.firstPersonPov;
    headYaw = 0.0;
    headPitch = 0.0;
    isTransitioning = true;
    transitionAlpha = 0.0;
    camera.fov = firstPersonFov;
    camera.updateProjectionMatrix();
  }

  /// Exits POV and returns to global tactical orbit perspective
  void exitToOrbitView() {
    mode = CameraMode.orbit;
    attachedPlayer = null;
    targetBall = null;
    isTransitioning = true;
    transitionAlpha = 0.0;
    camera.fov = defaultOrbitFov;
    camera.updateProjectionMatrix();
  }

  /// Handles touch drag to look around from the player's head
  void handleLookRotation(Offset delta) {
    if (mode != CameraMode.firstPersonPov) return;

    const double sensitivity = 0.004;
    headYaw -= delta.dx * sensitivity;
    headPitch -= delta.dy * sensitivity;

    // Clamp vertical pitch to prevent neck flipping (-45 deg to +45 deg)
    headPitch = headPitch.clamp(-math.pi / 4, math.pi / 4);
  }

  /// Updates camera transform every render tick (called in the game/render loop)
  void update(double delta) {
    if (mode == CameraMode.firstPersonPov && attachedPlayer != null) {
      // 1. Calculate Eye Position
      final playerPos = attachedPlayer!.position;
      final playerRotationY = attachedPlayer!.rotation.y;

      _targetCamPos.setValues(
        playerPos.x,
        playerPos.y + eyeHeight,
        playerPos.z,
      );

      // 2. Calculate Look-At Target (Combining Player Body Facing + Head Yaw/Pitch)
      final totalYaw = playerRotationY + headYaw;
      final forwardDistance = 15.0;

      final lookX = _targetCamPos.x + forwardDistance * math.sin(totalYaw) * math.cos(headPitch);
      final lookY = _targetCamPos.y + forwardDistance * math.sin(headPitch);
      final lookZ = _targetCamPos.z + forwardDistance * math.cos(totalYaw) * math.cos(headPitch);

      _targetLookAt.setValues(lookX, lookY, lookZ);

      // 3. Smooth Camera Follow / Transition
      if (isTransitioning) {
        transitionAlpha += delta * 2.5; // ~400ms transition
        if (transitionAlpha >= 1.0) {
          transitionAlpha = 1.0;
          isTransitioning = false;
        }
        camera.position.lerp(_targetCamPos, transitionAlpha);
        _currentLookAt.lerp(_targetLookAt, transitionAlpha);
        camera.lookAt(_currentLookAt);
      } else {
        camera.position.setFrom(_targetCamPos);
        camera.lookAt(_targetLookAt);
      }
    } else if (mode == CameraMode.orbit) {
      // Global Orbit camera targeting pitch center
      if (isTransitioning) {
        _targetCamPos.setValues(0, 45, 60);
        _targetLookAt.setValues(0, 0, 0);

        transitionAlpha += delta * 2.0;
        if (transitionAlpha >= 1.0) {
          transitionAlpha = 1.0;
          isTransitioning = false;
        }
        camera.position.lerp(_targetCamPos, transitionAlpha);
        _currentLookAt.lerp(_targetLookAt, transitionAlpha);
        camera.lookAt(_currentLookAt);
      }
    }
  }
}
