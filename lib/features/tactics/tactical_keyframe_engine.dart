import 'dart:math' as math;
import 'package:vector_math/vector_math_64.dart' as v64;

// Snapshot of a single player or ball at one specific keyframe
class EntityStateSnapshot {
  final String id;
  final v64.Vector3 position;
  final double headingRadians;
  final double elevation; // For ball trajectory height

  EntityStateSnapshot({
    required this.id,
    required this.position,
    required this.headingRadians,
    this.elevation = 0.0,
  });

  EntityStateSnapshot copyWith({
    v64.Vector3? position,
    double? headingRadians,
    double? elevation,
  }) {
    return EntityStateSnapshot(
      id: id,
      position: position ?? this.position.clone(),
      headingRadians: headingRadians ?? this.headingRadians,
      elevation: elevation ?? this.elevation,
    );
  }
}

// Tactical Keyframe Phase representing one tactical moment
class TacticalKeyframe {
  final String id;
  String name;
  double durationSeconds; // Duration to transition to this keyframe
  final Map<String, EntityStateSnapshot> snapshots; // entityId -> State

  TacticalKeyframe({
    required this.id,
    required this.name,
    this.durationSeconds = 2.0,
    required this.snapshots,
  });

  TacticalKeyframe cloneWithNewId(String newId, String newName) {
    return TacticalKeyframe(
      id: newId,
      name: newName,
      durationSeconds: durationSeconds,
      snapshots: snapshots.map((k, v) => MapEntry(k, v.copyWith())),
    );
  }
}

// Math Engine: Smooth Spline and Hermite Interpolation
class KeyframeInterpolator {
  /// Cubic Hermite Interpolation between two points with velocity tangents
  static v64.Vector3 interpolateHermite(
    v64.Vector3 p0,
    v64.Vector3 p1,
    v64.Vector3 p2,
    v64.Vector3 p3,
    double t,
  ) {
    // Catmull-Rom tangent calculation
    final m1 = (p2 - p0) * 0.5;
    final m2 = (p3 - p1) * 0.5;

    final t2 = t * t;
    final t3 = t2 * t;

    // Hermite basis functions
    final h00 = 2 * t3 - 3 * t2 + 1;
    final h10 = t3 - 2 * t2 + t;
    final h01 = -2 * t3 + 3 * t2;
    final h11 = t3 - t2;

    return (p1 * h00) + (m1 * h10) + (p2 * h01) + (m2 * h11);
  }

  /// Angle interpolation taking shortest circular distance
  static double interpolateAngle(double a0, double a1, double t) {
    double diff = (a1 - a0) % (2 * math.pi);
    if (diff > math.pi) diff -= 2 * math.pi;
    if (diff < -math.pi) diff += 2 * math.pi;
    return a0 + diff * t;
  }

  /// Parabolic arc for ball trajectories
  static double computeBallParabola(double y0, double y1, double apexHeight, double t) {
    final baseHeight = y0 + (y1 - y0) * t;
    final arc = 4 * apexHeight * t * (1 - t);
    return baseHeight + arc;
  }
}
