import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/core/router/app_router.dart';
import 'package:captain/features/onboarding/presentation/widgets/features_onboarding_page.dart';
import 'package:captain/features/onboarding/presentation/widgets/setup_onboarding_page.dart';
import 'package:captain/features/onboarding/presentation/widgets/welcome_onboarding_page.dart';
import 'package:captain/features/settings/application/app_preferences_notifier.dart';
import 'package:captain/features/settings/domain/app_language.dart';
import 'package:captain/features/settings/domain/app_preferences.dart';
import 'package:captain/features/settings/domain/coach_role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  final _displayNameController = TextEditingController();
  final _teamNameController = TextEditingController();
  var _pageIndex = 0;
  var _language = AppLanguage.arabic;
  var _selectedColor = teamColorSwatches.first;
  var _selectedRole = CoachRole.headCoach;
  var _isSaving = false;

  @override
  void dispose() {
    _pageController.dispose();
    _displayNameController.dispose();
    _teamNameController.dispose();
    super.dispose();
  }

  bool get _isArabic => _language == AppLanguage.arabic;

  Future<void> _nextPage() async {
    if (_pageIndex < 2) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
      return;
    }
    await _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final current =
        ref.read(appPreferencesProvider).value ?? const AppPreferences();
    await ref.read(appPreferencesProvider.notifier).savePreferences(
          current.copyWith(
            onboardingCompleted: true,
            language: _language,
            teamName: _teamNameController.text.trim(),
            teamColorValue: _selectedColor,
            coachRole: _selectedRole,
            displayName: _displayNameController.text.trim(),
            defaultSessionName: _displayNameController.text.trim(),
          ),
        );

    if (!mounted) return;
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
                child: Row(
                  children: [
                    if (_pageIndex > 0)
                      InkWell(
                        onTap: () => _pageController.previousPage(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutCubic,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Icon(
                            _isArabic
                                ? Icons.arrow_forward_ios
                                : Icons.arrow_back_ios_new,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 36),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          3,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _pageIndex == index ? 28 : 8,
                            height: 6,
                            decoration: BoxDecoration(
                              gradient: _pageIndex == index
                                  ? LinearGradient(
                                      colors: [
                                        AppColors.primary,
                                        Color(0xFF00B0FF),
                                      ],
                                    )
                                  : null,
                              color: _pageIndex == index
                                  ? null
                                  : Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(999),
                              boxShadow: _pageIndex == index
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.4),
                                        blurRadius: 8,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (_pageIndex < 2)
                      InkWell(
                        onTap: _nextPage,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primary
                                  .withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _isArabic ? 'التالي' : 'Next',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                _isArabic
                                    ? Icons.arrow_back
                                    : Icons.arrow_forward,
                                size: 14,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 36),
                  ],
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _pageIndex = index),
                  children: [
                    WelcomeOnboardingPage(
                      language: _language,
                      onLanguageChanged: (language) {
                        setState(() => _language = language);
                      },
                    ),
                    FeaturesOnboardingPage(isArabic: _isArabic),
                    SetupOnboardingPage(
                      isArabic: _isArabic,
                      displayNameController: _displayNameController,
                      teamNameController: _teamNameController,
                      selectedColor: _selectedColor,
                      selectedRole: _selectedRole,
                      onColorChanged: (color) {
                        setState(() => _selectedColor = color);
                      },
                      onRoleChanged: (role) {
                        setState(() => _selectedRole = role);
                      },
                      onComplete: _completeOnboarding,
                      isSaving: _isSaving,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
