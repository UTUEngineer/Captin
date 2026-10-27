import 'dart:math' as math;

import 'package:captain/features/tactical_board/application/tactic_playback.dart';
import 'package:captain/features/tactical_board/application/tactical_board_notifier.dart';
import 'package:captain/features/tactical_board/domain/arrow.dart';
import 'package:captain/features/tactical_board/domain/player.dart';
import 'package:captain/features/tactical_board/domain/zone.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:three_js/three_js.dart' as three;

const footballerModelAsset = 'assets/models/footballer.glb';

/// FIFA pitch, metres.
const _pitchLength = 105.0;
const _pitchWidth = 68.0;

/// Players are drawn larger than life so they read from a broadcast camera.
const _playerScale = 2.3;

enum Board3DCamera { broadcast, tactical, behindGoal }

/// Live 3D rendering of the tactical board with animated GLB footballers.
///
/// It mirrors [tacticalBoardProvider] (positions, ball, arrows, zones) and the
/// running [tacticPlaybackProvider] frame. Players blend between `idle`,
/// `run` and `sprint` clips depending on how fast they move and turn to face
/// their direction of travel.
class Board3DView extends ConsumerStatefulWidget {
  const Board3DView({super.key, required this.size});

  final Size size;

  @override
  ConsumerState<Board3DView> createState() => _Board3DViewState();
}

class _Board3DViewState extends ConsumerState<Board3DView> {
  late final three.ThreeJS _three;
  three.OrbitControls? _controls;
  Uint8List? _modelBytes;
  bool _ready = false;
  Board3DCamera _camera = Board3DCamera.broadcast;

  final Map<String, _Footballer> _players = {};
  final three.Group _annotations = three.Group();
  three.Mesh? _ball;
  List<Arrow>? _lastArrows;
  List<Zone>? _lastZones;

  @override
  void initState() {
    super.initState();
    _three = three.ThreeJS(
      size: widget.size,
      onSetupComplete: () {
        if (mounted) setState(() => _ready = true);
      },
      setup: _setup,
      settings: three.Settings(
        enableShadowMap: false,
        antialias: true,
        clearColor: 0x0b1220,
      ),
    );
  }

  @override
  void dispose() {
    _controls?.dispose();
    _three.dispose();
    super.dispose();
  }

  // ── Coordinates ────────────────────────────────────────────────────────

  /// Board relative (x across, y along) → world (X along length, Z across).
  static three.Vector3 _world(double x, double y, [double height = 0]) {
    return three.Vector3(
      (0.5 - y) * _pitchLength,
      height,
      (x - 0.5) * _pitchWidth,
    );
  }

  // ── Scene setup ────────────────────────────────────────────────────────

  Future<void> _setup() async {
    _three.scene = three.Scene();
    _three.scene.background = three.Color.fromHex32(0x0b1220);

    _three.camera = three.PerspectiveCamera(
      38,
      _three.width / _three.height,
      0.5,
      600,
    );
    _controls = three.OrbitControls(_three.camera, _three.globalKey)
      ..enableDamping = true
      ..dampingFactor = 0.08
      ..maxPolarAngle = math.pi / 2 - 0.06
      ..minDistance = 12
      ..maxDistance = 190;
    _applyCamera(_camera);

    _three.scene.add(three.HemisphereLight(0xffffff, 0x2e4a2e, 1.1));
    final sun = three.DirectionalLight(0xffffff, 1.4);
    sun.position.setValues(-30, 70, 40);
    _three.scene.add(sun);

    _buildPitch();
    _three.scene.add(_annotations);

    final ball = three.Mesh(
      three.SphereGeometry(0.55, 20, 16),
      three.MeshStandardMaterial()
        ..color = three.Color.fromHex32(0xffffff)
        ..roughness = 0.35,
    );
    ball.visible = false;
    _ball = ball;
    _three.scene.add(ball);

    try {
      final data = await rootBundle.load(footballerModelAsset);
      _modelBytes = data.buffer.asUint8List();
    } catch (_) {
      _modelBytes = null;
    }

    await _syncPlayers(ref.read(tacticalBoardProvider).players);

    _three.addAnimationEvent((dt) => _tick(dt));
  }

  void _buildPitch() {
    // Grass with mowing stripes.
    const stripes = 14;
    for (var i = 0; i < stripes; i++) {
      final stripe = three.Mesh(
        three.PlaneGeometry(_pitchLength / stripes, _pitchWidth + 10),
        three.MeshStandardMaterial()
          ..color = three.Color.fromHex32(i.isEven ? 0x2e7d32 : 0x388e3c)
          ..roughness = 0.95,
      );
      stripe.rotation.x = -math.pi / 2;
      stripe.position.setValues(
        -_pitchLength / 2 + (i + 0.5) * _pitchLength / stripes,
        0,
        0,
      );
      _three.scene.add(stripe);
    }
    // Run-off around the pitch.
    final surround = three.Mesh(
      three.PlaneGeometry(_pitchLength + 40, _pitchWidth + 40),
      three.MeshStandardMaterial()..color = three.Color.fromHex32(0x1b5e20),
    );
    surround.rotation.x = -math.pi / 2;
    surround.position.y = -0.05;
    _three.scene.add(surround);

    final line = three.LineBasicMaterial()
      ..color = three.Color.fromHex32(0xffffff);
    void polyline(List<three.Vector3> pts) {
      _three.scene.add(
        three.Line(three.BufferGeometry().setFromPoints(pts), line),
      );
    }

    const hl = _pitchLength / 2, hw = _pitchWidth / 2, y = 0.04;
    polyline([
      three.Vector3(-hl, y, -hw),
      three.Vector3(hl, y, -hw),
      three.Vector3(hl, y, hw),
      three.Vector3(-hl, y, hw),
      three.Vector3(-hl, y, -hw),
    ]);
    polyline([three.Vector3(0, y, -hw), three.Vector3(0, y, hw)]);
    polyline([
      for (var i = 0; i <= 48; i++)
        three.Vector3(
          9.15 * math.cos(i / 48 * 2 * math.pi),
          y,
          9.15 * math.sin(i / 48 * 2 * math.pi),
        ),
    ]);
    for (final s in [-1.0, 1.0]) {
      final gx = s * hl;
      // penalty area 16.5 x 40.3, goal area 5.5 x 18.3
      polyline([
        three.Vector3(gx, y, -20.15),
        three.Vector3(gx - s * 16.5, y, -20.15),
        three.Vector3(gx - s * 16.5, y, 20.15),
        three.Vector3(gx, y, 20.15),
      ]);
      polyline([
        three.Vector3(gx, y, -9.15),
        three.Vector3(gx - s * 5.5, y, -9.15),
        three.Vector3(gx - s * 5.5, y, 9.15),
        three.Vector3(gx, y, 9.15),
      ]);
      // Goal frame.
      final post = three.MeshStandardMaterial()
        ..color = three.Color.fromHex32(0xffffff);
      for (final z in [-3.66, 3.66]) {
        final p = three.Mesh(three.CylinderGeometry(0.12, 0.12, 2.44, 8), post);
        p.position.setValues(gx, 1.22, z);
        _three.scene.add(p);
      }
      final bar = three.Mesh(three.CylinderGeometry(0.12, 0.12, 7.32, 8), post);
      bar.rotation.x = math.pi / 2;
      bar.position.setValues(gx, 2.44, 0);
      _three.scene.add(bar);
    }
  }

  void _applyCamera(Board3DCamera mode) {
    final cam = _three.camera;
    switch (mode) {
      case Board3DCamera.broadcast:
        cam.position.setValues(0, 48, 82);
      case Board3DCamera.tactical:
        cam.position.setValues(0, 125, 0.1);
      case Board3DCamera.behindGoal:
        cam.position.setValues(-88, 26, 0);
    }
    _controls?.target.setValues(0, 0, 0);
    cam.lookAt(three.Vector3(0, 0, 0));
  }

  // ── Players ────────────────────────────────────────────────────────────

  Future<void> _syncPlayers(List<Player> players) async {
    final ids = players.map((p) => p.id).toSet();
    for (final id in _players.keys.toList()) {
      if (!ids.contains(id)) {
        _three.scene.remove(_players.remove(id)!.root);
      }
    }
    for (final p in players) {
      if (_players.containsKey(p.id)) continue;
      final footballer = await _Footballer.create(
        bytes: _modelBytes,
        player: p,
      );
      footballer.root.position.setFrom(_world(p.x, p.y));
      footballer.root.rotation.y = p.isHomeTeam ? math.pi / 2 : -math.pi / 2;
      _players[p.id] = footballer;
      _three.scene.add(footballer.root);
    }
  }

  bool _syncing = false;

  void _tick(double dt) {
    _controls?.update();
    final board = ref.read(tacticalBoardProvider);
    final playbackNotifier = ref.read(tacticPlaybackProvider.notifier);
    final playback = ref.read(tacticPlaybackProvider);
    if (playback.isPlaying) {
      playbackNotifier.tick(Duration(microseconds: (dt * 1e6).round()));
    }
    final frame = ref.read(tacticPlaybackProvider).frame;

    if (!_syncing && board.players.length != _players.length) {
      _syncing = true;
      _syncPlayers(board.players).whenComplete(() => _syncing = false);
    }

    for (final p in board.players) {
      final f = _players[p.id];
      if (f == null) continue;
      final pos = frame?.players[p.id] ?? Offset(p.x, p.y);
      f.update(target: _world(pos.dx, pos.dy), dt: dt, idleFacesHome: p.isHomeTeam);
    }

    final ballPos = frame?.ball ??
        (board.ball == null ? null : Offset(board.ball!.x, board.ball!.y));
    final ball = _ball;
    if (ball != null) {
      ball.visible = ballPos != null;
      if (ballPos != null) {
        final target = _world(ballPos.dx, ballPos.dy, 0.55);
        final k = 1 - math.exp(-dt * 14);
        final before = ball.position.clone();
        ball.position.x += (target.x - ball.position.x) * k;
        ball.position.z += (target.z - ball.position.z) * k;
        // Lofted look while travelling.
        final travel = before.distanceTo(ball.position);
        ball.position.y = 0.55 + math.min(4, travel * 6);
        ball.rotation.z -= (ball.position.x - before.x) / 0.55;
        ball.rotation.x += (ball.position.z - before.z) / 0.55;
      }
    }

    if (!identical(_lastArrows, board.arrows) ||
        !identical(_lastZones, board.zones)) {
      _lastArrows = board.arrows;
      _lastZones = board.zones;
      _rebuildAnnotations(board.arrows, board.zones);
    }
  }

  // ── Annotations ────────────────────────────────────────────────────────

  void _rebuildAnnotations(List<Arrow> arrows, List<Zone> zones) {
    _annotations.clear();
    for (final zone in zones) {
      final color = zone.colorValue & 0xFFFFFF;
      final material = three.MeshBasicMaterial()
        ..color = three.Color.fromHex32(color)
        ..transparent = true
        ..opacity = 0.28
        ..side = three.DoubleSide;
      final shape = three.Shape();
      final pts = zone.shape == ZoneShape.polygon && zone.points.length >= 6
          ? [
              for (var i = 0; i < zone.points.length; i += 2)
                _world(zone.points[i], zone.points[i + 1]),
            ]
          : [
              _world(zone.x, zone.y),
              _world(zone.x + zone.width, zone.y),
              _world(zone.x + zone.width, zone.y + zone.height),
              _world(zone.x, zone.y + zone.height),
            ];
      // Shape lives in the XY plane; rotate onto the ground (XZ).
      shape.moveTo(pts.first.x, -pts.first.z);
      for (final p in pts.skip(1)) {
        shape.lineTo(p.x, -p.z);
      }
      shape.closePath();
      final mesh = three.Mesh(three.ShapeGeometry([shape]), material);
      mesh.rotation.x = -math.pi / 2;
      mesh.position.y = 0.06;
      _annotations.add(mesh);
    }

    for (final arrow in arrows) {
      final colorValue =
          (arrow.colorValue ?? defaultArrowColor(arrow.type).toARGB32()) &
              0xFFFFFF;
      final start = _world(arrow.startX, arrow.startY, 0.15);
      final end = _world(arrow.endX, arrow.endY, 0.15);
      final c = arrowControlPoint(
        Offset(arrow.startX, arrow.startY),
        Offset(arrow.endX, arrow.endY),
        arrow.curved ? arrow.bend : 0,
      );
      final lofted = arrow.type == ArrowType.pass && arrow.curved;
      final control = _world(c.dx, c.dy, lofted ? 9 : 0.15);
      final curve = three.QuadraticBezierCurve3(start, control, end);
      final points = curve.getPoints(40).whereType<three.Vector3>().toList();
      _annotations.add(
        three.Line(
          three.BufferGeometry().setFromPoints(points),
          three.LineBasicMaterial()..color = three.Color.fromHex32(colorValue),
        ),
      );
      if (arrow.type.hasHead && points.length >= 2) {
        final head = three.Mesh(
          three.ConeGeometry(0.9, 2.4, 12),
          three.MeshBasicMaterial()..color = three.Color.fromHex32(colorValue),
        );
        final tip = points.last;
        final prev = points[points.length - 2];
        head.position.setFrom(tip);
        // Cone points +Y; aim it along the last segment.
        final dir = three.Vector3(tip.x - prev.x, tip.y - prev.y, tip.z - prev.z)
          ..normalize();
        head.quaternion.setFromUnitVectors(three.Vector3(0, 1, 0), dir);
        _annotations.add(head);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: _three.build()),
        if (!_ready)
          const Center(child: CircularProgressIndicator()),
        Positioned(
          top: 12,
          right: 12,
          child: Material(
            color: const Color(0xE60F172A),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final mode in Board3DCamera.values)
                    IconButton(
                      tooltip: switch (mode) {
                        Board3DCamera.broadcast => 'Broadcast camera',
                        Board3DCamera.tactical => 'Top-down tactical camera',
                        Board3DCamera.behindGoal => 'Behind the goal',
                      },
                      isSelected: _camera == mode,
                      color: Colors.white70,
                      selectedIcon: Icon(
                        _cameraIcon(mode),
                        color: const Color(0xFF10B981),
                      ),
                      icon: Icon(_cameraIcon(mode)),
                      onPressed: () {
                        setState(() => _camera = mode);
                        _applyCamera(mode);
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  IconData _cameraIcon(Board3DCamera mode) => switch (mode) {
        Board3DCamera.broadcast => Icons.videocam_outlined,
        Board3DCamera.tactical => Icons.grid_on_rounded,
        Board3DCamera.behindGoal => Icons.sports_soccer_outlined,
      };
}

/// One animated player: GLB model + team ring + animation mixer.
class _Footballer {
  _Footballer._(this.root, this._mixer, this._actions);

  final three.Group root;
  final three.AnimationMixer? _mixer;
  final Map<String, three.AnimationAction> _actions;
  String? _current;
  double _speed = 0;
  three.Vector3? _last;

  static Future<_Footballer> create({
    required Uint8List? bytes,
    required Player player,
  }) async {
    final root = three.Group();
    final isGk = (player.label ?? '').toUpperCase() == 'GK';
    final kit = isGk
        ? 0xf59e0b
        : (player.isHomeTeam ? 0x2563eb : 0xdc2626);
    final shorts = player.isHomeTeam ? 0xffffff : 0x111827;

    // Team ring on the grass.
    final ring = three.Mesh(
      three.CircleGeometry(radius: 1.25, segments: 28),
      three.MeshBasicMaterial()
        ..color = three.Color.fromHex32(kit)
        ..transparent = true
        ..opacity = 0.55,
    );
    ring.rotation.x = -math.pi / 2;
    ring.position.y = 0.05;
    root.add(ring);

    three.AnimationMixer? mixer;
    final actions = <String, three.AnimationAction>{};
    three.GLTFData? gltf;
    if (bytes != null) {
      try {
        gltf = await three.GLTFLoader().fromBytes(bytes);
      } catch (_) {
        gltf = null;
      }
    }

    if (gltf != null) {
      final model = gltf.scene;
      model.scale.setValues(_playerScale, _playerScale, _playerScale);
      model.traverse((child) {
        if (child is! three.Mesh) return;
        final name = child.name;
        int? color;
        if (name.startsWith('Kit_Jersey') || name.startsWith('Kit_Socks')) {
          color = kit;
        } else if (name.startsWith('Kit_Shorts')) {
          color = shorts;
        }
        if (color != null) {
          child.material = three.MeshStandardMaterial()
            ..color = three.Color.fromHex32(color)
            ..roughness = 0.75;
        }
      });
      root.add(model);
      mixer = three.AnimationMixer(model);
      for (final clip in gltf.animations ?? const []) {
        if (clip is! three.AnimationClip) continue;
        final action = mixer.clipAction(clip);
        if (action != null) actions[clip.name] = action;
      }
    } else {
      // Fallback capsule when the model is unavailable.
      final body = three.Mesh(
        three.CylinderGeometry(0.9, 0.9, 3.6, 16),
        three.MeshStandardMaterial()..color = three.Color.fromHex32(kit),
      );
      body.position.y = 1.8;
      root.add(body);
    }

    final f = _Footballer._(root, mixer, actions);
    f._play('idle');
    return f;
  }

  void _play(String name) {
    if (_current == name) return;
    final next = _actions[name];
    if (next == null) return;
    final prev = _current == null ? null : _actions[_current];
    next
      ..reset()
      ..play();
    if (prev != null) {
      next.crossFadeFrom(prev, 0.25);
    }
    _current = name;
  }

  void update({
    required three.Vector3 target,
    required double dt,
    required bool idleFacesHome,
  }) {
    final pos = root.position;
    final k = 1 - math.exp(-dt * 9);
    final dx = (target.x - pos.x) * k;
    final dz = (target.z - pos.z) * k;
    pos.x += dx;
    pos.z += dz;

    final moved = math.sqrt(dx * dx + dz * dz);
    final instantSpeed = dt > 0 ? moved / dt : 0.0;
    _speed += (instantSpeed - _speed) * math.min(1, dt * 8);

    if (moved > 0.002) {
      final heading = math.atan2(dx, dz);
      var diff = heading - root.rotation.y;
      while (diff > math.pi) {
        diff -= 2 * math.pi;
      }
      while (diff < -math.pi) {
        diff += 2 * math.pi;
      }
      root.rotation.y += diff * math.min(1, dt * 10);
    }

    if (_speed > 14) {
      _play('sprint');
    } else if (_speed > 1.6) {
      _play('run');
    } else {
      _play('idle');
    }
    final action = _current == null ? null : _actions[_current];
    if (action != null && _current != 'idle') {
      action.timeScale = (_speed / (_current == 'sprint' ? 16 : 7)).clamp(0.7, 1.6);
    }
    _mixer?.update(dt);
    _last = pos.clone();
  }

  three.Vector3? get lastPosition => _last;
}
