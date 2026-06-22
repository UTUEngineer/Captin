import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/collaboration/application/collaboration_providers.dart';
import 'package:captain/features/collaboration/presentation/widgets/join_session_dialog.dart';
import 'package:captain/features/collaboration/presentation/widgets/share_session_sheet.dart';
import 'package:captain/features/collaboration/presentation/widgets/start_session_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class CollaborationBar extends ConsumerWidget {
  const CollaborationBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collaboration = ref.watch(collaborationProvider);

    if (!collaboration.isConfigured) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: AppColors.surfaceElevated,
        child: Text(
          'Collaboration requires Supabase credentials in .env',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      );
    }

    if (!collaboration.isInSession) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            const Icon(Icons.groups_outlined, size: 18),
            const SizedBox(width: 8),
            Text(
              'Live collaboration',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            OutlinedButton(
              onPressed: () => JoinSessionDialog.show(context),
              child: const Text('Join'),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () => StartSessionDialog.show(context),
              child: const Text('Start session'),
            ),
          ],
        ),
      );
    }

    final session = collaboration.currentSession!;
    final latencyLabel = collaboration.latencyMs == null
        ? 'Live'
        : '${collaboration.latencyMs!.clamp(0, 9999)} ms';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: collaboration.isConnected
                      ? AppColors.pitchGreenLight
                      : AppColors.accentRed,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                session.code,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              IconButton(
                tooltip: 'Copy session code',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: session.code));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Session code copied')),
                  );
                },
                icon: const Icon(Icons.copy_outlined, size: 18),
              ),
              const SizedBox(width: 8),
              Text(
                latencyLabel,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const Spacer(),
              for (final collaborator in collaboration.collaborators)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: collaborator.color,
                    child: Text(
                      collaborator.name.characters.first.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Share session',
                onPressed: () => ShareSessionSheet.show(context),
                icon: const Icon(Icons.qr_code_2_outlined),
              ),
              IconButton(
                tooltip: 'Leave session',
                onPressed: () =>
                    ref.read(collaborationProvider.notifier).leaveSession(),
                icon: const Icon(Icons.logout_outlined),
              ),
            ],
          ),
          if (collaboration.isHost)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: const Text('Viewers only'),
              subtitle: const Text('Collaborators can watch but not edit'),
              value: session.viewersOnly,
              onChanged: (value) => ref
                  .read(collaborationProvider.notifier)
                  .setViewersOnly(value),
            ),
        ],
      ),
    );
  }
}
