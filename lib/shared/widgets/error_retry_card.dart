import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/core/theme/arabic_text_styles.dart';
import 'package:flutter/material.dart';

class ErrorRetryCard extends StatelessWidget {
  const ErrorRetryCard({
    super.key,
    required this.message,
    required this.onRetry,
    this.isArabic = true,
  });

  final String message;
  final VoidCallback onRetry;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.accentRed, size: 36),
            const SizedBox(height: 12),
            Text(
              message,
              style: ArabicTextStyles.cairo(fontSize: 15),
              textAlign: TextAlign.center,
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(isArabic ? 'إعادة المحاولة' : 'Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
