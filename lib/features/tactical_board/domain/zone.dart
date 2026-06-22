import 'package:freezed_annotation/freezed_annotation.dart';

part 'zone.freezed.dart';
part 'zone.g.dart';

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
  }) = _Zone;

  factory Zone.fromJson(Map<String, dynamic> json) => _$ZoneFromJson(json);
}
