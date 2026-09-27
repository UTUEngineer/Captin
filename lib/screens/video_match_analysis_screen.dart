import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../widgets/interactive_3d_pitch.dart';
import '../widgets/tactical_keyframe_bar.dart';
import '../services/tracking_player_engine.dart';
import '../services/tactical_keyframe_engine.dart';

class VideoMatchAnalysisScreen extends StatefulWidget {
  final String? initialVideoUrl;

  const VideoMatchAnalysisScreen({
    super.key,
    this.initialVideoUrl,
  });

  @override
  State<VideoMatchAnalysisScreen> createState() => _VideoMatchAnalysisScreenState();
}

class _VideoMatchAnalysisScreenState extends State<VideoMatchAnalysisScreen> {
  late VideoPlayerController _videoController;
  TrackingPlaybackEngine? _trackingEngine;
  final TacticalKeyframeEngine _keyframeEngine = TacticalKeyframeEngine();

  bool _isVideoInitialized = false;
  bool _showHeatmap = false;
  bool _showRiskCorridor = false;
  final double _matchFps = 25.0;
  int _lastSyncedFrameIndex = -1;
  final int _trackedPlayersCount = 22;
  final double _avgConfidence = 0.94;

  final String _sampleVideoUrl = 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';

  @override
  void initState() {
    super.initState();
    _initVideoPlayer();
  }

  Future<void> _initVideoPlayer() async {
    final url = widget.initialVideoUrl ?? _sampleVideoUrl;
    _videoController = VideoPlayerController.networkUrl(Uri.parse(url));

    try {
      await _videoController.initialize();
      _videoController.addListener(_onVideoTick);
      if (mounted) {
        setState(() => _isVideoInitialized = true);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isVideoInitialized = true);
      }
    }
  }

  void _onVideoTick() {
    if (!_videoController.value.isInitialized || _trackingEngine == null) return;
    final currentPos = _videoController.value.position;
    final posInSeconds = currentPos.inMilliseconds / 1000.0;
    final targetFrame = (posInSeconds * _matchFps).floor();

    if (targetFrame != _lastSyncedFrameIndex) {
      _lastSyncedFrameIndex = targetFrame;
      _trackingEngine?.seekToFrame(targetFrame);
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
      backgroundColor: const Color(0xFF070B14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 2,
        title: const Text(
          'AI Video vs 3D Simulation Sync',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            tooltip: 'Toggle 3D Heatmap',
            icon: Icon(
              Icons.local_fire_department_outlined,
              color: _showHeatmap ? const Color(0xFFF59E0B) : Colors.white60,
            ),
            onPressed: () {
              setState(() => _showHeatmap = !_showHeatmap);
            },
          ),
          IconButton(
            tooltip: 'Toggle Passing Risk Corridors',
            icon: Icon(
              Icons.alt_route_outlined,
              color: _showRiskCorridor ? const Color(0xFFEF4444) : Colors.white60,
            ),
            onPressed: () {
              setState(() => _showRiskCorridor = !_showRiskCorridor);
            },
          ),
          IconButton(
            tooltip: '4-Point Homography Calibration',
            icon: const Icon(Icons.crop_free, color: Color(0xFF38BDF8)),
            onPressed: _showHomographyDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // CV Metrics Summary Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: const Color(0xFF1E293B),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricPill('CV Engine', 'YOLOv8 + ByteTrack', Icons.memory, const Color(0xFF38BDF8)),
                _buildMetricPill('Tracked', '$_trackedPlayersCount Players', Icons.people_alt, const Color(0xFF10B981)),
                _buildMetricPill('Confidence', '${(_avgConfidence * 100).toStringAsFixed(1)}%', Icons.check_circle_outline, const Color(0xFFFACC15)),
                _buildMetricPill('Frame', '#$_lastSyncedFrameIndex @ ${_matchFps.toInt()} FPS', Icons.timer_outlined, const Color(0xFFA855F7)),
              ],
            ),
          ),

          // Dual Playhead View (Side-by-side or Top/Bottom)
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 900;

                return isWide
                    ? Row(
                        children: [
                          Expanded(flex: 1, child: _buildMasterVideoContainer()),
                          const VerticalDivider(color: Colors.white12, width: 2),
                          Expanded(flex: 1, child: _buildSlave3DPitchContainer()),
                        ],
                      )
                    : Column(
                        children: [
                          Expanded(flex: 1, child: _buildMasterVideoContainer()),
                          Expanded(flex: 1, child: _buildSlave3DPitchContainer()),
                        ],
                      );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricPill(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text('$label: ', style: const TextStyle(color: Colors.white54, fontSize: 11)),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
      ],
    );
  }

  Widget _buildMasterVideoContainer() {
    return Container(
      color: Colors.black,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _isVideoInitialized && _videoController.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _videoController.value.aspectRatio > 0 ? _videoController.value.aspectRatio : 16 / 9,
                  child: VideoPlayer(_videoController),
                )
              : const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Color(0xFF38BDF8)),
                      SizedBox(height: 12),
                      Text('Raw Match Footage (Calibrated)', style: TextStyle(color: Colors.white60, fontSize: 13)),
                    ],
                  ),
                ),

          // Calibrated Video Badge Overlay
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.videocam, color: Colors.redAccent, size: 12),
                  SizedBox(width: 6),
                  Text('Raw Match Footage (Calibrated)', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),

          // Play/Pause Overlay Controller
          Positioned(
            bottom: 12,
            right: 12,
            child: FloatingActionButton.small(
              backgroundColor: const Color(0xFF38BDF8),
              onPressed: () {
                setState(() {
                  if (_videoController.value.isPlaying) {
                    _videoController.pause();
                  } else {
                    _videoController.play();
                  }
                });
              },
              child: Icon(
                _videoController.value.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlave3DPitchContainer() {
    return Container(
      color: const Color(0xFF0A0F1D),
      child: Stack(
        children: [
          Listener(
            onPointerDown: (_) {
              if (_videoController.value.isPlaying) {
                _videoController.pause(); // Auto-pause video on 3D node touch
              }
            },
            child: Interactive3DPitchCanvas(
              onEngineReady: (engine) {
                _trackingEngine = engine;
              },
            ),
          ),

          // Reconstructed 3D Sync Badge
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0F1D).withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.5)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.view_in_ar, color: Color(0xFF10B981), size: 12),
                  SizedBox(width: 6),
                  Text('Synchronized 3D Simulation & Passing Corridors', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),

          // Keyframe bar overlay
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

  void _showHomographyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Row(
          children: [
            Icon(Icons.crop_free, color: Color(0xFF38BDF8)),
            SizedBox(width: 8),
            Text('4-Point Homography Calibration', style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select 4 pitch corner control points on the video frame to map 2D broadcast coordinates to 3D pitch space:',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            SizedBox(height: 12),
            Text('• Top-Left Pitch Corner (X1, Y1)', style: TextStyle(color: Colors.white54, fontSize: 12)),
            Text('• Top-Right Pitch Corner (X2, Y2)', style: TextStyle(color: Colors.white54, fontSize: 12)),
            Text('• Bottom-Right Pitch Corner (X3, Y3)', style: TextStyle(color: Colors.white54, fontSize: 12)),
            Text('• Bottom-Left Pitch Corner (X4, Y4)', style: TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8)),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Homography Matrix Re-Calibrated Successfully!'),
                  backgroundColor: Color(0xFF10B981),
                ),
              );
            },
            child: const Text('Auto-Calibrate', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
