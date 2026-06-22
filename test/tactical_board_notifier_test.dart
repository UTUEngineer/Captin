import 'package:captain/features/tactical_board/application/tactical_board_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TacticalBoardNotifier undo/redo', () {
    late ProviderContainer container;
    late TacticalBoardNotifier notifier;

    setUp(() {
      container = ProviderContainer();
      notifier = container.read(tacticalBoardProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('undo restores previous player position', () {
      final player = container.read(tacticalBoardProvider).players.first;
      final originalX = player.x;
      final originalY = player.y;

      notifier.movePlayer(playerId: player.id, x: 0.42, y: 0.58);

      final moved = container.read(tacticalBoardProvider).players.first;
      expect(moved.x, 0.42);
      expect(container.read(tacticalBoardProvider).canUndo, isTrue);

      notifier.undo();

      final restored = container.read(tacticalBoardProvider).players.first;
      expect(restored.x, originalX);
      expect(restored.y, originalY);
      expect(container.read(tacticalBoardProvider).canRedo, isTrue);
    });

    test('redo reapplies undone change', () {
      final player = container.read(tacticalBoardProvider).players.first;

      notifier.movePlayer(playerId: player.id, x: 0.33, y: 0.67);
      notifier.undo();
      notifier.redo();

      final playerAfterRedo =
          container.read(tacticalBoardProvider).players.first;
      expect(playerAfterRedo.x, 0.33);
      expect(playerAfterRedo.y, 0.67);
      expect(container.read(tacticalBoardProvider).canRedo, isFalse);
    });

    test('new edit clears redo stack', () {
      final player = container.read(tacticalBoardProvider).players.first;

      notifier.movePlayer(playerId: player.id, x: 0.2, y: 0.2);
      notifier.undo();
      expect(container.read(tacticalBoardProvider).canRedo, isTrue);

      notifier.movePlayer(playerId: player.id, x: 0.8, y: 0.8);
      expect(container.read(tacticalBoardProvider).canRedo, isFalse);
    });
  });
}
