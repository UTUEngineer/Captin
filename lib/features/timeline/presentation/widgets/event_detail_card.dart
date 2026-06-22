import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/timeline/domain/timeline_event.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EventDetailCard extends StatelessWidget {
  const EventDetailCard({
    super.key,
    required this.event,
    required this.onClose,
    this.onOpenBoard,
  });

  final TimelineEvent event;
  final VoidCallback onClose;
  final VoidCallback? onOpenBoard;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      color: AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(event.type.icon, color: event.type.color, size: 18),
                const SizedBox(width: 8),
                Text(
                  '${event.formattedTime} • ${event.type.arabicLabel}',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close, size: 18),
                ),
              ],
            ),
            if (event.playerName != null && event.playerName!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                event.playerName!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            if (event.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                event.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
            if (onOpenBoard != null) ...[
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: onOpenBoard,
                icon: const Icon(Icons.draw_outlined, size: 18),
                label: const Text('Open Tactical Board'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
