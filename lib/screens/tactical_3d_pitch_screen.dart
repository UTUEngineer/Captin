import 'package:flutter/material.dart';
import '../widgets/tactical_3d_pitch.dart';
import '../services/tracking_player_engine.dart';
import '../services/supabase_service.dart';

/// شاشة الملعب التكتيكي ثلاثي الأبعاد 3D Tactical Pitch Screen
/// توفر تجربة كاملة للمدربين والكابتن لإدارة ومحاكاة التشكيلات والتمريرات تكتيكياً.
class Tactical3DPitchScreen extends StatefulWidget {
  const Tactical3DPitchScreen({super.key});

  @override
  State<Tactical3DPitchScreen> createState() => _Tactical3DPitchScreenState();
}

class _Tactical3DPitchScreenState extends State<Tactical3DPitchScreen> {
  bool _isSaving = false;
  String _selectedFormation = '4-3-3';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030712),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 4,
        title: Row(
          children: [
            const Icon(Icons.view_in_ar, color: Color(0xFF00E5FF), size: 24),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'الملعب التكتيكي 3D',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '3D Tactical Pitch Simulation Engine',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF00E5FF),
                    ),
                  )
                : const Icon(Icons.cloud_upload_outlined, color: Color(0xFF00E5FF)),
            tooltip: 'حفظ الخطة في Supabase',
            onPressed: _isSaving ? null : _saveBoardToCloud,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // 1. المحرك ثلاثي الأبعاد للملعب
          Positioned.fill(
            child: Tactical3DPitchWidget(
              onEngineReady: (engine) {
                setState(() {
                  _playbackEngine = engine;
                });
              },
            ),
          ),

          // 2. شريط تحكم علوي للتكتيك
          Positioned(
            top: 16,
            right: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // اختيار التشكيلة
                  Row(
                    children: [
                      const Icon(Icons.space_dashboard_outlined,
                          color: Color(0xFF00E5FF), size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'التشكيلة:',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: _selectedFormation,
                        dropdownColor: const Color(0xFF0F172A),
                        style: const TextStyle(
                            color: Color(0xFF00E5FF), fontWeight: FontWeight.bold),
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(value: '4-3-3', child: Text('4-3-3')),
                          DropdownMenuItem(value: '5-3-2', child: Text('5-3-2')),
                          DropdownMenuItem(value: '4-2-3-1', child: Text('4-2-3-1')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedFormation = val;
                            });
                          }
                        },
                      ),
                    ],
                  ),

                  // زر التحديث والمعاينة
                  TextButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم تحديث التشكيلة على الملعب 3D'),
                          backgroundColor: Color(0xFF00E5FF),
                        ),
                      );
                    },
                    icon: const Icon(Icons.refresh, size: 18, color: Colors.white),
                    label: const Text('إعادة ضبط',
                        style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveBoardToCloud() async {
    setState(() => _isSaving = true);
    try {
      final supabaseService = SupabaseService();
      await supabaseService.save3DTacticalBoard(
        title: 'خطة تكتيكية 3D - $_selectedFormation',
        formation: _selectedFormation,
        board3DStateJson: {
          'formation': _selectedFormation,
          'created_at': DateTime.now().toIso8601String(),
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ الخطة التكتيكية 3D بنجاح في السحابة!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في الحفظ: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
