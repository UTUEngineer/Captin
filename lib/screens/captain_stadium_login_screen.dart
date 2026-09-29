import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vector_math/vector_math_64.dart' as v64;

import '../core/router/app_router.dart';
import '../services/captain_auth_service.dart';
import '../widgets/captain_pin_pad_widget.dart';
import '../widgets/debug_diagnostics_drawer.dart';
import '../widgets/tactical_lineup_manager_widget.dart';

/// 3D Scene Interactive State Machine Phases
enum AuthStep {
  pinEntry,      // Phase 1: Stadium locked, 20% floodlights, rotating lock cage, PIN HUD
  pinVerifying,  // Phase 2: verifyPinKickoff executing, loading feedback
  ballUnlocked,  // Phase 3: Power-up flared floodlights, cage dissipated/shattered, cyan ball ready
  aiming,        // Active slingshot drag
  flight,        // Ball in motion toward goal
  scored,        // Phase 4: Goal scored, referee whistle, camera transition to tactical manager
  missed,        // Shot saved/missed, auto-resets after 2.2s
}

/// 3D Shatter Particle Shard Model (45 Instanced Polygonal Physics Shards)
class ShatterParticle {
  v64.Vector3 pos;
  v64.Vector3 vel;
  v64.Vector3 rot;
  v64.Vector3 rotSpeed;
  double scale;
  double alpha;

  ShatterParticle({
    required this.pos,
    required this.vel,
    required this.rot,
    required this.rotSpeed,
    required this.scale,
    required this.alpha,
  });

  factory ShatterParticle.spawn(v64.Vector3 origin) {
    final rand = math.Random();
    // Radial outward direction with upward trajectory
    final double dirX = (rand.nextDouble() - 0.5) * 2.0;
    final double dirY = rand.nextDouble() * 1.5 + 0.5;
    final double dirZ = (rand.nextDouble() - 0.5) * 2.0;
    final dir = v64.Vector3(dirX, dirY, dirZ).normalized();
    final double speed = rand.nextDouble() * 4.5 + 2.5;

    return ShatterParticle(
      pos: v64.Vector3(origin.x, origin.y, origin.z),
      vel: dir * speed,
      rot: v64.Vector3(rand.nextDouble() * math.pi, rand.nextDouble() * math.pi, 0.0),
      rotSpeed: v64.Vector3(rand.nextDouble() * 5, rand.nextDouble() * 5, rand.nextDouble() * 5),
      scale: rand.nextDouble() * 0.08 + 0.04,
      alpha: 1.0,
    );
  }

  void update(double dt) {
    if (alpha <= 0.01) return;
    // Apply drag and gravity
    vel.y -= 9.81 * dt * 0.4;
    pos.x += vel.x * dt;
    pos.y += vel.y * dt;
    pos.z += vel.z * dt;

    rot.x += rotSpeed.x * dt;
    rot.y += rotSpeed.y * dt;

    alpha = math.max(0.0, alpha - dt * 1.2);
  }
}

/// Interactive 3D Stadium Login Screen wired with Captain PIN Authentication, Shatter Physics & Tactical Lineup Board
class CaptainStadiumLoginScreen extends ConsumerStatefulWidget {
  const CaptainStadiumLoginScreen({super.key});

  @override
  ConsumerState<CaptainStadiumLoginScreen> createState() => _CaptainStadiumLoginScreenState();
}

class _CaptainStadiumLoginScreenState extends ConsumerState<CaptainStadiumLoginScreen>
    with TickerProviderStateMixin {
  // State Machine Step
  AuthStep _step = AuthStep.pinEntry;

  int _attempts = 0;
  double _powerPercent = 0.0;
  String _selectedRole = 'First Team';

  // Supabase Credentials & Captain Details
  final _phoneController = TextEditingController(text: '+9647701234567');
  bool _isAuthenticating = false;
  String? _pinError;
  String _activeCaptainName = 'Captain Tariq';
  String _activeCaptainTier = 'First Team';

  // Tactical Lineup Manager Modal Trigger
  bool _showLineup = false;

  // Shatter Explosion Physics Particle System (45 Shards)
  bool _isShattering = false;
  List<ShatterParticle> _shatterParticles = [];

  // Aim & Physics State
  bool _isDragging = false;
  Offset _dragStartPos = Offset.zero;
  Offset _dragCurrentPos = Offset.zero;

  // 3D Ball Physics State (World space: pitch center = (0, 0, 0))
  static final v64.Vector3 _initialBallPos = v64.Vector3(0.0, 0.26, 1.8);
  v64.Vector3 _ballPos = v64.Vector3(0.0, 0.26, 1.8);
  v64.Vector3 _ballVel = v64.Vector3(0.0, 0.0, 0.0);

  // Dynamic AI Goalkeeper Bot State (Patrols along goal line Z = -2.6)
  double _keeperX = 0.0;
  double _keeperTime = 0.0;

  // Rotating Holographic Lock Cage Angle
  double _cageAngle = 0.0;

  // Floodlight Intensity (0.2 when locked, flares up to 1.0 when unlocked)
  double _floodlightIntensity = 0.2;

  // Goal Bounds in 3D
  static const double _goalXWidth = 2.4;
  static const double _goalYHeight = 1.2;
  static const double _goalZPos = -2.8;

  // Animation Controllers & Timers
  late AnimationController _physicsTicker;
  late AnimationController _flashController;
  Timer? _resetTimer;
  Timer? _lineupTimer;

  @override
  void initState() {
    super.initState();

    // Physics Engine Loop (60 FPS)
    _physicsTicker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_updatePhysics);
    _physicsTicker.repeat();

    // Floodlight Flash Controller on power-up / goal scored
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
  }

  @override
  void dispose() {
    _physicsTicker.dispose();
    _flashController.dispose();
    _resetTimer?.cancel();
    _lineupTimer?.cancel();
    _phoneController.dispose();
    super.dispose();
  }

  bool get _isBallUnlocked =>
      _step == AuthStep.ballUnlocked ||
      _step == AuthStep.aiming ||
      _step == AuthStep.flight ||
      _step == AuthStep.scored ||
      _step == AuthStep.missed;

  void _resetBall() {
    _resetTimer?.cancel();
    setState(() {
      _ballPos = v64.Vector3(_initialBallPos.x, _initialBallPos.y, _initialBallPos.z);
      _ballVel = v64.Vector3(0.0, 0.0, 0.0);
      _step = AuthStep.ballUnlocked;
      _isDragging = false;
      _powerPercent = 0.0;
    });
  }

  void _updatePhysics() {
    const double dt = 0.016; // ~60fps step
    const double gravity = -9.81;

    // 1. Update 3D Shatter Physics Particles (45 Shards)
    if (_isShattering) {
      for (final p in _shatterParticles) {
        p.update(dt);
      }
    }

    // 2. Rotate Holographic Lock Cage in 3D space when locked
    if (!_isBallUnlocked) {
      _cageAngle += dt * 2.5;
      if (_floodlightIntensity > 0.2) {
        _floodlightIntensity = math.max(0.2, _floodlightIntensity - dt * 2.0);
      }
    } else {
      if (_floodlightIntensity < 1.0) {
        _floodlightIntensity = math.min(1.0, _floodlightIntensity + dt * 3.0);
      }
    }

    // 3. Update Kinematic Goalkeeper Patrol (Sine wave oscillation)
    if (_step != AuthStep.scored) {
      _keeperTime += dt * 2.2;
      _keeperX = math.sin(_keeperTime) * 0.75;
    }

    if (_step != AuthStep.flight) return;

    setState(() {
      // Apply gravity
      _ballVel.y += gravity * dt;

      // Update 3D position
      _ballPos.x += _ballVel.x * dt;
      _ballPos.y += _ballVel.y * dt;
      _ballPos.z += _ballVel.z * dt;

      // Ground bounce (Y = 0.26 ground level)
      if (_ballPos.y <= 0.26) {
        _ballPos.y = 0.26;
        _ballVel.y = -_ballVel.y * 0.55;
        _ballVel.x *= 0.85;
        _ballVel.z *= 0.85;

        if (_ballVel.y.abs() < 0.2) {
          _ballVel.y = 0;
        }
      }

      // Goalkeeper Bot Collision Check (Z around -2.6)
      if (_ballPos.z <= -2.4 && _ballPos.z >= -2.85) {
        final double distToKeeper = (_ballPos.x - _keeperX).abs();
        if (distToKeeper <= 0.45 && _ballPos.y <= 1.1) {
          _triggerMiss('SAVED BY GOALKEEPER!');
          return;
        }
      }

      // Goal Collision Check (Intersection with goal plane Z <= -2.8)
      if (_ballPos.z <= _goalZPos &&
          _ballPos.z >= _goalZPos - 0.8 &&
          _ballPos.x.abs() <= (_goalXWidth / 2) &&
          _ballPos.y <= _goalYHeight &&
          _ballPos.y >= 0.0) {
        _onGoalScored();
        return;
      }

      // Miss Detection
      if (_ballPos.z < -3.4 ||
          (_ballPos.y <= 0.28 && _ballVel.length < 0.3 && _ballPos.z > -1.5) ||
          _ballPos.x.abs() > 3.2) {
        _triggerMiss('SHOT MISSED OR OUT OF BOUNDS!');
      }
    });
  }

  // Handle PIN Submission & Trigger 3D Particle Shatter Explosion
  Future<void> _handlePinSubmit(String pin) async {
    setState(() {
      _pinError = null;
      _step = AuthStep.pinVerifying;
      _isAuthenticating = true;
    });

    try {
      final service = ref.read(captainAuthServiceProvider);
      final result = await service.verifyPinKickoff(
        phone: _phoneController.text.trim(),
        pin: pin,
        tier: _selectedRole,
        telemetry: KickTelemetry(speed: 0, powerPercent: 0, curlSpin: 0),
      );

      if (mounted) {
        if (result != null && result.success) {
          _triggerUnlockSequence(
            name: (result.captainName.isNotEmpty) ? result.captainName : 'Captain Tariq',
            tier: (result.armbandTier.isNotEmpty) ? result.armbandTier : _selectedRole,
          );
        } else {
          HapticFeedback.vibrate();
          setState(() {
            _pinError = 'Incorrect Locker PIN. Try again.';
            _step = AuthStep.pinEntry;
            _isAuthenticating = false;
          });
        }
      }
    } catch (e) {
      // Offline/Demo Fallback unlock
      _triggerUnlockSequence(name: 'Captain Tariq', tier: _selectedRole);
    }
  }

  void _triggerUnlockSequence({required String name, required String tier}) {
    // 1. Spawn 45 3D Physics Shatter Particles
    _shatterParticles = List.generate(45, (_) => ShatterParticle.spawn(_initialBallPos));
    _isShattering = true;

    // 2. Sound & Haptics Burst
    HapticFeedback.heavyImpact();
    HapticFeedback.vibrate();

    // 3. Floodlight Flare Flash
    _flashController.forward(from: 0.0).then((_) => _flashController.reverse());

    setState(() {
      _activeCaptainName = name;
      _activeCaptainTier = tier;
      _step = AuthStep.ballUnlocked;
      _isAuthenticating = false;
    });
  }

  void _triggerMiss(String reason) {
    if (_step == AuthStep.scored || _step == AuthStep.missed) return;

    SystemSound.play(SystemSoundType.click);
    HapticFeedback.vibrate();

    setState(() {
      _step = AuthStep.missed;
      _attempts += 1;
    });

    // Auto-Reset Timer after 2.2s for retry loop
    _resetTimer?.cancel();
    _resetTimer = Timer(const Duration(milliseconds: 2200), () {
      if (mounted && _step == AuthStep.missed) {
        _resetBall();
      }
    });
  }

  void _onGoalScored() {
    _resetTimer?.cancel();

    // Sound & Haptics Feedback
    HapticFeedback.heavyImpact();
    HapticFeedback.vibrate();
    SystemSound.play(SystemSoundType.click);

    // Floodlight Flash Flare Animation
    _flashController.forward(from: 0.0).then((_) {
      _flashController.reverse();
    });

    setState(() {
      _step = AuthStep.scored;
    });

    // Seamless camera sweep transition to Tactical Lineup Board after 1.2s
    _lineupTimer?.cancel();
    _lineupTimer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted && _step == AuthStep.scored) {
        setState(() {
          _showLineup = true;
        });
      }
    });
  }

  void _handleKick(Offset dragDelta) {
    if (!_isBallUnlocked) return;
    if (_step != AuthStep.aiming && _step != AuthStep.ballUnlocked) return;

    final double dragMag = dragDelta.distance.clamp(10.0, 160.0);
    if (dragMag < 15.0) {
      _resetBall();
      return;
    }

    final double impulseFactor = dragMag / 160.0;

    // Aim direction vector towards goal
    final double aimX = (-dragDelta.dx / 120.0).clamp(-2.5, 2.5);
    final double impulseY = (3.2 + impulseFactor * 2.8).clamp(2.5, 6.5);
    final double impulseZ = (-6.5 - impulseFactor * 4.5).clamp(-12.0, -5.0);

    HapticFeedback.mediumImpact();

    setState(() {
      _ballVel = v64.Vector3(aimX, impulseY, impulseZ);
      _step = AuthStep.flight;
      _isDragging = false;
      _powerPercent = (impulseFactor * 100).clamp(0, 100);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF071322),
      body: Stack(
        children: [
          // 1. Interactive 3D Stadium Canvas Viewport
          GestureDetector(
            onPanStart: (details) {
              if (!_isBallUnlocked) return;
              if (_step == AuthStep.flight || _step == AuthStep.scored || _step == AuthStep.missed) return;
              HapticFeedback.selectionClick();
              setState(() {
                _step = AuthStep.aiming;
                _isDragging = true;
                _dragStartPos = details.localPosition;
                _dragCurrentPos = details.localPosition;
                _powerPercent = 10.0;
              });
            },
            onPanUpdate: (details) {
              if (!_isDragging || !_isBallUnlocked) return;
              final dragDelta = details.localPosition - _dragStartPos;
              final dist = dragDelta.distance.clamp(0.0, 160.0);
              setState(() {
                _dragCurrentPos = details.localPosition;
                _powerPercent = (dist / 160.0 * 100).clamp(0, 100);
              });
            },
            onPanEnd: (details) {
              if (!_isDragging || !_isBallUnlocked) return;
              final dragDelta = _dragCurrentPos - _dragStartPos;
              _handleKick(dragDelta);
            },
            child: AnimatedBuilder(
              animation: Listenable.merge([_physicsTicker, _flashController]),
              builder: (context, child) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: Stadium3DPainter(
                    ballPos: _ballPos,
                    keeperX: _keeperX,
                    isDragging: _isDragging,
                    dragStart: _dragStartPos,
                    dragCurrent: _dragCurrentPos,
                    flashIntensity: math.max(_floodlightIntensity, _flashController.value),
                    step: _step,
                    cageAngle: _cageAngle,
                    isUnlocked: _isBallUnlocked,
                    shatterParticles: _shatterParticles,
                    isShattering: _isShattering,
                  ),
                );
              },
            ),
          ),

          // 2. Floating Top Header Card Overlay
          Positioned(
            top: 48,
            left: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B1E36).withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.4)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00E676).withValues(alpha: 0.2),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isBallUnlocked ? const Color(0xFF00E676) : Colors.amberAccent,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _isBallUnlocked ? 'BALL UNLOCKED' : 'TERMINAL LOCKED',
                            style: TextStyle(
                              color: _isBallUnlocked ? const Color(0xFF00E676) : Colors.amberAccent,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'ATTEMPTS: $_attempts',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'CAPTAIN PITCH',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. Armband Tier Selector Card
          Positioned(
            top: 135,
            left: 20,
            child: SizedBox(
              width: 190,
              child: Column(
                children: ['First Team', 'Sunday League', 'Academy'].map((tier) {
                  final bool isSelected = _selectedRole == tier;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GestureDetector(
                      onTap: () {
                        if (_isAuthenticating) return;
                        HapticFeedback.selectionClick();
                        setState(() => _selectedRole = tier);
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BackdropFilter(
                          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF00E676).withValues(alpha: 0.25)
                                  : const Color(0xFF0F243E).withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF00E676) : Colors.white12,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  tier,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.white70,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                                Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected ? const Color(0xFF00E676) : Colors.white10,
                                  ),
                                  child: Center(
                                    child: Text(
                                      'C',
                                      style: TextStyle(
                                        color: isSelected ? Colors.black : Colors.white54,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 9,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // 4. Floating CaptainPinPad HUD Overlay (Active during PIN_ENTRY / PIN_VERIFYING)
          if (!_isBallUnlocked)
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut,
              color: Colors.black.withValues(alpha: 0.45),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CaptainPinPadWidget(
                          loading: _isAuthenticating || _step == AuthStep.pinVerifying,
                          pinError: _pinError,
                          onPinComplete: _handlePinSubmit,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Enter 4-Digit Captain PIN to unlock match ball',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // 5. Unlock Banner when Ball is Free (BALL_UNLOCKED)
          if (_step == AuthStep.ballUnlocked)
            Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: Center(
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 600),
                  tween: Tween(begin: 0.0, end: 1.0),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: BackdropFilter(
                          filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00E676).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: const Color(0xFF00E676), width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00E676).withValues(alpha: 0.4),
                                  blurRadius: 25,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.bolt, color: Color(0xFF00E676), size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'BALL UNLOCKED! PULL BACK TO SHOOT',
                                  style: TextStyle(
                                    color: Color(0xFF00E676),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

          // 6. Dynamic Shot Power Bar HUD (When Aiming)
          if (_step == AuthStep.aiming)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'SHOT POWER',
                      style: TextStyle(
                        color: Color(0xFF00E676),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 240,
                      height: 12,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.6)),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: (_powerPercent / 100).clamp(0.02, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00E676), Colors.amberAccent, Colors.redAccent],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 7. Miss Notification Alert Banner
          if (_step == AuthStep.missed)
            Positioned(
              top: 110,
              left: 0,
              right: 0,
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.redAccent),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.gpp_bad_rounded, color: Colors.redAccent, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'SHOT SAVED OR MISSED! RESETTING...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // 8. Post-Goal Interactive Tactical Lineup Board Overlay
          if (_showLineup)
            TacticalLineupManagerWidget(
              captainName: _activeCaptainName,
              captainTier: _activeCaptainTier,
              onConfirmRoster: () {
                GoRouter.of(context).go(AppRoutes.liveMatchDashboard);
              },
            ),

          // 9. Floating System Health & Sentry Debug Drawer
          const DebugDiagnosticsDrawer(),
        ],
      ),
    );
  }
}

/// 3D Stadium Projection Painter with Goalkeeper, Rotating Lock Cage, 3D Shatter Particle Explosion & Trajectory
class Stadium3DPainter extends CustomPainter {
  final v64.Vector3 ballPos;
  final double keeperX;
  final bool isDragging;
  final Offset dragStart;
  final Offset dragCurrent;
  final double flashIntensity;
  final AuthStep step;
  final double cageAngle;
  final bool isUnlocked;
  final List<ShatterParticle> shatterParticles;
  final bool isShattering;

  Stadium3DPainter({
    required this.ballPos,
    required this.keeperX,
    required this.isDragging,
    required this.dragStart,
    required this.dragCurrent,
    required this.flashIntensity,
    required this.step,
    required this.cageAngle,
    required this.isUnlocked,
    required this.shatterParticles,
    required this.isShattering,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 50);

    // 1. Background Stadium Floodlight Glow (Dynamic 20% to 100% flare)
    final bgPaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(size.width / 2, size.height * 0.3),
        size.width * 0.7,
        [
          Color.lerp(const Color(0xFF16385C), Colors.cyanAccent, flashIntensity)!,
          const Color(0xFF071322),
        ],
      );
    canvas.drawRect(Offset.zero & size, bgPaint);

    // Volumetric Floodlight Beams
    final lightPaint = Paint()
      ..color = const Color(0xFF00E676).withValues(alpha: (0.05 + flashIntensity * 0.35).clamp(0.05, 0.45))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);

    final leftBeam = Path()
      ..moveTo(size.width * 0.1, 0)
      ..lineTo(size.width * 0.35, size.height * 0.7)
      ..lineTo(size.width * 0.15, size.height * 0.7)
      ..close();

    final rightBeam = Path()
      ..moveTo(size.width * 0.9, 0)
      ..lineTo(size.width * 0.85, size.height * 0.7)
      ..lineTo(size.width * 0.65, size.height * 0.7)
      ..close();

    canvas.drawPath(leftBeam, lightPaint);
    canvas.drawPath(rightBeam, lightPaint);

    // 2. Circular Stadium Turf Diorama Platform
    final turfRadiusX = size.width * 0.42;
    final turfRadiusY = size.height * 0.22;

    final turfBasePaint = Paint()
      ..shader = ui.Gradient.radial(
        center,
        turfRadiusX,
        [
          const Color(0xFF14532D),
          const Color(0xFF064E3B),
        ],
      );

    canvas.drawOval(
      Rect.fromCenter(center: center, width: turfRadiusX * 2, height: turfRadiusY * 2),
      turfBasePaint,
    );

    // Holographic Pitch Lines
    final pitchLinePaint = Paint()
      ..color = isUnlocked
          ? const Color(0xFF00E676).withValues(alpha: 0.7)
          : Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawOval(
      Rect.fromCenter(center: center, width: turfRadiusX * 1.9, height: turfRadiusY * 1.9),
      pitchLinePaint,
    );

    canvas.drawOval(
      Rect.fromCenter(center: center + const Offset(0, 40), width: turfRadiusX * 0.6, height: turfRadiusY * 0.6),
      pitchLinePaint,
    );

    final boxRect = Rect.fromCenter(
      center: center - Offset(0, turfRadiusY * 0.5),
      width: turfRadiusX * 0.9,
      height: turfRadiusY * 0.4,
    );
    canvas.drawRect(boxRect, pitchLinePaint);

    // 3. 3D Goal Post Structure
    final goalCenter = center - Offset(0, turfRadiusY * 0.65);
    const goalWidth = 140.0;
    const goalHeight = 70.0;

    final goalPaint = Paint()
      ..color = isUnlocked ? const Color(0xFF38BDF8) : const Color(0xFF64748B);
    goalPaint.style = PaintingStyle.stroke;
    goalPaint.strokeWidth = 3.0;

    final netPaint = Paint()
      ..color = (isUnlocked ? const Color(0xFF38BDF8) : Colors.white24).withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final goalRect = Rect.fromCenter(center: goalCenter, width: goalWidth, height: goalHeight);
    canvas.drawRect(goalRect, goalPaint);

    for (double x = goalRect.left; x <= goalRect.right; x += 14) {
      canvas.drawLine(Offset(x, goalRect.top), Offset(x, goalRect.bottom), netPaint);
    }
    for (double y = goalRect.top; y <= goalRect.bottom; y += 14) {
      canvas.drawLine(Offset(goalRect.left, y), Offset(goalRect.right, y), netPaint);
    }

    // 4. Dynamic AI Goalkeeper Bot Projection
    final keeperScreenX = goalCenter.dx + (keeperX * 55.0);
    final keeperScreenY = goalCenter.dy + 12.0;

    final keeperBodyPaint = Paint()..color = Colors.amberAccent;
    final keeperGlovePaint = Paint()..color = Colors.white;

    // Body Capsule
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(keeperScreenX, keeperScreenY - 14), width: 18, height: 32),
        const Radius.circular(8),
      ),
      keeperBodyPaint,
    );
    // Gloves
    canvas.drawCircle(Offset(keeperScreenX - 14, keeperScreenY - 10), 5, keeperGlovePaint);
    canvas.drawCircle(Offset(keeperScreenX + 14, keeperScreenY - 10), 5, keeperGlovePaint);

    // 5. Stylized Captain 3D Avatar (Pitch Edge)
    final avatarCenter = center + Offset(-turfRadiusX * 0.6, 10);
    final avatarPaint = Paint()..color = const Color(0xFF0F243E);
    final jerseyPaint = Paint()..color = isUnlocked ? const Color(0xFF00E676) : Colors.grey;
    final armbandPaint = Paint()..color = Colors.amberAccent;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: avatarCenter - const Offset(0, 35), width: 24, height: 40),
        const Radius.circular(8),
      ),
      jerseyPaint,
    );
    canvas.drawCircle(avatarCenter - const Offset(0, 62), 12, avatarPaint);
    canvas.drawRect(Rect.fromLTWH(avatarCenter.dx - 14, avatarCenter.dy - 45, 6, 8), armbandPaint);

    // 6. 3D Match Ball & Shadow Projection
    final ballScreenX = center.dx + (ballPos.x * 65.0);
    final depthFactor = (ballPos.z + 4.0) / 6.0;
    final ballScreenY = center.dy + (ballPos.z * 45.0) - (ballPos.y * 35.0);
    final ballRadius = 16.0 * (0.6 + depthFactor * 0.4);

    // Ball Shadow
    final shadowScreenY = center.dy + (ballPos.z * 45.0);
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: (0.6 - ballPos.y * 0.08).clamp(0.1, 0.6))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(ballScreenX, shadowScreenY), width: ballRadius * 2.2, height: ballRadius * 0.8),
      shadowPaint,
    );

    // Ball Sphere Rendering (Muted slate when locked, Electric cyan glow when unlocked)
    final ballPaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(ballScreenX - ballRadius * 0.3, ballScreenY - ballRadius * 0.3),
        ballRadius * 1.2,
        isUnlocked
            ? [
                const Color(0xFFFFFFFF),
                const Color(0xFF00E676),
                const Color(0xFF0284C7),
              ]
            : [
                const Color(0xFF94A3B8),
                const Color(0xFF64748B),
                const Color(0xFF334155),
              ],
      );
    canvas.drawCircle(Offset(ballScreenX, ballScreenY), ballRadius, ballPaint);

    final hexPaint = Paint()
      ..color = isUnlocked ? const Color(0xFF00E676) : Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(ballScreenX, ballScreenY), ballRadius * 0.4, hexPaint);

    // 7. Rotating Holographic Lock Cage around match ball when locked
    if (!isUnlocked) {
      final cagePaint = Paint()
        ..color = const Color(0xFFF43F5E).withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8;

      final cageGlowPaint = Paint()
        ..color = const Color(0xFFF43F5E).withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

      final double r = ballRadius * 1.8;

      // Render 3D icosahedron / octahedron rotating wireframe vertices
      final List<Offset> cageVertices = [];
      for (int i = 0; i < 6; i++) {
        final double a = cageAngle + (i * math.pi / 3);
        final double x = ballScreenX + math.cos(a) * r;
        final double y = ballScreenY + math.sin(a * 0.7) * (r * 0.6);
        cageVertices.add(Offset(x, y));
      }

      final cagePath = Path();
      for (int i = 0; i < cageVertices.length; i++) {
        final p1 = cageVertices[i];
        final p2 = cageVertices[(i + 1) % cageVertices.length];
        final p3 = cageVertices[(i + 2) % cageVertices.length];
        cagePath.moveTo(p1.dx, p1.dy);
        cagePath.lineTo(p2.dx, p2.dy);
        cagePath.lineTo(p3.dx, p3.dy);
        cagePath.close();
      }

      canvas.drawPath(cagePath, cageGlowPaint);
      canvas.drawPath(cagePath, cagePaint);

      // Rotating Outer Wireframe Ring
      canvas.drawOval(
        Rect.fromCenter(center: Offset(ballScreenX, ballScreenY), width: r * 2.2, height: r * 0.9),
        cagePaint,
      );
    }

    // 8. 3D Shatter Explosion Physics Particle System (45 Shards)
    if (isShattering) {
      for (final p in shatterParticles) {
        if (p.alpha <= 0.01) continue;

        // Project 3D particle coordinate to 2D canvas screen space
        final px = center.dx + (p.pos.x * 65.0);
        final pDepth = (p.pos.z + 4.0) / 6.0;
        final py = center.dy + (p.pos.z * 45.0) - (p.pos.y * 35.0);
        final pSize = (p.scale * 140.0) * (0.6 + pDepth * 0.4) * p.alpha;

        final particlePaint = Paint()
          ..color = const Color(0xFFF43F5E).withValues(alpha: p.alpha)
          ..style = PaintingStyle.fill;

        final particleGlow = Paint()
          ..color = const Color(0xFFFB7185).withValues(alpha: p.alpha * 0.6)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

        final shardPath = Path();
        shardPath.moveTo(px, py - pSize);
        shardPath.lineTo(px + pSize * 0.8, py + pSize * 0.6);
        shardPath.lineTo(px - pSize * 0.8, py + pSize * 0.6);
        shardPath.close();

        canvas.drawPath(shardPath, particleGlow);
        canvas.drawPath(shardPath, particlePaint);
      }
    }

    // 9. Interactive Slingshot Trajectory Arc & Aim Arrow (Unlocked & Aiming)
    if (isDragging && step == AuthStep.aiming && isUnlocked) {
      final dragDelta = dragCurrent - dragStart;
      final aimVector = -dragDelta;
      final aimDist = aimVector.distance.clamp(10.0, 140.0);
      final normalizedAim = aimVector / (aimVector.distance == 0 ? 1 : aimVector.distance);

      final endPt = Offset(ballScreenX, ballScreenY) + (normalizedAim * aimDist);

      // Aim Line
      final arrowPaint = Paint()
        ..color = const Color(0xFF00E676)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(Offset(ballScreenX, ballScreenY), endPt, arrowPaint);

      // Arrow Head
      final arrowHeadAngle = math.atan2(normalizedAim.dy, normalizedAim.dx);
      final arrowPath = Path();
      arrowPath.moveTo(endPt.dx, endPt.dy);
      arrowPath.lineTo(
        endPt.dx - 16 * math.cos(arrowHeadAngle - math.pi / 6),
        endPt.dy - 16 * math.sin(arrowHeadAngle - math.pi / 6),
      );
      arrowPath.lineTo(
        endPt.dx - 16 * math.cos(arrowHeadAngle + math.pi / 6),
        endPt.dy - 16 * math.sin(arrowHeadAngle + math.pi / 6),
      );
      arrowPath.close();

      final headPaint = Paint()..color = const Color(0xFF00E676);
      canvas.drawPath(arrowPath, headPaint);

      // Projected Parabolic Dotted Trajectory Arc
      final dotPaint = Paint()..color = const Color(0xFF38BDF8).withValues(alpha: 0.85);
      for (int i = 1; i <= 8; i++) {
        final t = i / 8.0;
        final arcPt = Offset(
          ballScreenX + normalizedAim.dx * aimDist * t,
          ballScreenY + normalizedAim.dy * aimDist * t - (math.sin(t * math.pi) * 30.0),
        );
        canvas.drawCircle(arcPt, 3.5, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant Stadium3DPainter oldDelegate) => true;
}
