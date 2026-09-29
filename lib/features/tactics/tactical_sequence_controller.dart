import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'tactical_keyframe_engine.dart';

class TacticalSequenceController extends ChangeNotifier {
  final List<TacticalKeyframe> keyframes = [];
  int _activeKeyframeIndex = 0;
  bool _isPlaying = false;
  double _playbackSpeed = 1.0;
  bool _isLooping = true;

  // Timeline progress [0.0 to TotalDuration]
  double _currentTime = 0.0;

  int get activeKeyframeIndex => _activeKeyframeIndex;
  bool get isPlaying => _isPlaying;
  double get playbackSpeed => _playbackSpeed;
  bool get isLooping => _isLooping;
  double get currentTime => _currentTime;

  double get totalDuration {
    if (keyframes.length <= 1) return 0.0;
    double d = 0;
    for (int i = 1; i < keyframes.length; i++) {
      d += keyframes[i].durationSeconds;
    }
    return d;
  }

  void addKeyframe({
    required String name,
    required Map<String, EntityStateSnapshot> currentState,
    double duration = 2.0,
  }) {
    final kf = TacticalKeyframe(
      id: 'kf_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      durationSeconds: duration,
      snapshots: currentState.map((k, v) => MapEntry(k, v.copyWith())),
    );
    keyframes.add(kf);
    _activeKeyframeIndex = keyframes.length - 1;
    _currentTime = totalDuration;
    notifyListeners();
  }

  void removeKeyframe(int index) {
    if (keyframes.length <= 1) return;
    keyframes.removeAt(index);
    if (_activeKeyframeIndex >= keyframes.length) {
      _activeKeyframeIndex = keyframes.length - 1;
    }
    _currentTime = _getTimestampForIndex(_activeKeyframeIndex);
    notifyListeners();
  }

  void play() {
    if (keyframes.length < 2) return;
    if (_currentTime >= totalDuration) {
      _currentTime = 0.0;
    }
    _isPlaying = true;
    notifyListeners();
  }

  void pause() {
    _isPlaying = false;
    notifyListeners();
  }

  void togglePlayPause() {
    if (_isPlaying) {
      pause();
    } else {
      play();
    }
  }

  void setPlaybackSpeed(double speed) {
    _playbackSpeed = speed;
    notifyListeners();
  }

  void toggleLooping() {
    _isLooping = !_isLooping;
    notifyListeners();
  }

  void seekTo(double time) {
    _currentTime = time.clamp(0.0, totalDuration);
    _syncActiveKeyframeWithTime();
    notifyListeners();
  }

  void selectKeyframe(int index) {
    if (index < 0 || index >= keyframes.length) return;
    _activeKeyframeIndex = index;
    _currentTime = _getTimestampForIndex(index);
    notifyListeners();
  }

  double _getTimestampForIndex(int index) {
    double t = 0.0;
    for (int i = 1; i <= index && i < keyframes.length; i++) {
      t += keyframes[i].durationSeconds;
    }
    return t;
  }

  void _syncActiveKeyframeWithTime() {
    if (keyframes.isEmpty) return;
    double accumulator = 0.0;
    for (int i = 1; i < keyframes.length; i++) {
      final nextTime = accumulator + keyframes[i].durationSeconds;
      if (_currentTime <= nextTime) {
        _activeKeyframeIndex = i - 1;
        return;
      }
      accumulator = nextTime;
    }
    _activeKeyframeIndex = keyframes.length - 1;
  }

  // Ticked from Ticker / AnimationController
  void advanceTime(double deltaSeconds) {
    if (!_isPlaying || totalDuration <= 0) return;

    _currentTime += deltaSeconds * _playbackSpeed;

    if (_currentTime >= totalDuration) {
      if (_isLooping) {
        _currentTime = 0.0;
      } else {
        _currentTime = totalDuration;
        _isPlaying = false;
      }
    }
    _syncActiveKeyframeWithTime();
    notifyListeners();
  }

  // Calculate live interpolated state of any entity at current timeline position
  EntityStateSnapshot? evaluateEntity(String id) {
    if (keyframes.isEmpty) return null;
    if (keyframes.length == 1) return keyframes.first.snapshots[id];

    double accumulator = 0.0;
    for (int i = 1; i < keyframes.length; i++) {
      final segDuration = keyframes[i].durationSeconds;
      final nextAccumulator = accumulator + segDuration;

      if (_currentTime <= nextAccumulator || i == keyframes.length - 1) {
        final t = segDuration > 0 ? ((_currentTime - accumulator) / segDuration).clamp(0.0, 1.0) : 1.0;

        final k0 = keyframes[math.max(0, i - 2)].snapshots[id];
        final k1 = keyframes[i - 1].snapshots[id];
        final k2 = keyframes[i].snapshots[id];
        final k3 = keyframes[math.min(keyframes.length - 1, i + 1)].snapshots[id];

        if (k1 == null || k2 == null) return null;

        final p0 = k0?.position ?? k1.position;
        final p1 = k1.position;
        final p2 = k2.position;
        final p3 = k3?.position ?? k2.position;

        final livePos = KeyframeInterpolator.interpolateHermite(p0, p1, p2, p3, t);
        final liveAngle = KeyframeInterpolator.interpolateAngle(k1.headingRadians, k2.headingRadians, t);
        final liveElev = KeyframeInterpolator.computeBallParabola(k1.elevation, k2.elevation, 4.0, t);

        return EntityStateSnapshot(
          id: id,
          position: livePos,
          headingRadians: liveAngle,
          elevation: liveElev,
        );
      }
      accumulator = nextAccumulator;
    }
    return keyframes.last.snapshots[id];
  }
}
