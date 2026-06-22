import 'package:captain/core/router/app_router.dart';
import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/formations/application/tactic_library_providers.dart';
import 'package:captain/features/formations/domain/tactic_board_template.dart';
import 'package:captain/features/formations/presentation/widgets/board_thumbnail.dart';
import 'package:captain/features/formations/presentation/widgets/save_board_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FormationLibraryScreen extends ConsumerWidget {
  const FormationLibraryScreen({
    super.key,
    this.savedOnly = false,
  });

  final bool savedOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryAsync = ref.watch(tacticLibraryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(savedOnly ? 'Saved Boards' : 'Formation Library'),
      ),
      body: libraryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Failed to load library: $error')),
        data: (templates) {
          final items = savedOnly
              ? templates.where((template) => !template.isPreset).toList()
              : templates;

          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  savedOnly
                      ? 'No saved boards yet. Create a tactical board and tap Save.'
                      : 'No templates available.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.78,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final template = items[index];
              return _TemplateCard(
                template: template,
                onOpen: () => context.push(AppRoutes.tacticalBoard, extra: template),
                onRename: template.isPreset
                    ? null
                    : () => _renameTemplate(context, ref, template),
                onSwipeDelete: template.isPreset
                    ? null
                    : () => ref
                        .read(tacticLibraryProvider.notifier)
                        .deleteTemplate(template.id),
                onDelete: template.isPreset
                    ? null
                    : () => _deleteTemplate(context, ref, template),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _renameTemplate(
    BuildContext context,
    WidgetRef ref,
    TacticBoardTemplate template,
  ) async {
    final result = await showRenameBoardDialog(context, template);
    if (result == null) return;

    await ref.read(tacticLibraryProvider.notifier).renameTemplate(
          id: template.id,
          name: result.name,
          description: result.description,
        );
  }

  Future<void> _deleteTemplate(
    BuildContext context,
    WidgetRef ref,
    TacticBoardTemplate template,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: const Text('Delete template?'),
        content: Text('Delete "${template.name}" from your library?'),
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
    await ref.read(tacticLibraryProvider.notifier).deleteTemplate(template.id);
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({
    required this.template,
    required this.onOpen,
    this.onRename,
    this.onSwipeDelete,
    this.onDelete,
  });

  final TacticBoardTemplate template;
  final VoidCallback onOpen;
  final VoidCallback? onRename;
  final Future<void> Function()? onSwipeDelete;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final card = Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        onLongPress: onRename == null && onDelete == null
            ? null
            : () => _showActions(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return BoardThumbnail(
                    template: template,
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          template.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: template.badgeColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          template.badgeLabel,
                          style: TextStyle(
                            color: template.badgeColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    template.formattedDate,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (template.description != null &&
                      template.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      template.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (onSwipeDelete == null) return card;

    return Dismissible(
      key: ValueKey(template.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.accentRed,
        child: const Icon(Icons.delete_outline, color: AppColors.textPrimary),
      ),
      confirmDismiss: (_) async {
        await onSwipeDelete!();
        return true;
      },
      child: card,
    );
  }

  void _showActions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Rename'),
                onTap: () {
                  Navigator.of(context).pop();
                  onRename?.call();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.of(context).pop();
                  onDelete?.call();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
