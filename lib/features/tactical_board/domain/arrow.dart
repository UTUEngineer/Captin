import 'package:freezed_annotation/freezed_annotation.dart';

part 'arrow.freezed.dart';
part 'arrow.g.dart';

enum ArrowType {
  pass,
  run,
  press,
  curvedRun,
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
  }) = _Arrow;

  factory Arrow.fromJson(Map<String, dynamic> json) => _$ArrowFromJson(json);
}
