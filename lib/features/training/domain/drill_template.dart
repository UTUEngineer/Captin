import 'package:captain/features/training/domain/drill_path.dart';
import 'package:captain/features/training/domain/training_prop.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'drill_template.freezed.dart';
part 'drill_template.g.dart';

@freezed
abstract class DrillTemplate with _$DrillTemplate {
  const factory DrillTemplate({
    required String id,
    required String name,
    required String description,
    @Default([]) List<TrainingProp> props,
    @Default([]) List<DrillPath> paths,
    @Default(8) int recommendedPlayers,
  }) = _DrillTemplate;

  factory DrillTemplate.fromJson(Map<String, dynamic> json) =>
      _$DrillTemplateFromJson(json);
}
