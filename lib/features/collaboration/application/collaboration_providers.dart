import 'package:captain/features/collaboration/application/collaboration_notifier.dart';
import 'package:captain/features/collaboration/application/session_manager.dart';
import 'package:captain/features/collaboration/data/collaboration_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final collaborationServiceProvider = Provider<CollaborationService>((ref) {
  final service = CollaborationService();
  ref.onDispose(service.unsubscribe);
  return service;
});

final sessionManagerProvider = Provider<SessionManager>((ref) {
  return const SessionManager();
});

final collaborationProvider =
    StateNotifierProvider<CollaborationNotifier, CollaborationState>(
  (ref) {
    return CollaborationNotifier(
      ref.watch(collaborationServiceProvider),
      ref.watch(sessionManagerProvider),
      ref,
    );
  },
);
