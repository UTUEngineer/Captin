import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:vector_math/vector_math_64.dart' as v64;

import '../features/tactics/tactical_keyframe_engine.dart';
import '../features/tactics/tactical_sequence_controller.dart';

class KeyframeSequencePlaygroundScreen extends StatefulWidget {
  const KeyframeSequencePlaygroundScreen({super.key});

  @override
  State<KeyframeSequencePlaygroundScreen> createState() => _KeyframeSequencePlaygroundScreenState();
}

class _KeyframeSequencePlaygroundScreenState extends State<KeyframeSequencePlaygroundScreen>
    with SingleTickerProviderStateMixin {
  late final TacticalSequenceController _controller;
  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

  // Camera Settings
  double _cameraAzimuth = math.pi / 2.3;
  double _cameraElevation = 0.58;
  final double _cameraDistance = 88.0;

  @override
  void initState() {
    super.initState();
    _controller = TacticalSequenceController();
    _seedDefaultSequence();

    _ticker = createTicker((elapsed) {
      if (_lastElapsed != Duration.zero) {
        final dt = (elapsed - _lastElapsed).inMicroseconds / 1000000.0;
        _controller.advanceTime(dt);
      }
      _lastElapsed = elapsed;
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _seedDefaultSequence() {
    // Initial State: Midfield Build-up (Phase 1)
    final p1 = <String, EntityStateSnapshot>{
      'ball': EntityStateSnapshot(id: 'ball', position: v64.Vector3(-15, 0.2, 0), headingRadians: 0),
      'h_dm': EntityStateSnapshot(id: 'h_dm', position: v64.Vector3(-16, 0, 0), headingRadians: 0),
      'h_rw': EntityStateSnapshot(id: 'h_rw', position: v64.Vector3(5, 0, 24), headingRadians: 0),
      'h_st': EntityStateSnapshot(id: 'h_st', position: v64.Vector3(12, 0, -2), headingRadians: 0),
      'h_lw': EntityStateSnapshot(id: 'h_lw', position: v64.Vector3(6, 0, -22), headingRadians: 0),
      'a_cb1': EntityStateSnapshot(id: 'a_cb1', position: v64.Vector3(26, 0, 6), headingRadians: math.pi),
      'a_cb2': EntityStateSnapshot(id: 'a_cb2', position: v64.Vector3(26, 0, -6), headingRadians: math.pi),
    };
    _controller.addKeyframe(name: '1. Build-up', currentState: p1, duration: 0.0);

    // Keyframe 2: Wing Overload & Run in behind (Phase 2)
    final p2 = <String, EntityStateSnapshot>{
      'ball': EntityStateSnapshot(id: 'ball', position: v64.Vector3(18, 0.2, 26), headingRadians: 0),
      'h_dm': EntityStateSnapshot(id: 'h_dm', position: v64.Vector3(-4, 0, 8), headingRadians: 0.3),
      'h_rw': EntityStateSnapshot(id: 'h_rw', position: v64.Vector3(20, 0, 25), headingRadians: 0.1),
      'h_st': EntityStateSnapshot(id: 'h_st', position: v64.Vector3(28, 0, 2), headingRadians: 0.2),
      'h_lw': EntityStateSnapshot(id: 'h_lw', position: v64.Vector3(22, 0, -14), headingRadians: 0.4),
      'a_cb1': EntityStateSnapshot(id: 'a_cb1', position: v64.Vector3(30, 0, 14), headingRadians: math.pi - 0.4),
      'a_cb2': EntityStateSnapshot(id: 'a_cb2', position: v64.Vector3(32, 0, -2), headingRadians: math.pi),
    };
    _controller.addKeyframe(name: '2. Wing Overload', currentState: p2, duration: 2.5);

    // Keyframe 3: Cutback & Box Finish (Phase 3)
    final p3 = <String, EntityStateSnapshot>{
      'ball': EntityStateSnapshot(id: 'ball', position: v64.Vector3(34, 0.2, 4), headingRadians: 0),
      'h_dm': EntityStateSnapshot(id: 'h_dm', position: v64.Vector3(12, 0, 10), headingRadians: 0.2),
      'h_rw': EntityStateSnapshot(id: 'h_rw', position: v64.Vector3(38, 0, 20), headingRadians: -math.pi / 2),
      'h_st': EntityStateSnapshot(id: 'h_st', position: v64.Vector3(35, 0, 3), headingRadians: 0),
      'h_lw': EntityStateSnapshot(id: 'h_lw', position: v64.Vector3(32, 0, -6), headingRadians: 0.5),
      'a_cb1': EntityStateSnapshot(id: 'a_cb1', position: v64.Vector3(36, 0, 8), headingRadians: math.pi),
      'a_cb2': EntityStateSnapshot(id: 'a_cb2', position: v64.Vector3(36, 0, 0), headingRadians: math.pi),
    };
    _controller.addKeyframe(name: '3. Cutback Finish', currentState: p3, duration: 2.0);
  }

  void _recordCurrentAsNewKeyframe() {
    final activeKeyframe = _controller.keyframes[_controller.activeKeyframeIndex];
    final currentSnapshots = <String, EntityStateSnapshot>{};

    for (final entry in activeKeyframe.snapshots.entries) {
      final evaluated = _controller.evaluateEntity(entry.key);
      currentSnapshots[entry.key] = evaluated ?? entry.value.copyWith();
    }

    _controller.addKeyframe(
      name: 'Phase ${_controller.keyframes.length + 1}',
      currentState: currentSnapshots,
      duration: 2.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D14),
      appBar: AppBar(
        title: const Text(
          '3D TACTICAL KEYFRAME PLAYGROUND',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        backgroundColor: const Color(0xFF161B26),
        actions: [
          IconButton(
            tooltip: 'Record Keyframe Snapshot',
            icon: const Icon(Icons.add_photo_alternate, color: Color(0xFF00E676)),
            onPressed: _recordCurrentAsNewKeyframe,
          ),
          IconButton(
            tooltip: 'Delete Current Keyframe',
            icon: const Icon(Icons.delete_sweep, color: Colors.white70),
            onPressed: () => _controller.removeKeyframe(_controller.activeKeyframeIndex),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Stack(
            children: [
              // 3D Canvas
              GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _cameraAzimuth -= details.delta.dx * 0.007;
                    _cameraElevation = (_cameraElevation + details.delta.dy * 0.007).clamp(0.12, 1.4);
                  });
                },
                child: CustomPaint(
                  size: Size.infinite,
                  painter: KeyframeScene3DPainter(
                    controller: _controller,
                    cameraAzimuth: _cameraAzimuth,
                    cameraElevation: _cameraElevation,
                    cameraDistance: _cameraDistance,
                  ),
                ),
              ),

              // Bottom Control Dock & Interactive Timeline Scrubbing Bar
              Positioned(
                bottom: 20,
                left: 16,
                right: 16,
                child: _buildTimelineTransportDock(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTimelineTransportDock() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF131822).withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 16, offset: Offset(0, 4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: Keyframe Phase Chips
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _controller.keyframes.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final kf = _controller.keyframes[idx];
                final isSelected = _controller.activeKeyframeIndex == idx;
                return ChoiceChip(
                  label: Text(kf.name, style: TextStyle(color: isSelected ? Colors.black : Colors.white, fontSize: 11)),
                  selected: isSelected,
                  selectedColor: const Color(0xFF00E676),
                  backgroundColor: const Color(0xFF1E2638),
                  onSelected: (_) => _controller.selectKeyframe(idx),
                );
              },
            ),
          ),
          const SizedBox(height: 10),

          // Row 2: Scrubbing Slider with time counter
          Row(
            children: [
              Text(
                '${_controller.currentTime.toStringAsFixed(1)}s',
                style: const TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 12),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFF00E676),
                    inactiveTrackColor: Colors.white12,
                    thumbColor: const Color(0xFF00E676),
                    trackHeight: 3.0,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  ),
                  child: Slider(
                    value: _controller.currentTime.clamp(0.0, _controller.totalDuration),
                    min: 0.0,
                    max: math.max(0.001, _controller.totalDuration),
                    onChanged: (v) => _controller.seekTo(v),
                  ),
                ),
              ),
              Text(
                '${_controller.totalDuration.toStringAsFixed(1)}s',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),

          // Row 3: Playback Transport Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: Playback speeds
              Row(
                children: [0.5, 1.0, 1.5, 2.0].map((speed) {
                  final active = _controller.playbackSpeed == speed;
                  return InkWell(
                    onTap: () => _controller.setPlaybackSpeed(speed),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        color: active ? const Color(0xFF2979FF) : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${speed}x',
                        style: TextStyle(
                          color: active ? Colors.white : Colors.white60,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              // Center: Step Prev, Play/Pause, Step Next
              Row(
                children: [
                  IconButton(
                    iconSize: 20,
                    icon: const Icon(Icons.skip_previous, color: Colors.white70),
                    onPressed: () {
                      if (_controller.activeKeyframeIndex > 0) {
                        _controller.selectKeyframe(_controller.activeKeyframeIndex - 1);
                      }
                    },
                  ),
                  InkWell(
                    onTap: _controller.togglePlayPause,
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Color(0xFF00E676), shape: BoxShape.circle),
                      child: Icon(
                        _controller.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.black,
                        size: 22,
                      ),
                    ),
                  ),
                  IconButton(
                    iconSize: 20,
                    icon: const Icon(Icons.skip_next, color: Colors.white70),
                    onPressed: () {
                      if (_controller.activeKeyframeIndex < _controller.keyframes.length - 1) {
                        _controller.selectKeyframe(_controller.activeKeyframeIndex + 1);
                      }
                    },
                  ),
                ],
              ),

              // Right: Loop toggle
              IconButton(
                iconSize: 18,
                tooltip: 'Loop Playback',
                icon: Icon(
                  Icons.loop,
                  color: _controller.isLooping ? const Color(0xFF00E676) : Colors.white30,
                ),
                onPressed: _controller.toggleLooping,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==============================================================
// 4. 3D PROJECTION PAINTER WITH GHOST TRAIL INTERPOLATION
// ==============================================================

class KeyframeScene3DPainter extends CustomPainter {
  final TacticalSequenceController controller;
  final double cameraAzimuth;
  final double cameraElevation;
  final double cameraDistance;

  KeyframeScene3DPainter({
    required this.controller,
    required this.cameraAzimuth,
    required this.cameraElevation,
    required this.cameraDistance,
  });

  Offset? _project(v64.Vector3 world, Size size, v64.Matrix4 vp) {
    final v4 = v64.Vector4(world.x, world.y, world.z, 1.0);
    final clip = vp.transformed(v4);
    if (clip.w <= 0.001) return null;
    final ndcX = clip.x / clip.w;
    final ndcY = clip.y / clip.w;
    return Offset((ndcX + 1.0) * 0.5 * size.width, (1.0 - ndcY) * 0.5 * size.height);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final eye = v64.Vector3(
      cameraDistance * math.cos(cameraElevation) * math.sin(cameraAzimuth),
      cameraDistance * math.sin(cameraElevation),
      cameraDistance * math.cos(cameraElevation) * math.cos(cameraAzimuth),
    );
    final view = v64.makeViewMatrix(eye, v64.Vector3(0, 0, 0), v64.Vector3(0, 1, 0));
    final proj = v64.makePerspectiveMatrix(v64.radians(45.0), size.width / size.height, 0.5, 500.0);
    final vp = proj * view;

    _drawGrassAndPitch(canvas, size, vp);
    _drawInterpolatedGhostTrails(canvas, size, vp);
    _drawLiveEntities(canvas, size, vp, eye);
  }

  void _drawGrassAndPitch(Canvas canvas, Size size, v64.Matrix4 vp) {
    const l2 = 52.5;
    const w2 = 34.0;
    final corners = [
      _project(v64.Vector3(-l2, 0, -w2), size, vp),
      _project(v64.Vector3(l2, 0, -w2), size, vp),
      _project(v64.Vector3(l2, 0, w2), size, vp),
      _project(v64.Vector3(-l2, 0, w2), size, vp),
    ];
    if (corners.any((c) => c == null)) return;

    final turfPath = Path()
      ..moveTo(corners[0]!.dx, corners[0]!.dy)
      ..lineTo(corners[1]!.dx, corners[1]!.dy)
      ..lineTo(corners[2]!.dx, corners[2]!.dy)
      ..lineTo(corners[3]!.dx, corners[3]!.dy)
      ..close();

    canvas.drawPath(turfPath, Paint()..color = const Color(0xFF1B382B));

    // Pitch Outline
    final linePaint = Paint()
      ..color = Colors.white54
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawPath(turfPath, linePaint);

    // Halfway Line
    final h1 = _project(v64.Vector3(0, 0, -w2), size, vp);
    final h2 = _project(v64.Vector3(0, 0, w2), size, vp);
    if (h1 != null && h2 != null) canvas.drawLine(h1, h2, linePaint);
  }

  void _drawInterpolatedGhostTrails(Canvas canvas, Size size, v64.Matrix4 vp) {
    if (controller.keyframes.length < 2) return;

    // Draw spline trajectory paths for each entity across all keyframes
    final firstKf = controller.keyframes.first;
    for (final entityId in firstKf.snapshots.keys) {
      final isBall = entityId == 'ball';
      final pathPaint = Paint()
        ..color = isBall ? const Color(0xFFFFD700).withValues(alpha: 0.4) : const Color(0xFF2979FF).withValues(alpha: 0.35)
        ..strokeWidth = isBall ? 1.5 : 2.0
        ..style = PaintingStyle.stroke;

      Offset? prevPoint;
      const samplesPerSegment = 20;

      for (int i = 1; i < controller.keyframes.length; i++) {
        final k0 = controller.keyframes[math.max(0, i - 2)].snapshots[entityId];
        final k1 = controller.keyframes[i - 1].snapshots[entityId];
        final k2 = controller.keyframes[i].snapshots[entityId];
        final k3 = controller.keyframes[math.min(controller.keyframes.length - 1, i + 1)].snapshots[entityId];

        if (k1 == null || k2 == null) continue;

        for (int step = 0; step <= samplesPerSegment; step++) {
          final t = step / samplesPerSegment;
          final pos = KeyframeInterpolator.interpolateHermite(
            k0?.position ?? k1.position,
            k1.position,
            k2.position,
            k3?.position ?? k2.position,
            t,
          );
          final elev = isBall ? KeyframeInterpolator.computeBallParabola(k1.elevation, k2.elevation, 4.0, t) : 0.0;
          final screenPt = _project(v64.Vector3(pos.x, pos.y + elev, pos.z), size, vp);

          if (screenPt != null && prevPoint != null) {
            canvas.drawLine(prevPoint, screenPt, pathPaint);
          }
          prevPoint = screenPt;
        }
      }
    }
  }

  void _drawLiveEntities(Canvas canvas, Size size, v64.Matrix4 vp, v64.Vector3 eye) {
    if (controller.keyframes.isEmpty) return;

    final firstKf = controller.keyframes.first;
    for (final entityId in firstKf.snapshots.keys) {
      final state = controller.evaluateEntity(entityId);
      if (state == null) continue;

      if (entityId == 'ball') {
        final groundPt = _project(v64.Vector3(state.position.x, 0, state.position.z), size, vp);
        final ballPt = _project(v64.Vector3(state.position.x, state.position.y + state.elevation, state.position.z), size, vp);
        if (ballPt != null) {
          if (groundPt != null && state.elevation > 0.3) {
            canvas.drawCircle(groundPt, 4.0, Paint()..color = Colors.black45);
            canvas.drawLine(groundPt, ballPt, Paint()..color = Colors.white24..strokeWidth = 1.0);
          }
          canvas.drawCircle(ballPt, 6.0, Paint()..color = Colors.white);
          canvas.drawCircle(ballPt, 4.0, Paint()..color = Colors.black87..style = PaintingStyle.stroke..strokeWidth = 1.2);
        }
        continue;
      }

      // Player Cylinders
      final basePt = _project(v64.Vector3(state.position.x, 0, state.position.z), size, vp);
      final headPt = _project(v64.Vector3(state.position.x, 1.85, state.position.z), size, vp);
      if (basePt == null || headPt == null) continue;

      // Ground Cast Shadow
      canvas.drawOval(
        Rect.fromCenter(center: basePt, width: 14.0, height: 7.0),
        Paint()..color = Colors.black.withValues(alpha: 0.4),
      );

      final isHome = entityId.startsWith('h_');
      final playerColor = isHome ? const Color(0xFF2979FF) : const Color(0xFFFF1744);

      // Player 3D Extrusion
      canvas.drawLine(
        basePt,
        headPt,
        Paint()
          ..color = playerColor
          ..strokeWidth = 12.0
          ..strokeCap = StrokeCap.round,
      );

      // Directional Heading Indicator (facing vector)
      final forwardWorld = v64.Vector3(
        state.position.x + math.cos(state.headingRadians) * 1.5,
        0.2,
        state.position.z + math.sin(state.headingRadians) * 1.5,
      );
      final forwardPt = _project(forwardWorld, size, vp);
      if (forwardPt != null) {
        canvas.drawLine(
          basePt,
          forwardPt,
          Paint()
            ..color = const Color(0xFF00E676)
            ..strokeWidth = 2.5,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant KeyframeScene3DPainter oldDelegate) => true;
}
