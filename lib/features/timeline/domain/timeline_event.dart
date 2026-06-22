import 'package:captain/features/timeline/domain/timeline_event_type.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'timeline_event.freezed.dart';
part 'timeline_event.g.dart';

class TimelineEventTypeConverter
    implements JsonConverter<TimelineEventType, String> {
  const TimelineEventTypeConverter();

  @override
  TimelineEventType fromJson(String json) {
    return TimelineEventTypeJson.fromWire(json) ?? TimelineEventType.keyMoment;
  }

  @override
  String toJson(TimelineEventType object) => object.wireName;
}

@freezed
abstract class TimelineEvent with _$TimelineEvent {
  const factory TimelineEvent({
    required String id,
    required int minute,
    @Default(0) int second,
    @TimelineEventTypeConverter() required TimelineEventType type,
    @Default('') String description,
    String? linkedTacticalBoardId,
    String? teamId,
    String? playerName,
  }) = _TimelineEvent;

  factory TimelineEvent.fromJson(Map<String, dynamic> json) =>
      _$TimelineEventFromJson(json);
}

extension TimelineEventTime on TimelineEvent {
  double get timeInMinutes => minute + (second / 60.0);

  String get formattedTime {
    final paddedSecond = second.toString().padLeft(2, '0');
    return '$minute:$paddedSecond';
  }
}
