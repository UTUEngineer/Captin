import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/core/theme/arabic_text_styles.dart';
import 'package:captain/features/tactical_board/domain/player.dart';
import 'package:flutter/material.dart';

class PlayerToken extends StatelessWidget {
  const PlayerToken({
    super.key,
    required this.player,
    required this.size,
    this.showLabel = true,
    this.isSelected = false,
    this.isDragging = false,
    this.elevatedShadow = false,
  });

  final Player player;
  final double size;
  final bool showLabel;
  final bool isSelected;
  final bool isDragging;
  final bool elevatedShadow;

  Color get _fillColor =>
      player.isHomeTeam ? AppColors.pitchGreenLight : AppColors.accentRed;

  Color get _borderColor {
    if (isSelected) return AppColors.accentOrange;
    return player.isHomeTeam ? AppColors.textPrimary : const Color(0xFFFFCDD2);
  }

  List<BoxShadow> get _shadows {
    if (isSelected) {
      return [
        BoxShadow(
          color: AppColors.accentOrange.withValues(alpha: 0.75),
          blurRadius: size * 0.55,
          spreadRadius: size * 0.04,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.35),
          blurRadius: size * 0.12,
          offset: Offset(0, size * 0.05),
        ),
      ];
    }

    if (isDragging || elevatedShadow) {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.5),
          blurRadius: size * 0.28,
          spreadRadius: size * 0.02,
          offset: Offset(0, size * 0.08),
        ),
      ];
    }

    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.35),
        blurRadius: size * 0.12,
        offset: Offset(0, size * 0.05),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final numberStyle = TextStyle(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.bold,
      fontSize: size * 0.38,
    );

    final scale = isDragging ? 1.15 : 1.0;

    return AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _fillColor,
              border: Border.all(
                color: _borderColor,
                width: isSelected ? 3 : 2,
              ),
              boxShadow: _shadows,
            ),
            alignment: Alignment.center,
            child: Text('${player.number}', style: numberStyle),
          ),
          if (showLabel && player.label != null && player.label!.isNotEmpty) ...[
            SizedBox(height: size * 0.08),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: size * 2.4),
              child: Text(
                ellipsizeLabel(player.label!),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: ArabicTextStyles.cairo(
                  fontSize: size * 0.22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ).copyWith(
                  shadows: const [Shadow(color: Colors.black, blurRadius: 4)],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
