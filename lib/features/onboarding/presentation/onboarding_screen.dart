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
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    if (_pageIndex > 0)
                      IconButton(
                        onPressed: () => _pageController.previousPage(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutCubic,
                        ),
                        icon: Icon(
                          _isArabic
                              ? Icons.arrow_forward_ios
                              : Icons.arrow_back_ios_new,
                        ),
                      )
                    else
                      const SizedBox(width: 48),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          3,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _pageIndex == index ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _pageIndex == index
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).dividerColor,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _pageIndex == 2 ? null : _nextPage,
                      child: Text(_isArabic ? 'التالي' : 'Next'),
                    ),
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
