import 'package:captain/features/tactical_board/domain/arrow.dart';
import 'package:captain/features/tactical_board/domain/formation.dart';
import 'package:captain/features/tactical_board/domain/highlight_circle.dart';
import 'package:captain/features/tactical_board/domain/player.dart';
import 'package:captain/features/tactical_board/domain/text_annotation.dart';
import 'package:captain/features/tactical_board/domain/zone.dart';

/// Immutable snapshot of board state for undo/redo.
class BoardSnapshot {
  const BoardSnapshot({
    required this.players,
    this.selectedFormation,
    this.arrows = const [],
    this.zones = const [],
    this.highlights = const [],
    this.textAnnotations = const [],
  });

  factory BoardSnapshot.fromState({
    required List<Player> players,
    FormationType? selectedFormation,
    List<Arrow> arrows = const [],
    List<Zone> zones = const [],
    List<HighlightCircle> highlights = const [],
    List<TextAnnotation> textAnnotations = const [],
  }) {
    return BoardSnapshot(
      players: players.map((player) => player.copyWith()).toList(growable: false),
      selectedFormation: selectedFormation,
      arrows: arrows.map((arrow) => arrow.copyWith()).toList(growable: false),
      zones: zones.map((zone) => zone.copyWith()).toList(growable: false),
      highlights:
          highlights.map((circle) => circle.copyWith()).toList(growable: false),
      textAnnotations: textAnnotations
          .map((note) => note.copyWith())
          .toList(growable: false),
    );
  }

  final List<Player> players;
  final FormationType? selectedFormation;
  final List<Arrow> arrows;
  final List<Zone> zones;
  final List<HighlightCircle> highlights;
  final List<TextAnnotation> textAnnotations;
}
