import 'package:captain/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PlayerRatingsChart extends StatelessWidget {
  const PlayerRatingsChart({
    super.key,
    required this.ratings,
  });

  final Map<String, double> ratings;

  @override
  Widget build(BuildContext context) {
    if (ratings.isEmpty) return const SizedBox.shrink();

    final entries = ratings.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'تقييم اللاعبين',
          style: GoogleFonts.cairo(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 12),
        ...entries.map((entry) {
          final fraction = (entry.value / 10).clamp(0.0, 1.0);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Expanded(
                      child: Text(
                        entry.key,
                        style: GoogleFonts.cairo(color: AppColors.textPrimary),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                    Text(
                      entry.value.toStringAsFixed(1),
                      style: GoogleFonts.cairo(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: fraction,
                    minHeight: 8,
                    backgroundColor: AppColors.border,
                    color: const Color(0xFF00C853),
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
