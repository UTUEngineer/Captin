import 'package:flutter/material.dart';
import '../services/pdf_tactical_report_service.dart';
import '../services/tactical_session_service.dart';

class AiScoutingModal extends StatelessWidget {
  final String teamName;
  final String formation;
  final Map<String, dynamic> report;
  final VoidCallback onApplyTo3D;

  const AiScoutingModal({
    super.key,
    required this.teamName,
    required this.formation,
    required this.report,
    required this.onApplyTo3D,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رأس التقرير
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.psychology, color: Color(0xFF10B981), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تقرير السكاوتنج الذكي: $teamName',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      'تشكيلة الخصم: $formation | الخطة المقترحة: ${report["counter_formation"] ?? "4-2-3-1"}',
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // نقطة القوة
          _buildInfoTile(
            title: 'أبرز نقاط القوة',
            desc: report['team_strength'] ?? '',
            icon: Icons.flash_on,
            iconColor: const Color(0xFF10B981),
            bgColor: const Color(0xFF10B981).withValues(alpha: 0.1),
          ),
          const SizedBox(height: 10),

          // ثغرة الخصم
          _buildInfoTile(
            title: 'الثغرة الدفاعية المستهدفة',
            desc: report['team_vulnerability'] ?? '',
            icon: Icons.shield_outlined,
            iconColor: Colors.amberAccent,
            bgColor: Colors.amber.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 10),

          // الخطة المقترحة
          if (report['recommended_counter_strategy'] != null &&
              report['recommended_counter_strategy'].toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildInfoTile(
                title: 'الخطة المقترحة تكتيكياً',
                desc: report['recommended_counter_strategy'] ?? '',
                icon: Icons.auto_graph,
                iconColor: const Color(0xFF38BDF8),
                bgColor: const Color(0xFF38BDF8).withValues(alpha: 0.1),
              ),
            ),

          // اللاعب المحوري للضغط
          if (report['key_player_to_press'] != null &&
              report['key_player_to_press'] is Map)
            _buildInfoTile(
              title: 'هدف الضغط العالي: ${report['key_player_to_press']['name'] ?? ''}',
              desc: report['key_player_to_press']['reason'] ?? '',
              icon: Icons.track_changes,
              iconColor: Colors.redAccent,
              bgColor: Colors.red.withValues(alpha: 0.1),
            ),
          const SizedBox(height: 16),

          // الأزرار التفاعلية (تطبيق ثلاثي الأبعاد + تصدير PDF)
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF10B981)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('جاري إعداد تقرير الـ PDF الاحترافي...')),
                    );

                    await PdfTacticalReportService.instance.exportAndShareReport(
                      matchTitle: "تحليل مباراة $teamName",
                      opponentTeam: teamName,
                      formation: formation,
                      players: TacticalSessionService.instance.activePlayers,
                      aiReport: report,
                    );
                  },
                  icon: const Icon(Icons.picture_as_pdf, color: Color(0xFF10B981), size: 18),
                  label: const Text('تصدير PDF 📄', style: TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    onApplyTo3D();
                  },
                  icon: const Icon(Icons.sports_soccer, color: Colors.white, size: 18),
                  label: const Text(
                    'تطبيق 3D ⚽',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String desc,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: iconColor, fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
