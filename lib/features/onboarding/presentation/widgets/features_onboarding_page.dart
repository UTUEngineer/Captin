import 'package:captain/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum OnboardingFeature {
  board(Icons.draw_outlined, 'ابنِ تكتيكك', 'Build your tactics', 'Tactical Board'),
  video(Icons.analytics_outlined, 'حلّل المباريات', 'Analyze matches', 'Video Analysis'),
  ai(Icons.auto_awesome, 'تقارير ذكية', 'Smart reports', 'AI Reports');

  const OnboardingFeature(
    this.icon,
    this.arabicTitle,
    this.englishTitle,
    this.englishSubtitle,
  );

  final IconData icon;
  final String arabicTitle;
  final String englishTitle;
  final String englishSubtitle;
}

class FeaturesOnboardingPage extends StatefulWidget {
  const FeaturesOnboardingPage({
    super.key,
    required this.isArabic,
  });

  final bool isArabic;

  @override
  State<FeaturesOnboardingPage> createState() => _FeaturesOnboardingPageState();
}

class _FeaturesOnboardingPageState extends State<FeaturesOnboardingPage>
    with SingleTickerProviderStateMixin {
  OnboardingFeature? _activeFeature;
  late final AnimationController _demoController;

  @override
  void initState() {
    super.initState();
    _demoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
  }

  @override
  void dispose() {
    _demoController.dispose();
    super.dispose();
  }

  Future<void> _playDemo(OnboardingFeature feature) async {
    setState(() => _activeFeature = feature);
    _demoController
      ..reset()
      ..forward();
    await Future<void>.delayed(const Duration(milliseconds: 2000));
    if (mounted) {
      setState(() => _activeFeature = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.isArabic ? 'ابنِ تكتيكك' : 'Build your tactics',
            style: GoogleFonts.cairo(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            textDirection: widget.isArabic ? TextDirection.rtl : TextDirection.ltr,
          ),
          const SizedBox(height: 8),
          Text(
            widget.isArabic
                ? 'اضغط على أي بطاقة لمشاهدة عرض سريع'
                : 'Tap a card for a quick preview',
            style: GoogleFonts.cairo(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              itemCount: OnboardingFeature.values.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final feature = OnboardingFeature.values[index];
                final isActive = _activeFeature == feature;
                return AnimatedSlide(
                  offset: Offset(0, isActive ? -0.02 : 0),
                  duration: const Duration(milliseconds: 300),
                  child: Material(
                    color: isActive
                        ? AppColors.pitchGreen.withValues(alpha: 0.25)
                        : AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _playDemo(feature),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(feature.icon, size: 32),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.isArabic
                                        ? feature.arabicTitle
                                        : feature.englishTitle,
                                    style: GoogleFonts.cairo(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    feature.englishSubtitle,
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            if (isActive)
                              FadeTransition(
                                opacity: _demoController,
                                child: const Icon(
                                  Icons.play_circle_outline,
                                  color: AppColors.pitchGreenLight,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
