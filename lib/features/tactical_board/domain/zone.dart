import 'package:freezed_annotation/freezed_annotation.dart';

part 'zone.freezed.dart';
part 'zone.g.dart';

enum ZoneShape {
  rectangle,
  /// Free-hand lasso; vertices stored in [Zone.points] as x0,y0,x1,y1,...
  polygon,
}

enum ZonePattern {
  solid,
  hatched,
}

@freezed
abstract class Zone with _$Zone {
  const factory Zone({
    required String id,
    required double x,
    required double y,
    required double width,
    required double height,
    required int colorValue,
    @Default(false) bool locked,
    @Default(0) int zIndex,
    @Default(0.0) double rotation,
    @Default(ZoneShape.rectangle) ZoneShape shape,
    @Default(<double>[]) List<double> points,
    @Default(ZonePattern.solid) ZonePattern pattern,
    String? label,
  }) = _Zone;

  factory Zone.fromJson(Map<String, dynamic> json) => _$ZoneFromJson(json);
}
