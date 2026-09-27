import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../widgets/interactive_3d_pitch.dart';
import '../widgets/tactical_keyframe_bar.dart';
import '../services/tracking_player_engine.dart';
import '../services/tactical_keyframe_engine.dart';

class SyncedMatchAnalysisScreen extends StatefulWidget {
  final String videoUrl;
  final String trackingJsonRaw;

  const SyncedMatchAnalysisScreen({
    super.key,
    required this.videoUrl,
    required this.trackingJsonRaw,
  });

  @override
  State<SyncedMatchAnalysisScreen> createState() => _SyncedMatchAnalysisScreenState();
}

class _SyncedMatchAnalysisScreenState extends State<SyncedMatchAnalysisScreen> {
  // 1. مشغل الفيديو ومحرك الـ 3D
  late VideoPlayerController _videoController;
  TrackingPlaybackEngine? _trackingEngine;
  final TacticalKeyframeEngine _keyframeEngine = TacticalKeyframeEngine();

  bool isVideoInitialized = false;
  bool isUserDragging3DNode = false;
  double matchFps = 25.0; // معدل إطارات تتبع YOLO
  int lastSyncedFrameIndex = -1;

  @override
  void initState() {
    super.initState();
    _setupVideoAndSync();
  }

  // 2. تهيئة مشغل الفيديو وربط المزامنة الحية (Video Listener)
  Future<void> _setupVideoAndSync() async {
    _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));

    await _videoController.initialize();

    // ربط مستمع تغيير الوقت الحقيقي في الفيديو (Tick Listener)
    _videoController.addListener(_onVideoTick);

    setState(() {
      isVideoInitialized = true;
    });
  }

  // 3. الميثود الجوهرية: تزامن الـ 3D تلقائياً مع موقع الفيديو الحالي بالمللي ثانية
  void _onVideoTick() {
    if (!_videoController.value.isInitialized || _trackingEngine == null || isUserDragging3DNode) return;

    // أ) جلب الوقت الحالي للفيديو بالمللي ثانية
    final currentPosition = _videoController.value.position;
    final double positionInSeconds = currentPosition.inMilliseconds / 1000.0;

    // ب) تحويل الوقت الحالي إلى رقم الإطار المناسب (Frame Index)
    final int targetFrameIndex = (positionInSeconds * matchFps).floor();

    // ج) تحديث موقع اللاعبين والكرة في الـ 3D Canvas فقط إذا انتقل الفيديو لإطار جديد
    if (targetFrameIndex != lastSyncedFrameIndex) {
      lastSyncedFrameIndex = targetFrameIndex;

      // توجيه محرك الـ 3D للانتقال فوراً للإطار المطابق (Direct Seek)
      _trackingEngine!.seekToFrame(targetFrameIndex);
    }
  }

  @override
  void dispose() {
    _videoController.removeListener(_onVideoTick);
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          "المزامنة اللحظية: فيديو المباراة + تتبع 3D",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          // زر التقديم / الإرجاع السريع لمزامنة الـ Sync
          IconButton(
            icon: Icon(
              _videoController.value.isPlaying ? Icons.pause_circle : Icons.play_circle,
              color: const Color(0xFF38BDF8),
            ),
            onPressed: () {
              setState(() {
                if (_videoController.value.isPlaying) {
                  _videoController.pause();
                } else {
                  _videoController.play();
                }
              });
            },
          ),
        ],
      ),
      body: !isVideoInitialized
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8)))
          : LayoutBuilder(
              builder: (context, constraints) {
                // للتعامل مع الشاشات العريضة (Desktop/Tablet Split View)
                final isWideScreen = constraints.maxWidth > 900;

                return isWideScreen
                    ? Row(
                        children: [
                          // A. الجانب الأيسر: فيديو المباراة الحقيقي
                          Expanded(
                            flex: 5,
                            child: _buildVideoPlayerContainer(),
                          ),
                          const VerticalDivider(color: Colors.white12, width: 2),

                          // B. الجانب الأيمن: السبورة والتتبع 3D Canvas
                          Expanded(
                            flex: 5,
                            child: _build3DPitchContainer(),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          // التنسيق المزدوج المتراتب للشاشات الصغيرة (Mobile Top/Bottom)
                          Expanded(
                            flex: 4,
                            child: _buildVideoPlayerContainer(),
                          ),
                          Expanded(
                            flex: 6,
                            child: _build3DPitchContainer(),
                          ),
                        ],
                      );
              },
            ),
    );
  }

  // مكوّن حاوي فيديو المباراة
  Widget _buildVideoPlayerContainer() {
    return Container(
      color: Colors.black,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _videoController.value.aspectRatio,
            child: VideoPlayer(_videoController),
          ),

          // شارة إظهار مزامنة الفيديو الحية (Live Sync Badge)
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                "MATCH VIDEO (MASTER)",
                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // مكوّن حاوي الملعب والرسوم 3D Canvas
  Widget _build3DPitchContainer() {
    return Container(
      color: const Color(0xFF0F172A),
      child: Stack(
        children: [
          // الـ 3D Canvas Widget الذي يحتوي على ThreeJS
          Listener(
            onPointerDown: (_) {
              if (_videoController.value.isPlaying) {
                _videoController.pause();
                setState(() {
                  isUserDragging3DNode = true;
                });
              }
            },
            onPointerUp: (_) {
              setState(() {
                isUserDragging3DNode = false;
              });
            },
            child: Interactive3DPitchCanvas(
              onEngineReady: (engine) {
                _trackingEngine = engine;
                _trackingEngine?.loadTrackingJson(widget.trackingJsonRaw);
              },
            ),
          ),

          // شارة إظهار حالة الـ 3D Sync
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF0EA5E9).withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                "3D TRACKING (SLAVE)",
                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // شريط التسجيل والتحكم بالخطوات (Keyframing Toolbar Overlay)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Center(
              child: TacticalKeyframeBar(
                engine: _keyframeEngine,
                onRecordStep: () {
                  if (_trackingEngine != null) {
                    setState(() {
                      _keyframeEngine.recordKeyframe(
                        playersGroup: _trackingEngine!.playersGroup,
                        ballMesh: _trackingEngine!.ballMesh,
                      );
                    });
                  }
                },
                onPlaySequence: () {
                  setState(() {
                    if (_keyframeEngine.isPlayingSequence) {
                      _keyframeEngine.pauseSequence();
                    } else {
                      _keyframeEngine.playSequence();
                    }
                  });
                },
                onClearSequence: () {
                  setState(() {
                    _keyframeEngine.clearSequence();
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
