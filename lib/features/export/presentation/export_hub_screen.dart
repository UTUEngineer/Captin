import 'package:captain/core/router/app_router.dart';
import 'package:captain/features/export/presentation/export_hub_sheet.dart';
import 'package:captain/features/settings/application/app_preferences_notifier.dart';
import 'package:captain/features/tactical_board/application/tactical_board_notifier.dart';
import 'package:captain/shared/widgets/empty_state_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ExportHubScreen extends ConsumerWidget {
  const ExportHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boardState = ref.watch(tacticalBoardProvider);
    final title = boardState.selectedFormation?.label ?? 'Tactical Board';
    final isArabic =
        ref.watch(appPreferencesProvider).value?.isArabic ?? true;

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'مركز التصدير' : 'Export Hub'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth.clamp(320.0, 900.0);
          final canvasSize = Size(width, width * 0.62);

          if (boardState.players.isEmpty) {
            return EmptyStateView(
              icon: Icons.file_upload_outlined,
              isArabic: isArabic,
              title: isArabic
                  ? 'لا يوجد لوحة تكتيكية بعد'
                  : 'No tactical board yet',
              subtitle: isArabic
                  ? 'افتح اللوحة التكتيكية واختر تشكيلة قبل التصدير.'
                  : 'Open the tactical board and set a formation before exporting.',
              actionLabel: isArabic ? 'فتح اللوحة' : 'Open board',
              onAction: () => context.push(AppRoutes.tacticalBoard),
            );
          }

          return ExportHubSheet(
            boardState: boardState,
            canvasSize: canvasSize,
            title: title,
            fullScreen: true,
          );
        },
      ),
    );
  }
}
