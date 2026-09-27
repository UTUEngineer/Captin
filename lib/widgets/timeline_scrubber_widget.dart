import 'package:flutter/material.dart';

class TimelineScrubberWidget extends StatefulWidget {
  final int totalFrames;
  final int currentFrame;
  final double fps;
  final bool isPlaying;
  final double playbackSpeed;
  final ValueChanged<int> onSeekToFrame;
  final VoidCallback onTogglePlayPause;
  final ValueChanged<double> onSpeedChanged;

  const TimelineScrubberWidget({
    super.key,
    required this.totalFrames,
    required this.currentFrame,
    this.fps = 25.0,
    required this.isPlaying,
    this.playbackSpeed = 1.0,
    required this.onSeekToFrame,
    required this.onTogglePlayPause,
    required this.onSpeedChanged,
  });

  @override
  State<TimelineScrubberWidget> createState() => _TimelineScrubberWidgetState();
}

class _TimelineScrubberWidgetState extends State<TimelineScrubberWidget> {
  // تحويل رقم الإطار (Frame) إلى صيغة وقت (MM:SS)
  String _formatTimestamp(int frameIdx) {
    if (widget.fps <= 0) return "00:00";
    final totalSeconds = (frameIdx / widget.fps).floor();
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final double maxSliderValue = widget.totalFrames > 0 ? (widget.totalFrames - 1).toDouble() : 1.0;
    final double currentSliderValue = widget.currentFrame.toDouble().clamp(0.0, maxSliderValue);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.85), // Dark Slate Glass
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // A. السلايدر الزمني وعرض الإطارات (Main Slider Row)
          Row(
            children: [
              // زر التشغيل / الإيقاف المؤقت (Play/Pause Button)
              IconButton(
                icon: Icon(
                  widget.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                  color: const Color(0xFF38BDF8), // Sky Blue Accent
                  size: 36,
                ),
                onPressed: widget.onTogglePlayPause,
              ),

              // العداد الزمني الحقيقي (Timestamp & Frame Counter)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "${_formatTimestamp(widget.currentFrame)} / ${_formatTimestamp(widget.totalFrames)}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // السلايدر التفاعلي للجري والتقديم الفريمي
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFF38BDF8),
                    inactiveTrackColor: Colors.white24,
                    trackHeight: 4.0,
                    thumbColor: Colors.white,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
                    overlayColor: const Color(0xFF38BDF8).withValues(alpha: 0.3),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),
                  ),
                  child: Slider(
                    value: currentSliderValue,
                    min: 0.0,
                    max: maxSliderValue,
                    onChanged: (double value) {
                      widget.onSeekToFrame(value.round());
                    },
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // قائمة اختيار سرعة العرض (Speed Selector Menu)
              PopupMenuButton<double>(
                initialValue: widget.playbackSpeed,
                tooltip: "سرعة العرض",
                onSelected: widget.onSpeedChanged,
                color: const Color(0xFF1E293B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Text(
                    "${widget.playbackSpeed}x",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                itemBuilder: (context) => [
                  _buildSpeedMenuItem(0.25),
                  _buildSpeedMenuItem(0.5),
                  _buildSpeedMenuItem(1.0),
                  _buildSpeedMenuItem(1.5),
                  _buildSpeedMenuItem(2.0),
                ],
              ),
            ],
          ),

          // B. أزرار التحكم الفريمي السريع (Frame-by-Frame Controls)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // إرجاع 5 ثوانٍ
              _buildStepButton(
                icon: Icons.replay_5,
                tooltip: "إرجاع 5 ثوانٍ",
                onPressed: () {
                  final target = (widget.currentFrame - (widget.fps * 5)).round();
                  widget.onSeekToFrame(target.clamp(0, widget.totalFrames - 1));
                },
              ),

              // إطار واحد للخلف (Frame Step Back)
              _buildStepButton(
                icon: Icons.skip_previous_outlined,
                tooltip: "الإطار السابق",
                onPressed: () {
                  if (widget.currentFrame > 0) {
                    widget.onSeekToFrame(widget.currentFrame - 1);
                  }
                },
              ),

              const SizedBox(width: 16),

              // إطار واحد للأمام (Frame Step Forward)
              _buildStepButton(
                icon: Icons.skip_next_outlined,
                tooltip: "الإطار التالي",
                onPressed: () {
                  if (widget.currentFrame < widget.totalFrames - 1) {
                    widget.onSeekToFrame(widget.currentFrame + 1);
                  }
                },
              ),

              // تقديم 5 ثوانٍ
              _buildStepButton(
                icon: Icons.forward_5,
                tooltip: "تقديم 5 ثوانٍ",
                onPressed: () {
                  final target = (widget.currentFrame + (widget.fps * 5)).round();
                  widget.onSeekToFrame(target.clamp(0, widget.totalFrames - 1));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  PopupMenuItem<double> _buildSpeedMenuItem(double speed) {
    return PopupMenuItem<double>(
      value: speed,
      child: Text(
        "${speed}x",
        style: const TextStyle(color: Colors.white, fontSize: 13),
      ),
    );
  }

  Widget _buildStepButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Icon(icon, color: Colors.white70, size: 20),
      tooltip: tooltip,
      onPressed: onPressed,
      splashRadius: 18,
    );
  }
}
