import 'package:freezed_annotation/freezed_annotation.dart';

part 'player.freezed.dart';
part 'player.g.dart';

@freezed
abstract class Player with _$Player {
  const factory Player({
    required String id,
    required int number,
    required double x,
    required double y,
    String? label,
    @Default(true) bool isHomeTeam,
    @Default(false) bool locked,
    @Default(0) int zIndex,
  }) = _Player;

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
}
