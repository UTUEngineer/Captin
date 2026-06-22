import 'package:captain/core/router/app_router.dart';
import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/tactical_board/application/tactical_board_notifier.dart';
import 'package:captain/features/tactical_board/presentation/widgets/pitch_canvas.dart';
import 'package:captain/features/timeline/application/timeline_providers.dart';
import 'package:captain/features/timeline/presentation/timeline_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({
    super.key,
    this.matchId = defaultMatchId,
  });

  final String matchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(
      timelineControllerProvider(matchId).select((state) => state.activeSnapshot),
      (previous, next) {
        if (next == null) return;
        ref.read(tacticalBoardProvider.notifier).loadTemplate(
              next,
              recordHistory: false,
            );
      },
    );

    final timelineState = ref.watch(timelineControllerProvider(matchId));
    final boardState = ref.watch(tacticalBoardProvider);
    final size = MediaQuery.sizeOf(context);
    final timelineHeight = size.height * 0.3;
    final boardHeight = size.height * 0.7 - kToolbarHeight;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Timeline'),
        actions: [
          IconButton(
            tooltip: 'Open tactical board',
            onPressed: () => context.push(AppRoutes.tacticalBoard),
            icon: const Icon(Icons.open_in_new),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: timelineHeight,
            child: TimelineWidget(
              matchId: matchId,
              height: timelineHeight,
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: timelineState.activeSnapshot == null
                  ? Center(
                      key: const ValueKey('empty-board'),
                      child: Text(
                        'Scrub the timeline to preview linked boards',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    )
                  : PitchCanvas(
                      key: ValueKey(timelineState.activeSnapshot!.id),
                      boardState: boardState,
                      constraints: Size(size.width, boardHeight),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
