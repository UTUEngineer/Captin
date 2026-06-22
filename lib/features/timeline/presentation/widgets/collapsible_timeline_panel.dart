import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/timeline/application/timeline_providers.dart';
import 'package:captain/features/timeline/presentation/timeline_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CollapsibleTimelinePanel extends ConsumerStatefulWidget {
  const CollapsibleTimelinePanel({
    super.key,
    this.matchId = defaultMatchId,
  });

  final String matchId;

  @override
  ConsumerState<CollapsibleTimelinePanel> createState() =>
      _CollapsibleTimelinePanelState();
}

class _CollapsibleTimelinePanelState
    extends ConsumerState<CollapsibleTimelinePanel> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onVerticalDragUpdate: (details) {
                if (details.delta.dy < -4 && !_expanded) {
                  setState(() => _expanded = true);
                } else if (details.delta.dy > 4 && _expanded) {
                  setState(() => _expanded = false);
                }
              },
              onTap: () => setState(() => _expanded = !_expanded),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _expanded
                              ? Icons.keyboard_arrow_down
                              : Icons.keyboard_arrow_up,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _expanded ? 'Hide timeline' : 'Match timeline',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (_expanded)
              TimelineWidget(
                matchId: widget.matchId,
                height: 112,
              ),
          ],
        ),
      ),
    );
  }
}
