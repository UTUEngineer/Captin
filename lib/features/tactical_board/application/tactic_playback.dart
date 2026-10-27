import 'dart:math' as math;

import 'package:captain/features/tactical_board/application/tactical_board_notifier.dart';
import 'package:captain/features/tactical_board/domain/arrow.dart';
import 'package:captain/features/tactical_board/domain/board_ball.dart';
import 'package:captain/features/tactical_board/domain/player.dart';
import 'package:flutter/animation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// How close (relative units) an arrow must start to a player to "belong"
/// to that player during playback.
const playbackAttachRadius = 0.07;

/// One animated movement inside a playback phase.
class PlaybackSegment {
  const PlaybackSegment({
    required this.start,
    required this.control,
    required this.end,
    required this.step,
    this.playerId,
    this.movesBall = false,
    this.delay = 0,
    this.span = 1,
  });

  final Offset start;
  final Offset control;
  final Offset end;
  final int step;

  /// Player moved by this segment (null = ball-only, e.g. a pass).
  final String? playerId;
  final bool movesBall;

  /// Start/length inside the phase, as fractions of the phase duration.
  final double delay;
  final double span;

  Offset pointAt(double t) {
    final u = 1 - t;
    return start * (u * u) + control * (2 * u * t) + end * (t * t);
  }

  Offset tangentAt(double t) {
    return (control - start) * (2 * (1 - t)) + (end - control) * (2 * t);
  }

  /// Local 0..1 progress of this segment at phase-local time [phaseT].
  double localT(double phaseT) {
    if (span <= 0) return phaseT >= delay ? 1 : 0;
    return ((phaseT - delay) / span).clamp(0.0, 1.0);
  }
}

/// A frame of the tactic animation.
class PlaybackFrame {
  const PlaybackFrame({
    required this.players,
    required this.ball,
    required this.step,
    required this.moving,
    required this.headings,
    required this.arrowProgress,
  });

  /// Positions for every player on the board.
  final Map<String, Offset> players;
  final Offset? ball;

  /// Current 1-based phase.
  final int step;

  /// Players currently running (used to switch 3D run/idle animations).
  final Set<String> moving;

  /// Facing angle (radians, relative-pitch space) for moving players.
  final Map<String, double> headings;

  /// 0..1 progress per arrow id (arrows "consumed" as play advances).
  final Map<String, double> arrowProgress;
}

/// Turns the arrows drawn on a board into a phase-by-phase animation.
///
/// * run / curved run / press arrows move the player standing at the arrow
///   start;
/// * pass / shot arrows move the ball (passes start once the passer's runs
///   in the same phase finish if they end at the pass origin);
/// * dribble arrows move the player and the ball together.
class TacticPlayback {
  TacticPlayback._({
    required this.initialPlayers,
    required this.initialBall,
    required this.segments,
    required this.stepCount,
    required this.arrowSegments,
  });

  factory TacticPlayback.fromBoard({
    required List<Player> players,
    required List<Arrow> arrows,
    BoardBall? ball,
  }) {
    final positions = {
      for (final p in players) p.id: Offset(p.x, p.y),
    };
    Offset? ballPos = ball == null ? null : Offset(ball.x, ball.y);
    final initialBall = ballPos;
    final segments = <PlaybackSegment>[];
    final arrowSegments = <String, PlaybackSegment>{};

    final steps = arrows.map((a) => a.step).toSet().toList()..sort();
    var stepIndex = 0;
    for (final step in steps) {
      stepIndex++;
      final stepArrows = arrows.where((a) => a.step == step).toList();
      final endPositions = Map<String, Offset>.from(positions);
      Offset? endBall = ballPos;

      // Player movement first so passes can be timed after them.
      final playerRunEnds = <String, double>{};
      for (final arrow in stepArrows.where((a) => a.type.movesPlayer)) {
        final start = Offset(arrow.startX, arrow.startY);
        final end = Offset(arrow.endX, arrow.endY);
        final playerId = _nearestPlayer(positions, start);
        if (playerId == null) continue;
        final from = positions[playerId]!;
        final control = arrowControlPoint(
          start,
          end,
          arrow.curved ? arrow.bend : 0,
        ) +
            (from - start) * 0.5;
        final isDribble = arrow.type == ArrowType.dribble;
        final segment = PlaybackSegment(
          start: from,
          control: control,
          end: end,
          step: stepIndex,
          playerId: playerId,
          movesBall: isDribble,
        );
        segments.add(segment);
        arrowSegments[arrow.id] = segment;
        endPositions[playerId] = end;
        playerRunEnds[playerId] = 1;
        if (isDribble) endBall = end;
      }

      // Ball movement (passes / shots).
      for (final arrow in stepArrows.where(
        (a) => a.type == ArrowType.pass || a.type == ArrowType.shot,
      )) {
        final start = Offset(arrow.startX, arrow.startY);
        final end = Offset(arrow.endX, arrow.endY);
        final control = arrowControlPoint(
          start,
          end,
          arrow.curved ? arrow.bend : 0,
        );
        // A passer that also runs this phase releases the ball afterwards.
        final passer = _nearestPlayer(endPositions, start);
        final passerRuns = passer != null && playerRunEnds.containsKey(passer) &&
            (endPositions[passer]! - start).distance < playbackAttachRadius &&
            (positions[passer]! - start).distance >= playbackAttachRadius;
        final segment = PlaybackSegment(
          start: start,
          control: control,
          end: end,
          step: stepIndex,
          movesBall: true,
          delay: passerRuns ? 0.55 : 0,
          span: passerRuns ? 0.45 : (arrow.type == ArrowType.shot ? 0.6 : 0.85),
        );
        segments.add(segment);
        arrowSegments[arrow.id] = segment;
        ballPos ??= start;
        endBall = end;
      }

      positions
        ..clear()
        ..addAll(endPositions);
      ballPos = endBall;
    }

    return TacticPlayback._(
      initialPlayers: {
        for (final p in players) p.id: Offset(p.x, p.y),
      },
      initialBall: initialBall ??
          segments
              .where((s) => s.movesBall)
              .map((s) => s.start)
              .cast<Offset?>()
              .firstWhere((_) => true, orElse: () => null),
      segments: segments,
      stepCount: stepIndex,
      arrowSegments: arrowSegments,
    );
  }

  final Map<String, Offset> initialPlayers;
  final Offset? initialBall;
  final List<PlaybackSegment> segments;
  final int stepCount;
  final Map<String, PlaybackSegment> arrowSegments;

  bool get isEmpty => segments.isEmpty;

  /// Total duration in phase units.
  double get duration => stepCount.toDouble();

  static String? _nearestPlayer(Map<String, Offset> positions, Offset point) {
    String? best;
    var bestDistance = playbackAttachRadius;
    positions.forEach((id, pos) {
      final d = (pos - point).distance;
      if (d <= bestDistance) {
        bestDistance = d;
        best = id;
      }
    });
    return best;
  }

  static const Curve _ease = Curves.easeInOutCubic;

  /// Frame at playback time [time] (0..[duration], in phases).
  PlaybackFrame frameAt(double time) {
    final t = time.clamp(0.0, duration);
    final players = Map<String, Offset>.from(initialPlayers);
    Offset? ball = initialBall;
    final moving = <String>{};
    final headings = <String, double>{};
    final currentStep = math.min(stepCount, t.floor() + 1);

    for (final segment in segments) {
      final phaseStart = (segment.step - 1).toDouble();
      final phaseT = (t - phaseStart).clamp(0.0, 1.0);
      if (t < phaseStart) continue;
      final local = segment.localT(phaseT);
      final eased = _ease.transform(local);
      final pos = segment.pointAt(eased);
      if (segment.playerId != null) {
        players[segment.playerId!] = pos;
        if (local > 0 && local < 1) {
          moving.add(segment.playerId!);
          final tangent = segment.tangentAt(eased);
          if (tangent.distance > 0) {
            headings[segment.playerId!] = math.atan2(tangent.dy, tangent.dx);
          }
        }
      }
      if (segment.movesBall && (local > 0 || segment.playerId != null)) {
        ball = segment.playerId != null
            ? pos + const Offset(0.008, -0.006)
            : pos;
      }
    }

    final arrowProgress = <String, double>{
      for (final entry in arrowSegments.entries)
        entry.key: t < entry.value.step - 1
            ? 0
            : entry.value.localT((t - (entry.value.step - 1)).clamp(0.0, 1.0)),
    };

    return PlaybackFrame(
      players: players,
      ball: ball,
      step: currentStep,
      moving: moving,
      headings: headings,
      arrowProgress: arrowProgress,
    );
  }
}

// ── Playback controller state ───────────────────────────────────────────

enum PlaybackStatus { idle, playing, paused, finished }

class TacticPlaybackState {
  const TacticPlaybackState({
    this.status = PlaybackStatus.idle,
    this.time = 0,
    this.speed = 1,
    this.playback,
    this.loop = false,
  });

  final PlaybackStatus status;
  final double time;
  final double speed;
  final TacticPlayback? playback;
  final bool loop;

  bool get isActive => status != PlaybackStatus.idle && playback != null;
  bool get isPlaying => status == PlaybackStatus.playing;

  PlaybackFrame? get frame => playback?.frameAt(time);

  TacticPlaybackState copyWith({
    PlaybackStatus? status,
    double? time,
    double? speed,
    TacticPlayback? playback,
    bool? loop,
  }) {
    return TacticPlaybackState(
      status: status ?? this.status,
      time: time ?? this.time,
      speed: speed ?? this.speed,
      playback: playback ?? this.playback,
      loop: loop ?? this.loop,
    );
  }
}

/// Seconds one phase takes at 1x speed.
const playbackSecondsPerStep = 1.6;

class TacticPlaybackNotifier extends StateNotifier<TacticPlaybackState> {
  TacticPlaybackNotifier(this._ref) : super(const TacticPlaybackState());

  final Ref _ref;

  /// Builds the animation from the current board and starts playing.
  /// Returns false when the board has no movement arrows.
  bool play() {
    if (state.status == PlaybackStatus.paused && state.playback != null) {
      state = state.copyWith(status: PlaybackStatus.playing);
      return true;
    }
    final board = _ref.read(tacticalBoardProvider);
    final playback = TacticPlayback.fromBoard(
      players: board.players,
      arrows: board.arrows,
      ball: board.ball,
    );
    if (playback.isEmpty) return false;
    state = TacticPlaybackState(
      status: PlaybackStatus.playing,
      playback: playback,
      speed: state.speed,
      loop: state.loop,
    );
    return true;
  }

  void pause() {
    if (state.status != PlaybackStatus.playing) return;
    state = state.copyWith(status: PlaybackStatus.paused);
  }

  void togglePlay() {
    if (state.isPlaying) {
      pause();
    } else if (state.status == PlaybackStatus.finished) {
      seek(0);
      state = state.copyWith(status: PlaybackStatus.playing);
    } else {
      play();
    }
  }

  void setSpeed(double speed) {
    state = state.copyWith(speed: speed.clamp(0.25, 3.0));
  }

  void toggleLoop() => state = state.copyWith(loop: !state.loop);

  void seek(double time) {
    final playback = state.playback;
    if (playback == null) return;
    state = state.copyWith(
      time: time.clamp(0.0, playback.duration),
      status: state.status == PlaybackStatus.finished
          ? PlaybackStatus.paused
          : state.status,
    );
  }

  /// Advances the clock; called from a ticker.
  void tick(Duration elapsed) {
    final playback = state.playback;
    if (playback == null || !state.isPlaying) return;
    final dt = elapsed.inMicroseconds / 1e6;
    var next = state.time + dt * state.speed / playbackSecondsPerStep;
    if (next >= playback.duration) {
      if (state.loop) {
        next = 0;
      } else {
        state = state.copyWith(
          time: playback.duration,
          status: PlaybackStatus.finished,
        );
        return;
      }
    }
    state = state.copyWith(time: next);
  }

  /// Leaves playback and restores the board as drawn.
  void stop() {
    state = TacticPlaybackState(speed: state.speed, loop: state.loop);
  }

  /// Leaves playback keeping players and ball where the animation ended.
  void applyResult() {
    final frame = state.frame;
    if (frame != null) {
      _ref.read(tacticalBoardProvider.notifier).applyPlaybackResult(
            players: frame.players,
            ball: frame.ball,
          );
    }
    stop();
  }
}

final tacticPlaybackProvider =
    StateNotifierProvider<TacticPlaybackNotifier, TacticPlaybackState>(
  (ref) => TacticPlaybackNotifier(ref),
);
