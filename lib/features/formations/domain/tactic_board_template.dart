import 'package:captain/features/tactical_board/domain/arrow.dart';
import 'package:captain/features/tactical_board/domain/formation.dart';
import 'package:captain/features/tactical_board/domain/highlight_circle.dart';
import 'package:captain/features/tactical_board/domain/pitch_orientation.dart';
import 'package:captain/features/tactical_board/domain/pitch_style.dart';
import 'package:captain/features/tactical_board/domain/player.dart';
import 'package:captain/features/tactical_board/domain/text_annotation.dart';
import 'package:captain/features/tactical_board/domain/zone.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'tactic_board_template.freezed.dart';
part 'tactic_board_template.g.dart';

@freezed
abstract class TacticBoardTemplate with _$TacticBoardTemplate {
  const factory TacticBoardTemplate({
    required String id,
    required String name,
    String? description,
    required DateTime updatedAt,
    @Default(false) bool isPreset,
    FormationType? formation,
    @Default(PitchOrientation.vertical) PitchOrientation orientation,
    @Default(PitchStyle.striped) PitchStyle pitchStyle,
    @Default([]) List<Player> players,
    @Default([]) List<Arrow> arrows,
    @Default([]) List<Zone> zones,
    @Default([]) List<HighlightCircle> highlights,
    @Default([]) List<TextAnnotation> textAnnotations,
  }) = _TacticBoardTemplate;

  factory TacticBoardTemplate.fromJson(Map<String, dynamic> json) =>
      _$TacticBoardTemplateFromJson(json);
}
