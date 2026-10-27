import 'dart:async';

import 'package:captain/features/presentation_mode/application/presentation_mode_notifier.dart';
import 'package:captain/features/presentation_mode/presentation/widgets/laser_pointer_overlay.dart';
import 'package:captain/features/presentation_mode/presentation/widgets/spotlight_player_token.dart';
import 'package:captain/features/tactical_board/application/board_layout_helpers.dart';
import 'package:captain/features/tactical_board/application/tactic_playback.dart';
import 'package:captain/features/tactical_board/application/tactical_board_notifier.dart';
import 'package:captain/features/tactical_board/domain/player.dart';
import 'package:captain/features/tactical_board/domain/text_annotation.dart';
import 'package:captain/features/tactical_board/presentation/widgets/annotations_painter.dart';
import 'package:captain/features/tactical_board/presentation/widgets/ball_token.dart';
import 'package:captain/features/tactical_board/presentation/widgets/pitch_painter.dart';
import 'package:captain/features/tactical_board/presentation/widgets/player_token.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Full-screen coach presentation: player spotlight with info card, guided
/// tour through the squad, zoom-to-player, laser pointer and tactic playback.
///
/// Always rendered on a dark "stage" regardless of the app theme so it reads
/// well on projectors and TVs.
class PresentationPitchView extends ConsumerStatefulWidget {
  const PresentationPitchView({
    super.key,
    required this.boardState,
    required this.constraints,
    required this.onExit,
  });

  final TacticalBoardState boardState;
  final Size constraints;
  final VoidCallback onExit;

  @override
  ConsumerState<PresentationPitchView> createState() =>
      _PresentationPitchViewState();
}

class _PresentationPitchViewState extends ConsumerState<PresentationPitchView>
    with TickerProviderStateMixin {
  static const _stage = Color(0xFF05080F);

  final TransformationController _transformController =
      TransformationController();
  final List<LaserTrailPoint> _laserPoints = [];
  final FocusNode _focusNode = FocusNode();
  Timer? _laserTimer;
  Timer? _tourTimer;
  AnimationController? _zoomController;
  Animation<Matrix4>? _zoomAnimation;
  late final AnimationController _spot = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );
  late final Ticker _playbackTicker = createTicker(_onTick);
  Duration _lastTick = Duration.zero;
  Offset? _spotFrom;
  Offset? _spotTo;
  bool _touring = false;

  @override
  void initState() {
    super.initState();
    _laserTimer = Timer.periodic(const Duration(milliseconds: 32), (_) {
      if (_laserPoints.isEmpty) return;
      final now = DateTime.now();
      _laserPoints.removeWhere(
        (point) => now.difference(point.createdAt).inMilliseconds > 1600,
      );
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _laserTimer?.cancel();
    _tourTimer?.cancel();
    _zoomController?.dispose();
    _transformController.dispose();
    _spot.dispose();
    _playbackTicker.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final delta = elapsed - _lastTick;
    _lastTick = elapsed;
    ref.read(tacticPlaybackProvider.notifier).tick(delta);
  }

  PitchLayout _layout() {
    return PitchLayout.compute(
      constraints: widget.constraints,
      orientation: widget.boardState.orientation,
    );
  }

  List<Player> get _ordered {
    final players = [...widget.boardState.players];
    players.sort((a, b) {
      if (a.isHomeTeam != b.isHomeTeam) return a.isHomeTeam ? -1 : 1;
      return a.number.compareTo(b.number);
    });
    return players;
  }

  Player? _byId(String? id) {
    if (id == null) return null;
    for (final p in widget.boardState.players) {
      if (p.id == id) return p;
    }
    return null;
  }

  // ── Spotlight ──────────────────────────────────────────────────────────

  void _setSpotlight(Player? player, {bool toggle = true}) {
    final notifier = ref.read(presentationModeProvider.notifier);
    final current = ref.read(presentationModeProvider).spotlightPlayerId;
    final layout = _layout();
    _spotFrom = current == null
        ? null
        : _anchorFor(_byId(current), layout);
    if (player == null) {
      notifier.clearSpotlight();
    } else if (toggle) {
      notifier.toggleSpotlight(player.id);
    } else if (current != player.id) {
      notifier.toggleSpotlight(player.id);
    }
    final next = ref.read(presentationModeProvider).spotlightPlayerId;
    _spotTo = _anchorFor(_byId(next), layout);
    _spot.forward(from: 0);
    HapticFeedback.selectionClick();
  }

  Offset? _anchorFor(Player? player, PitchLayout layout) {
    if (player == null) return null;
    return layout.positionFor(player.x, player.y);
  }

  void _step(int delta) {
    final players = _ordered;
    if (players.isEmpty) return;
    final current = ref.read(presentationModeProvider).spotlightPlayerId;
    var index = players.indexWhere((p) => p.id == current);
    index = index < 0 ? 0 : (index + delta) % players.length;
    if (index < 0) index += players.length;
    _setSpotlight(players[index], toggle: false);
  }

  void _toggleTour() {
    setState(() => _touring = !_touring);
    _tourTimer?.cancel();
    if (_touring) {
      _step(1);
      _tourTimer = Timer.periodic(
        const Duration(milliseconds: 3200),
        (_) => _step(1),
      );
    }
  }

  // ── Zoom ───────────────────────────────────────────────────────────────

  void _clearEffects() {
    _tourTimer?.cancel();
    setState(() => _touring = false);
    _setSpotlight(null);
    _resetZoom();
  }

  void _resetZoom() {
    _animateToMatrix(Matrix4.identity());
    ref.read(presentationModeProvider.notifier).setZoomed(false);
  }

  void _animateToMatrix(Matrix4 target) {
    _zoomController?.dispose();
    _zoomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _zoomAnimation = Matrix4Tween(
      begin: _transformController.value,
      end: target,
    ).animate(
      CurvedAnimation(parent: _zoomController!, curve: Curves.easeInOut),
    )..addListener(() {
        if (_zoomAnimation != null) {
          _transformController.value = _zoomAnimation!.value;
        }
      });
    _zoomController!.forward();
  }

  void _zoomToPlayer(Player player) {
    final layout = _layout();
    final focal = layout.positionFor(player.x, player.y);
    const scale = 2.2;
    final viewport = widget.constraints;
    final matrix = Matrix4.identity()
      ..translateByDouble(viewport.width / 2, viewport.height / 2, 0, 1)
      ..scaleByDouble(scale, scale, 1, 1)
      ..translateByDouble(-focal.dx, -focal.dy, 0, 1);

    ref.read(presentationModeProvider.notifier).setZoomed(true);
    _animateToMatrix(matrix);
  }

  void _handleBackgroundTap() {
    final presentation = ref.read(presentationModeProvider);
    if (presentation.isZoomed) {
      _resetZoom();
      return;
    }
    _clearEffects();
  }

  void _addLaserPoint(Offset localPosition) {
    setState(() {
      _laserPoints.add(
        LaserTrailPoint(position: localPosition, createdAt: DateTime.now()),
      );
    });
  }

  void _togglePlayback() {
    final notifier = ref.read(tacticPlaybackProvider.notifier);
    if (ref.read(tacticPlaybackProvider).isActive) {
      notifier.togglePlay();
    } else {
      notifier.play();
    }
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowRight ||
        key == LogicalKeyboardKey.arrowDown) {
      _step(1);
    } else if (key == LogicalKeyboardKey.arrowLeft ||
        key == LogicalKeyboardKey.arrowUp) {
      _step(-1);
    } else if (key == LogicalKeyboardKey.escape) {
      if (ref.read(presentationModeProvider).spotlightPlayerId != null) {
        _clearEffects();
      } else {
        widget.onExit();
      }
    } else if (key == LogicalKeyboardKey.space) {
      _togglePlayback();
    } else if (key == LogicalKeyboardKey.keyL) {
      ref.read(presentationModeProvider.notifier).toggleLaser();
    } else if (key == LogicalKeyboardKey.keyT) {
      _toggleTour();
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final boardState = widget.boardState;
    final presentation = ref.watch(presentationModeProvider);
    final playback = ref.watch(tacticPlaybackProvider);
    ref.listen<bool>(
      tacticPlaybackProvider.select((s) => s.isPlaying),
      (_, playing) {
        if (playing && !_playbackTicker.isActive) {
          _lastTick = Duration.zero;
          _playbackTicker.start();
        } else if (!playing && _playbackTicker.isActive) {
          _playbackTicker.stop();
        }
      },
    );
    final frame = playback.isActive ? playback.frame : null;

    final layout = _layout();
    final localLayout = PitchLayout(
      rect: Offset.zero & layout.rect.size,
      orientation: boardState.orientation,
      tokenSize: layout.tokenSize,
    );
    final spotlightId = presentation.spotlightPlayerId;
    final spotlightPlayer = _byId(spotlightId);
    Offset posOf(Player p) => frame?.players[p.id] ?? Offset(p.x, p.y);
    final players = sortedPlayers(boardState.players);

    // Arrows that start at the spotlighted player stay bright.
    final focusArrows = <String>{
      if (spotlightPlayer != null)
        for (final a in boardState.arrows)
          if ((Offset(a.startX, a.startY) - Offset(spotlightPlayer.x, spotlightPlayer.y))
                  .distance <
              playbackAttachRadius)
            a.id,
    };
    final ball = frame?.ball ??
        (boardState.ball == null
            ? null
            : Offset(boardState.ball!.x, boardState.ball!.y));

    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _onKey,
      child: ColoredBox(
        color: _stage,
        child: Stack(
          children: [
            InteractiveViewer(
              transformationController: _transformController,
              minScale: 0.75,
              maxScale: 3.5,
              panEnabled: !presentation.laserEnabled,
              scaleEnabled: !presentation.laserEnabled,
              boundaryMargin: const EdgeInsets.all(120),
              child: SizedBox(
                width: widget.constraints.width,
                height: widget.constraints.height,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fromRect(
                      rect: layout.rect,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _handleBackgroundTap,
                        child: Stack(
                          children: [
                            CustomPaint(
                              size: layout.rect.size,
                              painter: PitchPainter(
                                orientation: boardState.orientation,
                                style: boardState.pitchStyle,
                              ),
                            ),
                            CustomPaint(
                              size: layout.rect.size,
                              painter: AnnotationsPainter(
                                layout: localLayout,
                                zones: sortedZones(boardState.zones),
                                highlights:
                                    sortedHighlights(boardState.highlights),
                                arrows: sortedArrows(boardState.arrows)
                                    .where((a) =>
                                        frame == null ||
                                        (frame.arrowProgress[a.id] ?? 0) < 1)
                                    .toList(),
                                selectedIds: focusArrows,
                                focusStep: frame?.step,
                                showStepBadges: boardState.stepCount > 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    for (final player in players)
                      if (player.id != spotlightId)
                        _PresentationPlayer(
                          player: player,
                          position: posOf(player),
                          layout: layout,
                          animate: frame == null,
                          running: frame?.moving.contains(player.id) ?? false,
                          onTap: () => _setSpotlight(player),
                          onDoubleTap: () => _zoomToPlayer(player),
                        ),
                    ...sortedTextNotes(boardState.textAnnotations).map(
                      (note) => _PresentationTextNote(
                        note: note,
                        layout: layout,
                        dimmed: spotlightId != null,
                      ),
                    ),
                    if (ball != null)
                      _PresentationBall(position: ball, layout: layout),
                    // Stage spotlight: darken everything except a soft
                    // circle around the focused player.
                    Positioned.fill(
                      child: IgnorePointer(
                        child: AnimatedBuilder(
                          animation: _spot,
                          builder: (context, _) {
                            final t = Curves.easeOutCubic.transform(_spot.value);
                            final target = spotlightPlayer == null
                                ? null
                                : layout.positionFor(
                                    posOf(spotlightPlayer).dx,
                                    posOf(spotlightPlayer).dy,
                                  );
                            final from = _spotFrom ?? target ?? _spotTo;
                            final center = target == null
                                ? (from ?? Offset.zero)
                                : Offset.lerp(from ?? target, target, t)!;
                            final intensity = spotlightPlayer == null ? 1 - t : t;
                            return CustomPaint(
                              painter: _SpotlightPainter(
                                center: center,
                                radius: layout.tokenSize * 1.9,
                                intensity: (spotlightPlayer == null && _spotFrom == null)
                                    ? 0
                                    : intensity.clamp(0.0, 1.0),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    if (spotlightPlayer != null)
                      _PresentationSpotlightPlayer(
                        player: spotlightPlayer,
                        position: posOf(spotlightPlayer),
                        layout: layout,
                        onTap: () => _setSpotlight(spotlightPlayer),
                        onDoubleTap: () => _zoomToPlayer(spotlightPlayer),
                      ),
                    if (presentation.laserEnabled)
                      Positioned.fill(
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onPanStart: (details) =>
                              _addLaserPoint(details.localPosition),
                          onPanUpdate: (details) =>
                              _addLaserPoint(details.localPosition),
                          child: LaserPointerOverlay(points: _laserPoints),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _StageButton(
                      icon: Icons.close_rounded,
                      label: 'Exit',
                      onTap: widget.onExit,
                      filled: true,
                    ),
                    _StageButton(
                      icon: presentation.laserEnabled
                          ? Icons.highlight
                          : Icons.highlight_outlined,
                      label: 'Laser',
                      active: presentation.laserEnabled,
                      onTap: () => ref
                          .read(presentationModeProvider.notifier)
                          .toggleLaser(),
                    ),
                    _StageButton(
                      icon: Icons.person_search_rounded,
                      label: _touring ? 'Stop tour' : 'Player tour',
                      active: _touring,
                      onTap: _toggleTour,
                    ),
                    _StageButton(
                      icon: playback.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      label: playback.isPlaying ? 'Pause' : 'Play tactic',
                      active: playback.isActive,
                      onTap: _togglePlayback,
                    ),
                    if (playback.isActive)
                      _StageButton(
                        icon: Icons.replay_rounded,
                        label: 'Reset',
                        onTap: () =>
                            ref.read(tacticPlaybackProvider.notifier).stop(),
                      ),
                    if (spotlightId != null || presentation.isZoomed)
                      _StageButton(
                        icon: Icons.center_focus_weak_rounded,
                        label: 'Reset view',
                        onTap: _clearEffects,
                      ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween(
                        begin: const Offset(0, 0.3),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: spotlightPlayer == null
                      ? const _HintPill(key: ValueKey('hint'))
                      : _SpotlightCard(
                          key: ValueKey(spotlightPlayer.id),
                          player: spotlightPlayer,
                          index: _ordered.indexWhere(
                                (p) => p.id == spotlightPlayer.id,
                              ) +
                              1,
                          total: _ordered.length,
                          runs: focusArrows.length,
                          onPrev: () => _step(-1),
                          onNext: () => _step(1),
                          onZoom: () => _zoomToPlayer(spotlightPlayer),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  _SpotlightPainter({
    required this.center,
    required this.radius,
    required this.intensity,
  });

  final Offset center;
  final double radius;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    if (intensity <= 0) return;
    final rect = Offset.zero & size;
    final far = size.longestSide;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment(
            (center.dx / size.width) * 2 - 1,
            (center.dy / size.height) * 2 - 1,
          ),
          radius: far / size.shortestSide,
          colors: [
            Colors.transparent,
            Colors.transparent,
            Colors.black.withValues(alpha: 0.72 * intensity),
            Colors.black.withValues(alpha: 0.82 * intensity),
          ],
          stops: [
            0,
            (radius / far).clamp(0.0, 1.0),
            ((radius * 1.7) / far).clamp(0.0, 1.0),
            1,
          ],
        ).createShader(rect),
    );
    // Ring of light on the pitch around the player.
    canvas.drawCircle(
      center,
      radius * 0.72,
      Paint()
        ..color = const Color(0xFFFFE08A).withValues(alpha: 0.55 * intensity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter old) =>
      old.center != center ||
      old.radius != radius ||
      old.intensity != intensity;
}

class _SpotlightCard extends StatelessWidget {
  const _SpotlightCard({
    super.key,
    required this.player,
    required this.index,
    required this.total,
    required this.runs,
    required this.onPrev,
    required this.onNext,
    required this.onZoom,
  });

  final Player player;
  final int index;
  final int total;
  final int runs;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onZoom;

  @override
  Widget build(BuildContext context) {
    final role = player.label ?? 'Player';
    final team = player.isHomeTeam ? 'Home' : 'Away';
    final kit = player.isHomeTeam ? const Color(0xFF2563EB) : const Color(0xFFDC2626);
    return Container(
      margin: const EdgeInsets.all(16),
      constraints: const BoxConstraints(maxWidth: 460),
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
      decoration: BoxDecoration(
        color: const Color(0xF20F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x33FFFFFF)),
        boxShadow: [
          BoxShadow(color: kit.withValues(alpha: 0.35), blurRadius: 24),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onPrev,
            icon: const Icon(Icons.chevron_left_rounded, color: Colors.white70),
          ),
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kit,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Text(
              '${player.number}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#${player.number} · $role',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$team team · ${runs == 0 ? 'no movement drawn' : '$runs action${runs == 1 ? '' : 's'} drawn'}',
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  '$index / $total',
                  style: const TextStyle(
                    color: Color(0xFFFFE08A),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Zoom',
            onPressed: onZoom,
            icon: const Icon(Icons.zoom_in_rounded, color: Colors.white70),
          ),
          IconButton(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right_rounded, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _HintPill extends StatelessWidget {
  const _HintPill({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xCC0F172A),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Text(
        'Tap a player to spotlight · double-tap to zoom · ← → to step',
        style: TextStyle(color: Colors.white70, fontSize: 12),
      ),
    );
  }
}

class _StageButton extends StatelessWidget {
  const _StageButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final bg = filled
        ? const Color(0xFF10B981)
        : active
            ? const Color(0x3310B981)
            : const Color(0xCC0F172A);
    return Material(
      color: bg,
      shape: StadiumBorder(
        side: BorderSide(
          color: active ? const Color(0xFF10B981) : const Color(0x33FFFFFF),
        ),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PresentationBall extends StatelessWidget {
  const _PresentationBall({required this.position, required this.layout});

  final Offset position;
  final PitchLayout layout;

  @override
  Widget build(BuildContext context) {
    final size = layout.tokenSize * 0.48;
    final anchor = layout.positionFor(position.dx, position.dy);
    return Positioned(
      left: anchor.dx - size / 2,
      top: anchor.dy - size / 2,
      child: IgnorePointer(child: BallToken(size: size)),
    );
  }
}

class _PresentationPlayer extends StatelessWidget {
  const _PresentationPlayer({
    required this.player,
    required this.position,
    required this.layout,
    required this.animate,
    required this.running,
    required this.onTap,
    required this.onDoubleTap,
  });

  final Player player;
  final Offset position;
  final PitchLayout layout;
  final bool animate;
  final bool running;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;

  @override
  Widget build(BuildContext context) {
    final anchor = layout.positionFor(position.dx, position.dy);
    final labelHeight = player.label != null ? layout.tokenSize * 0.35 : 0.0;
    final totalHeight = layout.tokenSize + labelHeight;

    return AnimatedPositioned(
      duration: animate ? const Duration(milliseconds: 300) : Duration.zero,
      curve: Curves.easeOutCubic,
      left: anchor.dx - layout.tokenSize / 2,
      top: anchor.dy - totalHeight / 2,
      child: GestureDetector(
        onTap: onTap,
        onDoubleTap: onDoubleTap,
        child: PlayerToken(
          player: player,
          size: layout.tokenSize,
          isRunning: running,
        ),
      ),
    );
  }
}

class _PresentationSpotlightPlayer extends StatelessWidget {
  const _PresentationSpotlightPlayer({
    required this.player,
    required this.position,
    required this.layout,
    required this.onTap,
    required this.onDoubleTap,
  });

  final Player player;
  final Offset position;
  final PitchLayout layout;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;

  @override
  Widget build(BuildContext context) {
    final anchor = layout.positionFor(position.dx, position.dy);
    final labelHeight = player.label != null ? layout.tokenSize * 0.35 : 0.0;
    final totalHeight = layout.tokenSize + labelHeight;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      left: anchor.dx - layout.tokenSize / 2,
      top: anchor.dy - totalHeight / 2,
      child: GestureDetector(
        onTap: onTap,
        onDoubleTap: onDoubleTap,
        child: SpotlightPlayerToken(
          player: player,
          size: layout.tokenSize,
        ),
      ),
    );
  }
}

class _PresentationTextNote extends StatelessWidget {
  const _PresentationTextNote({
    required this.note,
    required this.layout,
    this.dimmed = false,
  });

  final TextAnnotation note;
  final PitchLayout layout;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final anchor = layout.positionFor(note.x, note.y);

    return Positioned(
      left: anchor.dx,
      top: anchor.dy,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: dimmed ? 0.2 : 0.95,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 160),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xEB0F172A),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0x33FFFFFF)),
          ),
          child: Text(
            note.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
