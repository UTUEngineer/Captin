import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/tactical_board/domain/player.dart';
import 'package:captain/features/tactical_board/presentation/widgets/pitch_painter.dart';
import 'package:flutter/material.dart';

class GhostTrailLayer extends StatelessWidget {
  const GhostTrailLayer({
    super.key,
    required this.players,
    required this.ghostPositions,
    required this.layout,
  });

  final List<Player> players;
  final Map<String, Offset> ghostPositions;
  final PitchLayout layout;

  @override
  Widget build(BuildContext context) {
    if (ghostPositions.isEmpty) return const SizedBox.shrink();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        for (final entry in ghostPositions.entries)
          if (_playerFor(entry.key) case final player?)
            _GhostDot(
              player: player,
              position: entry.value,
              layout: layout,
            ),
      ],
    );
  }

  Player? _playerFor(String id) {
    for (final player in players) {
      if (player.id == id) return player;
    }
    return null;
  }
}

class _GhostDot extends StatelessWidget {
  const _GhostDot({
    required this.player,
    required this.position,
    required this.layout,
  });

  final Player player;
  final Offset position;
  final PitchLayout layout;

  @override
  Widget build(BuildContext context) {
    final anchor = layout.positionFor(position.dx, position.dy);
    final size = layout.tokenSize;

    final color = player.isHomeTeam
        ? AppColors.pitchGreenLight
        : AppColors.accentRed;

    return Positioned(
      left: anchor.dx - size / 2,
      top: anchor.dy - size / 2,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.3),
            border: Border.all(
              color: color.withValues(alpha: 0.45),
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
