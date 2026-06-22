import 'dart:async';

import 'package:captain/features/formations/domain/tactic_board_template.dart';
import 'package:captain/features/tactical_board/application/tactical_board_notifier.dart';
import 'package:captain/features/timeline/data/timeline_repository.dart';
import 'package:captain/features/timeline/data/timeline_snapshot_store.dart';
import 'package:captain/features/timeline/domain/match_timeline.dart';
import 'package:captain/features/timeline/domain/timeline_event.dart';
import 'package:captain/features/timeline/domain/timeline_event_type.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();
const timelinePlaybackSpeeds = [0.5, 1.0, 2.0, 4.0];

class TimelineState {
  const TimelineState({
    required this.timeline,
    this.currentMinute = 0,
    this.isPlaying = false,
    this.playbackSpeed = 1,
    this.highlightedEventId,
    this.triggeredEventIds = const {},
    this.activeSnapshot,
    this.isLoading = false,
  });

  final MatchTimeline timeline;
  final double currentMinute;
  final bool isPlaying;
  final double playbackSpeed;
  final String? highlightedEventId;
  final Set<String> triggeredEventIds;
  final TacticBoardTemplate? activeSnapshot;
  final bool isLoading;

  int get maxMinute => timeline.maxMinute;

  TimelineState copyWith({
    MatchTimeline? timeline,
    double? currentMinute,
    bool? isPlaying,
    double? playbackSpeed,
    String? highlightedEventId,
    bool clearHighlight = false,
    Set<String>? triggeredEventIds,
    TacticBoardTemplate? activeSnapshot,
    bool clearSnapshot = false,
    bool? isLoading,
  }) {
    return TimelineState(
      timeline: timeline ?? this.timeline,
      currentMinute: currentMinute ?? this.currentMinute,
      isPlaying: isPlaying ?? this.isPlaying,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      highlightedEventId: clearHighlight
          ? null
          : (highlightedEventId ?? this.highlightedEventId),
      triggeredEventIds: triggeredEventIds ?? this.triggeredEventIds,
      activeSnapshot:
          clearSnapshot ? null : (activeSnapshot ?? this.activeSnapshot),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class TimelineController extends StateNotifier<TimelineState> {
  TimelineController({
    required String matchId,
  })  : _matchId = matchId,
        super(
          TimelineState(
            timeline: MatchTimeline(
              id: _uuid.v4(),
              matchId: matchId,
            ),
          ),
        ) {
    _init();
  }

  TimelineRepository? _repository;
  TimelineSnapshotStore? _snapshotStore;
  final String _matchId;
  Timer? _playbackTimer;
  DateTime? _lastTick;

  Future<void> _init() async {
    _repository = await TimelineRepository.create();
    _snapshotStore = await TimelineSnapshotStore.create();
    await _load();
  }
  Future<void> _load() async {
    final repository = _repository;
    if (repository == null) return;
    state = state.copyWith(isLoading: true);
    final saved = await repository.loadTimeline(_matchId);
    state = state.copyWith(
      timeline: saved ??
          MatchTimeline(
            id: _uuid.v4(),
            matchId: _matchId,
          ),
      isLoading: false,
    );
    await _refreshActiveSnapshot();
  }

  Future<void> _persist() async {
    await _repository?.saveTimeline(state.timeline);
  }

  void play() {
    if (state.isPlaying) return;
    _lastTick = DateTime.now();
    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      _tickPlayback();
    });
    state = state.copyWith(isPlaying: true);
  }

  void pause() {
    _playbackTimer?.cancel();
    _playbackTimer = null;
    _lastTick = null;
    state = state.copyWith(isPlaying: false);
  }

  void togglePlayPause() {
    if (state.isPlaying) {
      pause();
    } else {
      play();
    }
  }

  void setPlaybackSpeed(double speed) {
    if (!timelinePlaybackSpeeds.contains(speed)) return;
    state = state.copyWith(playbackSpeed: speed);
  }

  void cyclePlaybackSpeed() {
    final index = timelinePlaybackSpeeds.indexOf(state.playbackSpeed);
    final next = timelinePlaybackSpeeds[(index + 1) % timelinePlaybackSpeeds.length];
    setPlaybackSpeed(next);
  }

  Future<void> seek(double minute) async {
    final clamped = minute.clamp(0.0, state.maxMinute.toDouble());
    state = state.copyWith(
      currentMinute: clamped,
      clearHighlight: true,
      triggeredEventIds: state.timeline.events
          .where((event) => event.timeInMinutes <= clamped)
          .map((event) => event.id)
          .toSet(),
    );
    await _refreshActiveSnapshot();
  }

  Future<void> addEvent({
    required int minute,
    required int second,
    required TimelineEventType type,
    required String description,
    String? playerName,
    String? teamId,
    TacticBoardTemplate? linkedSnapshot,
  }) async {
    final snapshotId = linkedSnapshot?.id;
    if (linkedSnapshot != null && snapshotId != null) {
      await _snapshotStore?.saveSnapshot(
        snapshotId: snapshotId,
        template: linkedSnapshot,
      );
    }

    final event = TimelineEvent(
      id: _uuid.v4(),
      minute: minute,
      second: second,
      type: type,
      description: description,
      playerName: playerName,
      teamId: teamId,
      linkedTacticalBoardId: snapshotId,
    );

    final events = [...state.timeline.events, event]
      ..sort(
        (a, b) => a.timeInMinutes.compareTo(b.timeInMinutes),
      );

    state = state.copyWith(
      timeline: state.timeline.copyWith(events: events),
    );
    await _persist();
  }

  Future<TacticBoardTemplate?> loadLinkedBoard(String snapshotId) {
    return _snapshotStore?.loadSnapshot(snapshotId) ?? Future.value(null);
  }

  Future<void> _refreshActiveSnapshot() async {
    TimelineEvent? candidate;
    for (final event in state.timeline.events) {
      if (event.linkedTacticalBoardId == null) continue;
      if (event.timeInMinutes <= state.currentMinute + 0.01) {
        candidate = event;
      }
    }

    if (candidate?.linkedTacticalBoardId == null) {
      state = state.copyWith(clearSnapshot: true);
      return;
    }

    final snapshot =
        await _snapshotStore?.loadSnapshot(candidate!.linkedTacticalBoardId!);
    state = state.copyWith(activeSnapshot: snapshot);
  }

  void _tickPlayback() {
    final lastTick = _lastTick;
    if (lastTick == null) return;

    final elapsedSeconds = DateTime.now().difference(lastTick).inMilliseconds / 1000;
    _lastTick = DateTime.now();

    final nextMinute =
        state.currentMinute + (elapsedSeconds / 60) * state.playbackSpeed * 60;
    if (nextMinute >= state.maxMinute) {
      seek(state.maxMinute.toDouble());
      pause();
      return;
    }

    state = state.copyWith(currentMinute: nextMinute);
    _checkEventCrossings();
    unawaited(_refreshActiveSnapshot());
  }

  void _checkEventCrossings() {
    final crossed = state.timeline.events.where((event) {
      if (state.triggeredEventIds.contains(event.id)) return false;
      return event.timeInMinutes <= state.currentMinute;
    }).toList();

    if (crossed.isEmpty) return;

    HapticFeedback.lightImpact();
    state = state.copyWith(
      highlightedEventId: crossed.last.id,
      triggeredEventIds: {
        ...state.triggeredEventIds,
        ...crossed.map((event) => event.id),
      },
    );
  }

  TacticBoardTemplate? buildBoardSnapshotFrom(TacticalBoardState boardState) {
    return TacticBoardTemplate(
      id: _uuid.v4(),
      name: 'Timeline ${state.currentMinute.toStringAsFixed(0)}\'',
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

  @override
  void dispose() {
    _playbackTimer?.cancel();
    super.dispose();
  }
}
