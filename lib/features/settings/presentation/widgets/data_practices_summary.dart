import 'package:captain/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class DataPracticesSummary extends StatelessWidget {
  const DataPracticesSummary({super.key, required this.isArabic});

  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final bullets = isArabic
        ? const [
            'البيانات الأساسية تُخزَّن على جهازك — لا حاجة لحساب.',
            'فيديو المباراة يُرفع إلى خادم الرؤية الذي تضبطه (ليس إلى Anthropic)؛ تُحذف نسخ الخادم بعد التحليل، مع حد أقصى 7 أيام للرفعات غير المكتملة.',
            'تقارير الكشافة ترسل إحصاءات نصية فقط إلى Anthropic بمفتاحك المخزَّن بأمان على الجهاز.',
            'التعاون المباشر (اختياري) يستخدم Supabase Realtime — بدون بريد أو حساب.',
            'الدوريات (اختياري) تستخدم API-Football بمفتاحك.',
            'لا SDKs إعلانات أو تتبع.',
          ]
        : const [
            'Core data stays on your device — no account required.',
            'Match video uploads go to your configured vision backend (not Anthropic); server copies are deleted after analysis, with a 7-day cap for incomplete uploads.',
            'AI scouting sends text stats only to Anthropic, using your API key stored securely on device.',
            'Live collaboration (optional) uses Supabase Realtime — no email or account login.',
            'Leagues (optional) use API-Football with your API key.',
            'No ad or analytics tracking SDKs.',
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          isArabic ? 'ممارسات البيانات' : 'Data practices',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        for (final line in bullets)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(color: AppColors.textSecondary)),
                Expanded(
                  child: Text(
                    line,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.35,
                        ),
                    textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
