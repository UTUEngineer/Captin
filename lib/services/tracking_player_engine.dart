import 'dart:convert';
import 'package:three_js/three_js.dart' as three;

// 1. نماذج البيانات القادمة من الـ JSON (Data Models)
class PlayerFrameData {
  final int trackId;
  final String team;
  final double x;
  final double y;

  PlayerFrameData({
    required this.trackId,
    required this.team,
    required this.x,
    required this.y,
  });

  factory PlayerFrameData.fromJson(Map<String, dynamic> json) {
    return PlayerFrameData(
      trackId: json['track_id'] as int? ?? 0,
      team: json['team'] as String? ?? 'home',
      x: (json['x'] as num?)?.toDouble() ?? 0.0,
      y: (json['y'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class MatchFrame {
  final int frameIdx;
  final double timestamp;
  final List<PlayerFrameData> players;
  final three.Vector3? ballPosition;

  MatchFrame({
    required this.frameIdx,
    required this.timestamp,
    required this.players,
    this.ballPosition,
  });

  factory MatchFrame.fromJson(Map<String, dynamic> json) {
    final playersList = (json['players'] as List<dynamic>?)
            ?.map((p) => PlayerFrameData.fromJson(p as Map<String, dynamic>))
            .toList() ??
        [];

    three.Vector3? ball;
    if (json['ball'] != null) {
      final ballJson = json['ball'] as Map<String, dynamic>;
      final bx = (ballJson['x'] as num?)?.toDouble() ?? 0.0;
      final by = (ballJson['y'] as num?)?.toDouble() ?? 0.0;
      final bz = (ballJson['z'] as num?)?.toDouble() ?? 0.5;
      ball = three.Vector3(bx, bz, by);
    }

    return MatchFrame(
      frameIdx: json['frame_idx'] as int? ?? 0,
      timestamp: (json['timestamp'] as num?)?.toDouble() ?? 0.0,
      players: playersList,
      ballPosition: ball,
    );
  }
}

// 2. محرك تشغيل وإدارة حركة التتبع (Tracking Playback Controller)
class TrackingPlaybackEngine {
  final three.Group playersGroup;
  final three.Mesh ballMesh;
  final List<MatchFrame> frames = [];

  Map<int, three.Mesh> activePlayerMeshes = {}; // ربط كل trackId بمجسمه في الـ 3D

  int currentFrameIndex = 0;
  bool isPlaying = false;
  double fps = 25.0;
  double playbackSpeed = 1.0;
  double _accumulatedTime = 0.0;

  TrackingPlaybackEngine({
    required this.playersGroup,
    required this.ballMesh,
  });

  void setSpeed(double speed) {
    playbackSpeed = speed;
  }

  // تحميل داتا الـ JSON من الباك إند
  void loadTrackingJson(String jsonRaw) {
    final data = jsonDecode(jsonRaw) as Map<String, dynamic>;
    fps = (data['fps'] as num?)?.toDouble() ?? 25.0;

    frames.clear();
    if (data['tracks'] != null) {
      for (var f in data['tracks'] as List<dynamic>) {
        frames.add(MatchFrame.fromJson(f as Map<String, dynamic>));
      }
    }

    currentFrameIndex = 0;
    _syncSceneToFrame(currentFrameIndex, interpolate: false);
  }

  void play() => isPlaying = true;
  void pause() => isPlaying = false;

  void seekToFrame(int frameIdx) {
    if (frames.isEmpty) return;
    currentFrameIndex = frameIdx.clamp(0, frames.length - 1);
    _syncSceneToFrame(currentFrameIndex, interpolate: false);
  }

  // 3. تحديث المواضع في كل إطار Render Loop (مع خاصية Lerp للتنعيم)
  void update(double deltaTime) {
    if (!isPlaying || frames.isEmpty) return;

    _accumulatedTime += deltaTime;
    final frameDuration = (1.0 / fps) / (playbackSpeed > 0 ? playbackSpeed : 1.0);

    if (_accumulatedTime >= frameDuration) {
      _accumulatedTime -= frameDuration;
      currentFrameIndex++;

      if (currentFrameIndex >= frames.length) {
        currentFrameIndex = 0; // إعادة العرض تلقائياً (Loop)
      }
    }

    // تنعيم الحركة بين الإطار الحالي والإطار القادم (Frame Interpolation)
    double alpha = (_accumulatedTime / frameDuration).clamp(0.0, 1.0);
    _syncSceneToFrame(currentFrameIndex, alpha: alpha, interpolate: true);
  }

  double _lerp(double a, double b, double alpha) => a + (b - a) * alpha;

  // 4. تزامن مجسمات 3D مع بيانات الإطار الحالي
  void _syncSceneToFrame(int index, {double alpha = 0.0, bool interpolate = true}) {
    if (index >= frames.length) return;

    final currentFrame = frames[index];
    final nextFrame = (index + 1 < frames.length) ? frames[index + 1] : currentFrame;

    Set<int> presentTrackIds = {};

    // أ) تحديث مواقع اللاعبين
    for (var playerData in currentFrame.players) {
      final trackId = playerData.trackId;
      presentTrackIds.add(trackId);

      // البحث عن موقع اللاعب في الإطار القادم للتنعيم
      PlayerFrameData nextPlayerData = nextFrame.players.firstWhere(
        (p) => p.trackId == trackId,
        orElse: () => playerData,
      );

      // الحساب الخطي للموقع المفترض في اللحظة Alpha
      double targetX = playerData.x;
      double targetZ = playerData.y;

      if (interpolate) {
        targetX = _lerp(playerData.x, nextPlayerData.x, alpha);
        targetZ = _lerp(playerData.y, nextPlayerData.y, alpha);
      }

      // إذا كان اللاعب موجوداً سابقاً ──► نحرك مجسمه
      if (activePlayerMeshes.containsKey(trackId)) {
        final mesh = activePlayerMeshes[trackId]!;
        mesh.position.x = targetX;
        mesh.position.z = targetZ;
      } else {
        // إذا كان لاعباً جديداً دخل الكادر ──► ننشئ مجسم 3D جديد له
        final newMesh = _createPlayerMesh(playerData.team);
        newMesh.position.setValues(targetX, 1.25, targetZ);
        playersGroup.add(newMesh);
        activePlayerMeshes[trackId] = newMesh;
      }
    }

    // ب) إخفاء اللاعبين الذين خرجوا من كادر التصوير في هذا الإطار
    activePlayerMeshes.removeWhere((trackId, mesh) {
      if (!presentTrackIds.contains(trackId)) {
        playersGroup.remove(mesh);
        return true;
      }
      return false;
    });

    // ج) تحديث موقع الكرة 3D
    if (currentFrame.ballPosition != null) {
      var ballTarget = currentFrame.ballPosition!;
      if (interpolate && nextFrame.ballPosition != null) {
        ballTarget = three.Vector3(
          _lerp(currentFrame.ballPosition!.x, nextFrame.ballPosition!.x, alpha),
          _lerp(currentFrame.ballPosition!.y, nextFrame.ballPosition!.y, alpha),
          _lerp(currentFrame.ballPosition!.z, nextFrame.ballPosition!.z, alpha),
        );
      }
      ballMesh.position.setValues(ballTarget.x, ballTarget.y, ballTarget.z);
    }
  }

  // دالة إنشاء مجسم 3D بخصائص الفريق
  three.Mesh _createPlayerMesh(String team) {
    final colorHex = (team == 'home') ? 0xef4444 : 0x3b82f6; // أحمر للهوم / أزرق للأواي
    final cylinderGeo = three.CylinderGeometry(1.2, 1.2, 2.5, 16);
    final material = three.MeshStandardMaterial()
      ..color = three.Color.fromHex32(colorHex)
      ..metalness = 0.2
      ..roughness = 0.3;
    final mesh = three.Mesh(cylinderGeo, material);
    mesh.castShadow = true;
    return mesh;
  }
}
