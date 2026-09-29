import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as v64;

// ==========================================
// 1. DATA MODELS & ENUMS
// ==========================================

enum TeamSide { home, away, ball }

enum CameraMode { orbit3D, birdEyeOverhead, beThePlayerPOV }

enum TacticalArrowType { groundPass, loftedPass, playerRun, highPress }

class Player3D {
  final String id;
  final int number;
  final String name;
  final TeamSide side;
  v64.Vector3 position; // X: [-52.5, 52.5], Y: [0, height], Z: [-34.0, 34.0]
  double headingRadians; // Direction the player faces

  Player3D({
    required this.id,
    required this.number,
    required this.name,
    required this.side,
    required this.position,
    this.headingRadians = 0.0,
  });

  Player3D copyWith({v64.Vector3? position, double? headingRadians}) {
    return Player3D(
      id: id,
      number: number,
      name: name,
      side: side,
      position: position ?? this.position.clone(),
      headingRadians: headingRadians ?? this.headingRadians,
    );
  }
}

class TacticalArrow3D {
  final String id;
  final v64.Vector3 start;
  final v64.Vector3 end;
  final TacticalArrowType type;
  final double apexHeight; // Used for parabolic lofted passes

  TacticalArrow3D({
    required this.id,
    required this.start,
    required this.end,
    required this.type,
    this.apexHeight = 0.0,
  });
}

// ==========================================
// 2. MAIN 3D TACTICAL BOARD WIDGET
// ==========================================

class Tactical3DBoardScreen extends StatefulWidget {
  const Tactical3DBoardScreen({super.key});

  @override
  State<Tactical3DBoardScreen> createState() => _Tactical3DBoardScreenState();
}

class _Tactical3DBoardScreenState extends State<Tactical3DBoardScreen> {
  // Pitch dimensions (standard FIFA 105m x 68m centered at (0,0,0))
  static const double pitchLength = 105.0;
  static const double pitchWidth = 68.0;

  // Camera parameters
  CameraMode _cameraMode = CameraMode.orbit3D;
  double _cameraAzimuth = math.pi / 2; // Horizontal rotation
  double _cameraElevation = 0.65; // Vertical angle (radians)
  final double _cameraDistance = 90.0; // Distance from target
  final v64.Vector3 _cameraTarget = v64.Vector3(0, 0, 0);

  // Interaction State
  List<Player3D> _players = [];
  final List<TacticalArrow3D> _arrows = [];
  String? _selectedPlayerId;
  int? _povPlayerIndex;
  bool _showTacticalCorridors = true;
  TacticalArrowType _activeDrawType = TacticalArrowType.groundPass;
  bool _drawingMode = false;
  v64.Vector3? _arrowDragStart;
  v64.Vector3? _arrowDragCurrent;

  @override
  void initState() {
    super.initState();
    _initializeSquads();
  }

  void _initializeSquads() {
    _players = [
      // Ball
      Player3D(
        id: 'ball',
        number: 0,
        name: 'Ball',
        side: TeamSide.ball,
        position: v64.Vector3(0, 0.2, 0),
      ),
      // HOME (Blue) - Standard 4-3-3 shape
      Player3D(id: 'h_gk', number: 1, name: 'GK', side: TeamSide.home, position: v64.Vector3(-45, 0, 0)),
      Player3D(id: 'h_rb', number: 2, name: 'RB', side: TeamSide.home, position: v64.Vector3(-30, 0, 22)),
      Player3D(id: 'h_cb1', number: 4, name: 'CB', side: TeamSide.home, position: v64.Vector3(-35, 0, 8)),
      Player3D(id: 'h_cb2', number: 5, name: 'CB', side: TeamSide.home, position: v64.Vector3(-35, 0, -8)),
      Player3D(id: 'h_lb', number: 3, name: 'LB', side: TeamSide.home, position: v64.Vector3(-30, 0, -22)),
      Player3D(id: 'h_dm', number: 6, name: 'DM', side: TeamSide.home, position: v64.Vector3(-20, 0, 0)),
      Player3D(id: 'h_cm1', number: 8, name: 'CM', side: TeamSide.home, position: v64.Vector3(-10, 0, 14)),
      Player3D(id: 'h_cm2', number: 10, name: 'AM', side: TeamSide.home, position: v64.Vector3(-10, 0, -14)),
      Player3D(id: 'h_rw', number: 7, name: 'RW', side: TeamSide.home, position: v64.Vector3(15, 0, 22)),
      Player3D(id: 'h_st', number: 9, name: 'ST', side: TeamSide.home, position: v64.Vector3(20, 0, 0)),
      Player3D(id: 'h_lw', number: 11, name: 'LW', side: TeamSide.home, position: v64.Vector3(15, 0, -22)),

      // AWAY (Red) - 4-4-2 shape
      Player3D(id: 'a_gk', number: 1, name: 'GK', side: TeamSide.away, position: v64.Vector3(45, 0, 0)),
      Player3D(id: 'a_rb', number: 2, name: 'RB', side: TeamSide.away, position: v64.Vector3(30, 0, -22)),
      Player3D(id: 'a_cb1', number: 4, name: 'CB', side: TeamSide.away, position: v64.Vector3(35, 0, -8)),
      Player3D(id: 'a_cb2', number: 5, name: 'CB', side: TeamSide.away, position: v64.Vector3(35, 0, 8)),
      Player3D(id: 'a_lb', number: 3, name: 'LB', side: TeamSide.away, position: v64.Vector3(30, 0, 22)),
      Player3D(id: 'a_rm', number: 7, name: 'RM', side: TeamSide.away, position: v64.Vector3(12, 0, -22)),
      Player3D(id: 'a_cm1', number: 6, name: 'CM', side: TeamSide.away, position: v64.Vector3(10, 0, -7)),
      Player3D(id: 'a_cm2', number: 8, name: 'CM', side: TeamSide.away, position: v64.Vector3(10, 0, 7)),
      Player3D(id: 'a_lm', number: 11, name: 'LM', side: TeamSide.away, position: v64.Vector3(12, 0, 22)),
      Player3D(id: 'a_st1', number: 9, name: 'ST', side: TeamSide.away, position: v64.Vector3(-5, 0, -6)),
      Player3D(id: 'a_st2', number: 10, name: 'ST', side: TeamSide.away, position: v64.Vector3(-5, 0, 6)),
    ];
  }

  // --- 3D Projection Helpers ---
  ({v64.Vector3 eye, v64.Vector3 target, v64.Vector3 up}) _calculateCameraVectors() {
    if (_cameraMode == CameraMode.beThePlayerPOV && _povPlayerIndex != null) {
      final p = _players[_povPlayerIndex!];
      final eye = v64.Vector3(p.position.x, 1.75, p.position.z); // Eye-level: 1.75m
      final forward = v64.Vector3(math.cos(p.headingRadians), 0, math.sin(p.headingRadians));
      final target = eye + forward * 20.0;
      return (eye: eye, target: target, up: v64.Vector3(0, 1, 0));
    } else if (_cameraMode == CameraMode.birdEyeOverhead) {
      final eye = v64.Vector3(0, 110, 0.001); // Near-straight top-down
      return (eye: eye, target: v64.Vector3(0, 0, 0), up: v64.Vector3(0, 0, -1));
    } else {
      // Free Orbit Mode
      final eyeX = _cameraTarget.x + _cameraDistance * math.cos(_cameraElevation) * math.sin(_cameraAzimuth);
      final eyeY = _cameraTarget.y + _cameraDistance * math.sin(_cameraElevation);
      final eyeZ = _cameraTarget.z + _cameraDistance * math.cos(_cameraElevation) * math.cos(_cameraAzimuth);
      return (eye: v64.Vector3(eyeX, eyeY, eyeZ), target: _cameraTarget, up: v64.Vector3(0, 1, 0));
    }
  }

  v64.Matrix4 _computeViewProjectionMatrix(Size size) {
    final camera = _calculateCameraVectors();
    final viewMatrix = v64.makeViewMatrix(camera.eye, camera.target, camera.up);
    final fov = _cameraMode == CameraMode.beThePlayerPOV ? 65.0 : 45.0;
    final projMatrix = v64.makePerspectiveMatrix(
      v64.radians(fov),
      size.width / (size.height <= 0 ? 1 : size.height),
      0.5,
      600.0,
    );
    return projMatrix * viewMatrix;
  }

  // Raycast Screen pixel (px, py) onto Pitch Ground plane (Y = 0)
  v64.Vector3? _screenToGroundPlane(Offset screenPos, Size size) {
    final camera = _calculateCameraVectors();
    final vp = _computeViewProjectionMatrix(size);
    final invVP = v64.Matrix4.inverted(vp);

    final ndcX = (2.0 * screenPos.dx / size.width) - 1.0;
    final ndcY = 1.0 - (2.0 * screenPos.dy / size.height);

    final nearWorld = invVP.transformed(v64.Vector4(ndcX, ndcY, -1.0, 1.0));
    final farWorld = invVP.transformed(v64.Vector4(ndcX, ndcY, 1.0, 1.0));

    final near = v64.Vector3(nearWorld.x / nearWorld.w, nearWorld.y / nearWorld.w, nearWorld.z / nearWorld.w);
    final far = v64.Vector3(farWorld.x / farWorld.w, farWorld.y / farWorld.w, farWorld.z / farWorld.w);

    final rayDir = (far - near)..normalize();
    if (rayDir.y.abs() < 1e-5) return null;

    final t = -camera.eye.y / rayDir.y;
    if (t < 0) return null;

    return camera.eye + (rayDir * t);
  }

  // --- Gestures & Interactivity ---
  void _handlePanUpdate(DragUpdateDetails details, Size size) {
    if (_drawingMode && _arrowDragStart != null) {
      final groundPt = _screenToGroundPlane(details.localPosition, size);
      if (groundPt != null) setState(() => _arrowDragCurrent = groundPt);
      return;
    }

    if (_selectedPlayerId != null && !_drawingMode) {
      final groundPt = _screenToGroundPlane(details.localPosition, size);
      if (groundPt != null) {
        setState(() {
          final idx = _players.indexWhere((p) => p.id == _selectedPlayerId);
          if (idx != -1) {
            // Clamp within pitch bounds
            final cx = groundPt.x.clamp(-pitchLength / 2, pitchLength / 2);
            final cz = groundPt.z.clamp(-pitchWidth / 2, pitchWidth / 2);
            _players[idx].position = v64.Vector3(cx, _players[idx].side == TeamSide.ball ? 0.2 : 0, cz);
          }
        });
      }
      return;
    }

    // Default Camera Orbit & Pan
    setState(() {
      _cameraAzimuth -= details.delta.dx * 0.007;
      _cameraElevation = (_cameraElevation + details.delta.dy * 0.007).clamp(0.08, math.pi / 2 - 0.05);
    });
  }

  void _handleTapDown(TapDownDetails details, Size size) {
    final groundPt = _screenToGroundPlane(details.localPosition, size);
    if (groundPt == null) return;

    if (_drawingMode) {
      setState(() {
        _arrowDragStart = groundPt;
        _arrowDragCurrent = groundPt;
      });
      return;
    }

    // Hit test players (radius 3.2 meters)
    String? hitPlayerId;
    for (final p in _players) {
      final dist = (p.position - groundPt).length;
      if (dist < 3.2) {
        hitPlayerId = p.id;
        break;
      }
    }

    setState(() {
      _selectedPlayerId = hitPlayerId;
      if (hitPlayerId != null && _cameraMode == CameraMode.beThePlayerPOV) {
        _povPlayerIndex = _players.indexWhere((p) => p.id == hitPlayerId);
      }
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    if (_drawingMode && _arrowDragStart != null && _arrowDragCurrent != null) {
      final dist = (_arrowDragCurrent! - _arrowDragStart!).length;
      if (dist > 2.0) {
        setState(() {
          _arrows.add(TacticalArrow3D(
            id: DateTime.now().toIso8601String(),
            start: _arrowDragStart!,
            end: _arrowDragCurrent!,
            type: _activeDrawType,
            apexHeight: _activeDrawType == TacticalArrowType.loftedPass ? 5.5 : 0.0,
          ));
        });
      }
    }
    setState(() {
      _arrowDragStart = null;
      _arrowDragCurrent = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D14),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          final vpMatrix = _computeViewProjectionMatrix(size);

          return Stack(
            children: [
              // 3D Canvas
              GestureDetector(
                onTapDown: (details) => _handleTapDown(details, size),
                onPanUpdate: (details) => _handlePanUpdate(details, size),
                onPanEnd: _handlePanEnd,
                child: CustomPaint(
                  size: size,
                  painter: Pitch3DPainter(
                    vpMatrix: vpMatrix,
                    cameraPos: _calculateCameraVectors().eye,
                    players: _players,
                    arrows: _arrows,
                    selectedPlayerId: _selectedPlayerId,
                    showTacticalCorridors: _showTacticalCorridors,
                    activePreviewArrowStart: _arrowDragStart,
                    activePreviewArrowEnd: _arrowDragCurrent,
                    activePreviewType: _activeDrawType,
                  ),
                ),
              ),

              // Top Status & Camera Mode Switcher
              Positioned(
                top: 40,
                left: 20,
                right: 20,
                child: _buildTopControlHeader(),
              ),

              // Bottom Control Dock
              Positioned(
                bottom: 24,
                left: 20,
                right: 20,
                child: _buildBottomTacticalDock(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopControlHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF161B26).withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            children: [
              const Icon(Icons.threed_rotation, color: Color(0xFF00E676), size: 18),
              const SizedBox(width: 8),
              Text(
                _cameraMode == CameraMode.beThePlayerPOV
                    ? 'POV: ${_selectedPlayerId ?? "Select Player"}'
                    : _cameraMode == CameraMode.birdEyeOverhead
                        ? 'TACTICAL 2D/3D OVERHEAD'
                        : '3D ORBIT FREE-CAM',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
        ),
        Row(
          children: [
            _buildHeaderCircleAction(
              icon: Icons.grid_goldenratio,
              active: _showTacticalCorridors,
              onTap: () => setState(() => _showTacticalCorridors = !_showTacticalCorridors),
              tooltip: 'Tactical Zones',
            ),
            const SizedBox(width: 8),
            _buildHeaderCircleAction(
              icon: Icons.undo,
              active: _arrows.isNotEmpty,
              onTap: () {
                if (_arrows.isNotEmpty) setState(() => _arrows.removeLast());
              },
              tooltip: 'Undo Vector',
            ),
            const SizedBox(width: 8),
            _buildHeaderCircleAction(
              icon: Icons.delete_outline,
              active: _arrows.isNotEmpty,
              onTap: () => setState(() => _arrows.clear()),
              tooltip: 'Clear Arrows',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderCircleAction({
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF2979FF).withValues(alpha: 0.2) : const Color(0xFF161B26).withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: active ? const Color(0xFF2979FF) : Colors.white12),
          ),
          child: Icon(icon, color: active ? const Color(0xFF2979FF) : Colors.white70, size: 18),
        ),
      ),
    );
  }

  Widget _buildBottomTacticalDock() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF161B26).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 16, offset: Offset(0, 6))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Camera Mode Selector
          Row(
            children: [
              _cameraButton(CameraMode.orbit3D, Icons.threed_rotation, '3D Pitch'),
              const SizedBox(width: 8),
              _cameraButton(CameraMode.birdEyeOverhead, Icons.vertical_align_bottom, 'Top-Down'),
              const SizedBox(width: 8),
              _cameraButton(CameraMode.beThePlayerPOV, Icons.person_pin_circle, 'Player POV'),
            ],
          ),

          const VerticalDivider(color: Colors.white24, width: 24, thickness: 1),

          // Tactical Arrow Selector
          Row(
            children: [
              _vectorButton(TacticalArrowType.groundPass, Icons.arrow_right_alt, 'Ground Pass'),
              const SizedBox(width: 6),
              _vectorButton(TacticalArrowType.loftedPass, Icons.redo, 'Lofted (3D)'),
              const SizedBox(width: 6),
              _vectorButton(TacticalArrowType.playerRun, Icons.linear_scale, 'Player Run'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cameraButton(CameraMode mode, IconData icon, String label) {
    final active = _cameraMode == mode;
    return InkWell(
      onTap: () {
        setState(() {
          _cameraMode = mode;
          if (mode == CameraMode.beThePlayerPOV) {
            _povPlayerIndex = _selectedPlayerId != null
                ? _players.indexWhere((p) => p.id == _selectedPlayerId)
                : 7; // Defaults to midfielder
          }
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF00E676).withValues(alpha: 0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: active ? const Color(0xFF00E676) : Colors.transparent),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: active ? const Color(0xFF00E676) : Colors.white60),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : Colors.white60,
                fontSize: 12,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _vectorButton(TacticalArrowType type, IconData icon, String label) {
    final active = _drawingMode && _activeDrawType == type;
    return InkWell(
      onTap: () {
        setState(() {
          if (_drawingMode && _activeDrawType == type) {
            _drawingMode = false;
          } else {
            _drawingMode = true;
            _activeDrawType = type;
          }
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF2979FF).withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: active ? const Color(0xFF2979FF) : Colors.white10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: active ? const Color(0xFF2979FF) : Colors.white60),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : Colors.white60,
                fontSize: 11,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==============================================================
// 3. 3D PITCH & ENTITY CUSTOM PAINTER (PROJECTION ENGINE)
// ==============================================================

class Pitch3DPainter extends CustomPainter {
  final v64.Matrix4 vpMatrix;
  final v64.Vector3 cameraPos;
  final List<Player3D> players;
  final List<TacticalArrow3D> arrows;
  final String? selectedPlayerId;
  final bool showTacticalCorridors;
  final v64.Vector3? activePreviewArrowStart;
  final v64.Vector3? activePreviewArrowEnd;
  final TacticalArrowType activePreviewType;

  Pitch3DPainter({
    required this.vpMatrix,
    required this.cameraPos,
    required this.players,
    required this.arrows,
    required this.selectedPlayerId,
    required this.showTacticalCorridors,
    this.activePreviewArrowStart,
    this.activePreviewArrowEnd,
    required this.activePreviewType,
  });

  // Project 3D coordinate (x,y,z) to 2D screen coordinate (dx, dy)
  Offset? _project(v64.Vector3 world, Size size) {
    final v4 = v64.Vector4(world.x, world.y, world.z, 1.0);
    final clip = vpMatrix.transformed(v4);

    // Behind near plane
    if (clip.w <= 0.001) return null;

    final ndcX = clip.x / clip.w;
    final ndcY = clip.y / clip.w;

    // Viewport transform
    final sx = (ndcX + 1.0) * 0.5 * size.width;
    final sy = (1.0 - ndcY) * 0.5 * size.height;
    return Offset(sx, sy);
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrassSurface(canvas, size);
    if (showTacticalCorridors) _drawTacticalCorridors(canvas, size);
    _drawPitchMarkings(canvas, size);
    _drawGoalFrames(canvas, size);
    _drawTacticalArrows(canvas, size);
    _drawPlayers(canvas, size);
  }

  void _drawGrassSurface(Canvas canvas, Size size) {
    const l2 = 105.0 / 2;
    const w2 = 68.0 / 2;
    const border = 5.0;

    final p1 = _project(v64.Vector3(-l2 - border, 0, -w2 - border), size);
    final p2 = _project(v64.Vector3(l2 + border, 0, -w2 - border), size);
    final p3 = _project(v64.Vector3(l2 + border, 0, w2 + border), size);
    final p4 = _project(v64.Vector3(-l2 - border, 0, w2 + border), size);

    if (p1 == null || p2 == null || p3 == null || p4 == null) return;

    final turfPath = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..lineTo(p4.dx, p4.dy)
      ..close();

    final turfPaint = Paint()
      ..color = const Color(0xFF1E3A2F)
      ..style = PaintingStyle.fill;
    canvas.drawPath(turfPath, turfPaint);

    // Alternating Grass Stripes (10 m intervals)
    final stripePaint = Paint()
      ..color = const Color(0xFF244437).withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;

    for (double x = -l2; x < l2; x += 10.5) {
      if (((x + l2) / 10.5).floor() % 2 == 0) continue;
      final s1 = _project(v64.Vector3(x, 0, -w2), size);
      final s2 = _project(v64.Vector3(x + 10.5, 0, -w2), size);
      final s3 = _project(v64.Vector3(x + 10.5, 0, w2), size);
      final s4 = _project(v64.Vector3(x, 0, w2), size);
      if (s1 != null && s2 != null && s3 != null && s4 != null) {
        final sp = Path()
          ..moveTo(s1.dx, s1.dy)
          ..lineTo(s2.dx, s2.dy)
          ..lineTo(s3.dx, s3.dy)
          ..lineTo(s4.dx, s4.dy)
          ..close();
        canvas.drawPath(sp, stripePaint);
      }
    }
  }

  void _drawTacticalCorridors(Canvas canvas, Size size) {
    // 5 Corridors: Left Flank, Half-space, Center, Half-space, Right Flank
    final corridorsZ = [-34.0, -20.4, -6.8, 6.8, 20.4, 34.0];
    final linePaint = Paint()
      ..color = const Color(0xFFFFD700).withValues(alpha: 0.35)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    for (int i = 1; i < corridorsZ.length - 1; i++) {
      _drawLine3D(
        canvas,
        size,
        v64.Vector3(-52.5, 0, corridorsZ[i]),
        v64.Vector3(52.5, 0, corridorsZ[i]),
        linePaint,
        isDashed: true,
      );
    }
  }

  void _drawPitchMarkings(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    const l2 = 52.5;
    const w2 = 34.0;

    // Outer Boundary
    _drawLine3D(canvas, size, v64.Vector3(-l2, 0, -w2), v64.Vector3(l2, 0, -w2), linePaint);
    _drawLine3D(canvas, size, v64.Vector3(l2, 0, -w2), v64.Vector3(l2, 0, w2), linePaint);
    _drawLine3D(canvas, size, v64.Vector3(l2, 0, w2), v64.Vector3(-l2, 0, w2), linePaint);
    _drawLine3D(canvas, size, v64.Vector3(-l2, 0, w2), v64.Vector3(-l2, 0, -w2), linePaint);

    // Halfway Line
    _drawLine3D(canvas, size, v64.Vector3(0, 0, -w2), v64.Vector3(0, 0, w2), linePaint);

    // Center Circle (Radius 9.15m)
    _drawCircle3D(canvas, size, v64.Vector3(0, 0, 0), 9.15, linePaint);

    // Penalty Boxes (16.5m deep, 40.32m wide)
    _drawBox3D(canvas, size, -l2, -l2 + 16.5, -20.16, 20.16, linePaint);
    _drawBox3D(canvas, size, l2 - 16.5, l2, -20.16, 20.16, linePaint);

    // Goal Boxes (5.5m deep, 18.32m wide)
    _drawBox3D(canvas, size, -l2, -l2 + 5.5, -9.16, 9.16, linePaint);
    _drawBox3D(canvas, size, l2 - 5.5, l2, -9.16, 9.16, linePaint);
  }

  void _drawGoalFrames(Canvas canvas, Size size) {
    final goalPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.8
      ..style = PaintingStyle.stroke;

    // Goal: Width 7.32m, Height 2.44m, Depth 2.0m
    for (final sign in [-1.0, 1.0]) {
      final xFront = sign * 52.5;
      final xBack = sign * 54.5;
      const yTop = 2.44;
      const zL = -3.66;
      const zR = 3.66;

      // Posts & Crossbar
      _drawLine3D(canvas, size, v64.Vector3(xFront, 0, zL), v64.Vector3(xFront, yTop, zL), goalPaint);
      _drawLine3D(canvas, size, v64.Vector3(xFront, 0, zR), v64.Vector3(xFront, yTop, zR), goalPaint);
      _drawLine3D(canvas, size, v64.Vector3(xFront, yTop, zL), v64.Vector3(xFront, yTop, zR), goalPaint);

      // Back frame
      _drawLine3D(canvas, size, v64.Vector3(xFront, yTop, zL), v64.Vector3(xBack, yTop, zL), goalPaint);
      _drawLine3D(canvas, size, v64.Vector3(xFront, yTop, zR), v64.Vector3(xBack, yTop, zR), goalPaint);
      _drawLine3D(canvas, size, v64.Vector3(xBack, yTop, zL), v64.Vector3(xBack, yTop, zR), goalPaint);
      _drawLine3D(canvas, size, v64.Vector3(xBack, 0, zL), v64.Vector3(xBack, yTop, zL), goalPaint);
      _drawLine3D(canvas, size, v64.Vector3(xBack, 0, zR), v64.Vector3(xBack, yTop, zR), goalPaint);
    }
  }

  void _drawPlayers(Canvas canvas, Size size) {
    // Sort players by distance to camera (Painter's algorithm for proper depth ordering)
    final sorted = List<Player3D>.from(players)
      ..sort((a, b) {
        final distA = (a.position - cameraPos).length2;
        final distB = (b.position - cameraPos).length2;
        return distB.compareTo(distA);
      });

    for (final p in sorted) {
      final basePt = _project(p.position, size);
      if (basePt == null) continue;

      if (p.side == TeamSide.ball) {
        _renderBall(canvas, size, p.position);
        continue;
      }

      // Ground Cast-Shadow
      final shadowRadius = 14.0 * (40.0 / (p.position - cameraPos).length).clamp(0.4, 2.2);
      canvas.drawOval(
        Rect.fromCenter(center: basePt, width: shadowRadius * 1.8, height: shadowRadius * 0.9),
        Paint()..color = Colors.black.withValues(alpha: 0.4),
      );

      // 3D Player Cylinder (Head height: 1.85m)
      final topPos = v64.Vector3(p.position.x, 1.85, p.position.z);
      final topPt = _project(topPos, size);
      if (topPt == null) continue;

      final isSelected = p.id == selectedPlayerId;
      final playerColor = p.side == TeamSide.home ? const Color(0xFF2979FF) : const Color(0xFFFF1744);

      // Body Cylinder Stroke
      final bodyWidth = (shadowRadius * 1.1).clamp(6.0, 24.0);
      final bodyPaint = Paint()
        ..color = playerColor
        ..strokeWidth = bodyWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(basePt, topPt, bodyPaint);

      // Selection Halo
      if (isSelected) {
        final haloPaint = Paint()
          ..color = const Color(0xFF00E676)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5;
        canvas.drawCircle(topPt, bodyWidth * 0.8, haloPaint);
      }

      // Player Number on Head
      if (bodyWidth > 10.0) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: '${p.number}',
            style: TextStyle(
              color: Colors.white,
              fontSize: (bodyWidth * 0.65).clamp(8.0, 14.0),
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(
          canvas,
          Offset(topPt.dx - textPainter.width / 2, topPt.dy - textPainter.height / 2),
        );
      }
    }
  }

  void _renderBall(Canvas canvas, Size size, v64.Vector3 pos) {
    final groundPt = _project(v64.Vector3(pos.x, 0, pos.z), size);
    final ballPt = _project(pos, size);
    if (ballPt == null) return;

    if (groundPt != null && pos.y > 0.3) {
      canvas.drawCircle(groundPt, 5.0, Paint()..color = Colors.black45);
      canvas.drawLine(groundPt, ballPt, Paint()..color = Colors.white24..strokeWidth = 1.0);
    }

    // Ball 3D Shading
    canvas.drawCircle(ballPt, 6.0, Paint()..color = Colors.white);
    canvas.drawCircle(ballPt, 4.0, Paint()..color = Colors.black87..style = PaintingStyle.stroke..strokeWidth = 1.2);
  }

  void _drawTacticalArrows(Canvas canvas, Size size) {
    for (final arrow in arrows) {
      _render3DArrow(canvas, size, arrow.start, arrow.end, arrow.type, arrow.apexHeight);
    }

    if (activePreviewArrowStart != null && activePreviewArrowEnd != null) {
      _render3DArrow(
        canvas,
        size,
        activePreviewArrowStart!,
        activePreviewArrowEnd!,
        activePreviewType,
        activePreviewType == TacticalArrowType.loftedPass ? 5.5 : 0.0,
      );
    }
  }

  void _render3DArrow(
    Canvas canvas,
    Size size,
    v64.Vector3 start,
    v64.Vector3 end,
    TacticalArrowType type,
    double apex,
  ) {
    final arrowColor = switch (type) {
      TacticalArrowType.groundPass => const Color(0xFF00E676),
      TacticalArrowType.loftedPass => const Color(0xFFFFD700),
      TacticalArrowType.playerRun => const Color(0xFF2979FF),
      TacticalArrowType.highPress => const Color(0xFFFF5252),
    };

    final paint = Paint()
      ..color = arrowColor
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    // Curved parabolic trajectory in 3D for lofted pass
    if (apex > 0) {
      const segments = 24;
      Offset? prev;
      for (int i = 0; i <= segments; i++) {
        final t = i / segments;
        final curr3D = v64.Vector3(
          start.x + (end.x - start.x) * t,
          start.y + (end.y - start.y) * t + (4 * apex * t * (1 - t)), // Parabola equation
          start.z + (end.z - start.z) * t,
        );
        final curr2D = _project(curr3D, size);
        if (curr2D != null && prev != null) {
          canvas.drawLine(prev, curr2D, paint);
        }
        prev = curr2D;
      }
    } else {
      final p1 = _project(start, size);
      final p2 = _project(end, size);
      if (p1 != null && p2 != null) {
        if (type == TacticalArrowType.playerRun) {
          _drawDashedLine2D(canvas, p1, p2, paint);
        } else {
          canvas.drawLine(p1, p2, paint);
        }
        _drawArrowHead(canvas, p1, p2, arrowColor);
      }
    }
  }

  void _drawArrowHead(Canvas canvas, Offset p1, Offset p2, Color color) {
    final angle = math.atan2(p2.dy - p1.dy, p2.dx - p1.dx);
    const arrowSize = 10.0;
    final path = Path()
      ..moveTo(p2.dx, p2.dy)
      ..lineTo(p2.dx - arrowSize * math.cos(angle - math.pi / 6), p2.dy - arrowSize * math.sin(angle - math.pi / 6))
      ..lineTo(p2.dx - arrowSize * math.cos(angle + math.pi / 6), p2.dy - arrowSize * math.sin(angle + math.pi / 6))
      ..close();
    canvas.drawPath(path, Paint()..color = color..style = PaintingStyle.fill);
  }

  void _drawDashedLine2D(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dashLength = 6.0;
    const dashSpace = 4.0;
    final dx = p2.dx - p1.dx;
    final dy = p2.dy - p1.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    final count = (distance / (dashLength + dashSpace)).floor();
    for (int i = 0; i < count; i++) {
      final startT = (i * (dashLength + dashSpace)) / distance;
      final endT = ((i * (dashLength + dashSpace)) + dashLength) / distance;
      canvas.drawLine(
        Offset(p1.dx + dx * startT, p1.dy + dy * startT),
        Offset(p1.dx + dx * endT, p1.dy + dy * endT),
        paint,
      );
    }
  }

  void _drawLine3D(Canvas canvas, Size size, v64.Vector3 a, v64.Vector3 b, Paint paint, {bool isDashed = false}) {
    final p1 = _project(a, size);
    final p2 = _project(b, size);
    if (p1 == null || p2 == null) return;
    if (isDashed) {
      _drawDashedLine2D(canvas, p1, p2, paint);
    } else {
      canvas.drawLine(p1, p2, paint);
    }
  }

  void _drawBox3D(Canvas canvas, Size size, double x1, double x2, double z1, double z2, Paint paint) {
    _drawLine3D(canvas, size, v64.Vector3(x1, 0, z1), v64.Vector3(x2, 0, z1), paint);
    _drawLine3D(canvas, size, v64.Vector3(x2, 0, z1), v64.Vector3(x2, 0, z2), paint);
    _drawLine3D(canvas, size, v64.Vector3(x2, 0, z2), v64.Vector3(x1, 0, z2), paint);
    _drawLine3D(canvas, size, v64.Vector3(x1, 0, z2), v64.Vector3(x1, 0, z1), paint);
  }

  void _drawCircle3D(Canvas canvas, Size size, v64.Vector3 center, double radius, Paint paint) {
    const segments = 48;
    Offset? prev;
    Offset? first;
    for (int i = 0; i <= segments; i++) {
      final theta = (i / segments) * 2 * math.pi;
      final pt3D = v64.Vector3(center.x + radius * math.cos(theta), 0, center.z + radius * math.sin(theta));
      final pt2D = _project(pt3D, size);
      if (pt2D != null) {
        first ??= pt2D;
        if (prev != null) canvas.drawLine(prev, pt2D, paint);
        prev = pt2D;
      }
    }
    if (prev != null && first != null) canvas.drawLine(prev, first, paint);
  }

  @override
  bool shouldRepaint(covariant Pitch3DPainter oldDelegate) => true;
}
