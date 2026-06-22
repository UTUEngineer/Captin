import 'package:captain/core/router/app_router.dart';
import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/video_analysis/data/local_video_job_store.dart';
import 'package:captain/features/video_analysis/domain/pending_video_job.dart';
import 'package:captain/features/video_analysis/domain/video_processing_args.dart';
import 'package:captain/features/video_analysis/domain/video_processing_status_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PendingAnalysisBanner extends ConsumerWidget {
  const PendingAnalysisBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingVideoJobProvider);

    return pendingAsync.maybeWhen(
      data: (job) {
        if (job == null) return const SizedBox.shrink();
        return _PendingAnalysisCard(job: job);
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _PendingAnalysisCard extends StatelessWidget {
  const _PendingAnalysisCard({required this.job});

  final PendingVideoJob job;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Material(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            context.push(
              AppRoutes.analyzeVideoProcessing,
              extra: VideoProcessingArgs.resume(
                videoId: job.videoId,
                label: job.label,
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.accentOrange),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.hourglass_top_outlined,
                  color: AppColors.accentOrange,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Analysis in progress',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${job.label} · ${job.status.phaseLabel}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
