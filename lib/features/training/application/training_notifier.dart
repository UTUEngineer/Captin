import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/formations/domain/tactic_board_template.dart';
import 'package:captain/features/training/domain/drill_path.dart';
import 'package:captain/features/training/domain/drill_path_style.dart';
import 'package:captain/features/training/domain/drill_template.dart';
import 'package:captain/features/training/domain/path_control_point.dart';
import 'package:captain/features/training/domain/training_prop.dart';
import 'package:captain/features/training/domain/training_prop_type.dart';
import 'package:captain/features/tactical_board/application/tactical_board_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();
const trainingPropColorPalette = <int>[
  0xFFFF7043,
  0xFFFFFFFF,
  0xFFFFEE58,
  0xFF42A5F5,
  0xFF66BB6A,
  0xFFAB47BC,
  0xFFE53935,
];

class TrainingState {
  const TrainingState({
    this.isTrainingMode = false,
    this.props = const [],
    this.paths = const [],
    this.pendingPropType,
    this.pathToolActive = false,
    this.selectedPathStyle = DrillPathStyle.run,
    this.selectedPropId,
    this.notes = '',
    this.sessionName = 'Training Session',
  });

  final bool isTrainingMode;
  final List<TrainingProp> props;
  final List<DrillPath> paths;
  final TrainingPropType? pendingPropType;
  final bool pathToolActive;
  final DrillPathStyle selectedPathStyle;
  final String? selectedPropId;
  final String notes;
  final String sessionName;

  TrainingState copyWith({
    bool? isTrainingMode,
    List<TrainingProp>? props,
    List<DrillPath>? paths,
    TrainingPropType? pendingPropType,
    bool clearPendingPropType = false,
    bool? pathToolActive,
    DrillPathStyle? selectedPathStyle,
    String? selectedPropId,
    bool clearSelectedProp = false,
    String? notes,
    String? sessionName,
  }) {
    return TrainingState(
      isTrainingMode: isTrainingMode ?? this.isTrainingMode,
      props: props ?? this.props,
      paths: paths ?? this.paths,
      pendingPropType: clearPendingPropType
          ? null
          : (pendingPropType ?? this.pendingPropType),
      pathToolActive: pathToolActive ?? this.pathToolActive,
      selectedPathStyle: selectedPathStyle ?? this.selectedPathStyle,
      selectedPropId:
          clearSelectedProp ? null : (selectedPropId ?? this.selectedPropId),
      notes: notes ?? this.notes,
      sessionName: sessionName ?? this.sessionName,
    );
  }
}

class TrainingNotifier extends StateNotifier<TrainingState> {
  TrainingNotifier() : super(const TrainingState());

  void setTrainingMode(bool enabled) {
    state = state.copyWith(
      isTrainingMode: enabled,
      clearPendingPropType: true,
      pathToolActive: false,
      clearSelectedProp: true,
    );
  }

  void toggleTrainingMode() => setTrainingMode(!state.isTrainingMode);

  void selectPropType(TrainingPropType? type) {
    state = state.copyWith(
      pendingPropType: type,
      pathToolActive: false,
      clearSelectedProp: true,
    );
  }

  void togglePathTool() {
    state = state.copyWith(
      pathToolActive: !state.pathToolActive,
      clearPendingPropType: true,
      clearSelectedProp: true,
    );
  }

  void setPathStyle(DrillPathStyle style) {
    state = state.copyWith(selectedPathStyle: style);
  }

  void placeProp({required double x, required double y}) {
    final type = state.pendingPropType;
    if (type == null || state.pathToolActive) return;

    final prop = TrainingProp(
      id: _uuid.v4(),
      type: type,
      x: x.clamp(0.05, 0.95),
      y: y.clamp(0.05, 0.95),
      colorValue: type.defaultColor.toARGB32(),
    );

    state = state.copyWith(
      props: [...state.props, prop],
      selectedPropId: prop.id,
    );
  }

  void addPath({
    required double startX,
    required double startY,
    required double endX,
    required double endY,
  }) {
    if (!state.pathToolActive) return;

    final dx = endX - startX;
    final dy = endY - startY;
    if (dx.abs() < 0.02 && dy.abs() < 0.02) return;

    final control = PathControlPoint(
      x: (startX + endX) / 2,
      y: (startY + endY) / 2 - 0.08,
    );

    final path = DrillPath(
      id: _uuid.v4(),
      startX: startX,
      startY: startY,
      endX: endX,
      endY: endY,
      controlPoints: [control],
      style: state.selectedPathStyle,
      colorValue: AppColors.pitchGreenLight.toARGB32(),
    );

    state = state.copyWith(paths: [...state.paths, path]);
  }

  void selectProp(String? id) {
    state = state.copyWith(
      selectedPropId: id,
      clearSelectedProp: id == null,
    );
  }

  void moveProp({required String propId, required double x, required double y}) {
    state = state.copyWith(
      props: state.props
          .map(
            (prop) => prop.id == propId
                ? prop.copyWith(
                    x: x.clamp(0.05, 0.95),
                    y: y.clamp(0.05, 0.95),
                  )
                : prop,
          )
          .toList(growable: false),
    );
  }

  void deleteProp(String propId) {
    state = state.copyWith(
      props: state.props.where((prop) => prop.id != propId).toList(),
      clearSelectedProp: state.selectedPropId == propId,
    );
  }

  void rotateProp(String propId) {
    state = state.copyWith(
      props: state.props
          .map(
            (prop) => prop.id == propId
                ? prop.copyWith(rotation: (prop.rotation + 45) % 360)
                : prop,
          )
          .toList(growable: false),
    );
  }

  void duplicateProp(String propId) {
    final source = state.props.where((prop) => prop.id == propId).firstOrNull;
    if (source == null) return;

    final copy = source.copyWith(
      id: _uuid.v4(),
      x: (source.x + 0.03).clamp(0.05, 0.95),
      y: (source.y + 0.03).clamp(0.05, 0.95),
    );

    state = state.copyWith(
      props: [...state.props, copy],
      selectedPropId: copy.id,
    );
  }

  void cyclePropColor(String propId) {
    state = state.copyWith(
      props: state.props.map((prop) {
        if (prop.id != propId) return prop;
        final current = prop.colorValue ?? prop.type.defaultColor.toARGB32();
        final index = trainingPropColorPalette.indexOf(current);
        final next = trainingPropColorPalette[
            (index + 1) % trainingPropColorPalette.length];
        return prop.copyWith(colorValue: next);
      }).toList(growable: false),
    );
  }

  void deletePath(String pathId) {
    state = state.copyWith(
      paths: state.paths.where((path) => path.id != pathId).toList(),
    );
  }

  void loadTemplate(DrillTemplate template) {
    state = state.copyWith(
      isTrainingMode: true,
      props: template.props.map((prop) => prop.copyWith()).toList(),
      paths: template.paths.map((path) => path.copyWith()).toList(),
      sessionName: template.name,
      clearPendingPropType: true,
      pathToolActive: false,
      clearSelectedProp: true,
    );
  }

  void loadSessionPropsAndPaths({
    required List<TrainingProp> props,
    required List<DrillPath> paths,
    required String name,
    String notes = '',
  }) {
    state = state.copyWith(
      isTrainingMode: true,
      props: props.map((prop) => prop.copyWith()).toList(),
      paths: paths.map((path) => path.copyWith()).toList(),
      sessionName: name,
      notes: notes,
      clearPendingPropType: true,
      pathToolActive: false,
      clearSelectedProp: true,
    );
  }

  void clearTrainingOverlay() {
    state = state.copyWith(
      props: const [],
      paths: const [],
      clearPendingPropType: true,
      pathToolActive: false,
      clearSelectedProp: true,
    );
  }

  TacticBoardTemplate? buildBoardTemplateFrom(TacticalBoardState boardState) {
    return TacticBoardTemplate(
      id: _uuid.v4(),
      name: state.sessionName,
      description: state.notes,
      updatedAt: DateTime.now(),
      formation: boardState.selectedFormation,
      orientation: boardState.orientation,
      pitchStyle: boardState.pitchStyle,
      players: boardState.players.map((player) => player.copyWith()).toList(),
      arrows: boardState.arrows.map((arrow) => arrow.copyWith()).toList(),
      zones: boardState.zones.map((zone) => zone.copyWith()).toList(),
      highlights:
          boardState.highlights.map((circle) => circle.copyWith()).toList(),
      textAnnotations: boardState.textAnnotations
          .map((note) => note.copyWith())
          .toList(),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return null;
    return iterator.current;
  }
}
