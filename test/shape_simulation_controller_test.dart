import 'dart:ui';

import 'package:captain/features/shape_simulation/application/shape_simulation_controller.dart';
import 'package:captain/features/shape_simulation/domain/player_role.dart';
import 'package:captain/features/shape_simulation/domain/simulation_mode.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const controller = ShapeSimulationController();

  group('ShapeSimulationController', () {
    test('moved player uses requested position', () {
      final positions = controller.onPlayerMoved(
        playerId: 'st',
        newPosition: const Offset(0.55, 0.2),
        currentPositions: {
          'gk': const Offset(0.5, 0.92),
          'st': const Offset(0.5, 0.18),
        },
        basePositions: {
          'gk': const Offset(0.5, 0.92),
          'st': const Offset(0.5, 0.18),
        },
        roles: {
          'gk': PlayerRole.gk,
          'st': PlayerRole.st,
        },
        mode: SimulationMode.possessionBuild,
      );

      expect(positions['st']!.dx, closeTo(0.55, 0.001));
      expect(positions['st']!.dy, closeTo(0.2, 0.001));
    });

    test('goalkeeper moves less than striker for same drag', () {
      final positions = controller.onPlayerMoved(
        playerId: 'st',
        newPosition: const Offset(0.65, 0.12),
        currentPositions: {
          'gk': const Offset(0.5, 0.92),
          'cb': const Offset(0.38, 0.75),
          'st': const Offset(0.5, 0.18),
        },
        basePositions: {
          'gk': const Offset(0.5, 0.92),
          'cb': const Offset(0.38, 0.75),
          'st': const Offset(0.5, 0.18),
        },
        roles: {
          'gk': PlayerRole.gk,
          'cb': PlayerRole.cb,
          'st': PlayerRole.st,
        },
        mode: SimulationMode.possessionBuild,
      );

      final gkShift = (positions['gk']! - const Offset(0.5, 0.92)).distance;
      final cbShift = (positions['cb']! - const Offset(0.38, 0.75)).distance;
      expect(gkShift, lessThan(cbShift));
    });

    test('positions are clamped to pitch bounds', () {
      final positions = controller.onPlayerMoved(
        playerId: 'st',
        newPosition: const Offset(0.99, 0.01),
        currentPositions: {
          'st': const Offset(0.5, 0.18),
        },
        basePositions: {
          'st': const Offset(0.5, 0.18),
        },
        roles: {
          'st': PlayerRole.st,
        },
        mode: SimulationMode.highPress,
      );

      expect(positions['st']!.dx, inInclusiveRange(0.05, 0.95));
      expect(positions['st']!.dy, inInclusiveRange(0.05, 0.95));
    });

    test('PlayerRole.fromLabel maps common labels', () {
      expect(PlayerRole.fromLabel('GK'), PlayerRole.gk);
      expect(PlayerRole.fromLabel('CB'), PlayerRole.cb);
      expect(PlayerRole.fromLabel('RB'), PlayerRole.fb);
      expect(PlayerRole.fromLabel('CDM'), PlayerRole.cdm);
      expect(PlayerRole.fromLabel('CAM'), PlayerRole.cam);
      expect(PlayerRole.fromLabel('RW'), PlayerRole.winger);
      expect(PlayerRole.fromLabel('ST'), PlayerRole.st);
    });
  });
}
