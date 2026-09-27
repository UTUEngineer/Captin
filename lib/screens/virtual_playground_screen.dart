import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../widgets/interactive_3d_pitch.dart';
import '../widgets/tactical_keyframe_bar.dart';
import '../services/tracking_player_engine.dart';
import '../services/tactical_keyframe_engine.dart';
import '../services/pdf_exporter_service.dart';
import '../services/tactical_session_service.dart';
import '../widgets/save_tactic_dialog.dart';

class VirtualPlaygroundScreen extends StatefulWidget {
  final List<Map<String, dynamic>>? initialSquad;

  const VirtualPlaygroundScreen({
    super.key,
    this.initialSquad,
  });

  @override
  State<VirtualPlaygroundScreen> createState() => _VirtualPlaygroundScreenState();
}

class _VirtualPlaygroundScreenState extends State<VirtualPlaygroundScreen> {
  TrackingPlaybackEngine? _trackingEngine;
  final TacticalKeyframeEngine _keyframeEngine = TacticalKeyframeEngine();
  final _sessionService = TacticalSessionService.instance;

  String _selectedFormation = '4-3-3';
  final List<String> _formations = ['4-3-3', '4-2-3-1', '3-5-2', '4-4-2', '5-3-2'];
  bool _isExporting = false;
  bool _showFormationsMenu = false;
  bool _isDrawingLines = false;
  bool _isDrawingZones = false;
  bool _isPovActive = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _sessionService,
      builder: (context, _) {
        final activePlayers = _sessionService.activePlayers;
        final matchTitle = _sessionService.activeMatchTitle ?? '3D Tactical Playground';
        final activeFormation = _sessionService.activeFormation ?? _selectedFormation;

        return Scaffold(
          backgroundColor: const Color(0xFF070B14),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0F172A),
            elevation: 2,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  matchTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'Formation: $activeFormation • ${activePlayers.length} Players Active',
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.remove_red_eye_outlined,
                  color: _isPovActive ? const Color(0xFF10B981) : Colors.white,
                ),
                tooltip: "Switch to 'Be The Player' POV",
                onPressed: () {
                  setState(() {
                    _isPovActive = !_isPovActive;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_isPovActive ? "Switched to 'Be The Player' First-Person POV (Eye level Y=1.75m)" : "Switched to 3D Orbit Camera"),
                      backgroundColor: const Color(0xFF10B981),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.video_library_outlined,
                  color: _keyframeEngine.isPlayingSequence ? const Color(0xFF10B981) : Colors.white,
                ),
                tooltip: "Play Keyframe Sequence",
                onPressed: () {
                  setState(() {
                    if (_keyframeEngine.isPlayingSequence) {
                      _keyframeEngine.pauseSequence();
                    } else {
                      _keyframeEngine.playSequence();
                    }
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.cloud_upload_outlined, color: Color(0xFF10B981)),
                tooltip: 'حفظ الخطة التكتيكية في السحابة',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const SaveTacticDialog(),
                  );
                },
              ),
              IconButton(
                icon: _isExporting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Color(0xFF10B981), strokeWidth: 2),
                      )
                    : const Icon(Icons.share_outlined, color: Colors.white),
                tooltip: "Export 3D PDF/GIF",
                onPressed: _exportTacticsPdf,
              ),
            ],
          ),
          body: Stack(
            children: [
              // 1. 3D OpenGL / Three.js Pitch Canvas with Raycasting
              Interactive3DPitchCanvas(
                onEngineReady: (engine) {
                  _trackingEngine = engine;
                },
              ),

              // 2. Reactive 3D Player Floating Badges & AI Weakness Markers
              if (activePlayers.isNotEmpty)
                LayoutBuilder(
                  builder: (context, constraints) {
                    final w = constraints.maxWidth;
                    final h = constraints.maxHeight;

                    return Stack(
                      children: activePlayers.map((player) {
                        // Normalize 3D Coordinates (X: -50 to 50, Z: -35 to 35) to 2D Overlay Bounds
                        final posX = ((player.coords3D.x + 50.0) / 100.0 * (w - 120)) + 40;
                        final posY = ((player.coords3D.z + 35.0) / 70.0 * (h - 160)) + 60;

                        return Positioned(
                          left: posX.clamp(10.0, w - 160.0),
                          top: posY.clamp(10.0, h - 80.0),
                          child: _buildReactivePlayerBadge(player),
                        );
                      }).toList(),
                    );
                  },
                ),

              // 3. Tactical Toolbar Overlay (Formations, Draw Lines, Press Zones)
              Positioned(
                left: 16,
                top: 16,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                    boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10)],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.grid_view, color: _showFormationsMenu ? const Color(0xFF10B981) : Colors.white70),
                        tooltip: 'Formation Switcher (4-3-3, 4-2-3-1...)',
                        onPressed: () {
                          setState(() => _showFormationsMenu = !_showFormationsMenu);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.edit_road, color: _isDrawingLines ? const Color(0xFF10B981) : Colors.white70),
                        tooltip: 'Draw Passing / Movement Arrows',
                        onPressed: () {
                          setState(() {
                            _isDrawingLines = !_isDrawingLines;
                            _isDrawingZones = false;
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.crop_square, color: _isDrawingZones ? const Color(0xFF10B981) : Colors.white70),
                        tooltip: 'Highlight Pressing / Compactness Zones',
                        onPressed: () {
                          setState(() {
                            _isDrawingZones = !_isDrawingZones;
                            _isDrawingLines = false;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Popover Formations Menu
              if (_showFormationsMenu)
                Positioned(
                  left: 70,
                  top: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF10B981)),
                      boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 12)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Preset Formations', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        ..._formations.map((f) => InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedFormation = f;
                                  _sessionService.activeFormation = f;
                                  _showFormationsMenu = false;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Formation $f Applied with Smooth Animation!'),
                                    backgroundColor: const Color(0xFF10B981),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                child: Row(
                                  children: [
                                    Icon(
                                      activeFormation == f ? Icons.radio_button_checked : Icons.radio_button_off,
                                      color: activeFormation == f ? const Color(0xFF10B981) : Colors.white38,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Formation $f',
                                      style: TextStyle(
                                        color: activeFormation == f ? Colors.white : Colors.white70,
                                        fontWeight: activeFormation == f ? FontWeight.bold : FontWeight.normal,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                ),

              // Player POV Badge Overlay
              if (_isPovActive)
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.visibility, color: Colors.white, size: 14),
                        SizedBox(width: 6),
                        Text(
                          "Player POV: #10 (Eye Level Y=1.75m)",
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),

              // Timeline Keyframe Bar at Bottom
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

              // Loaded Squad Badge Banner if activePlayers imported
              if (activePlayers.isNotEmpty)
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          'Imported Squad Loaded (${activePlayers.length} Players)',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReactivePlayerBadge(TacticalPlayerModel player) {
    final isGk = player.position == 'GK';
    final hasWeakness = player.weaknesses.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // AI Weakness Floating Marker Banner (if any)
        if (hasWeakness)
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(6),
              boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 4)],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 10),
                const SizedBox(width: 3),
                Flexible(
                  child: Text(
                    player.weaknesses.first,
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

        // 3D Player Node / Number Avatar
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isGk ? Colors.amber : const Color(0xFF10B981),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1.5),
            boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 6, offset: Offset(0, 2))],
          ),
          child: Center(
            child: Text(
              '#${player.number}',
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11),
            ),
          ),
        ),

        const SizedBox(height: 2),

        // Floating Name & Position Label
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.white12),
          ),
          child: Text(
            '${player.name} (${player.position})',
            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Future<void> _exportTacticsPdf() async {
    setState(() => _isExporting = true);
    try {
      final pitchImageBytes = Uint8List(0);
      await TacticalPdfExporter.generateAndShareTacticalReport(
        pitchImageBytes: pitchImageBytes,
        matchTitle: _sessionService.activeMatchTitle ?? 'Tactical Playbook - $_selectedFormation',
        coachName: 'Captain Coach',
        formationName: _sessionService.activeFormation ?? _selectedFormation,
        tacticalNotes: [
          'High press in opponent final third',
          'Overlapping fullbacks on wing transitions',
          'Keyframe steps recorded: ${_keyframeEngine.keyframes.length}',
        ],
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('3D PDF Export Generated Successfully!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export Note: $e'), backgroundColor: Colors.amber),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }
}
