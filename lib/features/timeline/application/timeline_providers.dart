import 'package:captain/features/timeline/application/timeline_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const defaultMatchId = 'local-match';

final timelineControllerProvider =
    StateNotifierProvider.family<TimelineController, TimelineState, String>(
  (ref, matchId) => TimelineController(matchId: matchId),
);
