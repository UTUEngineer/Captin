import 'package:captain/core/router/app_router.dart';
import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/training/application/training_providers.dart';
import 'package:captain/features/training/domain/drill_path_style.dart';
import 'package:captain/features/training/domain/training_prop_type.dart';
import 'package:captain/features/training/domain/training_session.dart';
import 'package:captain/features/tactical_board/application/tactical_board_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

class TrainingToolbar extends ConsumerWidget {
  const TrainingToolbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final training = ref.watch(trainingProvider);
    final notifier = ref.read(trainingProvider.notifier);

    return Container(
      width: 72,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(left: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
            child: Text(
              'Training',
              style: GoogleFonts.cairo(
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              children: [
                for (final type in TrainingPropType.values)
                  _PropButton(
                    icon: type.icon,
                    label: type.label,
                    selected: training.pendingPropType == type,
                    onTap: () {
                      notifier.selectPropType(
                        training.pendingPropType == type ? null : type,
                      );
                    },
                  ),
                const Divider(height: 16),
                _PropButton(
                  icon: Icons.timeline,
                  label: 'Path',
                  selected: training.pathToolActive,
                  onTap: notifier.togglePathTool,
                ),
                if (training.pathToolActive) ...[
                  for (final style in DrillPathStyle.values)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: ChoiceChip(
                        label: Text(
                          style.label,
                          style: const TextStyle(fontSize: 10),
                        ),
                        selected: training.selectedPathStyle == style,
                        onSelected: (_) => notifier.setPathStyle(style),
                      ),
                    ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                IconButton(
                  tooltip: 'Drill templates',
                  onPressed: () => context.push(AppRoutes.trainingTemplates),
                  icon: const Icon(Icons.grid_view_rounded, size: 20),
                ),
                IconButton(
                  tooltip: 'Save session',
                  onPressed: () => _saveSession(context, ref),
                  icon: const Icon(Icons.save_outlined, size: 20),
                ),
                IconButton(
                  tooltip: 'Clear props',
                  onPressed: notifier.clearTrainingOverlay,
                  icon: const Icon(Icons.delete_sweep_outlined, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveSession(BuildContext context, WidgetRef ref) async {
    final repository =
        await ref.read(trainingSessionRepositoryProvider.future);
    final training = ref.read(trainingProvider);
    final boardState = ref.read(tacticalBoardProvider);
    final notifier = ref.read(trainingProvider.notifier);

    final session = TrainingSession(
      id: const Uuid().v4(),
      name: training.sessionName,
      notes: training.notes,
      props: training.props,
      paths: training.paths,
      boardTemplate: notifier.buildBoardTemplateFrom(boardState),
      updatedAt: DateTime.now(),
    );

    await repository.saveSession(session);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved "${session.name}"')),
      );
    }
  }
}

class _PropButton extends StatelessWidget {
  const _PropButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.pitchGreenLight.withValues(alpha: 0.22)
                : AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppColors.pitchGreenLight : AppColors.border,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 18,
                color: selected
                    ? AppColors.pitchGreenLight
                    : AppColors.textSecondary,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
