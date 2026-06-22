import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/shape_simulation/application/shape_simulation_providers.dart';
import 'package:captain/features/shape_simulation/domain/simulation_mode.dart';
import 'package:captain/features/tactical_board/application/tactical_board_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class SimulationModePanel extends ConsumerWidget {
  const SimulationModePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final simulation = ref.watch(shapeSimulationProvider);
    final players = ref.watch(tacticalBoardProvider.select((s) => s.players));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome_motion_outlined,
                size: 18,
                color: simulation.isSimulationActive
                    ? AppColors.pitchGreenLight
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'محاكاة الشكل',
                style: GoogleFonts.cairo(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              FilterChip(
                label: Text(
                  simulation.isSimulationActive ? 'مفعّل' : 'إيقاف',
                  style: GoogleFonts.cairo(fontSize: 12),
                ),
                selected: simulation.isSimulationActive,
                showCheckmark: false,
                selectedColor: AppColors.pitchGreenLight.withValues(alpha: 0.25),
                side: BorderSide(
                  color: simulation.isSimulationActive
                      ? AppColors.pitchGreenLight
                      : AppColors.border,
                ),
                onSelected: (_) {
                  ref
                      .read(shapeSimulationProvider.notifier)
                      .toggleSimulation(players: players);
                },
              ),
            ],
          ),
          if (simulation.isSimulationActive) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: SimulationMode.values.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final mode = SimulationMode.values[index];
                  final selected = simulation.simulationMode == mode;

                  return ChoiceChip(
                    avatar: Icon(
                      mode.icon,
                      size: 16,
                      color: selected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                    label: Text(
                      mode.arabicLabel,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    selected: selected,
                    selectedColor:
                        AppColors.pitchGreenLight.withValues(alpha: 0.35),
                    backgroundColor: AppColors.surfaceElevated,
                    side: BorderSide(
                      color: selected
                          ? AppColors.pitchGreenLight
                          : AppColors.border,
                    ),
                    onSelected: (_) {
                      ref
                          .read(shapeSimulationProvider.notifier)
                          .setMode(mode);
                    },
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
