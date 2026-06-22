import 'package:captain/features/collaboration/domain/collaboration_event.dart';
import 'package:captain/features/tactical_board/application/tactical_board_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('applyRemotePlayerMove does not affect undo stack', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(tacticalBoardProvider.notifier);
    final player = container.read(tacticalBoardProvider).players.first;

    notifier.movePlayer(playerId: player.id, x: 0.42, y: 0.58);
    expect(container.read(tacticalBoardProvider).canUndo, isTrue);

    notifier.applyRemotePlayerMove(
      playerId: player.id,
      x: 0.33,
      y: 0.67,
    );

    final updated = container.read(tacticalBoardProvider).players.first;
    expect(updated.x, 0.33);
    expect(updated.y, 0.67);
    expect(container.read(tacticalBoardProvider).canUndo, isTrue);

    notifier.undo();
    final restored = container.read(tacticalBoardProvider).players.first;
    expect(restored.x, player.x);
    expect(restored.y, player.y);
  });

  test('applyRemoteAnnotation appends arrow without history', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(tacticalBoardProvider.notifier);
    final beforeCount = container.read(tacticalBoardProvider).arrows.length;

    notifier.applyRemoteAnnotation(
      kind: CollaborationAnnotationKind.arrow,
      data: {
        'id': 'remote-arrow',
        'startX': 0.1,
        'startY': 0.1,
        'endX': 0.4,
        'endY': 0.4,
        'type': 'pass',
        'curved': false,
        'locked': false,
        'zIndex': 1,
        'rotation': 0.0,
      },
    );

    final after = container.read(tacticalBoardProvider);
    expect(after.arrows.length, beforeCount + 1);
    expect(after.canUndo, isFalse);
  });
}
