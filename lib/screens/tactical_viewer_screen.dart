import 'package:captain/widgets/tactical_arrows_painter.dart';
import 'package:flutter/material.dart';

const Color _emeraldAccent = Color(0xFF10B981);
const Color _emeraldBorder = Color(0xFF059669);

class TacticalViewerScreen extends StatelessWidget {
  final Map<String, dynamic> boardData; // جُلب مباشرة من Supabase

  const TacticalViewerScreen({super.key, required this.boardData});

  @override
  Widget build(BuildContext context) {
    final List players = boardData['players'] as List? ?? [];
    final List rawArrows = boardData['arrows'] as List? ?? [];
    final List<ArrowData> arrows = rawArrows.map((a) {
      final Map<String, dynamic> map = a is Map<String, dynamic> ? a : Map<String, dynamic>.from(a as Map);
      return ArrowData.fromJson(map);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text("استعراض التاكتيك"),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 2,
      ),
      body: Center(
        child: Container(
          width: 360,
          height: 540,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _emeraldBorder, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    // 1. خطوط الملعب
                    Center(
                      child: Container(
                        width: constraints.maxWidth,
                        height: 1,
                        color: Colors.white10,
                      ),
                    ),

                    // 2. طبقة الأسهم والتحركات (SVG/Canvas)
                    CustomPaint(
                      size: Size(constraints.maxWidth, constraints.maxHeight),
                      painter: TacticalArrowsPainter(arrows: arrows),
                    ),

                    // 3. طبقة اللاعبين
                    ...List.generate(players.length, (index) {
                      final p = players[index] is Map<String, dynamic>
                          ? players[index]
                          : Map<String, dynamic>.from(players[index] as Map);
                      final double dx = (p['x'] as num? ?? 50).toDouble() / 100;
                      final double dy = (p['y'] as num? ?? 50).toDouble() / 100;
                      final bool isGk = p['isGk'] == true;

                      return Positioned(
                        left: dx * constraints.maxWidth - 14,
                        top: dy * constraints.maxHeight - 14,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: isGk ? Colors.amber : _emeraldAccent,
                            shape: BoxShape.circle,
                            boxShadow: const [
                              BoxShadow(color: Colors.black38, blurRadius: 6),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              "${p['name'] ?? ''}",
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
