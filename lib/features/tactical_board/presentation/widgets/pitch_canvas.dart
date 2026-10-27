import 'package:captain/core/services/haptic_patterns.dart';
import 'package:captain/core/services/haptic_service.dart';
import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/collaboration/application/collaboration_providers.dart';
import 'package:captain/features/collaboration/domain/collaboration_event.dart';
import 'package:captain/features/collaboration/presentation/widgets/remote_cursors_layer.dart';
import 'package:captain/features/shape_simulation/application/shape_simulation_notifier.dart';
import 'package:captain/features/shape_simulation/application/shape_simulation_providers.dart';
import 'package:captain/features/shape_simulation/presentation/widgets/ghost_trail_layer.dart';
import 'package:captain/features/tactical_board/application/board_layout_helpers.dart';
import 'package:captain/features/tactical_board/application/tactic_playback.dart';
import 'package:captain/features/tactical_board/application/tactical_board_notifier.dart';
import 'package:captain/features/tactical_board/domain/board_element.dart';
import 'package:captain/features/tactical_board/domain/board_tool.dart';
import 'package:captain/features/tactical_board/domain/player.dart';
import 'package:captain/features/tactical_board/domain/text_annotation.dart';
import 'package:captain/features/tactical_board/presentation/widgets/annotations_painter.dart';
import 'package:captain/features/tactical_board/presentation/widgets/ball_token.dart';
import 'package:captain/features/tactical_board/presentation/widgets/context_toolbar.dart';
import 'package:captain/features/tactical_board/presentation/widgets/manipulation_handles.dart';
import 'package:captain/features/tactical_board/presentation/widgets/pitch_painter.dart';
import 'package:captain/features/tactical_board/presentation/widgets/player_token.dart';
import 'package:captain/features/training/application/training_providers.dart';
import 'package:captain/features/training/presentation/training_pitch_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Interactive 2D tactical pitch.
///
/// Player dragging is handled directly with pan gestures on each token
/// (immediate, no long-press) and rendered from a local "live" position map,
/// so the token follows the finger 1:1 and the shape simulation can move
/// team-mates and opponents in real time. The board state is only committed
/// once, on release, as a single undo step.
class PitchCanvas extends ConsumerStatefulWidget {
  const PitchCanvas({
    super.key,
    required this.boardState,
    required this.constraints,
  });

  final TacticalBoardState boardState;
  final Size constraints;

  @override
  ConsumerState<PitchCanvas> createState() => _PitchCanvasState();
}

class _PitchCanvasState extends ConsumerState<PitchCanvas>
    with TickerProviderStateMixin {
  final GlobalKey _pitchKey = GlobalKey();

  late final AnimationController _flow = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );
  late final AnimationController _reveal = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
  );
  String? _revealArrowId;
  Ticker? _playbackTicker;
  Duration _lastTick = Duration.zero;

  // Live player drag.
  String? _draggingPlayerId;
  Offset _dragGrabOffset = Offset.zero;
  Map<String, Offset> _live = const {};

  // Ball drag.
  Offset? _ballLive;

  // Select-mode pan: marquee or moving the selection.
  Offset? _marqueeStart;
  Offset? _marqueeEnd;
  Offset? _moveLast;

  @override
  void initState() {
    super.initState();
    _syncFlow();
    _playbackTicker = createTicker(_onPlaybackTick);
  }

  @override
  void didUpdateWidget(covariant PitchCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.boardState.skipNextAnimation) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(tacticalBoardProvider.notifier).clearSkipAnimation();
        }
      });
    }
    final oldIds = oldWidget.boardState.arrows.map((a) => a.id).toSet();
    final added = widget.boardState.arrows
        .where((a) => !oldIds.contains(a.id))
        .toList();
    if (added.length == 1) {
      _revealArrowId = added.first.id;
      _reveal.forward(from: 0);
    }
    _syncFlow();
  }

  void _syncFlow() {
    final reduceMotion =
        WidgetsBinding.instance.platformDispatcher.accessibilityFeatures
            .disableAnimations;
    final shouldRun = widget.boardState.animateArrows && !reduceMotion;
    if (shouldRun && !_flow.isAnimating) {
      _flow.repeat();
    } else if (!shouldRun && _flow.isAnimating) {
      _flow.stop();
    }
  }

  void _onPlaybackTick(Duration elapsed) {
    final delta = elapsed - _lastTick;
    _lastTick = elapsed;
    ref.read(tacticPlaybackProvider.notifier).tick(delta);
  }

  void _syncPlaybackTicker(bool playing) {
    final ticker = _playbackTicker;
    if (ticker == null) return;
    if (playing && !ticker.isActive) {
      _lastTick = Duration.zero;
      ticker.start();
    } else if (!playing && ticker.isActive) {
      ticker.stop();
    }
  }

  @override
  void dispose() {
    _playbackTicker?.dispose();
    _flow.dispose();
    _reveal.dispose();
    super.dispose();
  }

  // ── Coordinate helpers ─────────────────────────────────────────────────

  ({double x, double y})? _relativeFromLocal(Offset local, PitchLayout layout) {
    return layout.relativeFor(layout.rect.topLeft + local);
  }

  Offset _relativeFromGlobal(Offset global, PitchLayout layout) {
    final box = context.findRenderObject() as RenderBox?;
    final local = box?.globalToLocal(global) ?? global;
    final rel = layout.relativeFor(local);
    return Offset(rel.x, rel.y);
  }

  // ── Player drag ────────────────────────────────────────────────────────

  bool _canDrag(Player player) {
    final state = widget.boardState;
    return state.activeTool.isSelect &&
        !player.locked &&
        ref.read(collaborationProvider).canEditBoard &&
        !ref.read(tacticPlaybackProvider).isActive;
  }

  void _onPlayerDragStart(Player player, DragStartDetails details, PitchLayout layout) {
    if (!_canDrag(player)) return;
    final pointer = _relativeFromGlobal(details.globalPosition, layout);
    _dragGrabOffset = Offset(player.x, player.y) - pointer;
    final notifier = ref.read(tacticalBoardProvider.notifier);
    final key = BoardElementKey(BoardElementKind.player, player.id);
    if (!widget.boardState.isSelected(key)) {
      notifier.selectElement(key, additive: widget.boardState.multiSelectActive);
    }
    notifier.setDraggingPlayer(player.id);

    final simulation = ref.read(shapeSimulationProvider);
    if (simulation.isSimulationActive) {
      ref.read(shapeSimulationProvider.notifier).beginDrag(
            playerId: player.id,
            players: widget.boardState.players,
          );
    }
    ref.read(hapticServiceProvider).selectionClick();
    setState(() {
      _draggingPlayerId = player.id;
      _live = {player.id: Offset(player.x, player.y)};
    });
  }

  void _onPlayerDragUpdate(Player player, DragUpdateDetails details, PitchLayout layout) {
    if (_draggingPlayerId != player.id) return;
    final pointer = _relativeFromGlobal(details.globalPosition, layout);
    final target = pointer + _dragGrabOffset;
    final clamped = layout.clampRelative(x: target.dx, y: target.dy);
    final next = Offset(clamped.x, clamped.y);
    final board = widget.boardState;

    final simulation = ref.read(shapeSimulationProvider);
    Map<String, Offset> live;
    if (simulation.isSimulationActive) {
      live = ref.read(shapeSimulationProvider.notifier).simulatePlayerMove(
            playerId: player.id,
            newPosition: next,
            players: board.players,
          );
      live[player.id] = next;
    } else {
      // Group move: drag every selected, unlocked player together.
      final delta = next - Offset(player.x, player.y);
      live = {player.id: next};
      for (final key in board.selectedElements) {
        if (key.kind != BoardElementKind.player || key.id == player.id) continue;
        final other = board.players.where((p) => p.id == key.id).firstOrNull;
        if (other == null || other.locked) continue;
        final moved = layout.clampRelative(
          x: other.x + delta.dx,
          y: other.y + delta.dy,
        );
        live[other.id] = Offset(moved.x, moved.y);
      }
    }
    setState(() => _live = live);
    ref.read(collaborationProvider.notifier).trackLocalCursor(
          x: next.dx,
          y: next.dy,
        );
  }

  void _onPlayerDragEnd(Player player) {
    if (_draggingPlayerId != player.id) return;
    final notifier = ref.read(tacticalBoardProvider.notifier);
    final positions = <String, ({double x, double y})>{
      for (final entry in _live.entries)
        entry.key: (
          x: notifier.snapValue(entry.value.dx),
          y: notifier.snapValue(entry.value.dy),
        ),
    };
    final board = widget.boardState;
    final changed = positions.entries.any((e) {
      final p = board.players.where((p) => p.id == e.key).firstOrNull;
      return p != null && (p.x != e.value.x || p.y != e.value.y);
    });
    if (changed) {
      notifier.movePlayers(positions: positions);
      final collab = ref.read(collaborationProvider.notifier);
      if (positions.length == 1) {
        collab.broadcastPlayerMoved(
          playerId: player.id,
          x: positions[player.id]!.x,
          y: positions[player.id]!.y,
        );
      } else {
        collab.broadcastPlayerBatch(positions);
      }
      playerPlacedHaptic(ref.read(hapticServiceProvider));
    } else {
      notifier.setDraggingPlayer(null);
    }
    if (ref.read(shapeSimulationProvider).isSimulationActive) {
      ref.read(shapeSimulationProvider.notifier).endDrag();
    }
    setState(() {
      _draggingPlayerId = null;
      _live = const {};
    });
  }

  // ── Ball drag ──────────────────────────────────────────────────────────

  void _onBallDragUpdate(DragUpdateDetails details, PitchLayout layout) {
    if (!widget.boardState.activeTool.isSelect &&
        widget.boardState.activeTool != BoardTool.ball) {
      return;
    }
    final p = _relativeFromGlobal(details.globalPosition, layout);
    setState(() => _ballLive = Offset(p.dx.clamp(0.0, 1.0), p.dy.clamp(0.0, 1.0)));
  }

  void _onBallDragEnd() {
    final pos = _ballLive;
    if (pos == null) return;
    ref.read(tacticalBoardProvider.notifier).setBall(x: pos.dx, y: pos.dy);
    setState(() => _ballLive = null);
  }

  // ── Annotation sync ────────────────────────────────────────────────────

  void _broadcastLatestAnnotation({
    required TacticalBoardState before,
    required TacticalBoardState after,
  }) {
    final collaboration = ref.read(collaborationProvider);
    if (!collaboration.isInSession || !collaboration.canEditBoard) return;

    final sync = ref.read(collaborationProvider.notifier);
    if (after.arrows.length > before.arrows.length) {
      sync.broadcastAnnotationAdded(
        kind: CollaborationAnnotationKind.arrow,
        data: after.arrows.last.toJson(),
      );
      return;
    }
    if (after.zones.length > before.zones.length) {
      sync.broadcastAnnotationAdded(
        kind: CollaborationAnnotationKind.zone,
        data: after.zones.last.toJson(),
      );
      return;
    }
    if (after.highlights.length > before.highlights.length) {
      sync.broadcastAnnotationAdded(
        kind: CollaborationAnnotationKind.highlight,
        data: after.highlights.last.toJson(),
      );
    }
  }

  void _commitDraftWithSync(TacticalBoardNotifier notifier) {
    final before = ref.read(tacticalBoardProvider);
    notifier.commitDraft();
    final after = ref.read(tacticalBoardProvider);
    _broadcastLatestAnnotation(before: before, after: after);
  }

  void _trackPointerOnPitch(Offset localPosition, PitchLayout layout) {
    final relative = layout.relativeFor(layout.rect.topLeft + localPosition);
    ref.read(collaborationProvider.notifier).trackLocalCursor(
          x: relative.x,
          y: relative.y,
        );
  }

  Future<void> _promptTextNote(double x, double y) async {
    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add note'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'Tactical note...'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
    controller.dispose();

    if (!mounted || text == null) return;
    final before = ref.read(tacticalBoardProvider);
    await ref.read(tacticalBoardProvider.notifier).addTextNote(
          x: x,
          y: y,
          text: text,
        );
    if (!mounted) return;
    final after = ref.read(tacticalBoardProvider);
    if (after.textAnnotations.length > before.textAnnotations.length) {
      ref.read(collaborationProvider.notifier).broadcastAnnotationAdded(
            kind: CollaborationAnnotationKind.text,
            data: after.textAnnotations.last.toJson(),
          );
    }
  }

  // ── Pitch gestures ─────────────────────────────────────────────────────

  void _onPitchTap(TapUpDetails details, PitchLayout layout) {
    if (ref.read(trainingProvider).isTrainingMode) return;
    final relative = _relativeFromLocal(details.localPosition, layout);
    if (relative == null) return;
    final notifier = ref.read(tacticalBoardProvider.notifier);
    final board = widget.boardState;

    switch (board.activeTool) {
      case BoardTool.select:
        final element = notifier.findElementAt(x: relative.x, y: relative.y);
        if (element != null) {
          notifier.selectElement(element, additive: board.multiSelectActive);
        } else {
          notifier.clearSelection();
        }
      case BoardTool.textNote:
        _promptTextNote(relative.x, relative.y);
      case BoardTool.eraser:
        notifier.eraseAt(x: relative.x, y: relative.y);
      case BoardTool.ball:
        notifier.setBall(x: relative.x, y: relative.y);
      default:
        break;
    }
  }

  void _onPitchPanStart(DragStartDetails details, PitchLayout layout) {
    if (ref.read(trainingProvider).isTrainingMode) return;
    if (!ref.read(collaborationProvider).canEditBoard) return;
    final board = widget.boardState;
    final tool = board.activeTool;
    final relative = _relativeFromLocal(details.localPosition, layout);
    if (relative == null) return;
    final notifier = ref.read(tacticalBoardProvider.notifier);

    if (tool.isDragDrawTool) {
      notifier.startDraft(x: relative.x, y: relative.y);
      return;
    }
    if (!tool.isSelect) return;

    // Drag on an element → select it (if needed) and move the selection.
    final hit = notifier.findElementAt(x: relative.x, y: relative.y);
    if (hit != null && !notifier.isLocked(hit)) {
      if (!board.isSelected(hit)) {
        notifier.selectElement(hit, additive: board.multiSelectActive);
      }
      notifier.beginInteraction();
      _moveLast = Offset(relative.x, relative.y);
      return;
    }
    // Otherwise start a rubber-band selection.
    setState(() {
      _marqueeStart = Offset(relative.x, relative.y);
      _marqueeEnd = _marqueeStart;
    });
  }

  void _onPitchPanUpdate(DragUpdateDetails details, PitchLayout layout) {
    final tool = widget.boardState.activeTool;
    final relative = _relativeFromLocal(details.localPosition, layout);
    if (relative == null) return;
    final point = Offset(relative.x, relative.y);
    final notifier = ref.read(tacticalBoardProvider.notifier);

    if (tool.isDragDrawTool) {
      notifier.updateDraft(x: relative.x, y: relative.y);
      return;
    }
    if (_moveLast != null) {
      final delta = point - _moveLast!;
      _moveLast = point;
      notifier.translateSelected(dx: delta.dx, dy: delta.dy);
      return;
    }
    if (_marqueeStart != null) {
      setState(() => _marqueeEnd = point);
    }
  }

  void _onPitchPanEnd() {
    final tool = widget.boardState.activeTool;
    final notifier = ref.read(tacticalBoardProvider.notifier);
    if (tool.isDragDrawTool) {
      if (!ref.read(collaborationProvider).canEditBoard) return;
      _commitDraftWithSync(notifier);
      return;
    }
    if (_moveLast != null) {
      _moveLast = null;
      return;
    }
    if (_marqueeStart != null && _marqueeEnd != null) {
      final rect = Rect.fromPoints(_marqueeStart!, _marqueeEnd!);
      if (rect.longestSide > 0.01) {
        notifier.selectInRect(rect, additive: widget.boardState.multiSelectActive);
      }
    }
    setState(() {
      _marqueeStart = null;
      _marqueeEnd = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final boardState = widget.boardState;
    final simulation = ref.watch(shapeSimulationProvider);
    final collaboration = ref.watch(collaborationProvider);
    final training = ref.watch(trainingProvider);
    final playback = ref.watch(tacticPlaybackProvider);
    ref.listen<bool>(
      tacticPlaybackProvider.select((s) => s.isPlaying),
      (_, playing) => _syncPlaybackTicker(playing),
    );
    final frame = playback.isActive ? playback.frame : null;

    final canEditBoard = collaboration.canEditBoard;
    final notifier = ref.read(tacticalBoardProvider.notifier);
    final layout = PitchLayout.compute(
      constraints: widget.constraints,
      orientation: boardState.orientation,
    );
    final localLayout = PitchLayout(
      rect: Offset.zero & layout.rect.size,
      orientation: boardState.orientation,
      tokenSize: layout.tokenSize,
    );
    final selectMode = boardState.activeTool.isSelect && frame == null;
    final tool = boardState.activeTool;
    final anchor = frame == null && _draggingPlayerId == null
        ? selectionAnchorFor(state: boardState, layout: layout)
        : null;

    final selectedIds = {
      for (final key in boardState.selectedElements) key.id,
    };
    final draftColor = tool.usesZoneColor
        ? Color(boardState.selectedZoneColor)
        : (boardState.arrowColorValue != null
            ? Color(boardState.arrowColorValue!)
            : null);

    Duration playerDuration(String id) {
      if (frame != null) return Duration.zero;
      if (id == _draggingPlayerId) return Duration.zero;
      if (_live.containsKey(id)) {
        return simulation.isSimulationActive
            ? shapeSimulationAnimationDuration
            : Duration.zero;
      }
      if (boardState.skipNextAnimation) return Duration.zero;
      return formationAnimationDuration;
    }

    Offset playerPos(Player p) =>
        frame?.players[p.id] ?? _live[p.id] ?? Offset(p.x, p.y);

    final ballPos = _ballLive ??
        frame?.ball ??
        (boardState.ball == null
            ? null
            : Offset(boardState.ball!.x, boardState.ball!.y));

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fromRect(
          rect: layout.rect,
          child: Listener(
            onPointerHover: collaboration.isInSession
                ? (event) => _trackPointerOnPitch(event.localPosition, layout)
                : null,
            onPointerMove: collaboration.isInSession
                ? (event) => _trackPointerOnPitch(event.localPosition, layout)
                : null,
            child: Stack(
              key: _pitchKey,
              clipBehavior: Clip.hardEdge,
              children: [
                RepaintBoundary(
                  child: CustomPaint(
                    size: layout.rect.size,
                    painter: PitchPainter(
                      orientation: boardState.orientation,
                      style: boardState.pitchStyle,
                    ),
                  ),
                ),
                RepaintBoundary(
                  child: AnimatedBuilder(
                    animation: Listenable.merge([_flow, _reveal]),
                    builder: (context, _) => CustomPaint(
                      size: layout.rect.size,
                      painter: AnnotationsPainter(
                        layout: localLayout,
                        zones: sortedZones(boardState.zones),
                        highlights: sortedHighlights(boardState.highlights),
                        arrows: frame == null
                            ? sortedArrows(boardState.arrows)
                            : sortedArrows(boardState.arrows)
                                .where(
                                  (a) => (frame.arrowProgress[a.id] ?? 0) < 1,
                                )
                                .toList(),
                        draft: boardState.draftDrawing,
                        draftColor: draftColor,
                        flowPhase: _flow.value,
                        animateFlow: boardState.animateArrows,
                        reveal: _revealArrowId == null || !_reveal.isAnimating
                            ? const {}
                            : {_revealArrowId!: _reveal.value},
                        selectedIds: selectedIds,
                        focusStep: frame?.step,
                        showStepBadges: boardState.stepCount > 1,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTapUp: (details) => _onPitchTap(details, layout),
                  onPanStart: (details) => _onPitchPanStart(details, layout),
                  onPanUpdate: (details) => _onPitchPanUpdate(details, layout),
                  onPanEnd: (_) => _onPitchPanEnd(),
                  onPanCancel: () {
                    if (tool.isDragDrawTool) notifier.cancelDraft();
                    _moveLast = null;
                    if (_marqueeStart != null) {
                      setState(() {
                        _marqueeStart = null;
                        _marqueeEnd = null;
                      });
                    }
                  },
                  child: SizedBox(
                    width: layout.rect.width,
                    height: layout.rect.height,
                  ),
                ),
                if (_marqueeStart != null && _marqueeEnd != null)
                  _MarqueeRect(
                    rect: Rect.fromPoints(
                      localLayout.positionFor(_marqueeStart!.dx, _marqueeStart!.dy),
                      localLayout.positionFor(_marqueeEnd!.dx, _marqueeEnd!.dy),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (training.isTrainingMode)
          Positioned.fromRect(
            rect: layout.rect,
            child: TrainingPitchLayer(
              layout: layout,
              localLayout: localLayout,
            ),
          ),
        if (collaboration.isInSession)
          Positioned.fromRect(
            rect: layout.rect,
            child: RemoteCursorsLayer(
              remoteCursors: collaboration.remoteCursors,
              layout: localLayout,
            ),
          ),
        if (frame == null) ...[
          ...sortedZones(boardState.zones).map((zone) {
            final key = BoardElementKey(BoardElementKind.zone, zone.id);
            final selected = boardState.isSelected(key);
            return ZoneResizeHandles(
              key: ValueKey('zone-handles-${zone.id}'),
              zone: zone,
              layout: layout,
              enabled: selectMode &&
                  selected &&
                  !zone.locked &&
                  boardState.selectedElements.length == 1,
              onResize: ({
                required x,
                required y,
                required width,
                required height,
                required commit,
              }) {
                notifier.resizeZone(
                  zoneId: zone.id,
                  x: x,
                  y: y,
                  width: width,
                  height: height,
                  commit: commit,
                );
              },
            );
          }),
          ...sortedArrows(boardState.arrows).map((arrow) {
            final key = BoardElementKey(BoardElementKind.arrow, arrow.id);
            final selected = boardState.isSelected(key);
            return ArrowEndpointHandles(
              key: ValueKey('arrow-handles-${arrow.id}'),
              arrow: arrow,
              layout: layout,
              enabled: selectMode &&
                  selected &&
                  !arrow.locked &&
                  boardState.selectedElements.length == 1,
              onEndpointMoved: ({
                required isStart,
                required x,
                required y,
                required commit,
              }) {
                notifier.updateArrowEndpoint(
                  arrowId: arrow.id,
                  isStart: isStart,
                  x: x,
                  y: y,
                  commit: commit,
                );
              },
            );
          }),
        ],
        if (anchor != null && boardState.selectedElements.length == 1)
          ...boardState.selectedElements
              .where((key) => key.kind.supportsRotation)
              .map((key) {
            final center = switch (key.kind) {
              BoardElementKind.arrow => () {
                  final arrow =
                      boardState.arrows.firstWhere((a) => a.id == key.id);
                  final start = layout.positionFor(arrow.startX, arrow.startY);
                  final end = layout.positionFor(arrow.endX, arrow.endY);
                  return Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
                }(),
              BoardElementKind.zone => () {
                  final zone = boardState.zones.firstWhere((z) => z.id == key.id);
                  return layout.positionFor(
                    zone.x + zone.width / 2,
                    zone.y + zone.height / 2,
                  );
                }(),
              _ => anchor.position,
            };

            final rotation = switch (key.kind) {
              BoardElementKind.arrow =>
                boardState.arrows.firstWhere((a) => a.id == key.id).rotation,
              BoardElementKind.zone =>
                boardState.zones.firstWhere((z) => z.id == key.id).rotation,
              _ => 0.0,
            };

            return RotationHandle(
              key: ValueKey('rotate-${key.kind.name}-${key.id}'),
              center: center,
              layout: layout,
              elementKey: key,
              currentRotation: rotation,
              enabled: selectMode && !notifier.isLocked(key),
              onRotate: (angle, {required commit}) {
                notifier.setElementRotation(key, angle, commit: commit);
              },
            );
          }),
        if (simulation.isSimulationActive && frame == null)
          Positioned.fromRect(
            rect: layout.rect,
            child: GhostTrailLayer(
              players: boardState.players,
              ghostPositions: simulation.ghostPositions,
              layout: localLayout,
            ),
          ),
        ...sortedPlayers(boardState.players).map((player) {
          final key = BoardElementKey(BoardElementKind.player, player.id);
          final pos = playerPos(player);
          return _DraggablePlayer(
            key: ValueKey(player.id),
            player: player,
            position: pos,
            layout: layout,
            animationDuration: playerDuration(player.id),
            isSelected: boardState.isSelected(key),
            isDragging: _draggingPlayerId == player.id,
            isRunning: frame?.moving.contains(player.id) ?? false,
            dimmed: frame != null && !(frame.moving.contains(player.id)),
            interactionsEnabled: selectMode && !player.locked && canEditBoard,
            selectMode: selectMode,
            onSelect: () => notifier.selectElement(
              key,
              additive: boardState.multiSelectActive,
            ),
            onLongPress: () => notifier.armMultiSelect(key),
            onDragStart: (d) => _onPlayerDragStart(player, d, layout),
            onDragUpdate: (d) => _onPlayerDragUpdate(player, d, layout),
            onDragEnd: () => _onPlayerDragEnd(player),
          );
        }),
        if (ballPos != null)
          _PositionedBall(
            position: ballPos,
            layout: layout,
            animate: frame == null && _ballLive == null,
            draggable: (selectMode || tool == BoardTool.ball) && canEditBoard,
            onDragUpdate: (d) => _onBallDragUpdate(d, layout),
            onDragEnd: _onBallDragEnd,
            onDoubleTap: notifier.removeBall,
          ),
        if (frame == null)
          ...sortedTextNotes(boardState.textAnnotations).map((note) {
            final key = BoardElementKey(BoardElementKind.text, note.id);
            return _DraggableTextNote(
              key: ValueKey(note.id),
              note: note,
              layout: layout,
              isSelected: boardState.isSelected(key),
              interactionsEnabled: selectMode && !note.locked && canEditBoard,
              onSelect: () => notifier.selectElement(
                key,
                additive: boardState.multiSelectActive,
              ),
              onLongPress: () => notifier.armMultiSelect(key),
              onMoved: (x, y) => notifier.moveTextNote(
                noteId: note.id,
                x: x,
                y: y,
              ),
            );
          }),
        if (anchor != null && selectMode)
          ContextToolbar(
            anchor: anchor.position,
            canvasSize: widget.constraints,
          ),
      ],
    );
  }
}

class _MarqueeRect extends StatelessWidget {
  const _MarqueeRect({required this.rect});

  final Rect rect;

  @override
  Widget build(BuildContext context) {
    return Positioned.fromRect(
      rect: rect,
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.brand.withValues(alpha: 0.12),
            border: Border.all(color: AppColors.brand, width: 1.5),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

class _PositionedBall extends StatelessWidget {
  const _PositionedBall({
    required this.position,
    required this.layout,
    required this.animate,
    required this.draggable,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onDoubleTap,
  });

  final Offset position;
  final PitchLayout layout;
  final bool animate;
  final bool draggable;
  final GestureDragUpdateCallback onDragUpdate;
  final VoidCallback onDragEnd;
  final VoidCallback onDoubleTap;

  @override
  Widget build(BuildContext context) {
    final size = layout.tokenSize * 0.48;
    final anchor = layout.positionFor(position.dx, position.dy);
    // Larger invisible hit area for fingers.
    final hit = size * 2;
    return AnimatedPositioned(
      duration: animate ? const Duration(milliseconds: 220) : Duration.zero,
      curve: Curves.easeOut,
      left: anchor.dx - hit / 2,
      top: anchor.dy - hit / 2,
      width: hit,
      height: hit,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: draggable ? onDragUpdate : null,
        onPanEnd: draggable ? (_) => onDragEnd() : null,
        onDoubleTap: draggable ? onDoubleTap : null,
        child: Center(child: BallToken(size: size)),
      ),
    );
  }
}

class _DraggablePlayer extends StatelessWidget {
  const _DraggablePlayer({
    super.key,
    required this.player,
    required this.position,
    required this.layout,
    required this.animationDuration,
    required this.isSelected,
    required this.isDragging,
    required this.isRunning,
    required this.dimmed,
    required this.interactionsEnabled,
    required this.selectMode,
    required this.onSelect,
    required this.onLongPress,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  final Player player;
  final Offset position;
  final PitchLayout layout;
  final Duration animationDuration;
  final bool isSelected;
  final bool isDragging;
  final bool isRunning;
  final bool dimmed;
  final bool interactionsEnabled;
  final bool selectMode;
  final VoidCallback onSelect;
  final VoidCallback onLongPress;
  final GestureDragStartCallback onDragStart;
  final GestureDragUpdateCallback onDragUpdate;
  final VoidCallback onDragEnd;

  @override
  Widget build(BuildContext context) {
    final anchor = layout.positionFor(position.dx, position.dy);
    final labelHeight = player.label != null ? layout.tokenSize * 0.35 : 0.0;
    final totalHeight = layout.tokenSize + labelHeight;

    return AnimatedPositioned(
      duration: animationDuration,
      curve: Curves.easeOutCubic,
      left: anchor.dx - layout.tokenSize / 2,
      top: anchor.dy - totalHeight / 2,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: dimmed ? 0.55 : 1,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: selectMode ? onSelect : null,
          onLongPress: selectMode ? onLongPress : null,
          onPanStart: interactionsEnabled ? onDragStart : null,
          onPanUpdate: interactionsEnabled ? onDragUpdate : null,
          onPanEnd: interactionsEnabled ? (_) => onDragEnd() : null,
          onPanCancel: interactionsEnabled ? onDragEnd : null,
          child: MouseRegion(
            cursor: interactionsEnabled
                ? (isDragging ? SystemMouseCursors.grabbing : SystemMouseCursors.grab)
                : SystemMouseCursors.basic,
            child: PlayerToken(
              player: player,
              size: layout.tokenSize,
              isSelected: isSelected,
              isDragging: isDragging,
              isRunning: isRunning,
            ),
          ),
        ),
      ),
    );
  }
}

class _DraggableTextNote extends StatefulWidget {
  const _DraggableTextNote({
    super.key,
    required this.note,
    required this.layout,
    required this.isSelected,
    required this.interactionsEnabled,
    required this.onSelect,
    required this.onLongPress,
    required this.onMoved,
  });

  final TextAnnotation note;
  final PitchLayout layout;
  final bool isSelected;
  final bool interactionsEnabled;
  final VoidCallback onSelect;
  final VoidCallback onLongPress;
  final void Function(double x, double y) onMoved;

  @override
  State<_DraggableTextNote> createState() => _DraggableTextNoteState();
}

class _DraggableTextNoteState extends State<_DraggableTextNote> {
  Offset? _dragOffset;

  @override
  Widget build(BuildContext context) {
    final anchor = widget.layout.positionFor(widget.note.x, widget.note.y);
    final position = anchor + (_dragOffset ?? Offset.zero);

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onTap: widget.onSelect,
        onLongPress: widget.onLongPress,
        onPanUpdate: widget.interactionsEnabled
            ? (details) {
                setState(() {
                  _dragOffset = (_dragOffset ?? Offset.zero) + details.delta;
                });
              }
            : null,
        onPanEnd: widget.interactionsEnabled
            ? (_) {
                if (_dragOffset == null) return;
                final relative = widget.layout.relativeFor(position);
                final clamped = widget.layout.clampRelative(
                  x: relative.x,
                  y: relative.y,
                );
                widget.onMoved(clamped.x, clamped.y);
                setState(() => _dragOffset = null);
              }
            : null,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 170),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xEB0B1220),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.isSelected
                  ? AppColors.accentOrange
                  : const Color(0x33FFFFFF),
              width: widget.isSelected ? 2 : 1,
            ),
            boxShadow: [
              if (widget.isSelected)
                BoxShadow(
                  color: AppColors.accentOrange.withValues(alpha: 0.45),
                  blurRadius: 12,
                ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 8,
              ),
            ],
          ),
          child: Text(
            widget.note.text,
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
