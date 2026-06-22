import 'package:freezed_annotation/freezed_annotation.dart';

part 'highlight_circle.freezed.dart';
part 'highlight_circle.g.dart';

@freezed
abstract class HighlightCircle with _$HighlightCircle {
  const factory HighlightCircle({
    required String id,
    required double centerX,
    required double centerY,
    required double radiusX,
    required double radiusY,
    required int colorValue,
    @Default(false) bool locked,
    @Default(0) int zIndex,
  }) = _HighlightCircle;

  factory HighlightCircle.fromJson(Map<String, dynamic> json) =>
      _$HighlightCircleFromJson(json);
}
