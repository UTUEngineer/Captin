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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        children: [
          // Tactical Pitch Simulation
          const Expanded(
            flex: 6,
            child: Center(
              child: OnboardingPitchAnimation(),
            ),
          ),
          const SizedBox(height: 16),

          // Pro League Aesthetic Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.sports_soccer,
                  color: AppColors.primary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  isArabic
                      ? 'المنصة التكتيكية الذكية'
                      : 'PRO TACTICAL PLATFORM',
                  style: GoogleFonts.cairo(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Main Headline
          Text(
            isArabic ? 'مرحباً بك في كابتن' : 'Welcome to Captain',
            style: GoogleFonts.cairo(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          ),
          const SizedBox(height: 8),

          // Subtitle
          Text(
            isArabic
                ? 'ارسم تشكيلاتك، حلّل خططك، وشارك رؤيتك مع فريقك بأحدث المعايير العالمية.'
                : 'Plan tactics, simulate dynamic play shapes, and share with your squad at top league standards.',
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          ),
          const SizedBox(height: 20),

          // Premium Language Switcher Card
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF161F1A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _LanguageTabItem(
                  label: 'العربية',
                  flag: '🇸🇦',
                  isSelected: isArabic,
                  onTap: () => onLanguageChanged(AppLanguage.arabic),
                ),
                _LanguageTabItem(
                  label: 'English',
                  flag: '🇬🇧',
                  isSelected: !isArabic,
                  onTap: () => onLanguageChanged(AppLanguage.english),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isArabic
                ? 'يمكنك تغيير اللغة لاحقاً من شاشة الإعدادات.'
                : 'You can change language anytime in Settings.',
            style: GoogleFonts.cairo(
              color: AppColors.textSecondary.withValues(alpha: 0.7),
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _LanguageTabItem extends StatelessWidget {
  const _LanguageTabItem({
    required this.label,
    required this.flag,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String flag;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(flag, style: const TextStyle(fontSize: 15)),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.cairo(
                color: isSelected ? Colors.black : AppColors.textSecondary,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
