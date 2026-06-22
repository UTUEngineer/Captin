import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/training/application/training_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class TrainingModeBar extends ConsumerWidget {
  const TrainingModeBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final training = ref.watch(trainingProvider);
    final notifier = ref.read(trainingProvider.notifier);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.fitness_center_outlined,
            size: 18,
            color: training.isTrainingMode
                ? AppColors.pitchGreenLight
                : AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            'Training Mode',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          if (training.isTrainingMode &&
              training.pendingPropType != null) ...[
            const SizedBox(width: 12),
            Text(
              'Tap pitch to place ${training.pendingPropType!.label}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
          const Spacer(),
          Switch(
            value: training.isTrainingMode,
            onChanged: notifier.setTrainingMode,
          ),
        ],
      ),
    );
  }
}
