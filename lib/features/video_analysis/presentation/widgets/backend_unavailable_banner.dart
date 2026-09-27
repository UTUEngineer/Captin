import 'package:captain/core/theme/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class BackendUnavailableBanner extends StatelessWidget {
  const BackendUnavailableBanner({
    super.key,
    this.onRetry,
    this.backendUrl,
  });

  final VoidCallback? onRetry;
  final String? backendUrl;

  @override
  Widget build(BuildContext context) {
    final url = backendUrl?.trim();
    final lines = <String>[
      'Video analysis is unavailable right now. Manual tactical boards still work normally.',
      if (url != null && url.isNotEmpty)
        'Checking: $url/health',
      if (kDebugMode) ...[
        'Start the vision backend:',
        r'cd c:\captin-vision-backend\docker',
        'docker compose up --build',
        'Then set VISION_BACKEND_URL in .env or run:',
        r'flutter run --dart-define=VISION_BACKEND_URL=http://10.0.2.2:8000',
      ],
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.accentRed.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accentRed.withValues(alpha: 0.45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            color: AppColors.accentRed,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              lines.join('\n'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.4,
                    fontFamily: kDebugMode ? 'monospace' : null,
                    fontSize: kDebugMode ? 12 : null,
                  ),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}
