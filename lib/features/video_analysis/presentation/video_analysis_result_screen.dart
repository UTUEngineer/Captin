import 'package:captain/core/router/app_router.dart';
import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/tactical_board/application/tactical_board_notifier.dart';
import 'package:captain/features/video_analysis/application/analysis_result_notifier.dart';
import 'package:captain/features/video_analysis/application/analysis_result_providers.dart';
import 'package:captain/features/video_analysis/domain/analysis_result_mapper.dart';
import 'package:captain/features/video_analysis/presentation/widgets/analysis_pitch_view.dart';
import 'package:captain/features/video_analysis/presentation/widgets/player_stats_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class VideoAnalysisResultScreen extends ConsumerWidget {
  const VideoAnalysisResultScreen({
    super.key,
    required this.videoId,
  });

  final String videoId;

  String _formatTime(double seconds) {
    final total = seconds.floor();
    final minutes = total ~/ 60;
    final remaining = total % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${remaining.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(analysisResultProvider(videoId));
    final notifier = ref.read(analysisResultProvider(videoId).notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis result'),
        actions: [
          if (state.result != null) ...[
            TextButton.icon(
              onPressed: () =>
                  context.push(AppRoutes.scoutingReportForVideo(videoId)),
              icon: const Icon(Icons.analytics_outlined),
              label: const Text('Scouting'),
            ),
            TextButton.icon(
              onPressed: () {
                final players = state.result!.playersAt(
                  state.currentTimeSeconds,
                );
                ref
                    .read(tacticalBoardProvider.notifier)
                    .loadAnalysisSnapshot(players);
                context.push(AppRoutes.tacticalBoard);
              },
              icon: const Icon(Icons.draw_outlined),
              label: const Text('Open as board'),
            ),
          ],
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null
              ? _ErrorBody(
                  message: state.errorMessage!,
                  onRetry: notifier.load,
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (state.loadedFromCache)
                      const _OfflineCacheBanner(),
                    if (state.isRefreshing)
                      const LinearProgressIndicator(minHeight: 2),
                    Expanded(
                      child: _ResultBody(
                        state: state,
                        formatTime: _formatTime,
                        onSeek: notifier.setCurrentTime,
                        onTogglePlayback: notifier.togglePlayback,
                        onToggleHeatmap: notifier.toggleHeatmap,
                        onTogglePossession: notifier.togglePossessionZones,
                        onToggleStats: notifier.toggleStatsPanel,
                        onSelectTrack: notifier.selectTrack,
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _ResultBody extends StatelessWidget {
  const _ResultBody({
    required this.state,
    required this.formatTime,
    required this.onSeek,
    required this.onTogglePlayback,
    required this.onToggleHeatmap,
    required this.onTogglePossession,
    required this.onToggleStats,
    required this.onSelectTrack,
  });

  final AnalysisResultState state;
  final String Function(double seconds) formatTime;
  final ValueChanged<double> onSeek;
  final VoidCallback onTogglePlayback;
  final VoidCallback onToggleHeatmap;
  final VoidCallback onTogglePossession;
  final VoidCallback onToggleStats;
  final ValueChanged<int?> onSelectTrack;

  @override
  Widget build(BuildContext context) {
    final result = state.result!;
    final players = result.playersAt(
      state.currentTimeSeconds,
      highlightTrackId: state.selectedTrackId,
    );
    final selectedAnalytics = state.selectedTrackId == null
        ? null
        : result.analyticsFor(state.selectedTrackId!);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: const Text('Heatmap'),
                selected: state.showHeatmap,
                onSelected: (_) => onToggleHeatmap(),
              ),
              FilterChip(
                label: const Text('Player stats'),
                selected: state.showStatsPanel,
                onSelected: (_) => onToggleStats(),
              ),
              FilterChip(
                label: const Text('Possession zones'),
                selected: state.showPossessionZones,
                onSelected: (_) => onTogglePossession(),
              ),
            ],
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  AnalysisPitchView(
                    players: players,
                    constraints: constraints.biggest,
                    result: result,
                    showHeatmap: state.showHeatmap,
                    showPossessionZones: state.showPossessionZones,
                    selectedTrackId: state.selectedTrackId,
                    onTrackSelected: onSelectTrack,
                  ),
                  if (state.showStatsPanel &&
                      selectedAnalytics != null &&
                      constraints.maxWidth >= 720)
                    Positioned(
                      right: 16,
                      top: 16,
                      width: 280,
                      child: PlayerStatsPanel(
                        analytics: selectedAnalytics,
                        onClose: () => onSelectTrack(null),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        if (state.showStatsPanel &&
            selectedAnalytics != null &&
            MediaQuery.sizeOf(context).width < 720)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: PlayerStatsPanel(
              analytics: selectedAnalytics,
              onClose: () => onSelectTrack(null),
            ),
          ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: onTogglePlayback,
                      icon: Icon(
                        state.isPlaying ? Icons.pause : Icons.play_arrow,
                      ),
                    ),
                    Text(formatTime(state.currentTimeSeconds)),
                    const Spacer(),
                    Text(formatTime(result.durationSeconds)),
                  ],
                ),
                Slider(
                  value: state.currentTimeSeconds
                      .clamp(0, result.durationSeconds),
                  max: result.durationSeconds <= 0 ? 1 : result.durationSeconds,
                  activeColor: AppColors.accentOrange,
                  onChanged: onSeek,
                ),
                Text(
                  state.showStatsPanel && state.selectedTrackId == null
                      ? 'Tap a player on the pitch to view stats.'
                      : 'Scrub the timeline to replay tracked movement.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OfflineCacheBanner extends StatelessWidget {
  const _OfflineCacheBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppColors.surfaceElevated,
      child: Row(
        children: [
          const Icon(
            Icons.offline_pin_outlined,
            size: 18,
            color: AppColors.accentOrange,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Showing saved analysis from this device.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.accentRed, size: 48),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
