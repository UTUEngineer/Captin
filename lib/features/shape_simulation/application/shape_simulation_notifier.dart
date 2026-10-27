import 'dart:ui';

import 'package:captain/features/shape_simulation/application/shape_simulation_controller.dart';
import 'package:captain/features/shape_simulation/domain/player_role.dart';
import 'package:captain/features/shape_simulation/domain/simulation_mode.dart';
import 'package:captain/features/tactical_board/domain/player.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const shapeSimulationAnimationDuration = Duration(milliseconds: 260);

class ShapeSimulationState {
  const ShapeSimulationState({
    this.isSimulationActive = false,
    this.anchorPlayerId,
    this.simulationMode = SimulationMode.possessionBuild,
    this.basePositions = const {},
    this.ghostPositions = const {},
    this.opponentsReact = true,
  });

  final bool isSimulationActive;
  final String? anchorPlayerId;
  final SimulationMode simulationMode;

  /// Shape captured when the simulation was switched on (both teams).
  final Map<String, Offset> basePositions;

  /// Where players stood before the current/last drag (shown as ghosts).
  final Map<String, Offset> ghostPositions;

  /// Whether the opposing team shifts in response.
  final bool opponentsReact;

  ShapeSimulationState copyWith({
    bool? isSimulationActive,
    String? anchorPlayerId,
    bool clearAnchorPlayer = false,
    SimulationMode? simulationMode,
    Map<String, Offset>? basePositions,
    Map<String, Offset>? ghostPositions,
    bool clearGhostPositions = false,
    bool? opponentsReact,
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
      opponentsReact: opponentsReact ?? this.opponentsReact,
    );
  }
}

class ShapeSimulationNotifier extends StateNotifier<ShapeSimulationState> {
  ShapeSimulationNotifier(this._controller)
      : super(const ShapeSimulationState());

  final ShapeSimulationController _controller;

  /// Positions at the moment the current drag started.
  Map<String, Offset> _dragStart = const {};

  void setMode(SimulationMode mode) {
    state = state.copyWith(simulationMode: mode);
  }

  void toggleOpponentsReact() {
    state = state.copyWith(opponentsReact: !state.opponentsReact);
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
      basePositions: _positions(players),
      clearGhostPositions: true,
      clearAnchorPlayer: true,
    );
  }

  void syncBasePositions(List<Player> players) {
    if (!state.isSimulationActive) return;
    state = state.copyWith(
      basePositions: _positions(players),
      clearGhostPositions: true,
      clearAnchorPlayer: true,
    );
  }

  /// Call when the user picks up a player while the simulation is on.
  void beginDrag({required String playerId, required List<Player> players}) {
    _dragStart = _positions(players);
    state = state.copyWith(
      ghostPositions: _dragStart,
      anchorPlayerId: playerId,
    );
  }

  /// Positions for every player affected by dragging [playerId] to
  /// [newPosition] (relative coords). Works for both teams: teammates keep
  /// the shape, opponents slide across when [ShapeSimulationState.opponentsReact].
  Map<String, Offset> simulatePlayerMove({
    required String playerId,
    required Offset newPosition,
    required List<Player> players,
  }) {
    if (_dragStart.isEmpty || !_dragStart.containsKey(playerId)) {
      beginDrag(playerId: playerId, players: players);
    }
    final mover = players.where((p) => p.id == playerId).firstOrNull;
    if (mover == null) return {playerId: newPosition};
    final isHome = mover.isHomeTeam;

    final team = {
      for (final p in players.where((p) => p.isHomeTeam == isHome))
        p.id: _dragStart[p.id] ?? Offset(p.x, p.y),
    };
    final roles = {
      for (final p in players) p.id: PlayerRole.fromLabel(p.label),
    };

    final result = _controller.onPlayerMoved(
      playerId: playerId,
      newPosition: newPosition,
      currentPositions: team,
      basePositions: team,
      roles: roles,
      mode: state.simulationMode,
    );

    if (state.opponentsReact) {
      final opponents = {
        for (final p in players.where((p) => p.isHomeTeam != isHome))
          p.id: _dragStart[p.id] ?? Offset(p.x, p.y),
      };
      final displacement = newPosition - (team[playerId] ?? newPosition);
      // Opponents attack the other goal, so their "vertical" is mirrored
      // relative to the mover — the controller handles signs uniformly.
      result.addAll(
        _controller.opponentsReact(
          displacement: displacement,
          anchor: newPosition,
          opponentPositions: opponents,
          roles: roles,
          mode: state.simulationMode,
        ),
      );
    }
    return result;
  }

  void endDrag() {
    _dragStart = const {};
    state = state.copyWith(clearAnchorPlayer: true);
  }

  /// Shape the board had when the simulation started.
  Map<String, Offset> get resetPositions => state.basePositions;

  void clearGhosts() {
    state = state.copyWith(clearGhostPositions: true);
  }

  Map<String, Offset> _positions(List<Player> players) {
    return {
      for (final player in players) player.id: Offset(player.x, player.y),
    };
  }
}
