import 'dart:math' as math;
import 'package:flutter/material.dart';

class TacticsHubScreen extends StatefulWidget {
  const TacticsHubScreen({super.key});

  @override
  State<TacticsHubScreen> createState() => _TacticsHubScreenState();
}

class _TacticsHubScreenState extends State<TacticsHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0C10),
      appBar: AppBar(
        title: const Text('Section 1: Tactics & Analysis'),
        backgroundColor: const Color(0xFF161B22),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF2979FF),
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(icon: Icon(Icons.draw), text: 'Tactical Board & Drills'),
            Tab(icon: Icon(Icons.video_library), text: 'Match Video Sync'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _InteractiveBoardView(),
          _VideoSyncView(),
        ],
      ),
    );
  }
}

enum TacticalTool { select, passVector, playerRun, pressingZone, cone, hurdle, miniGoal, eraser }

class TacticalNode {
  final String id;
  final String label;
  final String team; // 'home' | 'away'
  Offset position; // Normalized 0..1 coordinates on pitch

  TacticalNode({
    required this.id,
    required this.label,
    required this.team,
    required this.position,
  });
}

class TacticalPath {
  final TacticalTool tool;
  final List<Offset> points;
  final Color color;

  TacticalPath({
    required this.tool,
    required this.points,
    required this.color,
  });
}

class TacticalEquipment {
  final TacticalTool tool;
  final Offset position;

  TacticalEquipment({
    required this.tool,
    required this.position,
  });
}

class _InteractiveBoardView extends StatefulWidget {
  const _InteractiveBoardView();

  @override
  State<_InteractiveBoardView> createState() => _InteractiveBoardViewState();
}

class _InteractiveBoardViewState extends State<_InteractiveBoardView> {
  TacticalTool _selectedTool = TacticalTool.select;
  Color _currentColor = const Color(0xFF2979FF);

  late List<TacticalNode> _nodes;
  final List<TacticalPath> _paths = [];
  final List<TacticalEquipment> _equipment = [];
  TacticalPath? _activePath;
  int? _draggedNodeIndex;

  Offset _ballPosition = const Offset(0.5, 0.5);
  bool _isDraggingBall = false;

  @override
  void initState() {
    super.initState();
    _initDefaultLineup();
  }

  void _initDefaultLineup() {
    // 11 Home Players (Blue)
    final home = [
      Offset(0.08, 0.50), // GK
      Offset(0.22, 0.15), // LB
      Offset(0.20, 0.38), // LCB
      Offset(0.20, 0.62), // RCB
      Offset(0.22, 0.85), // RB
      Offset(0.35, 0.50), // DM
      Offset(0.42, 0.30), // LCM
      Offset(0.42, 0.70), // RCM
      Offset(0.48, 0.18), // LW
      Offset(0.49, 0.50), // ST
      Offset(0.48, 0.82), // RW
    ];

    // 11 Away Players (Red)
    final away = [
      Offset(0.92, 0.50), // GK
      Offset(0.78, 0.85), // LB
      Offset(0.80, 0.62), // LCB
      Offset(0.80, 0.38), // RCB
      Offset(0.78, 0.15), // RB
      Offset(0.65, 0.50), // DM
      Offset(0.58, 0.70), // LCM
      Offset(0.58, 0.30), // RCM
      Offset(0.52, 0.82), // LW
      Offset(0.51, 0.50), // ST
      Offset(0.52, 0.18), // RW
    ];

    _nodes = [
      for (int i = 0; i < home.length; i++)
        TacticalNode(
          id: 'h_$i',
          label: i == 0 ? 'GK' : '${i + 1}',
          team: 'home',
          position: home[i],
        ),
      for (int i = 0; i < away.length; i++)
        TacticalNode(
          id: 'a_$i',
          label: i == 0 ? 'GK' : '${i + 1}',
          team: 'away',
          position: away[i],
        ),
    ];
  }

  void _clearCanvas() {
    setState(() {
      _paths.clear();
      _equipment.clear();
      _activePath = null;
    });
  }

  void _resetPositions() {
    setState(() {
      _clearCanvas();
      _initDefaultLineup();
      _ballPosition = const Offset(0.5, 0.5);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildToolPalette(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final height = constraints.maxHeight;

                return GestureDetector(
                  onPanStart: (details) => _handlePanStart(details.localPosition, Size(width, height)),
                  onPanUpdate: (details) => _handlePanUpdate(details.localPosition, Size(width, height)),
                  onPanEnd: (_) => _handlePanEnd(),
                  child: Stack(
                    children: [
                      CustomPaint(
                        size: Size(width, height),
                        painter: PitchCanvasPainter(
                          nodes: _nodes,
                          paths: [..._paths, ?_activePath],
                          equipment: _equipment,
                          ballPosition: _ballPosition,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToolPalette() {
    return Container(
      color: const Color(0xFF161B22),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _toolBtn(TacticalTool.select, Icons.touch_app, 'Select / Move'),
            _toolBtn(TacticalTool.passVector, Icons.arrow_right_alt, 'Pass Line'),
            _toolBtn(TacticalTool.playerRun, Icons.gesture, 'Run Curve'),
            _toolBtn(TacticalTool.pressingZone, Icons.blur_on, 'Press Zone'),
            const VerticalDivider(color: Colors.white24, width: 16),
            _toolBtn(TacticalTool.cone, Icons.change_history, 'Cone'),
            _toolBtn(TacticalTool.hurdle, Icons.power_input, 'Hurdle'),
            _toolBtn(TacticalTool.miniGoal, Icons.crop_square, 'Mini Goal'),
            _toolBtn(TacticalTool.eraser, Icons.cleaning_services, 'Eraser'),
            const SizedBox(width: 12),
            _colorPickerBtn(const Color(0xFF2979FF)),
            _colorPickerBtn(const Color(0xFFFF5252)),
            _colorPickerBtn(const Color(0xFF00E676)),
            _colorPickerBtn(const Color(0xFFFFD600)),
            const SizedBox(width: 12),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white70),
              tooltip: 'Reset Pitch',
              onPressed: _resetPositions,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white70),
              tooltip: 'Clear Drawings',
              onPressed: _clearCanvas,
            ),
          ],
        ),
      ),
    );
  }

  Widget _toolBtn(TacticalTool tool, IconData icon, String tooltip) {
    final isSelected = _selectedTool == tool;
    return Tooltip(
      message: tooltip,
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        child: IconButton(
          icon: Icon(icon),
          color: isSelected ? const Color(0xFF00E676) : Colors.white70,
          style: IconButton.styleFrom(
            backgroundColor: isSelected
                ? const Color(0xFF00E676).withValues(alpha: 0.2)
                : Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () => setState(() => _selectedTool = tool),
        ),
      ),
    );
  }

  Widget _colorPickerBtn(Color color) {
    final isSelected = _currentColor == color;
    return GestureDetector(
      onTap: () => setState(() => _currentColor = color),
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }

  void _handlePanStart(Offset point, Size canvasSize) {
    final normPoint = Offset(
      point.dx.clamp(0, canvasSize.width) / canvasSize.width,
      point.dy.clamp(0, canvasSize.height) / canvasSize.height,
    );

    if (_selectedTool == TacticalTool.select) {
      // Check if touching ball
      final ballPx = Offset(_ballPosition.dx * canvasSize.width, _ballPosition.dy * canvasSize.height);
      if ((point - ballPx).distance < 24) {
        _isDraggingBall = true;
        return;
      }

      // Check if touching player node
      for (int i = 0; i < _nodes.length; i++) {
        final nodePx = Offset(_nodes[i].position.dx * canvasSize.width, _nodes[i].position.dy * canvasSize.height);
        if ((point - nodePx).distance < 24) {
          _draggedNodeIndex = i;
          return;
        }
      }
    } else if ([TacticalTool.cone, TacticalTool.hurdle, TacticalTool.miniGoal].contains(_selectedTool)) {
      setState(() {
        _equipment.add(TacticalEquipment(tool: _selectedTool, position: normPoint));
      });
    } else if (_selectedTool == TacticalTool.eraser) {
      setState(() {
        _paths.removeWhere((p) => p.points.any((pt) => (pt - normPoint).distance < 0.05));
        _equipment.removeWhere((e) => (e.position - normPoint).distance < 0.05);
      });
    } else {
      setState(() {
        _activePath = TacticalPath(
          tool: _selectedTool,
          points: [normPoint],
          color: _currentColor,
        );
      });
    }
  }

  void _handlePanUpdate(Offset point, Size canvasSize) {
    final normPoint = Offset(
      point.dx.clamp(0.02, 0.98) / canvasSize.width,
      point.dy.clamp(0.02, 0.98) / canvasSize.height,
    );

    if (_isDraggingBall) {
      setState(() => _ballPosition = normPoint);
    } else if (_draggedNodeIndex != null) {
      setState(() => _nodes[_draggedNodeIndex!].position = normPoint);
    } else if (_activePath != null) {
      setState(() => _activePath!.points.add(normPoint));
    }
  }

  void _handlePanEnd() {
    if (_activePath != null) {
      setState(() {
        _paths.add(_activePath!);
        _activePath = null;
      });
    }
    _draggedNodeIndex = null;
    _isDraggingBall = false;
  }
}

class PitchCanvasPainter extends CustomPainter {
  final List<TacticalNode> nodes;
  final List<TacticalPath> paths;
  final List<TacticalEquipment> equipment;
  final Offset ballPosition;

  PitchCanvasPainter({
    required this.nodes,
    required this.paths,
    required this.equipment,
    required this.ballPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final bgPaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRect(rect, bgPaint);

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Outer pitch lines
    const padding = 16.0;
    final pitchRect = Rect.fromLTRB(
      padding,
      padding,
      size.width - padding,
      size.height - padding,
    );
    canvas.drawRect(pitchRect, linePaint);

    // Halfway line & Center Circle
    final midX = size.width / 2;
    canvas.drawLine(
      Offset(midX, padding),
      Offset(midX, size.height - padding),
      linePaint,
    );
    canvas.drawCircle(Offset(midX, size.height / 2), 45, linePaint);
    canvas.drawCircle(Offset(midX, size.height / 2), 4, Paint()..color = Colors.white30);

    // Penalty Boxes
    final boxHeight = size.height * 0.45;
    final boxTop = (size.height - boxHeight) / 2;
    final boxWidth = size.width * 0.16;

    // Left Box
    canvas.drawRect(
      Rect.fromLTWH(padding, boxTop, boxWidth, boxHeight),
      linePaint,
    );

    // Right Box
    canvas.drawRect(
      Rect.fromLTWH(size.width - padding - boxWidth, boxTop, boxWidth, boxHeight),
      linePaint,
    );

    // Render Tactical Paths (Passes, Runs, Pressing)
    for (final path in paths) {
      if (path.points.length < 2) continue;

      final paint = Paint()
        ..color = path.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = path.tool == TacticalTool.pressingZone ? 8 : 3.5
        ..strokeCap = StrokeCap.round;

      if (path.tool == TacticalTool.pressingZone) {
        paint.color = path.color.withValues(alpha: 0.35);
      }

      final pathObj = Path();
      final p0 = Offset(path.points.first.dx * size.width, path.points.first.dy * size.height);
      pathObj.moveTo(p0.dx, p0.dy);

      for (int i = 1; i < path.points.length; i++) {
        final pt = Offset(path.points[i].dx * size.width, path.points[i].dy * size.height);
        pathObj.lineTo(pt.dx, pt.dy);
      }
      canvas.drawPath(pathObj, paint);

      // Draw arrowhead for pass/run
      if (path.tool == TacticalTool.passVector || path.tool == TacticalTool.playerRun) {
        final last = Offset(path.points.last.dx * size.width, path.points.last.dy * size.height);
        final prev = Offset(
          path.points[path.points.length - 2].dx * size.width,
          path.points[path.points.length - 2].dy * size.height,
        );
        final angle = math.atan2(last.dy - prev.dy, last.dx - prev.dx);
        const arrowSize = 10.0;

        final arrowPath = Path()
          ..moveTo(last.dx, last.dy)
          ..lineTo(
            last.dx - arrowSize * math.cos(angle - math.pi / 6),
            last.dy - arrowSize * math.sin(angle - math.pi / 6),
          )
          ..lineTo(
            last.dx - arrowSize * math.cos(angle + math.pi / 6),
            last.dy - arrowSize * math.sin(angle + math.pi / 6),
          )
          ..close();

        canvas.drawPath(arrowPath, Paint()..color = path.color);
      }
    }

    // Render Equipment (Cones, Hurdles, Mini Goals)
    for (final eq in equipment) {
      final pos = Offset(eq.position.dx * size.width, eq.position.dy * size.height);
      final eqPaint = Paint()..color = const Color(0xFFFFD600);

      if (eq.tool == TacticalTool.cone) {
        final conePath = Path()
          ..moveTo(pos.dx, pos.dy - 8)
          ..lineTo(pos.dx - 8, pos.dy + 8)
          ..lineTo(pos.dx + 8, pos.dy + 8)
          ..close();
        canvas.drawPath(conePath, eqPaint);
      } else if (eq.tool == TacticalTool.hurdle) {
        canvas.drawLine(
          Offset(pos.dx - 10, pos.dy),
          Offset(pos.dx + 10, pos.dy),
          eqPaint..strokeWidth = 3,
        );
      } else if (eq.tool == TacticalTool.miniGoal) {
        canvas.drawRect(
          Rect.fromCenter(center: pos, width: 18, height: 10),
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
    }

    // Render Players
    for (final node in nodes) {
      final pos = Offset(node.position.dx * size.width, node.position.dy * size.height);
      final isHome = node.team == 'home';
      final baseColor = isHome ? const Color(0xFF2979FF) : const Color(0xFFFF5252);

      // Node shadow
      canvas.drawCircle(
        pos,
        14,
        Paint()..color = Colors.black38,
      );

      // Node body
      canvas.drawCircle(
        pos,
        13,
        Paint()..color = baseColor,
      );
      canvas.drawCircle(
        pos,
        13,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );

      // Label
      final textPainter = TextPainter(
        text: TextSpan(
          text: node.label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        pos - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }

    // Render Ball
    final ballPx = Offset(ballPosition.dx * size.width, ballPosition.dy * size.height);
    canvas.drawCircle(ballPx, 8, Paint()..color = Colors.white);
    canvas.drawCircle(
      ballPx,
      8,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant PitchCanvasPainter oldDelegate) => true;
}

class _VideoSyncView extends StatefulWidget {
  const _VideoSyncView();

  @override
  State<_VideoSyncView> createState() => _VideoSyncViewState();
}

class _VideoSyncViewState extends State<_VideoSyncView> {
  bool _isPlaying = false;
  double _playbackPosition = 0.35; // 0.0 to 1.0 timeline
  final String _currentTimestamp = '00:34:12';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top: Video Player Display
        Expanded(
          flex: 5,
          child: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF161B22),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.smart_display_rounded,
                        size: 64,
                        color: const Color(0xFF2979FF).withValues(alpha: 0.8),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Match Video Feed (Calibration Synced)',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Frame-to-Pitch Homography Active (30 FPS)',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF00E676)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.circle, size: 8, color: Color(0xFF00E676)),
                        const SizedBox(width: 6),
                        Text(
                          'SYNCED: $_currentTimestamp',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Timeline Scrubber & Player Controls
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: const Color(0xFF161B22),
          child: Row(
            children: [
              IconButton(
                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                color: const Color(0xFF2979FF),
                onPressed: () => setState(() => _isPlaying = !_isPlaying),
              ),
              Expanded(
                child: Slider(
                  value: _playbackPosition,
                  activeColor: const Color(0xFF2979FF),
                  inactiveColor: Colors.white12,
                  onChanged: (val) => setState(() => _playbackPosition = val),
                ),
              ),
              const Text('00:34:12 / 00:90:00', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ),

        // Bottom: Synchronized 2D Coordinates View
        Expanded(
          flex: 4,
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2979FF).withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Live 2D Pitch Coordinate Tracking',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Icon(Icons.radar, color: Color(0xFF2979FF), size: 18),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Center(
                    child: CustomPaint(
                      size: const Size(double.infinity, double.infinity),
                      painter: SyncedPitchMiniPainter(playbackPos: _playbackPosition),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class SyncedPitchMiniPainter extends CustomPainter {
  final double playbackPos;
  SyncedPitchMiniPainter({required this.playbackPos});

  @override
  void paint(Canvas canvas, Size size) {
    final pitchRect = Offset.zero & size;
    canvas.drawRect(
      pitchRect,
      Paint()..color = const Color(0xFF1E293B),
    );
    canvas.drawRect(
      pitchRect,
      Paint()
        ..color = Colors.white24
        ..style = PaintingStyle.stroke,
    );

    // Center Line
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      Paint()..color = Colors.white24,
    );

    // Simulated synced tracking positions animated by playbackPos
    final shift = (playbackPos - 0.5) * 60;
    final players = [
      Offset(size.width * 0.15 + shift, size.height * 0.5),
      Offset(size.width * 0.35 + shift * 0.8, size.height * 0.25),
      Offset(size.width * 0.35 + shift * 0.8, size.height * 0.75),
      Offset(size.width * 0.65 + shift * 0.5, size.height * 0.35),
      Offset(size.width * 0.65 + shift * 0.5, size.height * 0.65),
      Offset(size.width * 0.85 + shift * 0.2, size.height * 0.5),
    ];

    for (int i = 0; i < players.length; i++) {
      final isHome = i < 3;
      final color = isHome ? const Color(0xFF2979FF) : const Color(0xFFFF5252);
      canvas.drawCircle(players[i], 8, Paint()..color = color);
      canvas.drawCircle(players[i], 12, Paint()..color = color.withValues(alpha: 0.3));
    }
  }

  @override
  bool shouldRepaint(covariant SyncedPitchMiniPainter oldDelegate) =>
      oldDelegate.playbackPos != playbackPos;
}
