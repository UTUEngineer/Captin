import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/core/theme/arabic_text_styles.dart';
import 'package:flutter/material.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({
    super.key,
    required this.isOffline,
    this.isArabic = true,
  });

  final bool isOffline;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    if (!isOffline) return const SizedBox.shrink();

    return Material(
      color: AppColors.accentOrange.withValues(alpha: 0.92),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              const Icon(Icons.wifi_off, color: Colors.black, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isArabic
                      ? 'وضع عدم الاتصال — ستُزامَن التغييرات عند عودة الشبكة'
                      : 'Offline mode — changes will sync when you reconnect',
                  style: ArabicTextStyles.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
