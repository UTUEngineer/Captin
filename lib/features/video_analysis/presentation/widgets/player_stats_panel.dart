import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/video_analysis/domain/analysis_result.dart';
import 'package:flutter/material.dart';

class PlayerStatsPanel extends StatelessWidget {
  const PlayerStatsPanel({
    super.key,
    required this.analytics,
    required this.onClose,
  });

  final PlayerAnalytics analytics;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Player T${analytics.trackId}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            _StatRow(
              label: 'Distance covered',
              value: '${analytics.distanceKm.toStringAsFixed(2)} km',
            ),
            _StatRow(
              label: 'Sprints',
              value: '${analytics.sprintCount}',
            ),
            _StatRow(
              label: 'Max speed',
              value: '${analytics.maxSpeedKmh.toStringAsFixed(1)} km/h',
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
