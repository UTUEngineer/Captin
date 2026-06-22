import 'dart:ui';

import 'package:captain/features/shape_simulation/domain/player_role.dart';
import 'package:captain/features/shape_simulation/domain/simulation_mode.dart';

const shapeSimulationMinBound = 0.05;
const shapeSimulationMaxBound = 0.95;
const shapeSimulationMinPlayerDistance = 0.05;

class ShapeSimulationController {
  const ShapeSimulationController();

  Map<String, Offset> onPlayerMoved({
    required String playerId,
    required Offset newPosition,
    required Map<String, Offset> currentPositions,
    required Map<String, Offset> basePositions,
    required Map<String, PlayerRole> roles,
    required SimulationMode mode,
    bool Function(String playerId)? includePlayer,
  }) {
    final base = basePositions[playerId];
    if (base == null) {
      return {playerId: _clamp(newPosition)};
    }

    final displacement = _applyMode(mode, newPosition - base);
    final result = <String, Offset>{};

    for (final entry in currentPositions.entries) {
      final id = entry.key;
      if (includePlayer != null && !includePlayer(id)) {
        result[id] = entry.value;
        continue;
      }

      if (id == playerId) {
        result[id] = _clamp(newPosition);
        continue;
      }

      final playerBase = basePositions[id] ?? entry.value;
      final role = roles[id] ?? PlayerRole.cm;
      final weighted = Offset(
        displacement.dx * role.displacementWeight,
        displacement.dy * role.displacementWeight,
      );
      result[id] = _clamp(playerBase + weighted);
    }

    _separateOverlappingPlayers(result);
    return result;
  }

  Offset _applyMode(SimulationMode mode, Offset displacement) {
    return switch (mode) {
      SimulationMode.defensiveBlock => Offset(
          displacement.dx * 0.55,
          displacement.dy * 1.15,
        ),
      SimulationMode.highPress => Offset(
          displacement.dx * 0.85,
          displacement.dy * 0.75,
        ),
      SimulationMode.possessionBuild => Offset(
          displacement.dx * 1.05,
          displacement.dy * 0.95,
        ),
      SimulationMode.counterAttack => Offset(
          displacement.dx * 0.9,
          displacement.dy * 0.65,
        ),
      SimulationMode.setPiece => Offset(
          displacement.dx * 0.45,
          displacement.dy * 0.55,
        ),
    };
  }

  void _separateOverlappingPlayers(Map<String, Offset> positions) {
    final ids = positions.keys.toList();
    for (var pass = 0; pass < 4; pass++) {
      for (var i = 0; i < ids.length; i++) {
        for (var j = i + 1; j < ids.length; j++) {
          final aId = ids[i];
          final bId = ids[j];
          final a = positions[aId]!;
          final b = positions[bId]!;
          final delta = b - a;
          final distance = delta.distance;

          if (distance >= shapeSimulationMinPlayerDistance || distance == 0) {
            continue;
          }

          final push = (shapeSimulationMinPlayerDistance - distance) / 2;
          final direction = distance == 0
              ? const Offset(1, 0)
              : Offset(delta.dx / distance, delta.dy / distance);

          positions[aId] = _clamp(a - direction * push);
          positions[bId] = _clamp(b + direction * push);
        }
      }
    }
  }

  Offset _clamp(Offset position) {
    return Offset(
      position.dx.clamp(shapeSimulationMinBound, shapeSimulationMaxBound),
      position.dy.clamp(shapeSimulationMinBound, shapeSimulationMaxBound),
    );
  }
}
