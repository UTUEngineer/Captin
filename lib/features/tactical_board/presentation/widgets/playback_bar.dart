import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/settings/application/app_preferences_notifier.dart';
import 'package:captain/features/tactical_board/application/tactic_playback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Transport controls shown while a tactic is being played back.
class PlaybackBar extends ConsumerWidget {
  const PlaybackBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playback = ref.watch(tacticPlaybackProvider);
    final notifier = ref.read(tacticPlaybackProvider.notifier);
    final arabic = ref.watch(appPreferencesProvider).value?.isArabic ?? false;
    final total = playback.playback?.duration ?? 1;
    final step = playback.frame?.step ?? 1;

    return AnimatedSlide(
      offset: playback.isActive ? Offset.zero : const Offset(0, 1.4),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: playback.isActive ? 1 : 0,
        duration: const Duration(milliseconds: 200),
        child: IgnorePointer(
          ignoring: !playback.isActive,
          child: Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.fromLTRB(6, 4, 10, 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated.withValues(alpha: 0.97),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: const [
                BoxShadow(color: Color(0x4D000000), blurRadius: 18),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  tooltip: playback.isPlaying ? 'Pause' : 'Play',
                  onPressed: notifier.togglePlay,
                  icon: Icon(
                    playback.isPlaying
                        ? Icons.pause_circle_filled_rounded
                        : Icons.play_circle_fill_rounded,
                    size: 34,
                    color: AppColors.primary,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    arabic
                        ? 'مرحلة $step/${total.round()}'
                        : 'Phase $step/${total.round()}',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Expanded(
                  child: Slider(
                    value: playback.time.clamp(0, total),
                    max: total,
                    divisions: (total * 20).round().clamp(1, 1000),
                    onChanged: (v) {
                      notifier.pause();
                      notifier.seek(v);
                    },
                  ),
                ),
                PopupMenuButton<double>(
                  tooltip: 'Speed',
                  initialValue: playback.speed,
                  onSelected: notifier.setSpeed,
                  itemBuilder: (context) => [
                    for (final s in const [0.5, 1.0, 1.5, 2.0])
                      PopupMenuItem(value: s, child: Text('${s}x')),
                  ],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      '${playback.speed}x',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: arabic ? 'تكرار' : 'Loop',
                  onPressed: notifier.toggleLoop,
                  icon: Icon(
                    Icons.repeat_rounded,
                    color: playback.loop
                        ? AppColors.primary
                        : AppColors.textMuted,
                  ),
                ),
                IconButton(
                  tooltip: arabic ? 'اعتماد المواقع النهائية' : 'Keep end positions',
                  onPressed: notifier.applyResult,
                  icon: Icon(Icons.check_circle_outline_rounded,
                      color: AppColors.textSecondary),
                ),
                IconButton(
                  tooltip: arabic ? 'إغلاق' : 'Stop',
                  onPressed: notifier.stop,
                  icon: Icon(Icons.close_rounded, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
