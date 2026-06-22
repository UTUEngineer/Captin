import 'dart:async';
import 'dart:ui';

import 'package:captain/core/config/app_config.dart';
import 'package:captain/features/collaboration/application/session_manager.dart';
import 'package:captain/features/collaboration/data/collaboration_event_queue.dart';
import 'package:captain/features/collaboration/data/collaboration_service.dart';
import 'package:captain/features/collaboration/domain/collaboration_event.dart';
import 'package:captain/features/collaboration/domain/collaboration_session.dart';
import 'package:captain/features/collaboration/domain/collaborator.dart';
import 'package:captain/features/tactical_board/application/tactical_board_notifier.dart';
import 'package:captain/features/tactical_board/domain/formation.dart';
import 'package:captain/features/tactical_board/domain/player.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();
const _cursorBroadcastInterval = Duration(milliseconds: 33);

class RemoteCursor {
  const RemoteCursor({
    required this.collaboratorId,
    required this.name,
    required this.color,
    required this.target,
    required this.displayed,
  });

  final String collaboratorId;
  final String name;
  final Color color;
  final Offset target;
  final Offset displayed;

  RemoteCursor copyWith({
    Offset? target,
    Offset? displayed,
  }) {
    return RemoteCursor(
      collaboratorId: collaboratorId,
      name: name,
      color: color,
      target: target ?? this.target,
      displayed: displayed ?? this.displayed,
    );
  }
}

class CollaborationState {
  const CollaborationState({
    this.isConfigured = false,
    this.isConnected = false,
    this.currentSession,
    this.localCollaboratorId,
    this.localCollaboratorName,
    this.localRole = CollaboratorRole.editor,
    this.collaborators = const [],
    this.remoteCursors = const {},
    this.latencyMs,
    this.errorMessage,
  });

  final bool isConfigured;
  final bool isConnected;
  final CollaborationSession? currentSession;
  final String? localCollaboratorId;
  final String? localCollaboratorName;
  final CollaboratorRole localRole;
  final List<Collaborator> collaborators;
  final Map<String, RemoteCursor> remoteCursors;
  final int? latencyMs;
  final String? errorMessage;

  bool get isInSession => currentSession != null;

  bool get isHost => localRole == CollaboratorRole.host;

  bool get canEditBoard {
    if (!isInSession) return true;
    if (isHost) return true;
    if (currentSession?.viewersOnly ?? false) {
      return false;
    }
    return localRole == CollaboratorRole.editor;
  }

  CollaborationState copyWith({
    bool? isConfigured,
    bool? isConnected,
    CollaborationSession? currentSession,
    bool clearSession = false,
    String? localCollaboratorId,
    String? localCollaboratorName,
    CollaboratorRole? localRole,
    List<Collaborator>? collaborators,
    Map<String, RemoteCursor>? remoteCursors,
    int? latencyMs,
    bool clearLatency = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CollaborationState(
      isConfigured: isConfigured ?? this.isConfigured,
      isConnected: isConnected ?? this.isConnected,
      currentSession:
          clearSession ? null : (currentSession ?? this.currentSession),
      localCollaboratorId: localCollaboratorId ?? this.localCollaboratorId,
      localCollaboratorName:
          localCollaboratorName ?? this.localCollaboratorName,
      localRole: localRole ?? this.localRole,
      collaborators: collaborators ?? this.collaborators,
      remoteCursors: remoteCursors ?? this.remoteCursors,
      latencyMs: clearLatency ? null : (latencyMs ?? this.latencyMs),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class CollaborationNotifier extends StateNotifier<CollaborationState> {
  CollaborationNotifier(
    this._service,
    this._sessionManager,
    this._ref,
  ) : super(
          CollaborationState(
            isConfigured: AppConfig.isSupabaseConfigured,
          ),
        );

  final CollaborationService _service;
  final SessionManager _sessionManager;
  final Ref _ref;
  CollaborationEventQueue? _eventQueue;
  Timer? _cursorTimer;
  Timer? _cursorAnimationTimer;
  Offset? _pendingCursor;
  int? _lastPingSentMs;

  Future<void> createSession({required String hostName}) async {
    if (!state.isConfigured) {
      state = state.copyWith(
        errorMessage: 'Supabase is not configured. Add credentials to .env.',
      );
      return;
    }

    final localId = _uuid.v4();
    final session = _sessionManager.createSession(hostId: localId);
    final localCollaborator = Collaborator(
      id: localId,
      name: hostName.trim().isEmpty ? 'Host' : hostName.trim(),
      color: colorForCollaboratorId(localId),
      role: CollaboratorRole.host,
    );

    await _connect(
      session: session,
      localCollaborator: localCollaborator,
      role: CollaboratorRole.host,
    );

    await _broadcast(
      CollaborationEvent(
        type: CollaborationEventType.collaboratorJoined,
        senderId: localId,
        timestamp: _nowMs(),
        payload: localCollaborator.toJson(),
      ),
    );
  }

  Future<void> joinSession({
    required String code,
    required String displayName,
  }) async {
    if (!state.isConfigured) {
      state = state.copyWith(
        errorMessage: 'Supabase is not configured. Add credentials to .env.',
      );
      return;
    }

    if (!_sessionManager.validateJoinCode(code)) {
      state = state.copyWith(errorMessage: 'Invalid session code format.');
      return;
    }

    final localId = _uuid.v4();
    final session = _sessionManager.sessionFromCode(
      code: code,
      hostId: localId,
    );
    final localCollaborator = Collaborator(
      id: localId,
      name: displayName.trim().isEmpty ? 'Coach' : displayName.trim(),
      color: colorForCollaboratorId(localId),
      role: CollaboratorRole.editor,
    );

    await _connect(
      session: session,
      localCollaborator: localCollaborator,
      role: CollaboratorRole.editor,
    );

    await _broadcast(
      CollaborationEvent(
        type: CollaborationEventType.collaboratorJoined,
        senderId: localId,
        timestamp: _nowMs(),
        payload: localCollaborator.toJson(),
      ),
    );
  }

  Future<void> leaveSession() async {
    final localId = state.localCollaboratorId;
    if (localId != null && state.isConnected) {
      await _broadcast(
        CollaborationEvent(
          type: CollaborationEventType.collaboratorLeft,
          senderId: localId,
          timestamp: _nowMs(),
          payload: const {},
        ),
      );
    }

    _stopCursorTimers();
    await _service.unsubscribe();

    state = CollaborationState(isConfigured: AppConfig.isSupabaseConfigured);
  }

  Future<void> setViewersOnly(bool viewersOnly) async {
    if (!state.isHost) return;

    final session = state.currentSession;
    if (session == null) return;

    state = state.copyWith(
      currentSession: session.copyWith(viewersOnly: viewersOnly),
    );

    await _broadcast(
      CollaborationEvent(
        type: CollaborationEventType.viewersOnlyChanged,
        senderId: state.localCollaboratorId!,
        timestamp: _nowMs(),
        payload: {'viewersOnly': viewersOnly},
      ),
    );
  }

  void trackLocalCursor({required double x, required double y}) {
    if (!state.isConnected || !state.canEditBoard) return;
    _pendingCursor = Offset(x, y);
  }

  Future<void> broadcastPlayerMoved({
    required String playerId,
    required double x,
    required double y,
  }) async {
    if (!state.isInSession || !state.canEditBoard) return;

    await _broadcast(
      CollaborationEvent(
        type: CollaborationEventType.playerMoved,
        senderId: state.localCollaboratorId!,
        timestamp: _nowMs(),
        payload: {
          'playerId': playerId,
          'x': x,
          'y': y,
        },
      ),
    );
  }

  Future<void> broadcastPlayerBatch(
    Map<String, ({double x, double y})> positions,
  ) async {
    if (!state.isInSession || !state.canEditBoard) return;

    for (final entry in positions.entries) {
      await broadcastPlayerMoved(
        playerId: entry.key,
        x: entry.value.x,
        y: entry.value.y,
      );
    }
  }

  Future<void> broadcastFormationChanged({
    required FormationType formation,
    required List<Player> players,
  }) async {
    if (!state.isInSession || !state.canEditBoard) return;

    await _broadcast(
      CollaborationEvent(
        type: CollaborationEventType.formationChanged,
        senderId: state.localCollaboratorId!,
        timestamp: _nowMs(),
        payload: {
          'formation': formation.name,
          'players': players.map((player) => player.toJson()).toList(),
        },
      ),
    );
  }

  Future<void> broadcastAnnotationAdded({
    required CollaborationAnnotationKind kind,
    required Map<String, dynamic> data,
  }) async {
    if (!state.isInSession || !state.canEditBoard) return;

    await _broadcast(
      CollaborationEvent(
        type: CollaborationEventType.annotationAdded,
        senderId: state.localCollaboratorId!,
        timestamp: _nowMs(),
        payload: {
          'kind': kind.wireName,
          'data': data,
        },
      ),
    );
  }

  Future<void> _connect({
    required CollaborationSession session,
    required Collaborator localCollaborator,
    required CollaboratorRole role,
  }) async {
    await _service.subscribe(
      sessionId: session.id,
      senderId: localCollaborator.id,
      onEvent: _handleRemoteEvent,
    );

    state = state.copyWith(
      isConnected: true,
      currentSession: session,
      localCollaboratorId: localCollaborator.id,
      localCollaboratorName: localCollaborator.name,
      localRole: role,
      collaborators: [localCollaborator],
      clearError: true,
      clearLatency: true,
    );

    _startCursorTimers();
    await _sendPing();
    await _flushPendingEvents();
  }

  Future<CollaborationEventQueue> _queue() async {
    if (_eventQueue != null) return _eventQueue!;
    _eventQueue = await _ref.read(collaborationEventQueueProvider.future);
    return _eventQueue!;
  }

  Future<void> _flushPendingEvents() async {
    final queue = await _queue();
    final pending = await queue.drain();
    for (final event in pending) {
      await _service.send(event);
    }
  }

  Future<void> _broadcast(CollaborationEvent event) async {
    if (!state.isConnected) {
      if (state.isInSession) {
        final queue = await _queue();
        await queue.enqueue(event);
      }
      return;
    }

    try {
      await _service.send(event);
    } catch (error) {
      if (state.isInSession) {
        final queue = await _queue();
        await queue.enqueue(event);
      }
      state = state.copyWith(errorMessage: error.toString());
    }
  }

  void _handleRemoteEvent(CollaborationEvent event) {
    final receivedAt = _nowMs();
    state = state.copyWith(
      latencyMs: receivedAt - event.timestamp,
    );

    switch (event.type) {
      case CollaborationEventType.playerMoved:
        _applyRemotePlayerMove(event.payload);
      case CollaborationEventType.annotationAdded:
        _applyRemoteAnnotation(event.payload);
      case CollaborationEventType.formationChanged:
        _applyRemoteFormation(event.payload);
      case CollaborationEventType.cursorMoved:
        _applyRemoteCursor(event);
      case CollaborationEventType.collaboratorJoined:
        _upsertCollaborator(event.payload);
      case CollaborationEventType.collaboratorLeft:
        _removeCollaborator(event.senderId);
      case CollaborationEventType.viewersOnlyChanged:
        _applyViewersOnly(event.payload);
      case CollaborationEventType.ping:
        break;
    }
  }

  void _applyRemotePlayerMove(Map<String, dynamic> payload) {
    final playerId = payload['playerId'];
    final x = payload['x'];
    final y = payload['y'];
    if (playerId is! String || x is! num || y is! num) return;

    _ref.read(tacticalBoardProvider.notifier).applyRemotePlayerMove(
          playerId: playerId,
          x: x.toDouble(),
          y: y.toDouble(),
        );
  }

  void _applyRemoteFormation(Map<String, dynamic> payload) {
    final formationName = payload['formation'];
    final playersRaw = payload['players'];
    if (formationName is! String || playersRaw is! List) return;

    final formation = FormationType.values.firstWhere(
      (type) => type.name == formationName,
      orElse: () => FormationType.f433,
    );
    final players = playersRaw
        .whereType<Map>()
        .map((item) => Player.fromJson(Map<String, dynamic>.from(item)))
        .toList();

    _ref.read(tacticalBoardProvider.notifier).applyRemoteFormation(
          formation: formation,
          players: players,
        );
  }

  void _applyRemoteAnnotation(Map<String, dynamic> payload) {
    final kindName = payload['kind'];
    final data = payload['data'];
    if (kindName is! String || data is! Map) return;

    final kind = annotationKindFromWire(kindName);
    if (kind == null) return;

    _ref.read(tacticalBoardProvider.notifier).applyRemoteAnnotation(
          kind: kind,
          data: Map<String, dynamic>.from(data),
        );
  }

  void _applyRemoteCursor(CollaborationEvent event) {
    final x = event.payload['x'];
    final y = event.payload['y'];
    final name = event.payload['name'];
    if (x is! num || y is! num) return;

    final collaborator = state.collaborators.firstWhere(
      (item) => item.id == event.senderId,
      orElse: () => Collaborator(
        id: event.senderId,
        name: name is String ? name : 'Coach',
        color: colorForCollaboratorId(event.senderId),
      ),
    );

    final target = Offset(x.toDouble(), y.toDouble());
    final existing = state.remoteCursors[event.senderId];
    final cursor = RemoteCursor(
      collaboratorId: event.senderId,
      name: collaborator.name,
      color: collaborator.color,
      target: target,
      displayed: existing?.displayed ?? target,
    );

    state = state.copyWith(
      remoteCursors: {
        ...state.remoteCursors,
        event.senderId: cursor,
      },
    );
  }

  void _upsertCollaborator(Map<String, dynamic> payload) {
    final collaborator = Collaborator.fromJson(payload);
    final others = state.collaborators
        .where((item) => item.id != collaborator.id)
        .toList();
    state = state.copyWith(collaborators: [...others, collaborator]);
  }

  void _removeCollaborator(String collaboratorId) {
    final collaborators = state.collaborators
        .where((item) => item.id != collaboratorId)
        .toList();
    final cursors = Map<String, RemoteCursor>.from(state.remoteCursors)
      ..remove(collaboratorId);

    state = state.copyWith(
      collaborators: collaborators,
      remoteCursors: cursors,
    );
  }

  void _applyViewersOnly(Map<String, dynamic> payload) {
    final viewersOnly = payload['viewersOnly'];
    if (viewersOnly is! bool) return;

    final session = state.currentSession;
    if (session == null) return;

    state = state.copyWith(
      currentSession: session.copyWith(viewersOnly: viewersOnly),
    );
  }

  void _startCursorTimers() {
    _cursorTimer ??= Timer.periodic(_cursorBroadcastInterval, (_) {
      _flushCursorBroadcast();
    });

    _cursorAnimationTimer ??=
        Timer.periodic(const Duration(milliseconds: 16), (_) {
      _tickCursorAnimation();
    });
  }

  void _stopCursorTimers() {
    _cursorTimer?.cancel();
    _cursorTimer = null;
    _cursorAnimationTimer?.cancel();
    _cursorAnimationTimer = null;
    _pendingCursor = null;
  }

  Future<void> _flushCursorBroadcast() async {
    final cursor = _pendingCursor;
    final senderId = state.localCollaboratorId;
    if (cursor == null || senderId == null || !state.isConnected) return;

    await _broadcast(
      CollaborationEvent(
        type: CollaborationEventType.cursorMoved,
        senderId: senderId,
        timestamp: _nowMs(),
        payload: {
          'x': cursor.dx,
          'y': cursor.dy,
          'name': state.localCollaboratorName,
        },
      ),
    );
  }

  void _tickCursorAnimation() {
    if (state.remoteCursors.isEmpty) return;

    const stepMs = 16.0;
    const durationMs = 100.0;
    final t = stepMs / durationMs;

    final updated = <String, RemoteCursor>{};
    var changed = false;

    for (final entry in state.remoteCursors.entries) {
      final cursor = entry.value;
      if ((cursor.displayed - cursor.target).distance < 0.001) {
        updated[entry.key] = cursor;
        continue;
      }

      changed = true;
      updated[entry.key] = cursor.copyWith(
        displayed: Offset(
          cursor.displayed.dx + (cursor.target.dx - cursor.displayed.dx) * t,
          cursor.displayed.dy + (cursor.target.dy - cursor.displayed.dy) * t,
        ),
      );
    }

    if (changed) {
      state = state.copyWith(remoteCursors: updated);
    }
  }

  Future<void> _sendPing() async {
    final senderId = state.localCollaboratorId;
    if (senderId == null) return;
    _lastPingSentMs = _nowMs();
    await _broadcast(
      CollaborationEvent(
        type: CollaborationEventType.ping,
        senderId: senderId,
        timestamp: _lastPingSentMs!,
        payload: const {},
      ),
    );
  }

  int _nowMs() => DateTime.now().millisecondsSinceEpoch;

  @override
  void dispose() {
    _stopCursorTimers();
    _service.unsubscribe();
    super.dispose();
  }
}
