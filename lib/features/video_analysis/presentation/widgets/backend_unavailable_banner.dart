import 'package:captain/core/theme/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class BackendUnavailableBanner extends StatelessWidget {
  const BackendUnavailableBanner({
    super.key,
    this.onRetry,
    this.backendUrl,
    this.isArabic = false,
  });

  final VoidCallback? onRetry;
  final String? backendUrl;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final url = backendUrl?.trim();
    final message = isArabic
        ? 'خدمة تحليل الفيديو غير متوفرة حالياً. يمكنك استخدام لوحات التكتيك اليدوية كالمعتاد.'
        : 'Video analysis is unavailable right now. Manual tactical boards still work normally.';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.accentRed.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accentRed.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
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
                  message,
                  textDirection:
                      isArabic ? TextDirection.rtl : TextDirection.ltr,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                ),
              ),
              if (onRetry != null) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: onRetry,
                  child: Text(isArabic ? 'إعادة المحاولة' : 'Retry'),
                ),
              ],
            ],
          ),
          if (kDebugMode) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.accentRed.withValues(alpha: 0.25),
                ),
              ),
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (url != null && url.isNotEmpty)
                      SelectableText(
                        'Checking: $url/health',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    const SizedBox(height: 6),
                    SelectableText(
                      '# Start vision backend (Python):\n'
                      r'cd c:\captin-vision-backend'
                      '\n'
                      r'.\venv\Scripts\python.exe -m uvicorn app.main:app --port 8000'
                      '\n\n'
                      '# Or with Docker:\n'
                      r'cd c:\captin-vision-backend\docker && docker compose up --build',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: AppColors.textPrimary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
