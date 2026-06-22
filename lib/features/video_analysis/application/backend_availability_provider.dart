import 'package:captain/features/video_analysis/application/video_analysis_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum BackendAvailability {
  checking,
  available,
  unavailable,
}

final backendAvailabilityProvider =
    AutoDisposeAsyncNotifierProvider<BackendAvailabilityNotifier, BackendAvailability>(
  BackendAvailabilityNotifier.new,
);

class BackendAvailabilityNotifier
    extends AutoDisposeAsyncNotifier<BackendAvailability> {
  @override
  Future<BackendAvailability> build() async {
    final repository = ref.watch(videoAnalysisRepositoryProvider);
    final result = await repository.checkBackendHealth();
    if (result.isFailure || result.valueOrNull != true) {
      return BackendAvailability.unavailable;
    }
    return BackendAvailability.available;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    ref.invalidateSelf();
  }
}
