import 'package:captain/features/training/application/training_notifier.dart';
import 'package:captain/features/training/data/training_session_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final trainingProvider =
    StateNotifierProvider<TrainingNotifier, TrainingState>(
  (ref) => TrainingNotifier(),
);

final trainingSessionRepositoryProvider =
    FutureProvider<TrainingSessionRepository>((ref) {
  return TrainingSessionRepository.create();
});
