import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/onboarding/presentation/widgets/onboarding_pitch_animation.dart';
import 'package:captain/features/settings/domain/app_language.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeOnboardingPage extends StatelessWidget {
  const WelcomeOnboardingPage({
    super.key,
    required this.language,
    required this.onLanguageChanged,
  });

  final AppLanguage language;
  final ValueChanged<AppLanguage> onLanguageChanged;

  @override
  Widget build(BuildContext context) {
    final isArabic = language == AppLanguage.arabic;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Expanded(child: OnboardingPitchAnimation()),
          Text(
            isArabic ? 'مرحباً بك في كابتن' : 'Welcome to Captain',
            style: GoogleFonts.cairo(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          ),
          const SizedBox(height: 12),
          Text(
            isArabic
                ? 'منصة تحليل تكتيكي للمدربين — ارسم، حلّل، وشارك أفكارك.'
                : 'Tactical analysis for coaches — draw, analyze, and share your ideas.',
            style: GoogleFonts.cairo(fontSize: 16),
            textAlign: TextAlign.center,
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          ),
          const SizedBox(height: 24),
          Text(
            isArabic ? 'اللغة' : 'Language',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          SegmentedButton<AppLanguage>(
            segments: AppLanguage.values
                .map(
                  (item) => ButtonSegment(
                    value: item,
                    label: Text(item.label),
                  ),
                )
                .toList(),
            selected: {language},
            onSelectionChanged: (value) => onLanguageChanged(value.first),
          ),
          const SizedBox(height: 12),
          Text(
            isArabic ? 'يمكنك تغيير اللغة لاحقاً من الإعدادات.' : 'You can change language later in Settings.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
