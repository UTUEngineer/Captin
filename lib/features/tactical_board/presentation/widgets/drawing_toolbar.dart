import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/tactical_board/application/tactical_board_notifier.dart';
import 'package:captain/features/tactical_board/domain/board_tool.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DrawingToolbar extends ConsumerWidget {
  const DrawingToolbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boardState = ref.watch(tacticalBoardProvider);
    final activeTool = boardState.activeTool;
    final showPalette = activeTool == BoardTool.zone ||
        activeTool == BoardTool.circle;

    return Material(
      color: AppColors.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _ToolButton(
                  icon: Icons.near_me_outlined,
                  label: 'Select',
                  selected: activeTool == BoardTool.select,
                  onTap: () => ref
                      .read(tacticalBoardProvider.notifier)
                      .setTool(BoardTool.select),
                ),
                _ToolButton(
                  icon: Icons.arrow_forward,
                  label: 'Pass',
                  selected: activeTool == BoardTool.passArrow,
                  onTap: () => ref
                      .read(tacticalBoardProvider.notifier)
                      .setTool(BoardTool.passArrow),
                ),
                _ToolButton(
                  icon: Icons.directions_run,
                  label: 'Run',
                  selected: activeTool == BoardTool.runArrow,
                  onTap: () => ref
                      .read(tacticalBoardProvider.notifier)
                      .setTool(BoardTool.runArrow),
                ),
                _ToolButton(
                  icon: Icons.arrow_upward,
                  label: 'Press',
                  selected: activeTool == BoardTool.pressArrow,
                  accent: AppColors.accentRed,
                  onTap: () => ref
                      .read(tacticalBoardProvider.notifier)
                      .setTool(BoardTool.pressArrow),
                ),
                _ToolButton(
                  icon: Icons.timeline,
                  label: 'Curve',
                  selected: activeTool == BoardTool.curvedRun,
                  accent: AppColors.accentOrange,
                  onTap: () => ref
                      .read(tacticalBoardProvider.notifier)
                      .setTool(BoardTool.curvedRun),
                ),
                _ToolButton(
                  icon: Icons.crop_square,
                  label: 'Zone',
                  selected: activeTool == BoardTool.zone,
                  onTap: () => ref
                      .read(tacticalBoardProvider.notifier)
                      .setTool(BoardTool.zone),
                ),
                _ToolButton(
                  icon: Icons.circle_outlined,
                  label: 'Circle',
                  selected: activeTool == BoardTool.circle,
                  onTap: () => ref
                      .read(tacticalBoardProvider.notifier)
                      .setTool(BoardTool.circle),
                ),
                _ToolButton(
                  icon: Icons.text_fields,
                  label: 'Text',
                  selected: activeTool == BoardTool.textNote,
                  onTap: () => ref
                      .read(tacticalBoardProvider.notifier)
                      .setTool(BoardTool.textNote),
                ),
                _ToolButton(
                  icon: Icons.auto_fix_off,
                  label: 'Eraser',
                  selected: activeTool == BoardTool.eraser,
                  onTap: () => ref
                      .read(tacticalBoardProvider.notifier)
                      .setTool(BoardTool.eraser),
                ),
              ],
            ),
          ),
          if (showPalette)
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, bottom: 10),
              child: Row(
                children: [
                  Text(
                    'Color',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 12),
                  ...zoneColorPalette.map((color) {
                    final selected =
                        boardState.selectedZoneColor == color.toARGB32();
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () => ref
                            .read(tacticalBoardProvider.notifier)
                            .setZoneColor(color.toARGB32()),
                        customBorder: const CircleBorder(),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected
                                  ? AppColors.textPrimary
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.accent,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final color = accent ?? AppColors.pitchGreenLight;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 64,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? color.withValues(alpha: 0.22)
                : AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? color : AppColors.border,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: selected ? color : AppColors.textSecondary),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
