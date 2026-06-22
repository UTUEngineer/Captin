import 'package:captain/core/services/haptic_service.dart';
import 'package:captain/core/services/haptic_patterns.dart';
import 'package:captain/features/collaboration/application/collaboration_providers.dart';
import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/tactical_board/application/tactical_board_notifier.dart';
import 'package:captain/features/tactical_board/domain/formation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FormationPickerSheet extends ConsumerWidget {
  const FormationPickerSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const FormationPickerSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(
      tacticalBoardProvider.select((state) => state.selectedFormation),
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Select Formation',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Players animate into position when you switch formations.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ...FormationType.values.map((formation) {
              final isSelected = selected == formation;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.pitchGreenLight
                          : AppColors.border,
                    ),
                  ),
                  tileColor: isSelected
                      ? AppColors.pitchGreen.withValues(alpha: 0.25)
                      : AppColors.surface,
                  leading: Icon(
                    Icons.sports_soccer,
                    color: isSelected
                        ? AppColors.pitchGreenLight
                        : AppColors.textSecondary,
                  ),
                  title: Text(formation.label),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: AppColors.pitchGreenLight)
                      : null,
                  onTap: () {
                    ref
                        .read(tacticalBoardProvider.notifier)
                        .selectFormation(formation);
                    formationSnapHaptic(ref.read(hapticServiceProvider));
                    final boardState = ref.read(tacticalBoardProvider);
                    ref
                        .read(collaborationProvider.notifier)
                        .broadcastFormationChanged(
                          formation: formation,
                          players: boardState.players,
                        );
                    Navigator.of(context).pop();
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
