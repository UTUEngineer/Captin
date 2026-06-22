import 'package:captain/core/services/haptic_service.dart';
import 'package:captain/core/services/haptic_patterns.dart';
import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/collaboration/application/collaboration_providers.dart';
import 'package:captain/features/collaboration/domain/collaboration_event.dart';
import 'package:captain/features/collaboration/presentation/widgets/remote_cursors_layer.dart';
import 'package:captain/features/training/application/training_providers.dart';
import 'package:captain/features/training/presentation/training_pitch_layer.dart';
import 'package:captain/features/shape_simulation/application/shape_simulation_notifier.dart';
import 'package:captain/features/shape_simulation/application/shape_simulation_providers.dart';
import 'package:captain/features/shape_simulation/presentation/widgets/ghost_trail_layer.dart';
import 'package:captain/features/tactical_board/application/board_layout_helpers.dart';
import 'package:captain/features/tactical_board/application/tactical_board_notifier.dart';
import 'package:captain/features/tactical_board/domain/board_element.dart';
import 'package:captain/features/tactical_board/domain/board_tool.dart';
import 'package:captain/features/tactical_board/domain/player.dart';
import 'package:captain/features/tactical_board/domain/text_annotation.dart';
import 'package:captain/features/tactical_board/presentation/widgets/annotations_painter.dart';
import 'package:captain/features/tactical_board/presentation/widgets/context_toolbar.dart';
import 'package:captain/features/tactical_board/presentation/widgets/manipulation_handles.dart';
import 'package:captain/features/tactical_board/presentation/widgets/pitch_painter.dart';
import 'package:captain/features/tactical_board/presentation/widgets/player_token.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class _PitchCanvasState extends ConsumerState<PitchCanvas> {
  final GlobalKey _pitchKey = GlobalKey();

  @override
  void didUpdateWidget(covariant PitchCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.boardState.skipNextAnimation) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(tacticalBoardProvider.notifier).clearSkipAnimation();
      });
    }
  }

  ({double x, double y})? _relativeFromLocal(Offset local, PitchLayout layout) {
    final renderBox =
        _pitchKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return null;
    return layout.relativeFor(renderBox.localToGlobal(local));
  }

  void _handleDrop({
    required Player player,
    required Offset globalDropOffset,
    required PitchLayout layout,
  }) {
    if (player.locked) return;
    if (!ref.read(collaborationProvider).canEditBoard) return;

    final renderBox =
        _pitchKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final localDrop = renderBox.globalToLocal(globalDropOffset);
    final labelHeight =
        player.label != null ? layout.tokenSize * 0.35 : 0.0;
    final totalHeight = layout.tokenSize + labelHeight;
    final center = Offset(
      localDrop.dx + layout.tokenSize / 2,
      localDrop.dy + totalHeight / 2,
    );
    final globalCenter = renderBox.localToGlobal(center);
    final relative = layout.relativeFor(globalCenter);
    final clamped = layout.clampRelative(x: relative.x, y: relative.y);
    final notifier = ref.read(tacticalBoardProvider.notifier);
    final x = notifier.snapValue(clamped.x);
    final y = notifier.snapValue(clamped.y);

    final simulation = ref.read(shapeSimulationProvider);
    if (simulation.isSimulationActive && player.isHomeTeam) {
      final boardState = ref.read(tacticalBoardProvider);
      final positions = ref.read(shapeSimulationProvider.notifier).simulatePlayerMove(
            playerId: player.id,
            newPosition: Offset(x, y),
            players: boardState.players,
          );

      notifier.movePlayers(
        positions: {
          for (final entry in positions.entries)
            entry.key: (x: entry.value.dx, y: entry.value.dy),
        },
      );
      ref.read(collaborationProvider.notifier).broadcastPlayerBatch(
            {
              for (final entry in positions.entries)
                entry.key: (x: entry.value.dx, y: entry.value.dy),
            },
          );
      return;
    }

    notifier.movePlayer(
      playerId: player.id,
      x: x,
      y: y,
    );
    playerPlacedHaptic(ref.read(hapticServiceProvider));
    ref.read(collaborationProvider.notifier).broadcastPlayerMoved(
          playerId: player.id,
          x: x,
          y: y,
        );
  }

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
    final relative = layout.relativeFor(
      layout.rect.topLeft + localPosition,
    );
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
          backgroundColor: AppColors.surfaceElevated,
          title: const Text('Add note'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Tactical note...',
              border: OutlineInputBorder(),
            ),
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

  @override
  Widget build(BuildContext context) {
    final boardState = widget.boardState;
    final simulation = ref.watch(shapeSimulationProvider);
    final collaboration = ref.watch(collaborationProvider);
    final training = ref.watch(trainingProvider);
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
    final animationDuration = boardState.skipNextAnimation
        ? Duration.zero
        : simulation.isSimulationActive
            ? shapeSimulationAnimationDuration
            : formationAnimationDuration;
    final animationCurve = simulation.isSimulationActive
        ? Curves.easeOut
        : Curves.easeInOutCubic;
    final selectMode = boardState.activeTool.isSelect;
    final tool = boardState.activeTool;
    final anchor = selectionAnchorFor(state: boardState, layout: layout);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fromRect(
          rect: layout.rect,
          child: DragTarget<Player>(
            onWillAcceptWithDetails: (_) => selectMode,
            onAcceptWithDetails: (details) {
              _handleDrop(
                player: details.data,
                globalDropOffset: details.offset,
                layout: layout,
              );
            },
            builder: (context, candidateData, rejectedData) {
              return const SizedBox.shrink();
            },
          ),
        ),
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
                child: CustomPaint(
                  size: layout.rect.size,
                  painter: AnnotationsPainter(
                    layout: localLayout,
                    zones: sortedZones(boardState.zones),
                    highlights: sortedHighlights(boardState.highlights),
                    arrows: sortedArrows(boardState.arrows),
                    draft: boardState.draftDrawing,
                  ),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTapUp: (details) {
                  if (training.isTrainingMode) return;
                  final relative =
                      _relativeFromLocal(details.localPosition, layout);
                  if (relative == null) return;

                  switch (tool) {
                    case BoardTool.select:
                      final element = notifier.findElementAt(
                        x: relative.x,
                        y: relative.y,
                      );
                      if (element != null) {
                        notifier.selectElement(
                          element,
                          additive: boardState.multiSelectActive,
                        );
                      } else {
                        notifier.clearSelection();
                      }
                    case BoardTool.textNote:
                      _promptTextNote(relative.x, relative.y);
                    case BoardTool.eraser:
                      notifier.eraseAt(x: relative.x, y: relative.y);
                    default:
                      break;
                  }
                },
                onPanStart: (details) {
                  if (training.isTrainingMode) return;
                  if (!tool.isDragDrawTool || !canEditBoard) return;
                  final relative =
                      _relativeFromLocal(details.localPosition, layout);
                  if (relative == null) return;
                  notifier.startDraft(x: relative.x, y: relative.y);
                },
                onPanUpdate: (details) {
                  if (training.isTrainingMode) return;
                  if (!tool.isDragDrawTool) return;
                  final relative =
                      _relativeFromLocal(details.localPosition, layout);
                  if (relative == null) return;
                  notifier.updateDraft(x: relative.x, y: relative.y);
                },
                onPanEnd: (_) {
                  if (!tool.isDragDrawTool || !canEditBoard) return;
                  _commitDraftWithSync(notifier);
                },
                onPanCancel: () {
                  if (!tool.isDragDrawTool) return;
                  notifier.cancelDraft();
                },
                child: SizedBox(
                  width: layout.rect.width,
                  height: layout.rect.height,
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
        ...sortedZones(boardState.zones).map((zone) {
          final key = BoardElementKey(BoardElementKind.zone, zone.id);
          final selected = boardState.isSelected(key);
          return ZoneResizeHandles(
            key: ValueKey('zone-handles-${zone.id}'),
            zone: zone,
            layout: layout,
            enabled: selectMode && selected && !zone.locked,
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
            enabled: selectMode && selected && !arrow.locked,
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
        if (anchor != null)
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
        ...sortedPlayers(boardState.players).map((player) {
          final key = BoardElementKey(BoardElementKind.player, player.id);
          return _DraggablePlayer(
            key: ValueKey(player.id),
            player: player,
            layout: layout,
            animationDuration: animationDuration,
            animationCurve: animationCurve,
            isSelected: boardState.isSelected(key),
            isDragging: boardState.draggingPlayerId == player.id,
            interactionsEnabled: selectMode && !player.locked && canEditBoard,
            selectMode: selectMode,
            onSelect: () => notifier.selectElement(
              key,
              additive: boardState.multiSelectActive,
            ),
            onLongPress: () => notifier.armMultiSelect(key),
            onDragStarted: () => notifier.setDraggingPlayer(player.id),
            onDragEnded: () => notifier.setDraggingPlayer(null),
          );
        }),
        if (simulation.isSimulationActive)
          Positioned.fromRect(
            rect: layout.rect,
            child: GhostTrailLayer(
              players: boardState.players,
              ghostPositions: simulation.ghostPositions,
              layout: localLayout,
            ),
          ),
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

class _DraggablePlayer extends StatelessWidget {
  const _DraggablePlayer({
    super.key,
    required this.player,
    required this.layout,
    required this.animationDuration,
    required this.animationCurve,
    required this.isSelected,
    required this.isDragging,
    required this.interactionsEnabled,
    required this.selectMode,
    required this.onSelect,
    required this.onLongPress,
    required this.onDragStarted,
    required this.onDragEnded,
  });

  final Player player;
  final PitchLayout layout;
  final Duration animationDuration;
  final Curve animationCurve;
  final bool isSelected;
  final bool isDragging;
  final bool interactionsEnabled;
  final bool selectMode;
  final VoidCallback onSelect;
  final VoidCallback onLongPress;
  final VoidCallback onDragStarted;
  final VoidCallback onDragEnded;

  @override
  Widget build(BuildContext context) {
    final anchor = layout.positionFor(player.x, player.y);
    final labelHeight = player.label != null ? layout.tokenSize * 0.35 : 0.0;
    final totalHeight = layout.tokenSize + labelHeight;

    final token = PlayerToken(
      player: player,
      size: layout.tokenSize,
      isSelected: isSelected,
      isDragging: isDragging,
    );

    return AnimatedPositioned(
      duration: animationDuration,
      curve: animationCurve,
      left: anchor.dx - layout.tokenSize / 2,
      top: anchor.dy - totalHeight / 2,
      child: GestureDetector(
        onTap: selectMode ? onSelect : null,
        onLongPress: selectMode ? onLongPress : null,
        child: IgnorePointer(
          ignoring: !interactionsEnabled,
          child: LongPressDraggable<Player>(
            data: player,
            dragAnchorStrategy: pointerDragAnchorStrategy,
            onDragStarted: onDragStarted,
            onDragEnd: (_) => onDragEnded(),
            feedback: Material(
              type: MaterialType.transparency,
              child: PlayerToken(
                player: player,
                size: layout.tokenSize,
                isDragging: true,
                elevatedShadow: true,
              ),
            ),
            childWhenDragging: Opacity(opacity: 0.25, child: token),
            child: token,
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
                final relative = widget.layout.relativeFor(
                  Offset(position.dx, position.dy),
                );
                final clamped = widget.layout.clampRelative(
                  x: relative.x,
                  y: relative.y,
                );
                widget.onMoved(clamped.x, clamped.y);
                setState(() => _dragOffset = null);
              }
            : null,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 160),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.isSelected
                  ? AppColors.accentOrange
                  : AppColors.border,
              width: widget.isSelected ? 2 : 1,
            ),
            boxShadow: [
              if (widget.isSelected)
                BoxShadow(
                  color: AppColors.accentOrange.withValues(alpha: 0.45),
                  blurRadius: 12,
                ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 6,
              ),
            ],
          ),
          child: Text(
            widget.note.text,
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
