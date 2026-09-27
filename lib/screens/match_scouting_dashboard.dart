import 'package:flutter/material.dart';
import '../widgets/interactive_3d_pitch.dart';

// 1. نموذج بيانات المباراة المحللة (Match Model)
class AnalyzedMatch {
  final String id;
  final String title;
  final String competition;
  final String date;
  final String homeTeam;
  final String awayTeam;
  final String homeLogo;
  final String awayLogo;
  final String status; // 'completed', 'processing', 'failed'
  final double progress; // 0.0 to 1.0 (في حال كان قيد المعالجة)
  final String duration;
  final int totalPlayersTracked;

  AnalyzedMatch({
    required this.id,
    required this.title,
    required this.competition,
    required this.date,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeLogo,
    required this.awayLogo,
    required this.status,
    this.progress = 1.0,
    required this.duration,
    required this.totalPlayersTracked,
  });
}

class MatchScoutingDashboard extends StatefulWidget {
  const MatchScoutingDashboard({super.key});

  @override
  State<MatchScoutingDashboard> createState() => _MatchScoutingDashboardState();
}

class _MatchScoutingDashboardState extends State<MatchScoutingDashboard> {
  String selectedFilter = "الكل";

  // داتا تجريبية للمباريات المحللة
  final List<AnalyzedMatch> matches = [
    AnalyzedMatch(
      id: "video_101",
      title: "الكلاسيكو - تحليل الشوط الأول",
      competition: "دوري نجوم العراق",
      date: "2026-08-01",
      homeTeam: "الشرطة",
      awayTeam: "القوة الجوية",
      homeLogo: "🛡️",
      awayLogo: "🦅",
      status: "completed",
      duration: "45:00",
      totalPlayersTracked: 22,
    ),
    AnalyzedMatch(
      id: "video_102",
      title: "تحليل بناء اللعب من الخلف",
      competition: "دوري أبطال آسيا",
      date: "2026-07-28",
      homeTeam: "الزوراء",
      awayTeam: "النصر",
      homeLogo: "⚪",
      awayLogo: "🟡",
      status: "processing",
      progress: 0.65, // 65% مكتمل
      duration: "90:00",
      totalPlayersTracked: 20,
    ),
    AnalyzedMatch(
      id: "video_103",
      title: "الضغط العالي والتحولات",
      competition: "مباراة ودية",
      date: "2026-07-20",
      homeTeam: "أربيل",
      awayTeam: "دهوك",
      homeLogo: "🟡",
      awayLogo: "⚽",
      status: "completed",
      duration: "30:00",
      totalPlayersTracked: 18,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark Slate Background
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.analytics_outlined, color: Color(0xFF38BDF8)),
            SizedBox(width: 10),
            Text(
              "داشبورد التحليل والكشافة",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.video_call, color: Color(0xFF38BDF8)),
            tooltip: "رفع فيديو جديد",
            onPressed: () {
              // فتح شاشة رفع فيديو جديد للباك إند
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // A. كروت الإحصائيات السريعة (Quick Stats Row)
            Row(
              children: [
                _buildStatCard("المباريات المحللة", "${matches.where((m) => m.status == 'completed').length}", Icons.movie_outlined, const Color(0xFF38BDF8)),
                const SizedBox(width: 12),
                _buildStatCard("قيد المعالجة (YOLO)", "${matches.where((m) => m.status == 'processing').length}", Icons.memory, const Color(0xFFFACC15)),
                const SizedBox(width: 12),
                _buildStatCard("إجمالي التتبع", "60 لاعب", Icons.people_outline, const Color(0xFF22C55E)),
              ],
            ),

            const SizedBox(height: 25),

            // B. شريط تصفية المباريات (Filter Chips)
            Row(
              children: ["الكل", "مكتمل", "قيد المعالجة"].map((filter) {
                final isSelected = selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: ChoiceChip(
                    label: Text(filter, style: TextStyle(color: isSelected ? Colors.white : Colors.white60, fontSize: 12)),
                    selected: isSelected,
                    selectedColor: const Color(0xFF38BDF8).withValues(alpha: 0.3),
                    backgroundColor: const Color(0xFF1E293B),
                    side: BorderSide(color: isSelected ? const Color(0xFF38BDF8) : Colors.transparent),
                    onSelected: (val) {
                      setState(() => selectedFilter = filter);
                    },
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 15),

            // C. قائمة المباريات والفيديوهات المحللة (Matches List)
            Expanded(
              child: ListView.builder(
                itemCount: _filteredMatches.length,
                itemBuilder: (context, index) {
                  return _buildMatchCard(_filteredMatches[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<AnalyzedMatch> get _filteredMatches {
    if (selectedFilter == "مكتمل") {
      return matches.where((m) => m.status == 'completed').toList();
    } else if (selectedFilter == "قيد المعالجة") {
      return matches.where((m) => m.status == 'processing').toList();
    }
    return matches;
  }

  // كود كارت الإحصائيات (Stat Card Widget)
  Widget _buildStatCard(String title, String value, IconData icon, Color accentColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: accentColor, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text(title, style: const TextStyle(color: Colors.white54, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // كود كارت المباراة (Match Item Card)
  Widget _buildMatchCard(AnalyzedMatch match) {
    final bool isCompleted = match.status == 'completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // العنوان والدوري
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(match.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(match.competition, style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 11)),
                      const Text(" • ", style: TextStyle(color: Colors.white38)),
                      Text(match.date, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                    ],
                  ),
                ],
              ),

              // شارة الحالة (Status Badge)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isCompleted ? Colors.green.withValues(alpha: 0.15) : Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isCompleted ? Colors.greenAccent : Colors.amberAccent, width: 0.8),
                ),
                child: Text(
                  isCompleted ? "مكتمل 3D" : "معالجة YOLO ${(match.progress * 100).toInt()}%",
                  style: TextStyle(
                    color: isCompleted ? Colors.greenAccent : Colors.amberAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // تفاصيل الفرق والمواجهة
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    Text(match.homeLogo, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(match.homeTeam, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                  ],
                ),
                const Text("VS", style: TextStyle(color: Colors.white38, fontWeight: FontWeight.bold, fontSize: 12)),
                Row(
                  children: [
                    Text(match.awayTeam, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(width: 8),
                    Text(match.awayLogo, style: const TextStyle(fontSize: 18)),
                  ],
                ),
              ],
            ),
          ),

          // شريط التقدم إذا كان قيد المعالجة
          if (!isCompleted) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: match.progress,
              backgroundColor: Colors.white10,
              color: const Color(0xFFFACC15),
              minHeight: 4,
            ),
          ],

          const SizedBox(height: 14),

          // أزرار التفاعل والدخول لسبورة الـ 3D
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "المدة: ${match.duration}  |  اللاعبين: ${match.totalPlayersTracked}",
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
              ElevatedButton.icon(
                icon: Icon(
                  isCompleted ? Icons.view_in_ar : Icons.hourglass_top,
                  size: 16,
                  color: Colors.white,
                ),
                label: Text(
                  isCompleted ? "فتح التكتيك 3D" : "انتظار التجهيز",
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCompleted ? const Color(0xFF0EA5E9) : Colors.grey[800],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: isCompleted
                    ? () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const Interactive3DPitchScreen(),
                          ),
                        );
                      }
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
