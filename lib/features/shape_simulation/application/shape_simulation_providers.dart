import 'package:captain/features/shape_simulation/application/shape_simulation_controller.dart';
import 'package:captain/features/shape_simulation/application/shape_simulation_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final shapeSimulationControllerProvider =
    Provider<ShapeSimulationController>((ref) {
  return const ShapeSimulationController();
});

final shapeSimulationProvider =
    StateNotifierProvider<ShapeSimulationNotifier, ShapeSimulationState>(
  (ref) {
    return ShapeSimulationNotifier(
      ref.watch(shapeSimulationControllerProvider),
    );
  },
);
