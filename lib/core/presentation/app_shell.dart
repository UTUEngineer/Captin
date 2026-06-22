import 'package:captain/features/collaboration/application/collaboration_providers.dart';
import 'package:captain/features/settings/domain/app_preferences.dart';
import 'package:captain/features/tactical_board/application/board_autosave_controller.dart';
import 'package:captain/shared/widgets/offline_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppShell extends ConsumerWidget {
  const AppShell({
    super.key,
    required this.child,
    required this.prefs,
  });

  final Widget? child;
  final AppPreferences prefs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(boardAutosaveBootstrapProvider);
    final collaboration = ref.watch(collaborationProvider);
    final isOffline =
        collaboration.isInSession && !collaboration.isConnected;

    return Column(
      children: [
        OfflineBanner(isOffline: isOffline, isArabic: prefs.isArabic),
        Expanded(child: child ?? const SizedBox.shrink()),
      ],
    );
  }
}
