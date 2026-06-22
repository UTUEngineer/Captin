import 'package:captain/features/tactical_board/application/tactical_board_notifier.dart';
import 'package:captain/features/tactical_board/domain/arrow.dart';
import 'package:captain/features/tactical_board/domain/board_element.dart';
import 'package:captain/features/tactical_board/domain/highlight_circle.dart';
import 'package:captain/features/tactical_board/domain/player.dart';
import 'package:captain/features/tactical_board/domain/text_annotation.dart';
import 'package:captain/features/tactical_board/domain/zone.dart';
import 'package:captain/features/tactical_board/presentation/widgets/pitch_painter.dart';
import 'package:flutter/material.dart';

class BoardSelectionAnchor {
  const BoardSelectionAnchor({
    required this.position,
    required this.primaryKey,
  });

  final Offset position;
  final BoardElementKey primaryKey;
}

BoardSelectionAnchor? selectionAnchorFor({
  required TacticalBoardState state,
  required PitchLayout layout,
}) {
  if (state.selectedElements.isEmpty) return null;

  final primary = state.selectedElements.first;
  final position = switch (primary.kind) {
    BoardElementKind.player => () {
        final player = state.players.firstWhere((p) => p.id == primary.id);
        return layout.positionFor(player.x, player.y);
      }(),
    BoardElementKind.arrow => () {
        final arrow = state.arrows.firstWhere((a) => a.id == primary.id);
        final start = layout.positionFor(arrow.startX, arrow.startY);
        final end = layout.positionFor(arrow.endX, arrow.endY);
        return Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
      }(),
    BoardElementKind.zone => () {
        final zone = state.zones.firstWhere((z) => z.id == primary.id);
        return layout.positionFor(
          zone.x + zone.width / 2,
          zone.y + zone.height / 2,
        );
      }(),
    BoardElementKind.highlight => () {
        final circle = state.highlights.firstWhere((c) => c.id == primary.id);
        return layout.positionFor(circle.centerX, circle.centerY);
      }(),
    BoardElementKind.text => () {
        final note =
            state.textAnnotations.firstWhere((n) => n.id == primary.id);
        return layout.positionFor(note.x, note.y);
      }(),
  };

  return BoardSelectionAnchor(position: position, primaryKey: primary);
}

List<Zone> sortedZones(List<Zone> zones) {
  final copy = [...zones]..sort((a, b) => a.zIndex.compareTo(b.zIndex));
  return copy;
}

List<HighlightCircle> sortedHighlights(List<HighlightCircle> circles) {
  final copy = [...circles]..sort((a, b) => a.zIndex.compareTo(b.zIndex));
  return copy;
}

List<Arrow> sortedArrows(List<Arrow> arrows) {
  final copy = [...arrows]..sort((a, b) => a.zIndex.compareTo(b.zIndex));
  return copy;
}

List<Player> sortedPlayers(List<Player> players) {
  final copy = [...players]..sort((a, b) => a.zIndex.compareTo(b.zIndex));
  return copy;
}

List<TextAnnotation> sortedTextNotes(List<TextAnnotation> notes) {
  final copy = [...notes]..sort((a, b) => a.zIndex.compareTo(b.zIndex));
  return copy;
}
