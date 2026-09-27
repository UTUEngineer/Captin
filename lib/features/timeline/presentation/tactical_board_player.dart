import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:captain/features/timeline/domain/tactical_timeline_engine.dart';

class TacticalBoardPlayer extends StatefulWidget {
  final List<TacticalKeyframe> keyframes;
  final Size pitchSize;

  const TacticalBoardPlayer({
    super.key,
    required this.keyframes,
    this.pitchSize = const Size(1050, 680), // Standard pitch ratio (105m x 68m)
  });

  @override
  State<TacticalBoardPlayer> createState() => _TacticalBoardPlayerState();
}

class _TacticalBoardPlayerState extends State<TacticalBoardPlayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _playbackController;
  Duration _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _totalDuration = widget.keyframes.isNotEmpty
        ? widget.keyframes.last.timestamp
        : const Duration(seconds: 5);

    _playbackController = AnimationController(
      vsync: this,
      duration: _totalDuration,
    );
  }

  @override
  void didUpdateWidget(covariant TacticalBoardPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.keyframes.isNotEmpty) {
      _totalDuration = widget.keyframes.last.timestamp;
      _playbackController.duration = _totalDuration;
    }
  }

  @override
  void dispose() {
    _playbackController.dispose();
    super.dispose();
  }

  void _togglePlayback() {
    if (_playbackController.isAnimating) {
      _playbackController.stop();
    } else {
      if (_playbackController.isCompleted) {
        _playbackController.reset();
      }
      _playbackController.forward();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. Interactive Pitch Rendering Layer
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: widget.pitchSize.width / widget.pitchSize.height,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A2F),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24, width: 2),
                ),
                child: AnimatedBuilder(
                  animation: _playbackController,
                  builder: (context, child) {
                    final currentDuration = _totalDuration * _playbackController.value;
                    final activeNodes = KeyframeInterpolationEngine.evaluate(
                      keyframes: widget.keyframes,
                      time: currentDuration,
                    );

                    return CustomPaint(
                      painter: TacticalScenePainter(nodes: activeNodes),
                      size: Size.infinite,
                    );
                  },
                ),
              ),
            ),
          ),
        ),

        // 2. Timeline Controls & Keyframe Markers
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  _playbackController.isAnimating ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
                onPressed: _togglePlayback,
              ),
              Expanded(
                child: AnimatedBuilder(
                  animation: _playbackController,
                  builder: (context, _) {
                    return SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                        activeTrackColor: const Color(0xFF10B981),
                        inactiveTrackColor: Colors.white12,
                      ),
                      child: Slider(
                        value: _playbackController.value.clamp(0.0, 1.0),
                        onChanged: (val) {
                          _playbackController.value = val;
                        },
                      ),
                    );
                  },
                ),
              ),
              Text(
                "${(_playbackController.value * _totalDuration.inSeconds).toStringAsFixed(1)}s / ${_totalDuration.inSeconds}s",
                style: const TextStyle(color: Colors.white70, fontFamily: 'monospace'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// CustomPainter rendering interpolated player circles, ball markers, and vectors.
class TacticalScenePainter extends CustomPainter {
  final Map<String, TacticalNodeState> nodes;

  TacticalScenePainter({required this.nodes});

  @override
  bool shouldRepaint(covariant TacticalScenePainter oldDelegate) => true;

  @override
  void paint(Canvas canvas, Size size) {
    final playerPaint = Paint()
      ..color = const Color(0xFF3B82F6)
      ..style = PaintingStyle.fill;

    final ballPaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (final node in nodes.values) {
      final screenX = node.position.dx * size.width;
      final screenY = node.position.dy * size.height;
      final center = Offset(screenX, screenY);

      if (node.id.startsWith('ball')) {
        canvas.drawCircle(center, 7.0, ballPaint);
        canvas.drawCircle(center, 7.0, strokePaint);
      } else {
        // Render Player Node
        canvas.drawCircle(center, 14.0, playerPaint);
        canvas.drawCircle(center, 14.0, strokePaint);

        // Direction Indicator Needle
        final dirX = center.dx + math.cos(node.orientation) * 20.0;
        final dirY = center.dy + math.sin(node.orientation) * 20.0;
        canvas.drawLine(center, Offset(dirX, dirY), strokePaint);
      }
    }
  }
}
