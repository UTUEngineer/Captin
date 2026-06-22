import 'package:freezed_annotation/freezed_annotation.dart';

part 'path_control_point.freezed.dart';
part 'path_control_point.g.dart';

@freezed
abstract class PathControlPoint with _$PathControlPoint {
  const factory PathControlPoint({
    required double x,
    required double y,
  }) = _PathControlPoint;

  factory PathControlPoint.fromJson(Map<String, dynamic> json) =>
      _$PathControlPointFromJson(json);
}
