import 'package:captain/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class KeyFindingsSection extends StatelessWidget {
  const KeyFindingsSection({
    super.key,
    required this.findings,
  });

  final List<String> findings;

  static const _indicatorColors = [
    Color(0xFF00C853),
    AppColors.accentOrange,
    AppColors.accentRed,
    Color(0xFF29B6F6),
  ];

  @override
  Widget build(BuildContext context) {
    if (findings.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'أبرز الملاحظات',
          style: GoogleFonts.cairo(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 12),
        ...findings.asMap().entries.map((entry) {
          final color = _indicatorColors[entry.key % _indicatorColors.length];
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: TextDirection.rtl,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(top: 6, left: 10),
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                Expanded(
                  child: Text(
                    entry.value,
                    style: GoogleFonts.cairo(color: AppColors.textPrimary),
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
