import 'dart:ui';

import 'package:captain/features/shape_simulation/application/shape_simulation_controller.dart';
import 'package:captain/features/shape_simulation/domain/player_role.dart';
import 'package:captain/features/shape_simulation/domain/simulation_mode.dart';
import 'package:captain/features/tactical_board/domain/player.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const shapeSimulationAnimationDuration = Duration(milliseconds: 300);

class ShapeSimulationState {
  const ShapeSimulationState({
    this.isSimulationActive = false,
    this.anchorPlayerId,
    this.simulationMode = SimulationMode.possessionBuild,
    this.basePositions = const {},
    this.ghostPositions = const {},
  });

  final bool isSimulationActive;
  final String? anchorPlayerId;
  final SimulationMode simulationMode;
  final Map<String, Offset> basePositions;
  final Map<String, Offset> ghostPositions;

  ShapeSimulationState copyWith({
    bool? isSimulationActive,
    String? anchorPlayerId,
    bool clearAnchorPlayer = false,
    SimulationMode? simulationMode,
    Map<String, Offset>? basePositions,
    Map<String, Offset>? ghostPositions,
    bool clearGhostPositions = false,
  }) {
    return ShapeSimulationState(
      isSimulationActive: isSimulationActive ?? this.isSimulationActive,
      anchorPlayerId: clearAnchorPlayer
          ? null
          : (anchorPlayerId ?? this.anchorPlayerId),
      simulationMode: simulationMode ?? this.simulationMode,
      basePositions: basePositions ?? this.basePositions,
      ghostPositions: clearGhostPositions
          ? const {}
          : (ghostPositions ?? this.ghostPositions),
    );
  }
}

class ShapeSimulationNotifier extends StateNotifier<ShapeSimulationState> {
  ShapeSimulationNotifier(this._controller)
      : super(const ShapeSimulationState());

  final ShapeSimulationController _controller;

  void setMode(SimulationMode mode) {
    state = state.copyWith(simulationMode: mode);
  }

  void toggleSimulation({required List<Player> players}) {
    if (state.isSimulationActive) {
      state = state.copyWith(
        isSimulationActive: false,
        clearAnchorPlayer: true,
        clearGhostPositions: true,
      );
      return;
    }

    state = state.copyWith(
      isSimulationActive: true,
      basePositions: _positionsForTeam(players, isHomeTeam: true),
      clearGhostPositions: true,
      clearAnchorPlayer: true,
    );
  }

  void syncBasePositions(List<Player> players) {
    if (!state.isSimulationActive) return;
    state = state.copyWith(
      basePositions: _positionsForTeam(players, isHomeTeam: true),
      clearGhostPositions: true,
      clearAnchorPlayer: true,
    );
  }

  Map<String, Offset> simulatePlayerMove({
    required String playerId,
    required Offset newPosition,
    required List<Player> players,
  }) {
    final teamPositions = _positionsForTeam(players, isHomeTeam: true);
    final roles = {
      for (final player in players.where((p) => p.isHomeTeam))
        player.id: PlayerRole.fromLabel(player.label),
    };

    final ghosts = Map<String, Offset>.from(teamPositions);
    state = state.copyWith(
      ghostPositions: ghosts,
      anchorPlayerId: playerId,
    );

    return _controller.onPlayerMoved(
      playerId: playerId,
      newPosition: newPosition,
      currentPositions: teamPositions,
      basePositions: state.basePositions,
      roles: roles,
      mode: state.simulationMode,
      includePlayer: (id) => teamPositions.containsKey(id),
    );
  }

  Map<String, Offset> _positionsForTeam(
    List<Player> players, {
    required bool isHomeTeam,
  }) {
    return {
      for (final player in players.where((p) => p.isHomeTeam == isHomeTeam))
        player.id: Offset(player.x, player.y),
    };
  }
}
