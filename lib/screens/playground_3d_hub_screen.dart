import 'package:captain/features/tactics/tactical_3d_pitch_board.dart';
import 'package:captain/screens/play_sequence_screen.dart';
import 'package:flutter/material.dart';

class Playground3DHubScreen extends StatefulWidget {
  const Playground3DHubScreen({super.key});

  @override
  State<Playground3DHubScreen> createState() => _Playground3DHubScreenState();
}

class _Playground3DHubScreenState extends State<Playground3DHubScreen> {
  String _activePOV = 'Overhead Orbit';
  String _activeFormation = '4-3-3';

  bool _isPlayingSequence = false;
  int _activeKeyframe = 1;
  int _totalKeyframes = 4;
  double _transitionDuration = 2.0; // 0.5s to 4.0s
  bool _useFullMatrix3DEngine = false;
  bool _useKeyframeEngine = false;

  @override
  Widget build(BuildContext context) {
    if (_useFullMatrix3DEngine) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('3D Matrix Projection Engine'),
          backgroundColor: const Color(0xFF111827),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => setState(() => _useFullMatrix3DEngine = false),
          ),
        ),
        body: const Tactical3DBoardScreen(),
      );
    }

    if (_useKeyframeEngine) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('3D Keyframe Sequence Engine'),
          backgroundColor: const Color(0xFF111827),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => setState(() => _useKeyframeEngine = false),
          ),
        ),
        body: const KeyframeSequencePlaygroundScreen(),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF030712),
      appBar: AppBar(
        title: const Text('Section 2: 3D Virtual Playground'),
        backgroundColor: const Color(0xFF111827),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.animation, color: Color(0xFF2979FF)),
            tooltip: 'Launch Keyframe Sequence Engine',
            onPressed: () => setState(() => _useKeyframeEngine = true),
          ),
          IconButton(
            icon: const Icon(Icons.threed_rotation, color: Color(0xFF00E676)),
            tooltip: 'Launch 3D Matrix Engine',
            onPressed: () => setState(() => _useFullMatrix3DEngine = true),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _activeFormation,
                dropdownColor: const Color(0xFF1F2937),
                icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF00E676)),
                items: ['4-3-3', '4-2-3-1', '3-5-2', '4-4-2', '5-3-2']
                    .map((f) => DropdownMenuItem(
                          value: f,
                          child: Text(
                            'Formation: $f',
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _activeFormation = val);
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Stack(
        children: [
          // 3D Canvas / Texture Renderer binds here
          Positioned.fill(
            child: _build3DPitchCanvas(),
          ),

          // Keyframe Sequence Track Bar (Top Floating)
          Positioned(
            top: 16,
            left: 20,
            right: 20,
            child: _buildKeyframeTrackBar(),
          ),

          // Bottom POV Controls
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildQuickFormationBar(),
                const SizedBox(height: 10),
                _buildPlaygroundControls(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _build3DPitchCanvas() {
    return Container(
      color: const Color(0xFF070C16),
      child: CustomPaint(
        painter: _Pitch3DRendererPainter(
          povMode: _activePOV,
          formation: _activeFormation,
          activeKeyframe: _activeKeyframe,
        ),
        child: Container(),
      ),
    );
  }

  Widget _buildKeyframeTrackBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111827).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(_isPlayingSequence ? Icons.pause_circle_filled : Icons.play_circle_filled),
                    iconSize: 32,
                    color: const Color(0xFF00E676),
                    onPressed: () {
                      setState(() => _isPlayingSequence = !_isPlayingSequence);
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Keyframe Sequence: Step $_activeKeyframe / $_totalKeyframes',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF00E676),
                  side: const BorderSide(color: Color(0xFF00E676)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Keyframe', style: TextStyle(fontSize: 12)),
                onPressed: () {
                  setState(() => _totalKeyframes++);
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Duration: ', style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text('${_transitionDuration.toStringAsFixed(1)}s',
                  style: const TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 12)),
              Expanded(
                child: Slider(
                  value: _transitionDuration,
                  min: 0.5,
                  max: 4.0,
                  divisions: 7,
                  activeColor: const Color(0xFF00E676),
                  inactiveColor: Colors.white12,
                  onChanged: (val) => setState(() => _transitionDuration = val),
                ),
              ),
              Row(
                children: List.generate(
                  _totalKeyframes,
                  (index) => GestureDetector(
                    onTap: () => setState(() => _activeKeyframe = index + 1),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _activeKeyframe == index + 1
                            ? const Color(0xFF00E676)
                            : const Color(0xFF1F2937),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'KF ${index + 1}',
                        style: TextStyle(
                          color: _activeKeyframe == index + 1 ? Colors.black : Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFormationBar() {
    final formations = ['4-3-3', '4-2-3-1', '3-5-2', '4-4-2', '5-3-2'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: formations.map((f) {
          final isSelected = _activeFormation == f;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(f),
              selected: isSelected,
              selectedColor: const Color(0xFF00E676),
              backgroundColor: const Color(0xFF1F2937),
              labelStyle: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              onSelected: (selected) {
                if (selected) setState(() => _activeFormation = f);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPlaygroundControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _povButton('Overhead Orbit', Icons.threed_rotation),
          _povButton('Tactical Press View', Icons.radar),
          _povButton('Be The Player (POV)', Icons.person_pin_circle),
        ],
      ),
    );
  }

  Widget _povButton(String mode, IconData icon) {
    final isSelected = _activePOV == mode;
    return TextButton.icon(
      style: TextButton.styleFrom(
        foregroundColor: isSelected ? const Color(0xFF00E676) : Colors.white60,
      ),
      icon: Icon(icon),
      label: Text(mode),
      onPressed: () => setState(() => _activePOV = mode),
    );
  }
}

class _Pitch3DRendererPainter extends CustomPainter {
  final String povMode;
  final String formation;
  final int activeKeyframe;

  _Pitch3DRendererPainter({
    required this.povMode,
    required this.formation,
    required this.activeKeyframe,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = const Color(0xFF070C16));

    final isEyeLevel = povMode.contains('Player');
    final isPressView = povMode.contains('Press');

    final pitchPaint = Paint()
      ..color = const Color(0xFF10B981).withValues(alpha: isEyeLevel ? 0.25 : 0.4)
      ..style = PaintingStyle.fill;

    // Perspective pitch grid simulation
    final path = Path();
    if (isEyeLevel) {
      // Eye-level POV (Y=1.75m looking down pitch)
      path.moveTo(size.width * 0.1, size.height * 0.4);
      path.lineTo(size.width * 0.9, size.height * 0.4);
      path.lineTo(size.width * 1.2, size.height);
      path.lineTo(-size.width * 0.2, size.height);
    } else if (isPressView) {
      // Overhead Press View
      path.moveTo(size.width * 0.2, size.height * 0.2);
      path.lineTo(size.width * 0.8, size.height * 0.2);
      path.lineTo(size.width * 0.95, size.height * 0.85);
      path.lineTo(size.width * 0.05, size.height * 0.85);
    } else {
      // Free Orbit
      path.moveTo(size.width * 0.15, size.height * 0.25);
      path.lineTo(size.width * 0.85, size.height * 0.25);
      path.lineTo(size.width, size.height * 0.8);
      path.lineTo(0, size.height * 0.8);
    }
    path.close();
    canvas.drawPath(path, pitchPaint);

    // Pitch Outlines & Center Circle
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(path, linePaint);

    // Render 3D Animated Player Nodes
    final players = _getFormationPositions(formation, size);
    for (int i = 0; i < players.length; i++) {
      final p = players[i];
      final color = i == 0 ? const Color(0xFFFFD600) : const Color(0xFF00E676);

      // Height offset for 3D standing effect
      final head = Offset(p.dx, p.dy - 12);

      // Shadow
      canvas.drawOval(
        Rect.fromCenter(center: p, width: 14, height: 6),
        Paint()..color = Colors.black45,
      );

      // Body vector stick/pin
      canvas.drawLine(p, head, Paint()..color = color..strokeWidth = 3);
      canvas.drawCircle(head, 7, Paint()..color = color);

      // Eyeline POV cone if Be The Player mode
      if (isEyeLevel && i == 9) { // Eye level ST
        final eyeCone = Path()
          ..moveTo(head.dx, head.dy)
          ..lineTo(head.dx - 40, head.dy - 100)
          ..lineTo(head.dx + 40, head.dy - 100)
          ..close();
        canvas.drawPath(
          eyeCone,
          Paint()..color = const Color(0xFF00E676).withValues(alpha: 0.15),
        );
      }
    }

    // Text Label overlay showing active POV status
    final textSpan = TextSpan(
      text: '3D CAM: $povMode (Eye Height: ${isEyeLevel ? "1.75m" : "15m"})\nActive Shape: $formation',
      style: const TextStyle(color: Colors.white54, fontSize: 12, height: 1.4),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(20, size.height * 0.22));
  }

  List<Offset> _getFormationPositions(String form, Size size) {
    final w = size.width;
    final h = size.height;
    final kfShift = (activeKeyframe - 1) * 8.0;

    if (form == '3-5-2') {
      return [
        Offset(w * 0.5, h * 0.7 + kfShift),
        Offset(w * 0.3, h * 0.58),
        Offset(w * 0.5, h * 0.58),
        Offset(w * 0.7, h * 0.58),
        Offset(w * 0.15, h * 0.45),
        Offset(w * 0.35, h * 0.45),
        Offset(w * 0.5, h * 0.45),
        Offset(w * 0.65, h * 0.45),
        Offset(w * 0.85, h * 0.45),
        Offset(w * 0.4, h * 0.32),
        Offset(w * 0.6, h * 0.32),
      ];
    } else if (form == '4-2-3-1') {
      return [
        Offset(w * 0.5, h * 0.7 + kfShift),
        Offset(w * 0.2, h * 0.6),
        Offset(w * 0.4, h * 0.6),
        Offset(w * 0.6, h * 0.6),
        Offset(w * 0.8, h * 0.6),
        Offset(w * 0.35, h * 0.48),
        Offset(w * 0.65, h * 0.48),
        Offset(w * 0.25, h * 0.38),
        Offset(w * 0.5, h * 0.38),
        Offset(w * 0.75, h * 0.38),
        Offset(w * 0.5, h * 0.28),
      ];
    }

    // Default 4-3-3
    return [
      Offset(w * 0.5, h * 0.7 + kfShift),
      Offset(w * 0.2, h * 0.6),
      Offset(w * 0.4, h * 0.6),
      Offset(w * 0.6, h * 0.6),
      Offset(w * 0.8, h * 0.6),
      Offset(w * 0.3, h * 0.46),
      Offset(w * 0.5, h * 0.46),
      Offset(w * 0.7, h * 0.46),
      Offset(w * 0.25, h * 0.32),
      Offset(w * 0.5, h * 0.30),
      Offset(w * 0.75, h * 0.32),
    ];
  }

  @override
  bool shouldRepaint(covariant _Pitch3DRendererPainter oldDelegate) => true;
}
