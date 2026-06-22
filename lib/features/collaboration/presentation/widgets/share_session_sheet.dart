import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/collaboration/application/collaboration_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class ShareSessionSheet extends ConsumerWidget {
  const ShareSessionSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const ShareSessionSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(collaborationProvider).currentSession;
    if (session == null) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Share session',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              session.code,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 20),
            QrImageView(
              data: session.joinLink,
              size: 180,
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 16),
            SelectableText(
              session.joinLink,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: session.code));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Session code copied')),
                      );
                    },
                    icon: const Icon(Icons.copy_outlined),
                    label: const Text('Copy code'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      Share.share(
                        'Join my Captain tactical board session ${session.code}\n${session.joinLink}',
                      );
                    },
                    icon: const Icon(Icons.share_outlined),
                    label: const Text('Share link'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
