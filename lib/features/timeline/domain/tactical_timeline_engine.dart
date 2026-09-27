import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Represents the state of a single entity (player, ball) at a given point in time.
@immutable
class TacticalNodeState {
  final String id;
  final Offset position; // Normalized 0.0 -> 1.0 relative to pitch dimensions
  final double orientation; // Facing angle in radians
  final bool hasBall;
  final Map<String, dynamic>? metadata;

  const TacticalNodeState({
    required this.id,
    required this.position,
    this.orientation = 0.0,
    this.hasBall = false,
    this.metadata,
  });

  TacticalNodeState copyWith({
    Offset? position,
    double? orientation,
    bool? hasBall,
  }) {
    return TacticalNodeState(
      id: id,
      position: position ?? this.position,
      orientation: orientation ?? this.orientation,
      hasBall: hasBall ?? this.hasBall,
      metadata: metadata,
    );
  }
}

/// A distinct discrete snapshot on the coach's timeline.
@immutable
class TacticalKeyframe {
  final String id;
  final Duration timestamp;
  final Map<String, TacticalNodeState> nodes; // Keyed by entity ID
  final Curve transitionCurve;

  const TacticalKeyframe({
    required this.id,
    required this.timestamp,
    required this.nodes,
    this.transitionCurve = Curves.easeInOutCubic,
  });
}

/// Pure math & trajectory solver for keyframe interpolation.
class KeyframeInterpolationEngine {
  /// Evaluates the complete pitch state at any arbitrary playback duration [time].
  static Map<String, TacticalNodeState> evaluate({
    required List<TacticalKeyframe> keyframes,
    required Duration time,
  }) {
    if (keyframes.isEmpty) return {};
    if (keyframes.length == 1 || time <= keyframes.first.timestamp) {
      return keyframes.first.nodes;
    }
    if (time >= keyframes.last.timestamp) {
      return keyframes.last.nodes;
    }

    // 1. Locate the active bounding keyframe interval [k0, k1, k2, k3]
    int nextIdx = keyframes.indexWhere((kf) => kf.timestamp >= time);
    if (nextIdx == -1) nextIdx = keyframes.length - 1;
    int currIdx = nextIdx - 1;

    final k1 = keyframes[currIdx];
    final k2 = keyframes[nextIdx];

    // Surrounding points for tangent evaluation (clamped at boundaries)
    final k0 = keyframes[math.max(0, currIdx - 1)];
    final k3 = keyframes[math.min(keyframes.length - 1, nextIdx + 1)];

    final segmentDuration = (k2.timestamp - k1.timestamp).inMicroseconds;
    if (segmentDuration == 0) return k1.nodes;

    final elapsed = (time - k1.timestamp).inMicroseconds;
    final double rawT = (elapsed / segmentDuration).clamp(0.0, 1.0);
    final double curvedT = k1.transitionCurve.transform(rawT);

    final Map<String, TacticalNodeState> interpolatedNodes = {};

    // 2. Interpolate each entity tracked in the interval
    final allNodeIds = {...k1.nodes.keys, ...k2.nodes.keys};

    for (final id in allNodeIds) {
      final p1 = k1.nodes[id];
      final p2 = k2.nodes[id];

      if (p1 == null && p2 != null) {
        interpolatedNodes[id] = p2;
        continue;
      }
      if (p1 != null && p2 == null) {
        interpolatedNodes[id] = p1;
        continue;
      }

      final p0 = k0.nodes[id] ?? p1!;
      final p3 = k3.nodes[id] ?? p2!;

      // Catmull-Rom Centripetal Spline interpolation for organic pitch motion
      final interpolatedOffset = _catmullRom2D(
        p0.position,
        p1!.position,
        p2!.position,
        p3.position,
        curvedT,
      );

      // Shortest-arc angular interpolation for player orientation
      final interpolatedAngle = _lerpAngle(p1.orientation, p2.orientation, curvedT);

      interpolatedNodes[id] = TacticalNodeState(
        id: id,
        position: Offset(
          interpolatedOffset.dx.clamp(0.0, 1.0),
          interpolatedOffset.dy.clamp(0.0, 1.0),
        ),
        orientation: interpolatedAngle,
        hasBall: curvedT < 0.5 ? p1.hasBall : p2.hasBall,
      );
    }

    return interpolatedNodes;
  }

  /// 2D Catmull-Rom spline formulation with standard 0.5 tension.
  static Offset _catmullRom2D(Offset p0, Offset p1, Offset p2, Offset p3, double t) {
    final double t2 = t * t;
    final double t3 = t2 * t;

    final double x = 0.5 * (
      (2 * p1.dx) +
      (-p0.dx + p2.dx) * t +
      (2 * p0.dx - 5 * p1.dx + 4 * p2.dx - p3.dx) * t2 +
      (-p0.dx + 3 * p1.dx - 3 * p2.dx + p3.dx) * t3
    );

    final double y = 0.5 * (
      (2 * p1.dy) +
      (-p0.dy + p2.dy) * t +
      (2 * p0.dy - 5 * p1.dy + 4 * p2.dy - p3.dy) * t2 +
      (-p0.dy + 3 * p1.dy - 3 * p2.dy + p3.dy) * t3
    );

    return Offset(x, y);
  }

  /// Calculates shortest angular path across circular boundaries [-pi, pi].
  static double _lerpAngle(double a, double b, double t) {
    double diff = (b - a) % (2 * math.pi);
    if (diff > math.pi) diff -= 2 * math.pi;
    if (diff < -math.pi) diff += 2 * math.pi;
    return a + diff * t;
  }
}
