import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:captain/features/tactical_board/presentation/widgets/localized_pitch_canvas.dart';

class TacticalScreen extends StatefulWidget {
  const TacticalScreen({super.key});

  @override
  State<TacticalScreen> createState() => _TacticalScreenState();
}

class _TacticalScreenState extends State<TacticalScreen> {
  String _selectedTool = 'pass';
  
  // Tactical coordinate normalized strictly from top-left (0.0, 0.0) to bottom-right (1.0, 1.0)
  final List<Offset> _playerPositions = [
    const Offset(0.2, 0.5), // Goalkeeper
    const Offset(0.35, 0.25), // Defender Left
    const Offset(0.35, 0.75), // Defender Right
    const Offset(0.6, 0.5), // Midfielder
    const Offset(0.85, 0.5), // Striker
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: Text(l10n.appTitle),
        actions: [
          // Directional button spacing
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 16.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                // Export handler
              },
              icon: const Icon(Icons.picture_as_pdf, size: 18),
              label: Text(l10n.exportPdf),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          // 1. DIRECTIONAL SIDEBAR: Mirrors to the right in Arabic, left in English
          Container(
            width: 240,
            color: const Color(0xFF0F172A),
            padding: const EdgeInsetsDirectional.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.toolsHeader,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 16),
                _buildToolItem(
                  icon: Icons.arrow_right_alt,
                  title: l10n.passTool,
                  id: 'pass',
                ),
                _buildToolItem(
                  icon: Icons.directions_run,
                  title: l10n.runTool,
                  id: 'run',
                ),
                _buildToolItem(
                  icon: Icons.crop_free,
                  title: l10n.pressZoneTool,
                  id: 'zone',
                ),
                const Spacer(),
                // Metric badge localized with intl parameter
                Container(
                  padding: const EdgeInsetsDirectional.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    l10n.distanceCovered(10450),
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    minimumSize: const Size.fromHeight(42),
                  ),
                  onPressed: () {
                    setState(() => _playerPositions.clear());
                  },
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: Text(l10n.clearBoard),
                ),
              ],
            ),
          ),

          // 2. ISOLATED PITCH CANVAS: Strictly LTR Cartesian plane
          Expanded(
            child: Container(
              color: const Color(0xFF020617),
              padding: const EdgeInsetsDirectional.all(24.0),
              child: Center(
                child: AspectRatio(
                  aspectRatio: 105 / 68, // Standard FIFA pitch aspect ratio
                  child: Directionality(
                    // CRITICAL: Prevent horizontal inversion of pitch coordinates
                    textDirection: TextDirection.ltr,
                    child: LocalizedPitchCanvas(
                      players: _playerPositions,
                      onPlayerMoved: (index, newPos) {
                        setState(() {
                          _playerPositions[index] = newPos;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolItem({
    required IconData icon,
    required String title,
    required String id,
  }) {
    final isSelected = _selectedTool == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedTool = id),
      child: Container(
        margin: const EdgeInsetsDirectional.only(bottom: 8.0),
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF10B981).withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF10B981) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? const Color(0xFF10B981) : Colors.white60,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
