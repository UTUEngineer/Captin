import 'package:captain/features/collaboration/data/collaboration_event_queue.dart';
import 'package:captain/features/collaboration/domain/collaboration_event.dart';
import 'package:captain/features/formations/domain/tactic_board_template.dart';
import 'package:captain/features/tactical_board/data/local_board_autosave_store.dart';
import 'package:captain/features/tactical_board/domain/formation.dart';
import 'package:captain/features/tactical_board/domain/pitch_orientation.dart';
import 'package:captain/features/tactical_board/domain/pitch_style.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('LocalBoardAutosaveStore saves and restores board template', () async {
    SharedPreferences.setMockInitialValues({});
    final store = await LocalBoardAutosaveStore.create();
    final template = TacticBoardTemplate(
      id: 'autosave-1',
      name: 'autosave',
      updatedAt: DateTime(2026, 6, 20),
      formation: FormationType.f433,
      orientation: PitchOrientation.vertical,
      pitchStyle: PitchStyle.striped,
    );

    await store.save(template);
    final loaded = await store.load();

    expect(loaded?.id, template.id);
    expect(loaded?.formation, FormationType.f433);
  });

  test('CollaborationEventQueue enqueues and drains events', () async {
    SharedPreferences.setMockInitialValues({});
    final queue = await CollaborationEventQueue.create();
    const event = CollaborationEvent(
      type: CollaborationEventType.playerMoved,
      senderId: 'user-1',
      timestamp: 123,
      payload: {'playerId': 'p1', 'x': 0.5, 'y': 0.5},
    );

    await queue.enqueue(event);
    expect(await queue.pendingCount(), 1);

    final drained = await queue.drain();
    expect(drained, hasLength(1));
    expect(drained.first.type, CollaborationEventType.playerMoved);
    expect(await queue.pendingCount(), 0);
  });
}
