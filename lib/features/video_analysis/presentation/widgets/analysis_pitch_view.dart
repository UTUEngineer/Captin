import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/tactical_board/application/board_layout_helpers.dart';
import 'package:captain/features/tactical_board/domain/pitch_orientation.dart';
import 'package:captain/features/tactical_board/domain/pitch_style.dart';
import 'package:captain/features/tactical_board/domain/player.dart';
import 'package:captain/features/tactical_board/presentation/widgets/pitch_painter.dart';
import 'package:captain/features/tactical_board/presentation/widgets/player_token.dart';
import 'package:captain/features/video_analysis/domain/analysis_result.dart';
import 'package:captain/features/video_analysis/domain/analysis_result_mapper.dart';
import 'package:captain/features/video_analysis/presentation/widgets/heatmap_overlay_painter.dart';
import 'package:captain/features/video_analysis/presentation/widgets/possession_zones_overlay_painter.dart';
import 'package:flutter/material.dart';

class AnalysisPitchView extends StatelessWidget {
  const AnalysisPitchView({
    super.key,
    required this.players,
    required this.constraints,
    this.result,
    this.showHeatmap = false,
    this.showPossessionZones = false,
    this.selectedTrackId,
    this.onTrackSelected,
  });

  final List<Player> players;
  final Size constraints;
  final AnalysisResult? result;
  final bool showHeatmap;
  final bool showPossessionZones;
  final int? selectedTrackId;
  final ValueChanged<int>? onTrackSelected;

  @override
  Widget build(BuildContext context) {
    final layout = PitchLayout.compute(
      constraints: constraints,
      orientation: PitchOrientation.vertical,
    );

    final heatmap = result == null
        ? const <List<double>>[]
        : result!.aggregateHeatmap(trackId: selectedTrackId);

    return ColoredBox(
      color: AppColors.background,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fromRect(
            rect: layout.rect,
            child: CustomPaint(
              size: layout.rect.size,
              painter: PitchPainter(
                orientation: PitchOrientation.vertical,
                style: PitchStyle.striped,
              ),
            ),
          ),
          if (showPossessionZones && result?.possessionZones?.teamA != null)
            Positioned.fromRect(
              rect: layout.rect,
              child: CustomPaint(
                size: layout.rect.size,
                painter: PossessionZonesOverlayPainter(
                  zones: result!.possessionZones!.teamA!,
                ),
              ),
            ),
          if (showHeatmap && heatmap.isNotEmpty)
            Positioned.fromRect(
              rect: layout.rect,
              child: CustomPaint(
                size: layout.rect.size,
                painter: HeatmapOverlayPainter(grid: heatmap),
              ),
            ),
          ...sortedPlayers(players).map((player) {
            final trackId = int.tryParse(player.id.replaceFirst('track-', ''));
            final anchor = layout.positionFor(player.x, player.y);
            final labelHeight =
                player.label != null ? layout.tokenSize * 0.35 : 0.0;
            final totalHeight = layout.tokenSize + labelHeight;

            return Positioned(
              left: anchor.dx - layout.tokenSize / 2,
              top: anchor.dy - totalHeight / 2,
              child: GestureDetector(
                onTap: trackId == null ? null : () => onTrackSelected?.call(trackId),
                child: PlayerToken(
                  player: player,
                  size: layout.tokenSize,
                  isSelected: trackId != null && trackId == selectedTrackId,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
