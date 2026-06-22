import 'package:captain/features/training/domain/drill_path_style.dart';
import 'package:captain/features/training/domain/path_control_point.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'drill_path.freezed.dart';
part 'drill_path.g.dart';

@freezed
abstract class DrillPath with _$DrillPath {
  const factory DrillPath({
    required String id,
    required double startX,
    required double startY,
    required double endX,
    required double endY,
    @Default([]) List<PathControlPoint> controlPoints,
    @DrillPathStyleConverter() @Default(DrillPathStyle.run) DrillPathStyle style,
    @Default(0xFF2E7D32) int colorValue,
  }) = _DrillPath;

  factory DrillPath.fromJson(Map<String, dynamic> json) =>
      _$DrillPathFromJson(json);
}

extension DrillPathColors on DrillPath {
  Color get color => Color(colorValue);
}
