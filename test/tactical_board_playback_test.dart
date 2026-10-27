import 'dart:ui';

import 'package:captain/features/shape_simulation/application/shape_simulation_controller.dart';
import 'package:captain/features/shape_simulation/application/shape_simulation_notifier.dart';
import 'package:captain/features/shape_simulation/domain/player_role.dart';
import 'package:captain/features/shape_simulation/domain/simulation_mode.dart';
import 'package:captain/features/tactical_board/application/tactic_playback.dart';
import 'package:captain/features/tactical_board/application/tactical_board_notifier.dart';
import 'package:captain/features/tactical_board/domain/arrow.dart';
import 'package:captain/features/tactical_board/domain/board_ball.dart';
import 'package:captain/features/tactical_board/domain/board_element.dart';
import 'package:captain/features/tactical_board/domain/board_tool.dart';
import 'package:captain/features/tactical_board/domain/player.dart';
import 'package:captain/features/tactical_board/domain/zone.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TacticPlayback', () {
    const runner = Player(id: 'p1', number: 7, x: 0.2, y: 0.6);
    const passer = Player(id: 'p2', number: 8, x: 0.5, y: 0.6);

    test('run arrow moves the player at its start to its end', () {
      final playback = TacticPlayback.fromBoard(
        players: const [runner, passer],
        arrows: const [
          Arrow(
            id: 'a1',
            startX: 0.21,
            startY: 0.6,
            endX: 0.2,
            endY: 0.3,
            type: ArrowType.run,
          ),
        ],
      );

      expect(playback.stepCount, 1);
      final start = playback.frameAt(0);
      final end = playback.frameAt(playback.duration);
      expect(start.players['p1']!.dy, closeTo(0.6, 1e-6));
      expect(end.players['p1']!.dy, closeTo(0.3, 1e-6));
      // the other player stays put
      expect(end.players['p2'], const Offset(0.5, 0.6));
      final mid = playback.frameAt(0.5);
      expect(mid.moving, contains('p1'));
    });

    test('pass arrow moves the ball; phases run in order', () {
      final playback = TacticPlayback.fromBoard(
        players: const [runner, passer],
        ball: const BoardBall(x: 0.5, y: 0.6),
        arrows: const [
          Arrow(
            id: 'run',
            startX: 0.2,
            startY: 0.6,
            endX: 0.2,
            endY: 0.3,
            type: ArrowType.run,
          ),
          Arrow(
            id: 'pass',
            startX: 0.5,
            startY: 0.6,
            endX: 0.2,
            endY: 0.3,
            type: ArrowType.pass,
            step: 2,
          ),
        ],
      );

      expect(playback.stepCount, 2);
      final afterPhase1 = playback.frameAt(1);
      expect(afterPhase1.ball, const Offset(0.5, 0.6));
      expect(afterPhase1.players['p1']!.dy, closeTo(0.3, 1e-6));
      final end = playback.frameAt(2);
      expect(end.ball!.dx, closeTo(0.2, 1e-6));
      expect(end.ball!.dy, closeTo(0.3, 1e-6));
      expect(end.step, 2);
    });

    test('board without movement arrows is empty', () {
      final playback = TacticPlayback.fromBoard(
        players: const [runner],
        arrows: const [
          Arrow(
            id: 'l',
            startX: 0.9,
            startY: 0.9,
            endX: 0.8,
            endY: 0.8,
            type: ArrowType.line,
          ),
        ],
      );
      expect(playback.isEmpty, isTrue);
    });
  });

  group('Board selection & objects', () {
    test('selectInRect picks players inside the box', () {
      final notifier = TacticalBoardNotifier();
      final players = notifier.state.players;
      final target = players.first;
      notifier.selectInRect(
        Rect.fromCenter(
          center: Offset(target.x, target.y),
          width: 0.02,
          height: 0.02,
        ),
      );
      expect(
        notifier.state.selectedElements,
        contains(BoardElementKey(BoardElementKind.player, target.id)),
      );
    });

    test('translateSelected moves a selection as one undo step', () {
      final notifier = TacticalBoardNotifier();
      final player = notifier.state.players.first;
      notifier.selectPlayer(player.id);
      notifier.beginInteraction();
      notifier.translateSelected(dx: 0.05, dy: 0);
      notifier.translateSelected(dx: 0.05, dy: 0);
      final moved =
          notifier.state.players.firstWhere((p) => p.id == player.id);
      expect(moved.x, closeTo(player.x + 0.1, 1e-9));
      notifier.undo();
      final restored =
          notifier.state.players.firstWhere((p) => p.id == player.id);
      expect(restored.x, closeTo(player.x, 1e-9));
    });

    test('ball can be placed and undone', () {
      final notifier = TacticalBoardNotifier();
      notifier.setBall(x: 0.4, y: 0.5);
      expect(notifier.state.ball, const BoardBall(x: 0.4, y: 0.5));
      notifier.undo();
      expect(notifier.state.ball, isNull);
    });

    test('free-hand zone becomes a polygon zone', () {
      final notifier = TacticalBoardNotifier();
      notifier.setTool(BoardTool.freeZone);
      notifier.startDraft(x: 0.2, y: 0.2);
      notifier.updateDraft(x: 0.4, y: 0.2);
      notifier.updateDraft(x: 0.4, y: 0.4);
      notifier.updateDraft(x: 0.2, y: 0.4);
      notifier.commitDraft();
      final zone = notifier.state.zones.single;
      expect(zone.shape, ZoneShape.polygon);
      expect(zone.points.length, greaterThanOrEqualTo(6));
      expect(notifier.findElementAt(x: 0.3, y: 0.3)?.id, zone.id);
    });

    test('new arrow tools create typed arrows in the active phase', () {
      final notifier = TacticalBoardNotifier();
      notifier.setTool(BoardTool.dribbleArrow);
      notifier.setActiveStep(3);
      notifier.startDraft(x: 0.3, y: 0.5);
      notifier.updateDraft(x: 0.5, y: 0.3);
      notifier.commitDraft();
      final arrow = notifier.state.arrows.single;
      expect(arrow.type, ArrowType.dribble);
      expect(arrow.step, 3);
    });
  });

  group('Shape simulation', () {
    test('dragging a home player shifts teammates and opponents', () {
      final notifier = ShapeSimulationNotifier(const ShapeSimulationController());
      const players = [
        Player(id: 'st', number: 9, x: 0.5, y: 0.3, label: 'ST'),
        Player(id: 'cm', number: 8, x: 0.5, y: 0.5, label: 'CM'),
        Player(id: 'opp', number: 4, x: 0.5, y: 0.25, label: 'CB', isHomeTeam: false),
      ];
      notifier.toggleSimulation(players: players);
      notifier.beginDrag(playerId: 'st', players: players);
      final result = notifier.simulatePlayerMove(
        playerId: 'st',
        newPosition: const Offset(0.8, 0.3),
        players: players,
      );
      expect(result['st']!.dx, closeTo(0.8, 1e-6));
      expect(result['cm']!.dx, greaterThan(0.5));
      expect(result['opp']!.dx, greaterThan(0.5));
    });

    test('opponentsReact keeps goalkeeper calmer than full-back', () {
      const controller = ShapeSimulationController();
      final result = controller.opponentsReact(
        displacement: const Offset(0.2, 0),
        anchor: const Offset(0.7, 0.5),
        opponentPositions: const {
          'gk': Offset(0.5, 0.05),
          'fb': Offset(0.5, 0.2),
        },
        roles: const {'gk': PlayerRole.gk, 'fb': PlayerRole.fb},
        mode: SimulationMode.highPress,
      );
      expect(result['gk']!.dx - 0.5, lessThan(result['fb']!.dx - 0.5));
    });
  });
}
