import 'package:captain/features/formations/domain/tactic_board_template.dart';
import 'package:captain/features/training/domain/drill_path.dart';
import 'package:captain/features/training/domain/training_prop.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'training_session.freezed.dart';
part 'training_session.g.dart';

@freezed
abstract class TrainingSession with _$TrainingSession {
  const factory TrainingSession({
    required String id,
    required String name,
    @Default('') String notes,
    @Default([]) List<TrainingProp> props,
    @Default([]) List<DrillPath> paths,
    TacticBoardTemplate? boardTemplate,
    required DateTime updatedAt,
  }) = _TrainingSession;

  factory TrainingSession.fromJson(Map<String, dynamic> json) =>
      _$TrainingSessionFromJson(json);
}
