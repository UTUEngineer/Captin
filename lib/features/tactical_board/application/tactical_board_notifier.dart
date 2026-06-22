import 'dart:math' as math;
import 'dart:ui';

import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/collaboration/domain/collaboration_event.dart';
import 'package:captain/features/formations/domain/tactic_board_template.dart';
import 'package:captain/features/tactical_board/domain/arrow.dart';
import 'package:captain/features/tactical_board/domain/board_element.dart';
import 'package:captain/features/tactical_board/domain/board_snapshot.dart';
import 'package:captain/features/tactical_board/domain/board_tool.dart';
import 'package:captain/features/tactical_board/domain/formation.dart';
import 'package:captain/features/tactical_board/domain/formation_presets.dart';
import 'package:captain/features/tactical_board/domain/highlight_circle.dart';
import 'package:captain/features/tactical_board/domain/pitch_orientation.dart';
import 'package:captain/features/tactical_board/domain/pitch_style.dart';
import 'package:captain/features/tactical_board/domain/player.dart';
import 'package:captain/features/tactical_board/domain/text_annotation.dart';
import 'package:captain/features/tactical_board/domain/zone.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();
const formationAnimationDuration = Duration(milliseconds: 500);
const snapGridStep = 0.05;
const minDrawSize = 0.02;
const duplicateOffsetRelative = 0.025;
const maxBoardHistoryDepth = 50;

const zoneColorPalette = <Color>[
  AppColors.accentRed,
  AppColors.pitchGreenLight,
  Color(0xFF42A5F5),
  Color(0xFFFFEE58),
];

class DraftDrawing {
  const DraftDrawing({
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.tool,
  });

  final double startX;
  final double startY;
  final double endX;
  final double endY;
  final BoardTool tool;
}

class TacticalBoardState {
  const TacticalBoardState({
    this.selectedFormation,
    this.players = const [],
    this.arrows = const [],
    this.zones = const [],
    this.highlights = const [],
    this.textAnnotations = const [],
    this.orientation = PitchOrientation.vertical,
    this.pitchStyle = PitchStyle.striped,
    this.activeTool = BoardTool.select,
    this.selectedZoneColor = 0xFFE53935,
    this.selectedElements = const {},
    this.multiSelectActive = false,
    this.snapToGrid = false,
    this.draggingPlayerId,
    this.draftDrawing,
    this.canUndo = false,
    this.canRedo = false,
    this.skipNextAnimation = false,
  });

  final FormationType? selectedFormation;
  final List<Player> players;
  final List<Arrow> arrows;
  final List<Zone> zones;
  final List<HighlightCircle> highlights;
  final List<TextAnnotation> textAnnotations;
  final PitchOrientation orientation;
  final PitchStyle pitchStyle;
  final BoardTool activeTool;
  final int selectedZoneColor;
  final Set<BoardElementKey> selectedElements;
  final bool multiSelectActive;
  final bool snapToGrid;
  final String? draggingPlayerId;
  final DraftDrawing? draftDrawing;
  final bool canUndo;
  final bool canRedo;
  final bool skipNextAnimation;

  bool isSelected(BoardElementKey key) => selectedElements.contains(key);

  TacticalBoardState copyWith({
    FormationType? selectedFormation,
    List<Player>? players,
    List<Arrow>? arrows,
    List<Zone>? zones,
    List<HighlightCircle>? highlights,
    List<TextAnnotation>? textAnnotations,
    PitchOrientation? orientation,
    PitchStyle? pitchStyle,
    BoardTool? activeTool,
    int? selectedZoneColor,
    Set<BoardElementKey>? selectedElements,
    bool? multiSelectActive,
    bool? snapToGrid,
    String? draggingPlayerId,
    bool clearDraggingPlayer = false,
    DraftDrawing? draftDrawing,
    bool clearDraftDrawing = false,
    bool? canUndo,
    bool? canRedo,
    bool? skipNextAnimation,
    bool clearSelection = false,
  }) {
    return TacticalBoardState(
      selectedFormation: selectedFormation ?? this.selectedFormation,
      players: players ?? this.players,
      arrows: arrows ?? this.arrows,
      zones: zones ?? this.zones,
      highlights: highlights ?? this.highlights,
      textAnnotations: textAnnotations ?? this.textAnnotations,
      orientation: orientation ?? this.orientation,
      pitchStyle: pitchStyle ?? this.pitchStyle,
      activeTool: activeTool ?? this.activeTool,
      selectedZoneColor: selectedZoneColor ?? this.selectedZoneColor,
      selectedElements:
          clearSelection ? {} : (selectedElements ?? this.selectedElements),
      multiSelectActive: clearSelection
          ? false
          : (multiSelectActive ?? this.multiSelectActive),
      snapToGrid: snapToGrid ?? this.snapToGrid,
      draggingPlayerId: clearDraggingPlayer
          ? null
          : (draggingPlayerId ?? this.draggingPlayerId),
      draftDrawing:
          clearDraftDrawing ? null : (draftDrawing ?? this.draftDrawing),
      canUndo: canUndo ?? this.canUndo,
      canRedo: canRedo ?? this.canRedo,
      skipNextAnimation: skipNextAnimation ?? this.skipNextAnimation,
    );
  }
}

class TacticalBoardNotifier extends StateNotifier<TacticalBoardState> {
  TacticalBoardNotifier() : super(const TacticalBoardState()) {
    selectFormation(FormationType.f433, recordHistory: false);
  }

  final List<BoardSnapshot> _undoStack = [];
  final List<BoardSnapshot> _redoStack = [];

  void setTool(BoardTool tool) {
    state = state.copyWith(
      activeTool: tool,
      clearDraftDrawing: true,
      clearSelection: true,
    );
  }

  void setZoneColor(int colorValue) {
    state = state.copyWith(selectedZoneColor: colorValue);
  }

  void selectFormation(FormationType type, {bool recordHistory = true}) {
    if (recordHistory) _pushHistory();

    state = state.copyWith(
      selectedFormation: type,
      players: _buildPlayersForFormation(type),
      clearDraftDrawing: true,
      clearSelection: true,
      skipNextAnimation: false,
    );
  }

  void selectElement(BoardElementKey key, {bool additive = false}) {
    if (!state.activeTool.isSelect) return;

    if (additive || state.multiSelectActive) {
      final next = {...state.selectedElements};
      if (next.contains(key)) {
        next.remove(key);
      } else {
        next.add(key);
      }
      state = state.copyWith(
        selectedElements: next,
        multiSelectActive: true,
      );
      return;
    }

    state = state.copyWith(
      selectedElements: {key},
      multiSelectActive: false,
    );
  }

  void armMultiSelect(BoardElementKey key) {
    if (!state.activeTool.isSelect) return;
    state = state.copyWith(
      selectedElements: {key},
      multiSelectActive: true,
    );
  }

  void selectPlayer(String playerId) {
    selectElement(BoardElementKey(BoardElementKind.player, playerId));
  }

  void clearSelection() {
    if (state.selectedElements.isEmpty && !state.multiSelectActive) return;
    state = state.copyWith(clearSelection: true);
  }

  BoardElementKey? findElementAt({required double x, required double y}) {
    final noteId = _findTextAt(x, y);
    if (noteId != null) {
      return BoardElementKey(BoardElementKind.text, noteId);
    }

    final arrowId = _findArrowAt(x, y);
    if (arrowId != null) {
      return BoardElementKey(BoardElementKind.arrow, arrowId);
    }

    final zoneId = _findZoneAt(x, y);
    if (zoneId != null) {
      return BoardElementKey(BoardElementKind.zone, zoneId);
    }

    final circleId = _findCircleAt(x, y);
    if (circleId != null) {
      return BoardElementKey(BoardElementKind.highlight, circleId);
    }

    return null;
  }

  bool isLocked(BoardElementKey key) {
    return switch (key.kind) {
      BoardElementKind.player =>
        state.players.firstWhere((p) => p.id == key.id).locked,
      BoardElementKind.arrow =>
        state.arrows.firstWhere((a) => a.id == key.id).locked,
      BoardElementKind.zone => state.zones.firstWhere((z) => z.id == key.id).locked,
      BoardElementKind.highlight =>
        state.highlights.firstWhere((c) => c.id == key.id).locked,
      BoardElementKind.text =>
        state.textAnnotations.firstWhere((n) => n.id == key.id).locked,
    };
  }

  void deleteSelected() {
    if (state.selectedElements.isEmpty) return;
    _pushHistory();

    final playerIds = _idsFor(BoardElementKind.player);
    final arrowIds = _idsFor(BoardElementKind.arrow);
    final zoneIds = _idsFor(BoardElementKind.zone);
    final highlightIds = _idsFor(BoardElementKind.highlight);
    final textIds = _idsFor(BoardElementKind.text);

    state = state.copyWith(
      players: state.players.where((p) => !playerIds.contains(p.id)).toList(),
      arrows: state.arrows.where((a) => !arrowIds.contains(a.id)).toList(),
      zones: state.zones.where((z) => !zoneIds.contains(z.id)).toList(),
      highlights:
          state.highlights.where((c) => !highlightIds.contains(c.id)).toList(),
      textAnnotations:
          state.textAnnotations.where((n) => !textIds.contains(n.id)).toList(),
      clearSelection: true,
    );
  }

  void duplicateSelected() {
    if (state.selectedElements.isEmpty) return;
    _pushHistory();

    var players = state.players;
    var arrows = state.arrows;
    var zones = state.zones;
    var highlights = state.highlights;
    var notes = state.textAnnotations;
    final newSelection = <BoardElementKey>{};

    for (final key in state.selectedElements) {
      if (isLocked(key)) continue;

      switch (key.kind) {
        case BoardElementKind.player:
          final player = players.firstWhere((p) => p.id == key.id);
          final copy = player.copyWith(
            id: _uuid.v4(),
            x: _clamp(player.x + duplicateOffsetRelative),
            y: _clamp(player.y + duplicateOffsetRelative),
            locked: false,
            zIndex: _nextZIndex(BoardElementKind.player),
          );
          players = [...players, copy];
          newSelection.add(BoardElementKey(BoardElementKind.player, copy.id));
        case BoardElementKind.arrow:
          final arrow = arrows.firstWhere((a) => a.id == key.id);
          final copy = arrow.copyWith(
            id: _uuid.v4(),
            startX: _clamp(arrow.startX + duplicateOffsetRelative),
            startY: _clamp(arrow.startY + duplicateOffsetRelative),
            endX: _clamp(arrow.endX + duplicateOffsetRelative),
            endY: _clamp(arrow.endY + duplicateOffsetRelative),
            locked: false,
            zIndex: _nextZIndex(BoardElementKind.arrow),
          );
          arrows = [...arrows, copy];
          newSelection.add(BoardElementKey(BoardElementKind.arrow, copy.id));
        case BoardElementKind.zone:
          final zone = zones.firstWhere((z) => z.id == key.id);
          final copy = zone.copyWith(
            id: _uuid.v4(),
            x: _clamp(zone.x + duplicateOffsetRelative),
            y: _clamp(zone.y + duplicateOffsetRelative),
            locked: false,
            zIndex: _nextZIndex(BoardElementKind.zone),
          );
          zones = [...zones, copy];
          newSelection.add(BoardElementKey(BoardElementKind.zone, copy.id));
        case BoardElementKind.highlight:
          final circle = highlights.firstWhere((c) => c.id == key.id);
          final copy = circle.copyWith(
            id: _uuid.v4(),
            centerX: _clamp(circle.centerX + duplicateOffsetRelative),
            centerY: _clamp(circle.centerY + duplicateOffsetRelative),
            locked: false,
            zIndex: _nextZIndex(BoardElementKind.highlight),
          );
          highlights = [...highlights, copy];
          newSelection.add(BoardElementKey(BoardElementKind.highlight, copy.id));
        case BoardElementKind.text:
          final note = notes.firstWhere((n) => n.id == key.id);
          final copy = note.copyWith(
            id: _uuid.v4(),
            x: _clamp(note.x + duplicateOffsetRelative),
            y: _clamp(note.y + duplicateOffsetRelative),
            locked: false,
            zIndex: _nextZIndex(BoardElementKind.text),
          );
          notes = [...notes, copy];
          newSelection.add(BoardElementKey(BoardElementKind.text, copy.id));
      }
    }

    state = state.copyWith(
      players: players,
      arrows: arrows,
      zones: zones,
      highlights: highlights,
      textAnnotations: notes,
      selectedElements: newSelection,
    );
  }

  void setSelectedColor(int colorValue) {
    if (state.selectedElements.isEmpty) return;
    _pushHistory();

    final arrowIds = _idsFor(BoardElementKind.arrow);
    final zoneIds = _idsFor(BoardElementKind.zone);
    final highlightIds = _idsFor(BoardElementKind.highlight);

    state = state.copyWith(
      arrows: state.arrows
          .map(
            (arrow) => arrowIds.contains(arrow.id)
                ? arrow.copyWith(colorValue: colorValue)
                : arrow,
          )
          .toList(),
      zones: state.zones
          .map(
            (zone) => zoneIds.contains(zone.id)
                ? zone.copyWith(colorValue: colorValue)
                : zone,
          )
          .toList(),
      highlights: state.highlights
          .map(
            (circle) => highlightIds.contains(circle.id)
                ? circle.copyWith(colorValue: colorValue)
                : circle,
          )
          .toList(),
    );
  }

  void toggleSelectedLock() {
    if (state.selectedElements.isEmpty) return;
    _pushHistory();

    for (final key in state.selectedElements) {
      state = switch (key.kind) {
        BoardElementKind.player => state.copyWith(
            players: state.players
                .map(
                  (player) => player.id == key.id
                      ? player.copyWith(locked: !player.locked)
                      : player,
                )
                .toList(),
          ),
        BoardElementKind.arrow => state.copyWith(
            arrows: state.arrows
                .map(
                  (arrow) => arrow.id == key.id
                      ? arrow.copyWith(locked: !arrow.locked)
                      : arrow,
                )
                .toList(),
          ),
        BoardElementKind.zone => state.copyWith(
            zones: state.zones
                .map(
                  (zone) => zone.id == key.id
                      ? zone.copyWith(locked: !zone.locked)
                      : zone,
                )
                .toList(),
          ),
        BoardElementKind.highlight => state.copyWith(
            highlights: state.highlights
                .map(
                  (circle) => circle.id == key.id
                      ? circle.copyWith(locked: !circle.locked)
                      : circle,
                )
                .toList(),
          ),
        BoardElementKind.text => state.copyWith(
            textAnnotations: state.textAnnotations
                .map(
                  (note) => note.id == key.id
                      ? note.copyWith(locked: !note.locked)
                      : note,
                )
                .toList(),
          ),
      };
    }
  }

  void bringSelectedToFront() {
    if (state.selectedElements.isEmpty) return;
    _pushHistory();
    _shiftSelectedZIndex(toFront: true);
  }

  void sendSelectedToBack() {
    if (state.selectedElements.isEmpty) return;
    _pushHistory();
    _shiftSelectedZIndex(toFront: false);
  }

  void updateArrowEndpoint({
    required String arrowId,
    required bool isStart,
    required double x,
    required double y,
    bool commit = true,
  }) {
    final arrow = state.arrows.firstWhere((a) => a.id == arrowId);
    if (arrow.locked) return;

    if (commit) _pushHistory();
    final snappedX = snapValue(x);
    final snappedY = snapValue(y);

    state = state.copyWith(
      arrows: state.arrows
          .map(
            (item) => item.id == arrowId
                ? item.copyWith(
                    startX: isStart ? snappedX : item.startX,
                    startY: isStart ? snappedY : item.startY,
                    endX: isStart ? item.endX : snappedX,
                    endY: isStart ? item.endY : snappedY,
                  )
                : item,
          )
          .toList(),
    );
  }

  void resizeZone({
    required String zoneId,
    required double x,
    required double y,
    required double width,
    required double height,
    bool commit = true,
  }) {
    final zone = state.zones.firstWhere((z) => z.id == zoneId);
    if (zone.locked) return;

    if (commit) _pushHistory();
    state = state.copyWith(
      zones: state.zones
          .map(
            (item) => item.id == zoneId
                ? item.copyWith(
                    x: snapValue(x),
                    y: snapValue(y),
                    width: math.max(minDrawSize, snapValue(width)),
                    height: math.max(minDrawSize, snapValue(height)),
                  )
                : item,
          )
          .toList(),
    );
  }

  void setElementRotation(
    BoardElementKey key,
    double rotation, {
    bool commit = true,
  }) {
    if (!key.kind.supportsRotation) return;
    if (isLocked(key)) return;

    if (commit) _pushHistory();
    state = switch (key.kind) {
      BoardElementKind.arrow => state.copyWith(
          arrows: state.arrows
              .map(
                (arrow) => arrow.id == key.id
                    ? arrow.copyWith(rotation: rotation)
                    : arrow,
              )
              .toList(),
        ),
      BoardElementKind.zone => state.copyWith(
          zones: state.zones
              .map(
                (zone) => zone.id == key.id
                    ? zone.copyWith(rotation: rotation)
                    : zone,
              )
              .toList(),
        ),
      _ => state,
    };
  }

  void setDraggingPlayer(String? playerId) {
    state = state.copyWith(
      draggingPlayerId: playerId,
      clearDraggingPlayer: playerId == null,
    );
  }

  void toggleSnapToGrid() {
    state = state.copyWith(snapToGrid: !state.snapToGrid);
  }

  void undo() {
    if (_undoStack.isEmpty) return;

    _redoStack.add(_currentSnapshot());
    final snapshot = _undoStack.removeLast();
    _applySnapshot(snapshot);
    _syncHistoryFlags();
  }

  void redo() {
    if (_redoStack.isEmpty) return;

    _undoStack.add(_currentSnapshot());
    final snapshot = _redoStack.removeLast();
    _applySnapshot(snapshot);
    _syncHistoryFlags();
  }

  void startDraft({required double x, required double y}) {
    final tool = state.activeTool;
    if (!tool.isDragDrawTool) return;

    state = state.copyWith(
      draftDrawing: DraftDrawing(
        startX: x,
        startY: y,
        endX: x,
        endY: y,
        tool: tool,
      ),
    );
  }

  void updateDraft({required double x, required double y}) {
    final draft = state.draftDrawing;
    if (draft == null) return;

    state = state.copyWith(
      draftDrawing: DraftDrawing(
        startX: draft.startX,
        startY: draft.startY,
        endX: x,
        endY: y,
        tool: draft.tool,
      ),
    );
  }

  void commitDraft() {
    final draft = state.draftDrawing;
    if (draft == null) return;

    _pushHistory();

    switch (draft.tool) {
      case BoardTool.passArrow:
      case BoardTool.runArrow:
      case BoardTool.pressArrow:
      case BoardTool.curvedRun:
        _commitArrow(draft);
      case BoardTool.zone:
        _commitZone(draft);
      case BoardTool.circle:
        _commitCircle(draft);
      default:
        break;
    }

    state = state.copyWith(clearDraftDrawing: true);
  }

  void cancelDraft() {
    if (state.draftDrawing == null) return;
    state = state.copyWith(clearDraftDrawing: true);
  }

  Future<void> addTextNote({
    required double x,
    required double y,
    required String text,
  }) async {
    if (text.trim().isEmpty) return;
    _pushHistory();

    final note = TextAnnotation(
      id: _uuid.v4(),
      x: x,
      y: y,
      text: text.trim(),
      zIndex: _nextZIndex(BoardElementKind.text),
    );

    state = state.copyWith(
      textAnnotations: [...state.textAnnotations, note],
    );
  }

  void moveTextNote({
    required String noteId,
    required double x,
    required double y,
  }) {
    final note = state.textAnnotations.firstWhere((n) => n.id == noteId);
    if (note.locked) return;

    _pushHistory();
    final notes = state.textAnnotations.map((item) {
      if (item.id != noteId) return item;
      return item.copyWith(x: x, y: y);
    }).toList(growable: false);

    state = state.copyWith(textAnnotations: notes);
  }

  void eraseAt({required double x, required double y}) {
    final element = findElementAt(x: x, y: y);
    if (element == null) return;

    _pushHistory();
    state = switch (element.kind) {
      BoardElementKind.arrow => state.copyWith(
          arrows: state.arrows.where((a) => a.id != element.id).toList(),
        ),
      BoardElementKind.zone => state.copyWith(
          zones: state.zones.where((z) => z.id != element.id).toList(),
        ),
      BoardElementKind.highlight => state.copyWith(
          highlights:
              state.highlights.where((c) => c.id != element.id).toList(),
        ),
      BoardElementKind.text => state.copyWith(
          textAnnotations:
              state.textAnnotations.where((n) => n.id != element.id).toList(),
        ),
      BoardElementKind.player => state,
    };
  }

  void movePlayer({
    required String playerId,
    required double x,
    required double y,
  }) {
    final player = state.players.firstWhere((p) => p.id == playerId);
    if (player.locked) return;

    _pushHistory();
    final players = state.players.map((item) {
      if (item.id != playerId) return item;
      return item.copyWith(x: x, y: y);
    }).toList(growable: false);

    state = state.copyWith(
      players: players,
      skipNextAnimation: true,
      clearDraggingPlayer: true,
    );
  }

  void movePlayers({
    required Map<String, ({double x, double y})> positions,
  }) {
    if (positions.isEmpty) return;

    _pushHistory();
    final players = state.players.map((item) {
      final next = positions[item.id];
      if (next == null) return item;
      return item.copyWith(x: next.x, y: next.y);
    }).toList(growable: false);

    state = state.copyWith(
      players: players,
      skipNextAnimation: false,
      clearDraggingPlayer: true,
    );
  }

  void clearSkipAnimation() {
    if (!state.skipNextAnimation) return;
    state = state.copyWith(skipNextAnimation: false);
  }

  void setOrientation(PitchOrientation orientation) {
    state = state.copyWith(orientation: orientation);
  }

  void toggleOrientation() {
    state = state.copyWith(orientation: state.orientation.toggled());
  }

  void togglePitchStyle() {
    state = state.copyWith(pitchStyle: state.pitchStyle.toggled());
  }

  void syncOrientationWithViewport({
    required double width,
    required double height,
  }) {
    final autoOrientation = width >= height
        ? PitchOrientation.horizontal
        : PitchOrientation.vertical;
    if (state.orientation != autoOrientation) {
      state = state.copyWith(orientation: autoOrientation);
    }
  }

  double snapValue(double value) {
    if (!state.snapToGrid) return value.clamp(0.0, 1.0);
    return (value / snapGridStep).round() * snapGridStep;
  }

  Set<String> _idsFor(BoardElementKind kind) {
    return state.selectedElements
        .where((key) => key.kind == kind)
        .map((key) => key.id)
        .toSet();
  }

  double _clamp(double value) => value.clamp(0.0, 1.0);

  int _nextZIndex(BoardElementKind kind) {
    final values = switch (kind) {
      BoardElementKind.player => state.players.map((p) => p.zIndex),
      BoardElementKind.arrow => state.arrows.map((a) => a.zIndex),
      BoardElementKind.zone => state.zones.map((z) => z.zIndex),
      BoardElementKind.highlight => state.highlights.map((c) => c.zIndex),
      BoardElementKind.text => state.textAnnotations.map((n) => n.zIndex),
    };
    if (values.isEmpty) return 1;
    return values.reduce(math.max) + 1;
  }

  void _shiftSelectedZIndex({required bool toFront}) {
    for (final key in state.selectedElements) {
      final next = toFront ? _nextZIndex(key.kind) : 0;
      state = switch (key.kind) {
        BoardElementKind.player => state.copyWith(
            players: state.players
                .map(
                  (player) => player.id == key.id
                      ? player.copyWith(zIndex: next)
                      : player,
                )
                .toList(),
          ),
        BoardElementKind.arrow => state.copyWith(
            arrows: state.arrows
                .map(
                  (arrow) => arrow.id == key.id
                      ? arrow.copyWith(zIndex: next)
                      : arrow,
                )
                .toList(),
          ),
        BoardElementKind.zone => state.copyWith(
            zones: state.zones
                .map(
                  (zone) => zone.id == key.id
                      ? zone.copyWith(zIndex: next)
                      : zone,
                )
                .toList(),
          ),
        BoardElementKind.highlight => state.copyWith(
            highlights: state.highlights
                .map(
                  (circle) => circle.id == key.id
                      ? circle.copyWith(zIndex: next)
                      : circle,
                )
                .toList(),
          ),
        BoardElementKind.text => state.copyWith(
            textAnnotations: state.textAnnotations
                .map(
                  (note) => note.id == key.id
                      ? note.copyWith(zIndex: next)
                      : note,
                )
                .toList(),
          ),
      };
    }
  }

  void _commitArrow(DraftDrawing draft) {
    if (!_hasMinimumSize(draft.startX, draft.startY, draft.endX, draft.endY)) {
      return;
    }

    final type = switch (draft.tool) {
      BoardTool.passArrow => ArrowType.pass,
      BoardTool.runArrow => ArrowType.run,
      BoardTool.pressArrow => ArrowType.press,
      BoardTool.curvedRun => ArrowType.curvedRun,
      _ => ArrowType.pass,
    };

    final arrow = Arrow(
      id: _uuid.v4(),
      startX: draft.startX,
      startY: draft.startY,
      endX: draft.endX,
      endY: draft.endY,
      type: type,
      curved: draft.tool == BoardTool.curvedRun,
      colorValue: _defaultArrowColor(type).toARGB32(),
      zIndex: _nextZIndex(BoardElementKind.arrow),
    );

    state = state.copyWith(arrows: [...state.arrows, arrow]);
  }

  void _commitZone(DraftDrawing draft) {
    final bounds = _normalizedBounds(draft);
    if (bounds.width < minDrawSize || bounds.height < minDrawSize) return;

    final zone = Zone(
      id: _uuid.v4(),
      x: bounds.left,
      y: bounds.top,
      width: bounds.width,
      height: bounds.height,
      colorValue: state.selectedZoneColor,
      zIndex: _nextZIndex(BoardElementKind.zone),
    );

    state = state.copyWith(zones: [...state.zones, zone]);
  }

  void _commitCircle(DraftDrawing draft) {
    final bounds = _normalizedBounds(draft);
    if (bounds.width < minDrawSize || bounds.height < minDrawSize) return;

    final circle = HighlightCircle(
      id: _uuid.v4(),
      centerX: bounds.left + bounds.width / 2,
      centerY: bounds.top + bounds.height / 2,
      radiusX: bounds.width / 2,
      radiusY: bounds.height / 2,
      colorValue: state.selectedZoneColor,
      zIndex: _nextZIndex(BoardElementKind.highlight),
    );

    state = state.copyWith(highlights: [...state.highlights, circle]);
  }

  Color _defaultArrowColor(ArrowType type) {
    return switch (type) {
      ArrowType.pass => AppColors.textPrimary,
      ArrowType.run => AppColors.textPrimary,
      ArrowType.press => AppColors.accentRed,
      ArrowType.curvedRun => AppColors.accentOrange,
    };
  }

  ({double left, double top, double width, double height}) _normalizedBounds(
    DraftDrawing draft,
  ) {
    final left = math.min(draft.startX, draft.endX);
    final top = math.min(draft.startY, draft.endY);
    final width = (draft.endX - draft.startX).abs();
    final height = (draft.endY - draft.startY).abs();
    return (left: left, top: top, width: width, height: height);
  }

  bool _hasMinimumSize(double x1, double y1, double x2, double y2) {
    return (x2 - x1).abs() >= minDrawSize || (y2 - y1).abs() >= minDrawSize;
  }

  String? _findArrowAt(double x, double y) {
    const threshold = 0.025;
    final sorted = [...state.arrows]..sort((a, b) => b.zIndex.compareTo(a.zIndex));
    for (final arrow in sorted) {
      if (_distanceToArrow(arrow, x, y) <= threshold) return arrow.id;
    }
    return null;
  }

  String? _findZoneAt(double x, double y) {
    final sorted = [...state.zones]..sort((a, b) => b.zIndex.compareTo(a.zIndex));
    for (final zone in sorted) {
      if (x >= zone.x &&
          x <= zone.x + zone.width &&
          y >= zone.y &&
          y <= zone.y + zone.height) {
        return zone.id;
      }
    }
    return null;
  }

  String? _findCircleAt(double x, double y) {
    final sorted = [...state.highlights]
      ..sort((a, b) => b.zIndex.compareTo(a.zIndex));
    for (final circle in sorted) {
      final dx = (x - circle.centerX) / circle.radiusX;
      final dy = (y - circle.centerY) / circle.radiusY;
      if (dx * dx + dy * dy <= 1) return circle.id;
    }
    return null;
  }

  String? _findTextAt(double x, double y) {
    const threshold = 0.06;
    final sorted = [...state.textAnnotations]
      ..sort((a, b) => b.zIndex.compareTo(a.zIndex));
    for (final note in sorted) {
      final dx = x - note.x;
      final dy = y - note.y;
      if (math.sqrt(dx * dx + dy * dy) <= threshold) return note.id;
    }
    return null;
  }

  double _distanceToArrow(Arrow arrow, double x, double y) {
    if (arrow.curved) {
      return _distanceToQuadraticBezier(
        arrow.startX,
        arrow.startY,
        (arrow.startX + arrow.endX) / 2,
        arrow.startY - (arrow.endY - arrow.startY).abs() * 0.35,
        arrow.endX,
        arrow.endY,
        x,
        y,
      );
    }

    return _distanceToSegment(
      arrow.startX,
      arrow.startY,
      arrow.endX,
      arrow.endY,
      x,
      y,
    );
  }

  double _distanceToSegment(
    double x1,
    double y1,
    double x2,
    double y2,
    double px,
    double py,
  ) {
    final dx = x2 - x1;
    final dy = y2 - y1;
    if (dx == 0 && dy == 0) {
      return math.sqrt((px - x1) * (px - x1) + (py - y1) * (py - y1));
    }

    final t = ((px - x1) * dx + (py - y1) * dy) / (dx * dx + dy * dy);
    final clamped = t.clamp(0.0, 1.0);
    final closestX = x1 + clamped * dx;
    final closestY = y1 + clamped * dy;
    return math.sqrt(
      (px - closestX) * (px - closestX) + (py - closestY) * (py - closestY),
    );
  }

  double _distanceToQuadraticBezier(
    double x0,
    double y0,
    double cx,
    double cy,
    double x1,
    double y1,
    double px,
    double py,
  ) {
    var minDistance = double.infinity;
    for (var i = 0; i <= 20; i++) {
      final t = i / 20;
      final bx = (1 - t) * (1 - t) * x0 + 2 * (1 - t) * t * cx + t * t * x1;
      final by = (1 - t) * (1 - t) * y0 + 2 * (1 - t) * t * cy + t * t * y1;
      final distance = math.sqrt((px - bx) * (px - bx) + (py - by) * (py - by));
      if (distance < minDistance) minDistance = distance;
    }
    return minDistance;
  }

  void _pushHistory() {
    _undoStack.add(_currentSnapshot());
    if (_undoStack.length > maxBoardHistoryDepth) {
      _undoStack.removeAt(0);
    }
    _redoStack.clear();
    _syncHistoryFlags();
  }

  BoardSnapshot _currentSnapshot() {
    return BoardSnapshot.fromState(
      players: state.players,
      selectedFormation: state.selectedFormation,
      arrows: state.arrows,
      zones: state.zones,
      highlights: state.highlights,
      textAnnotations: state.textAnnotations,
    );
  }

  void _applySnapshot(BoardSnapshot snapshot) {
    state = state.copyWith(
      players: snapshot.players.map((player) => player.copyWith()).toList(),
      selectedFormation: snapshot.selectedFormation,
      arrows: snapshot.arrows.map((arrow) => arrow.copyWith()).toList(),
      zones: snapshot.zones.map((zone) => zone.copyWith()).toList(),
      highlights:
          snapshot.highlights.map((circle) => circle.copyWith()).toList(),
      textAnnotations: snapshot.textAnnotations
          .map((note) => note.copyWith())
          .toList(),
      clearSelection: true,
      clearDraftDrawing: true,
      skipNextAnimation: true,
    );
  }

  void _syncHistoryFlags() {
    state = state.copyWith(
      canUndo: _undoStack.isNotEmpty,
      canRedo: _redoStack.isNotEmpty,
    );
  }

  void _clearHistoryStacks() {
    _undoStack.clear();
    _redoStack.clear();
    _syncHistoryFlags();
  }

  List<Player> _buildPlayersForFormation(FormationType type) {
    final slots = formationSlotsFor(type);
    final homePlayers = slots.map((slot) {
      return Player(
        id: _uuid.v4(),
        number: slot.number,
        x: slot.x,
        y: slot.y,
        label: slot.label,
        isHomeTeam: true,
      );
    }).toList();

    final awayPlayers = slots.map((slot) {
      return Player(
        id: _uuid.v4(),
        number: slot.number,
        x: slot.x,
        y: 1 - slot.y,
        label: slot.label,
        isHomeTeam: false,
      );
    }).toList();

    return [...homePlayers, ...awayPlayers];
  }

  TacticBoardTemplate toTemplate({
    required String name,
    String? description,
    String? id,
  }) {
    return TacticBoardTemplate(
      id: id ?? _uuid.v4(),
      name: name,
      description: description,
      updatedAt: DateTime.now(),
      formation: state.selectedFormation,
      orientation: state.orientation,
      pitchStyle: state.pitchStyle,
      players: state.players.map((player) => player.copyWith()).toList(),
      arrows: state.arrows.map((arrow) => arrow.copyWith()).toList(),
      zones: state.zones.map((zone) => zone.copyWith()).toList(),
      highlights: state.highlights.map((circle) => circle.copyWith()).toList(),
      textAnnotations:
          state.textAnnotations.map((note) => note.copyWith()).toList(),
    );
  }

  void loadTemplate(TacticBoardTemplate template, {bool recordHistory = false}) {
    if (recordHistory) _pushHistory();

    _clearHistoryStacks();
    state = TacticalBoardState(
      selectedFormation: template.formation,
      players: template.players.map((player) => player.copyWith()).toList(),
      arrows: template.arrows.map((arrow) => arrow.copyWith()).toList(),
      zones: template.zones.map((zone) => zone.copyWith()).toList(),
      highlights:
          template.highlights.map((circle) => circle.copyWith()).toList(),
      textAnnotations:
          template.textAnnotations.map((note) => note.copyWith()).toList(),
      orientation: template.orientation,
      pitchStyle: template.pitchStyle,
      activeTool: BoardTool.select,
    );
  }

  void loadAnalysisSnapshot(List<Player> players) {
    _clearHistoryStacks();
    state = TacticalBoardState(
      players: players.map((player) => player.copyWith()).toList(),
      orientation: PitchOrientation.vertical,
      pitchStyle: PitchStyle.striped,
      activeTool: BoardTool.select,
      skipNextAnimation: true,
    );
  }

  void applyRemotePlayerMove({
    required String playerId,
    required double x,
    required double y,
  }) {
    final exists = state.players.any((player) => player.id == playerId);
    if (!exists) return;

    final players = state.players.map((item) {
      if (item.id != playerId) return item;
      if (item.locked) return item;
      return item.copyWith(x: x, y: y);
    }).toList(growable: false);

    state = state.copyWith(
      players: players,
      skipNextAnimation: true,
    );
  }

  void applyRemoteFormation({
    required FormationType formation,
    required List<Player> players,
  }) {
    state = state.copyWith(
      selectedFormation: formation,
      players: players.map((player) => player.copyWith()).toList(),
      clearSelection: true,
      skipNextAnimation: false,
    );
  }

  void applyRemoteAnnotation({
    required CollaborationAnnotationKind kind,
    required Map<String, dynamic> data,
  }) {
    switch (kind) {
      case CollaborationAnnotationKind.arrow:
        final arrow = Arrow.fromJson(data);
        if (state.arrows.any((item) => item.id == arrow.id)) return;
        state = state.copyWith(arrows: [...state.arrows, arrow]);
      case CollaborationAnnotationKind.zone:
        final zone = Zone.fromJson(data);
        if (state.zones.any((item) => item.id == zone.id)) return;
        state = state.copyWith(zones: [...state.zones, zone]);
      case CollaborationAnnotationKind.highlight:
        final circle = HighlightCircle.fromJson(data);
        if (state.highlights.any((item) => item.id == circle.id)) return;
        state = state.copyWith(highlights: [...state.highlights, circle]);
      case CollaborationAnnotationKind.text:
        final note = TextAnnotation.fromJson(data);
        if (state.textAnnotations.any((item) => item.id == note.id)) return;
        state = state.copyWith(
          textAnnotations: [...state.textAnnotations, note],
        );
    }
  }
}

final tacticalBoardProvider =
    StateNotifierProvider<TacticalBoardNotifier, TacticalBoardState>(
  (ref) => TacticalBoardNotifier(),
);
