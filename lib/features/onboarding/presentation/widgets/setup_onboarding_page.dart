import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/settings/domain/app_preferences.dart';
import 'package:captain/features/settings/domain/coach_role.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SetupOnboardingPage extends StatelessWidget {
  const SetupOnboardingPage({
    super.key,
    required this.isArabic,
    required this.teamNameController,
    required this.selectedColor,
    required this.selectedRole,
    required this.onColorChanged,
    required this.onRoleChanged,
    required this.onComplete,
    required this.isSaving,
  });

  final bool isArabic;
  final TextEditingController teamNameController;
  final int selectedColor;
  final CoachRole selectedRole;
  final ValueChanged<int> onColorChanged;
  final ValueChanged<CoachRole> onRoleChanged;
  final VoidCallback onComplete;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isArabic ? 'إعداد سريع' : 'Quick setup',
            style: GoogleFonts.cairo(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: teamNameController,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              labelText: isArabic ? 'اسم الفريق' : 'Team name',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isArabic ? 'لون الفريق' : 'Team color',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final color in teamColorSwatches)
                GestureDetector(
                  onTap: () => onColorChanged(color),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Color(color),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selectedColor == color
                            ? AppColors.textPrimary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            isArabic ? 'دورك' : 'Your role',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final role in CoachRole.values)
                ChoiceChip(
                  label: Text(
                    isArabic ? role.arabicLabel : role.englishLabel,
                  ),
                  selected: selectedRole == role,
                  onSelected: (_) => onRoleChanged(role),
                ),
            ],
          ),
          const Spacer(),
          FilledButton(
            onPressed: isSaving ? null : onComplete,
            child: isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    isArabic ? 'ابدأ الآن' : 'Get started',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
    );
  }
}
