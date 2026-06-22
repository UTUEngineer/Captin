import 'package:captain/features/tactical_board/domain/player.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'formation.freezed.dart';

enum FormationType {
  f433('4-3-3'),
  f4231('4-2-3-1'),
  f442('4-4-2'),
  f352('3-5-2'),
  f4141('4-1-4-1'),
  f343('3-4-3');

  const FormationType(this.label);
  final String label;
}

@freezed
abstract class Formation with _$Formation {
  const factory Formation({
    required FormationType type,
    required List<Player> players,
  }) = _Formation;
}
