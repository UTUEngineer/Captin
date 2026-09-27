class PitchDimensions {
  final double width;
  final double height;

  const PitchDimensions({
    required this.width,
    required this.height,
  });

  factory PitchDimensions.fromJson(Map<String, dynamic> json) {
    return PitchDimensions(
      width: (json['width'] as num?)?.toDouble() ?? 105.0,
      height: (json['height'] as num?)?.toDouble() ?? 68.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'width': width,
    'height': height,
  };
}

class Ball3D {
  final double x;
  final double y;
  final double z;

  const Ball3D({
    required this.x,
    required this.y,
    required this.z,
  });

  factory Ball3D.fromJson(Map<String, dynamic> json) {
    return Ball3D(
      x: (json['x'] as num?)?.toDouble() ?? 0.0,
      y: (json['y'] as num?)?.toDouble() ?? 0.0,
      z: (json['z'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'x': x,
    'y': y,
    'z': z,
  };
}

class PlayerTrack {
  final int trackId;
  final String team; // "home" or "away"
  final double x;
  final double y;

  const PlayerTrack({
    required this.trackId,
    required this.team,
    required this.x,
    required this.y,
  });

  factory PlayerTrack.fromJson(Map<String, dynamic> json) {
    return PlayerTrack(
      trackId: json['track_id'] as int? ?? 0,
      team: json['team'] as String? ?? 'home',
      x: (json['x'] as num?)?.toDouble() ?? 0.0,
      y: (json['y'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'track_id': trackId,
    'team': team,
    'x': x,
    'y': y,
  };
}

class FrameTrack {
  final int frameIdx;
  final double timestamp;
  final Ball3D ball;
  final List<PlayerTrack> players;

  const FrameTrack({
    required this.frameIdx,
    required this.timestamp,
    required this.ball,
    required this.players,
  });

  factory FrameTrack.fromJson(Map<String, dynamic> json) {
    return FrameTrack(
      frameIdx: json['frame_idx'] as int? ?? 0,
      timestamp: (json['timestamp'] as num?)?.toDouble() ?? 0.0,
      ball: json['ball'] != null
          ? Ball3D.fromJson(json['ball'] as Map<String, dynamic>)
          : const Ball3D(x: 0, y: 0, z: 0),
      players: (json['players'] as List<dynamic>?)
              ?.map((p) => PlayerTrack.fromJson(p as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'frame_idx': frameIdx,
    'timestamp': timestamp,
    'ball': ball.toJson(),
    'players': players.map((p) => p.toJson()).toList(),
  };
}

class TacticalVisionTrackingData {
  final int fps;
  final PitchDimensions pitchDimensions;
  final int totalFrames;
  final List<FrameTrack> tracks;

  const TacticalVisionTrackingData({
    required this.fps,
    required this.pitchDimensions,
    required this.totalFrames,
    required this.tracks,
  });

  factory TacticalVisionTrackingData.fromJson(Map<String, dynamic> json) {
    return TacticalVisionTrackingData(
      fps: json['fps'] as int? ?? 25,
      pitchDimensions: json['pitch_dimensions'] != null
          ? PitchDimensions.fromJson(json['pitch_dimensions'] as Map<String, dynamic>)
          : const PitchDimensions(width: 105.0, height: 68.0),
      totalFrames: json['total_frames'] as int? ?? 0,
      tracks: (json['tracks'] as List<dynamic>?)
              ?.map((t) => FrameTrack.fromJson(t as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'fps': fps,
    'pitch_dimensions': pitchDimensions.toJson(),
    'total_frames': totalFrames,
    'tracks': tracks.map((t) => t.toJson()).toList(),
  };
}
