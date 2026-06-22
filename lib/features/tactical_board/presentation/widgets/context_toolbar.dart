import 'package:captain/core/services/haptic_service.dart';
import 'package:captain/core/services/haptic_patterns.dart';
import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/tactical_board/application/tactical_board_notifier.dart';
import 'package:captain/features/tactical_board/domain/board_element.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContextToolbar extends ConsumerWidget {
  const ContextToolbar({
    super.key,
    required this.anchor,
    required this.canvasSize,
  });

  final Offset anchor;
  final Size canvasSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boardState = ref.watch(tacticalBoardProvider);
    if (boardState.selectedElements.isEmpty) {
      return const SizedBox.shrink();
    }

    final supportsColor = boardState.selectedElements
        .any((key) => key.kind.supportsColor);
    final supportsRotation = boardState.selectedElements
        .any((key) => key.kind.supportsRotation);
    final anyLocked = boardState.selectedElements
        .any((key) => ref.read(tacticalBoardProvider.notifier).isLocked(key));

    const toolbarWidth = 320.0;
    const toolbarHeight = 52.0;
    var left = anchor.dx - toolbarWidth / 2;
    var top = anchor.dy - toolbarHeight - 16;

    if (top < 8) {
      top = anchor.dy + 24;
    }
    if (left < 8) left = 8;
    if (left + toolbarWidth > canvasSize.width - 8) {
      left = canvasSize.width - toolbarWidth - 8;
    }
    if (top + toolbarHeight > canvasSize.height - 8) {
      top = canvasSize.height - toolbarHeight - 8;
    }

    return Positioned(
      left: left,
      top: top,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.85, end: 1),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        builder: (context, scale, child) {
          return Opacity(
            opacity: scale.clamp(0.0, 1.0),
            child: Transform.scale(scale: scale, child: child),
          );
        },
        child: Material(
          color: AppColors.surfaceElevated.withValues(alpha: 0.96),
          elevation: 8,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: toolbarWidth,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ToolbarIconButton(
                  icon: Icons.delete_outline,
                  tooltip: 'Delete',
                  onPressed: () => _confirmDelete(context, ref),
                ),
                _ToolbarIconButton(
                  icon: Icons.copy_outlined,
                  tooltip: 'Duplicate',
                  onPressed: () => ref
                      .read(tacticalBoardProvider.notifier)
                      .duplicateSelected(),
                ),
                if (supportsColor)
                  _ToolbarIconButton(
                    icon: Icons.palette_outlined,
                    tooltip: 'Color',
                    onPressed: () => _pickColor(context, ref),
                  ),
                if (supportsRotation)
                  _ToolbarIconButton(
                    icon: Icons.rotate_right,
                    tooltip: 'Rotate handle on canvas',
                    onPressed: () {},
                  ),
                _ToolbarIconButton(
                  icon: anyLocked ? Icons.lock : Icons.lock_open_outlined,
                  tooltip: anyLocked ? 'Unlock' : 'Lock',
                  onPressed: () => ref
                      .read(tacticalBoardProvider.notifier)
                      .toggleSelectedLock(),
                ),
                _ToolbarIconButton(
                  icon: Icons.flip_to_front,
                  tooltip: 'Bring front',
                  onPressed: () => ref
                      .read(tacticalBoardProvider.notifier)
                      .bringSelectedToFront(),
                ),
                _ToolbarIconButton(
                  icon: Icons.flip_to_back,
                  tooltip: 'Send back',
                  onPressed: () => ref
                      .read(tacticalBoardProvider.notifier)
                      .sendSelectedToBack(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final boardState = ref.read(tacticalBoardProvider);
    final hasPlayer = boardState.selectedElements
        .any((key) => key.kind == BoardElementKind.player);
    final hasText = boardState.selectedElements
        .any((key) => key.kind == BoardElementKind.text);

    if (hasPlayer || hasText) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.surfaceElevated,
          title: const Text('Delete selected?'),
          content: const Text(
            'This will remove the selected player(s) or note(s) from the board.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    ref.read(tacticalBoardProvider.notifier).deleteSelected();
    deleteActionHaptic(ref.read(hapticServiceProvider));
  }

  Future<void> _pickColor(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: zoneColorPalette.map((color) {
                return InkWell(
                  onTap: () {
                    ref
                        .read(tacticalBoardProvider.notifier)
                        .setSelectedColor(color.toARGB32());
                    Navigator.of(context).pop();
                  },
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class _ToolbarIconButton extends StatelessWidget {
  const _ToolbarIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      tooltip: tooltip,
      icon: Icon(icon, size: 20),
      onPressed: onPressed,
    );
  }
}
