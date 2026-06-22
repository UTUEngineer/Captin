import 'package:captain/features/timeline/application/timeline_controller.dart';
import 'package:captain/features/timeline/domain/match_timeline.dart';
import 'package:captain/features/timeline/domain/timeline_event.dart';
import 'package:captain/features/timeline/domain/timeline_event_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TimelineEvent', () {
    test('timeInMinutes combines minute and second', () {
      const event = TimelineEvent(
        id: '1',
        minute: 45,
        second: 30,
        type: TimelineEventType.goal,
      );

      expect(event.timeInMinutes, 45.5);
      expect(event.formattedTime, '45:30');
    });
  });

  group('TimelineState', () {
    test('maxMinute extends beyond 90 when events exist later', () {
      final state = TimelineState(
        timeline: MatchTimeline(
          id: 't1',
          matchId: 'm1',
          duration: 90,
          events: [
            const TimelineEvent(
              id: 'e1',
              minute: 93,
              type: TimelineEventType.goal,
            ),
          ],
        ),
      );

      expect(state.maxMinute, 93);
    });
  });
}
