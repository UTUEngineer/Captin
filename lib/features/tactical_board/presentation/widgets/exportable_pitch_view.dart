import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/training/application/training_notifier.dart';
import 'package:captain/features/training/presentation/drill_path_painter.dart';
import 'package:captain/features/training/presentation/training_prop_painter.dart';
import 'package:captain/features/tactical_board/application/board_layout_helpers.dart';
import 'package:captain/features/tactical_board/application/tactical_board_notifier.dart';
import 'package:captain/features/tactical_board/presentation/widgets/annotations_painter.dart';
import 'package:captain/features/tactical_board/presentation/widgets/pitch_painter.dart';
import 'package:captain/features/tactical_board/presentation/widgets/player_token.dart';
import 'package:flutter/material.dart';

class ExportablePitchView extends StatelessWidget {
  const ExportablePitchView({
    super.key,
    required this.repaintKey,
    required this.boardState,
    required this.constraints,
    this.trainingState,
  });

  final GlobalKey repaintKey;
  final TacticalBoardState boardState;
  final Size constraints;
  final TrainingState? trainingState;

  @override
  Widget build(BuildContext context) {
    final layout = PitchLayout.compute(
      constraints: constraints,
      orientation: boardState.orientation,
    );
    final localLayout = PitchLayout(
      rect: Offset.zero & layout.rect.size,
      orientation: boardState.orientation,
      tokenSize: layout.tokenSize,
    );

    return RepaintBoundary(
      key: repaintKey,
      child: ColoredBox(
        color: AppColors.background,
        child: SizedBox(
          width: constraints.width,
          height: constraints.height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fromRect(
                rect: layout.rect,
                child: CustomPaint(
                  size: layout.rect.size,
                  painter: PitchPainter(
                    orientation: boardState.orientation,
                    style: boardState.pitchStyle,
                  ),
                ),
              ),
              Positioned.fromRect(
                rect: layout.rect,
                child: CustomPaint(
                  size: layout.rect.size,
                  painter: AnnotationsPainter(
                    layout: localLayout,
                    zones: sortedZones(boardState.zones),
                    highlights: sortedHighlights(boardState.highlights),
                    arrows: sortedArrows(boardState.arrows),
                  ),
                ),
              ),
              if (trainingState != null &&
                  (trainingState!.props.isNotEmpty ||
                      trainingState!.paths.isNotEmpty))
                Positioned.fromRect(
                  rect: layout.rect,
                  child: Stack(
                    children: [
                      CustomPaint(
                        size: layout.rect.size,
                        painter: DrillPathPainter(
                          layout: localLayout,
                          paths: trainingState!.paths,
                        ),
                      ),
                      CustomPaint(
                        size: layout.rect.size,
                        painter: TrainingPropPainter(
                          layout: localLayout,
                          props: trainingState!.props,
                        ),
                      ),
                    ],
                  ),
                ),
              ...sortedPlayers(boardState.players).map((player) {
                final anchor = layout.positionFor(player.x, player.y);
                final labelHeight =
                    player.label != null ? layout.tokenSize * 0.35 : 0.0;
                final totalHeight = layout.tokenSize + labelHeight;

                return Positioned(
                  left: anchor.dx - layout.tokenSize / 2,
                  top: anchor.dy - totalHeight / 2,
                  child: PlayerToken(
                    player: player,
                    size: layout.tokenSize,
                  ),
                );
              }),
              ...sortedTextNotes(boardState.textAnnotations).map((note) {
                final anchor = layout.positionFor(note.x, note.y);
                return Positioned(
                  left: anchor.dx,
                  top: anchor.dy,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 160),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      note.text,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
