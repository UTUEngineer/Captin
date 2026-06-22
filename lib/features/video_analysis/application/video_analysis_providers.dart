import 'package:captain/core/network/api_client.dart';
import 'package:captain/features/settings/application/app_preferences_notifier.dart';
import 'package:captain/features/video_analysis/data/remote_video_analysis_repository.dart';
import 'package:captain/features/video_analysis/domain/video_analysis_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiClientProvider = Provider((ref) {
  final prefs = ref.watch(appPreferencesProvider).value;
  return createApiClient(baseUrl: prefs?.effectiveBackendUrl);
});

final videoAnalysisRepositoryProvider = Provider<VideoAnalysisRepository>(
  (ref) => RemoteVideoAnalysisRepository(ref.watch(apiClientProvider)),
);
