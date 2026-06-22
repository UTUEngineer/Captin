import 'package:captain/features/timeline/domain/timeline_event.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'match_timeline.freezed.dart';
part 'match_timeline.g.dart';

@freezed
abstract class MatchTimeline with _$MatchTimeline {
  const factory MatchTimeline({
    required String id,
    required String matchId,
    @Default(90) int duration,
    @Default([]) List<TimelineEvent> events,
  }) = _MatchTimeline;

  factory MatchTimeline.fromJson(Map<String, dynamic> json) =>
      _$MatchTimelineFromJson(json);
}

extension MatchTimelineBounds on MatchTimeline {
  int get maxMinute {
    var max = duration;
    for (final event in events) {
      if (event.minute > max) max = event.minute;
    }
    return max;
  }
}
