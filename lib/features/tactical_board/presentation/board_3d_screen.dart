import 'package:captain/features/tactical_board/application/tactic_playback.dart';
import 'package:captain/features/tactical_board/presentation/widgets/board_3d_view.dart';
import 'package:captain/features/tactical_board/presentation/widgets/playback_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Full-screen 3D stadium view of the current tactical board with animated
/// GLB footballers.
class Board3DScreen extends ConsumerWidget {
  const Board3DScreen({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const Board3DScreen()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playback = ref.watch(tacticPlaybackProvider);
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      appBar: AppBar(
        title: const Text('3D Stadium · Animated players'),
        actions: [
          IconButton(
            tooltip: playback.isPlaying ? 'Pause' : 'Play tactic',
            icon: Icon(
              playback.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            ),
            onPressed: () {
              final n = ref.read(tacticPlaybackProvider.notifier);
              if (playback.isActive) {
                n.togglePlay();
              } else if (!n.play()) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Draw run / pass arrows on the tactical board to animate them here.',
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => Stack(
          children: [
            Positioned.fill(
              child: Board3DView(
                key: ValueKey(constraints.biggest),
                size: constraints.biggest,
              ),
            ),
            const Positioned(left: 0, right: 0, bottom: 0, child: PlaybackBar()),
          ],
        ),
      ),
    );
  }
}
