import 'package:freezed_annotation/freezed_annotation.dart';

part 'arrow.freezed.dart';
part 'arrow.g.dart';

enum ArrowType {
  pass,
  run,
  press,
  curvedRun,
  dribble,
  shot,
  line,
}

extension ArrowTypeX on ArrowType {
  /// Arrows that move a player when the tactic is played back.
  bool get movesPlayer =>
      this == ArrowType.run ||
      this == ArrowType.curvedRun ||
      this == ArrowType.dribble ||
      this == ArrowType.press;

  /// Arrows that move the ball when the tactic is played back.
  bool get movesBall =>
      this == ArrowType.pass ||
      this == ArrowType.shot ||
      this == ArrowType.dribble;

  bool get hasHead => this != ArrowType.line;
}

@freezed
abstract class Arrow with _$Arrow {
  const factory Arrow({
    required String id,
    required double startX,
    required double startY,
    required double endX,
    required double endY,
    required ArrowType type,
    @Default(false) bool curved,
    int? colorValue,
    @Default(false) bool locked,
    @Default(0) int zIndex,
    @Default(0.0) double rotation,
    /// Signed curvature for curved arrows (fraction of arrow length).
    @Default(0.35) double bend,
    /// Playback phase this arrow belongs to (1-based).
    @Default(1) int step,
  }) = _Arrow;

  factory Arrow.fromJson(Map<String, dynamic> json) => _$ArrowFromJson(json);
}
