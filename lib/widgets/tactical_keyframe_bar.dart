import 'package:captain/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../services/tactical_keyframe_engine.dart';

class TacticalKeyframeBar extends StatelessWidget {
  final TacticalKeyframeEngine engine;
  final VoidCallback onRecordStep;
  final VoidCallback onPlaySequence;
  final VoidCallback onClearSequence;

  const TacticalKeyframeBar({
    super.key,
    required this.engine,
    required this.onRecordStep,
    required this.onPlaySequence,
    required this.onClearSequence,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Record Step Button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: onRecordStep,
            icon: const Icon(Icons.add_a_photo, size: 16),
            label: const Text("تسجيل خطوة", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),

          // Keyframe thumbnails / steps count
          if (engine.keyframes.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text("لا توجد خطوات مسجلة", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            )
          else
            Row(
              children: engine.keyframes.map((kf) {
                final isCurrent = engine.currentStepIndex + 1 == kf.stepIndex;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isCurrent ? AppColors.info : AppColors.border,
                    borderRadius: BorderRadius.circular(8),
                    border: isCurrent ? Border.all(color: Colors.white, width: 1.5) : null,
                  ),
                  child: Text(
                    "F${kf.stepIndex}",
                    style: TextStyle(
                      color: isCurrent ? Colors.black : AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
          const SizedBox(width: 8),

          // Play Sequence Button
          IconButton(
            onPressed: onPlaySequence,
            icon: Icon(
              engine.isPlayingSequence ? Icons.pause_circle_filled : Icons.play_circle_fill,
              color: AppColors.info,
              size: 28,
            ),
            tooltip: "تشغيل التسلسل التكتيكي",
          ),

          // Clear Button
          IconButton(
            onPressed: onClearSequence,
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
            tooltip: "مسح الخطوات",
          ),
        ],
      ),
    );
  }
}
