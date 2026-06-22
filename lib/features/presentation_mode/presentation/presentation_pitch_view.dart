import 'dart:async';

import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/presentation_mode/application/presentation_mode_notifier.dart';
import 'package:captain/features/presentation_mode/presentation/widgets/laser_pointer_overlay.dart';
import 'package:captain/features/presentation_mode/presentation/widgets/spotlight_player_token.dart';
import 'package:captain/features/tactical_board/application/board_layout_helpers.dart';
import 'package:captain/features/tactical_board/application/tactical_board_notifier.dart';
import 'package:captain/features/tactical_board/domain/player.dart';
import 'package:captain/features/tactical_board/domain/text_annotation.dart';
import 'package:captain/features/tactical_board/presentation/widgets/annotations_painter.dart';
import 'package:captain/features/tactical_board/presentation/widgets/pitch_painter.dart';
import 'package:captain/features/tactical_board/presentation/widgets/player_token.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  final TransformationController _transformController = TransformationController();
  final List<LaserTrailPoint> _laserPoints = [];
  Timer? _laserTimer;
  AnimationController? _zoomController;
  Animation<Matrix4>? _zoomAnimation;

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
  }

  @override
  void dispose() {
    _laserTimer?.cancel();
    _zoomController?.dispose();
    _transformController.dispose();
    super.dispose();
  }

  PitchLayout _layout() {
    return PitchLayout.compute(
      constraints: widget.constraints,
      orientation: widget.boardState.orientation,
    );
  }

  void _clearEffects() {
    ref.read(presentationModeProvider.notifier).clearSpotlight();
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

  void _handlePlayerTap(Player player) {
    ref.read(presentationModeProvider.notifier).toggleSpotlight(player.id);
  }

  void _handlePlayerDoubleTap(Player player) {
    _zoomToPlayer(player);
  }

  void _addLaserPoint(Offset localPosition) {
    setState(() {
      _laserPoints.add(
        LaserTrailPoint(position: localPosition, createdAt: DateTime.now()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final boardState = widget.boardState;
    final presentation = ref.watch(presentationModeProvider);
    final layout = _layout();
    final localLayout = PitchLayout(
      rect: Offset.zero & layout.rect.size,
      orientation: boardState.orientation,
      tokenSize: layout.tokenSize,
    );
    final spotlightId = presentation.spotlightPlayerId;
    final players = sortedPlayers(boardState.players);
    Player? spotlightPlayer;
    if (spotlightId != null) {
      for (final player in players) {
        if (player.id == spotlightId) {
          spotlightPlayer = player;
          break;
        }
      }
    }

    return Stack(
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
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 250),
                      opacity: spotlightId == null ? 1 : 0.35,
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
                              arrows: sortedArrows(boardState.arrows),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                ...players.where((player) => player.id != spotlightId).map(
                  (player) => _PresentationPlayer(
                    player: player,
                    layout: layout,
                    dimmed: spotlightId != null,
                    onTap: () => _handlePlayerTap(player),
                    onDoubleTap: () => _handlePlayerDoubleTap(player),
                  ),
                ),
                ...sortedTextNotes(boardState.textAnnotations).map(
                  (note) => _PresentationTextNote(
                    note: note,
                    layout: layout,
                    dimmed: spotlightId != null,
                  ),
                ),
                if (spotlightPlayer != null)
                  _PresentationSpotlightPlayer(
                    player: spotlightPlayer,
                    layout: layout,
                    onTap: () => _handlePlayerTap(spotlightPlayer!),
                    onDoubleTap: () => _handlePlayerDoubleTap(spotlightPlayer!),
                  ),
                if (presentation.laserEnabled)
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onPanStart: (details) => _addLaserPoint(details.localPosition),
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
            child: Row(
              children: [
                FilledButton.icon(
                  onPressed: widget.onExit,
                  icon: const Icon(Icons.close),
                  label: const Text('Exit'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () =>
                      ref.read(presentationModeProvider.notifier).toggleLaser(),
                  icon: Icon(
                    presentation.laserEnabled
                        ? Icons.highlight
                        : Icons.highlight_outlined,
                  ),
                  label: Text(
                    presentation.laserEnabled ? 'Laser on' : 'Laser',
                  ),
                ),
                const Spacer(),
                if (spotlightId != null || presentation.isZoomed)
                  TextButton(
                    onPressed: _clearEffects,
                    child: const Text('Reset view'),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PresentationPlayer extends StatelessWidget {
  const _PresentationPlayer({
    required this.player,
    required this.layout,
    required this.onTap,
    required this.onDoubleTap,
    this.dimmed = false,
  });

  final Player player;
  final PitchLayout layout;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final anchor = layout.positionFor(player.x, player.y);
    final labelHeight = player.label != null ? layout.tokenSize * 0.35 : 0.0;
    final totalHeight = layout.tokenSize + labelHeight;

    return Positioned(
      left: anchor.dx - layout.tokenSize / 2,
      top: anchor.dy - totalHeight / 2,
      child: GestureDetector(
        onTap: onTap,
        onDoubleTap: onDoubleTap,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: dimmed ? 0.25 : 1,
          child: PlayerToken(
            player: player,
            size: layout.tokenSize,
          ),
        ),
      ),
    );
  }
}

class _PresentationSpotlightPlayer extends StatelessWidget {
  const _PresentationSpotlightPlayer({
    required this.player,
    required this.layout,
    required this.onTap,
    required this.onDoubleTap,
  });

  final Player player;
  final PitchLayout layout;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;

  @override
  Widget build(BuildContext context) {
    final anchor = layout.positionFor(player.x, player.y);
    final labelHeight = player.label != null ? layout.tokenSize * 0.35 : 0.0;
    final totalHeight = layout.tokenSize + labelHeight;

    return Positioned(
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
            color: AppColors.surfaceElevated.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            note.text,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
