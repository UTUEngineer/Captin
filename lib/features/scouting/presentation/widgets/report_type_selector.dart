import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/scouting/domain/report_type.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportTypeSelector extends StatelessWidget {
  const ReportTypeSelector({
    super.key,
    required this.selectedType,
    required this.onSelected,
  });

  final ReportType selectedType;
  final ValueChanged<ReportType> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ReportType.values.map((type) {
          final selected = type == selectedType;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: selected,
              label: Text(
                type.arabicLabel,
                style: GoogleFonts.cairo(
                  color: selected ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
              selectedColor: AppColors.primary.withValues(alpha: 0.25),
              checkmarkColor: AppColors.primary,
              side: BorderSide(
                color: selected ? AppColors.primary : AppColors.border,
              ),
              onSelected: (_) => onSelected(type),
            ),
          );
        }).toList(),
      ),
    );
  }
}
