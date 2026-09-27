import 'package:flutter/material.dart';
import '../models/league_config.dart';
import '../services/claude_scouting_service.dart';
import '../services/football_api_service.dart';
import '../services/tactical_session_service.dart';
import '../utils/tactical_coords_adapter.dart';
import '../widgets/ai_scouting_modal.dart';

class LeagueScoutingScreen extends StatefulWidget {
  const LeagueScoutingScreen({super.key});

  @override
  State<LeagueScoutingScreen> createState() => _LeagueScoutingScreenState();
}

class _LeagueScoutingScreenState extends State<LeagueScoutingScreen> {
  LeagueConfig _selectedLeague = SupportedLeagues.all.first;
  List<Map<String, dynamic>> _fixtures = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchFixtures();
  }

  Future<void> _fetchFixtures() async {
    setState(() => _isLoading = true);
    final results = await FootballApiService.instance.getUpcomingFixtures(
      leagueId: _selectedLeague.id,
      season: _selectedLeague.currentSeason,
    );
    if (mounted) {
      setState(() {
        _fixtures = results;
        _isLoading = false;
      });
    }
  }

  Future<void> _importMatchTo3D(int fixtureId, String matchTitle) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('جاري جلب التشكيلات الرسمية...')),
    );

    final lineups = await FootballApiService.instance.getFixtureLineups(fixtureId);
    if (lineups == null || lineups['home'] == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('التشكيلة لم تعلن رسمياً بعد لهذه المباراة')),
        );
      }
      return;
    }

    // تحويل الفريقين
    final homePlayers = TacticalCoordsAdapter.convertTo3DPlayers(
      teamLineupData: lineups['home'],
      isHomeTeam: true,
    );

    final awayPlayers = lineups['away'] != null
        ? TacticalCoordsAdapter.convertTo3DPlayers(
            teamLineupData: lineups['away'],
            isHomeTeam: false,
          )
        : <TacticalPlayerModel>[];

    // الإرسال للقسم الأول (الملعب ثلاثي الأبعاد)
    TacticalSessionService.instance.importSquadToTactics(
      matchTitle: matchTitle,
      formation: lineups['home']['formation'] ?? '4-3-3',
      squad: [...homePlayers, ...awayPlayers],
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم تنزيل $matchTitle على الملعب ثلاثي الأبعاد!')),
      );
    }
  }

  // استدعاء التحليل وعرض الـ Modal
  Future<void> _analyzeAndShowReport(int fixtureId, String matchTitle) async {
    // 1. إظهار مؤشر انتظار
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF10B981)),
      ),
    );

    // 2. جلب التشكيلة
    final lineups = await FootballApiService.instance.getFixtureLineups(fixtureId);

    if (!mounted) return;
    Navigator.pop(context); // إغلاق مؤشر الانتظار

    if (lineups != null && lineups['home'] != null) {
      final homeData = lineups['home'];
      final teamName = homeData['team']?['name'] ?? homeData['teamName'] ?? 'الفريق الخصم';
      final formation = homeData['formation'] ?? '4-3-3';
      final List startXIList = homeData['startXI'] ?? homeData['players'] ?? [];
      final startXI = List<Map<String, dynamic>>.from(startXIList);

      // 3. تحليل Claude
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: Card(
            color: Color(0xFF0F172A),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Color(0xFF10B981)),
                  SizedBox(height: 14),
                  Text(
                    'جاري تحليل خطة الخصم عبر Claude AI...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      final aiReport = await ClaudeScoutingService.instance.analyzeOpponentTactics(
        teamName: teamName,
        formation: formation,
        players: startXI,
      );

      if (!mounted) return;
      Navigator.pop(context); // إغلاق شاشة التحليل

      if (aiReport != null) {
        // 4. إظهار تقرير التحليل النهائي للمدرب
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => AiScoutingModal(
            teamName: teamName,
            formation: formation,
            report: aiReport,
            onApplyTo3D: () {
              final homePlayers = TacticalCoordsAdapter.convertTo3DPlayers(
                teamLineupData: lineups['home'],
                isHomeTeam: true,
              );
              final awayPlayers = lineups['away'] != null
                  ? TacticalCoordsAdapter.convertTo3DPlayers(
                      teamLineupData: lineups['away'],
                      isHomeTeam: false,
                    )
                  : <TacticalPlayerModel>[];

              TacticalSessionService.instance.importSquadToTactics(
                matchTitle: "$matchTitle (تحليل تكتيكي)",
                formation: aiReport['counter_formation'] ?? formation,
                squad: [...homePlayers, ...awayPlayers],
              );

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم تطبيق الخطة المضادة لـ $matchTitle على الملعب 3D!'),
                  ),
                );
              }
            },
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر الحصول على تحليل الذكاء الاصطناعي حالياً.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('التشكيلة غير متوفرة بعد لهذه المباراة ليتم تحليلها.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text('مركز الدوريات والسكاوتينغ 📊'),
      ),
      body: Column(
        children: [
          // شريط اختيار الدوريات الأفقي
          Container(
            height: 58,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: SupportedLeagues.all.length,
              itemBuilder: (context, idx) {
                final league = SupportedLeagues.all[idx];
                final isSelected = league.id == _selectedLeague.id;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedLeague = league);
                    _fetchFixtures();
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF10B981) : const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Text(league.flagEmoji, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Text(
                          league.name,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // قائمة المباريات
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)))
                : _fixtures.isEmpty
                    ? const Center(
                        child: Text(
                          'لا توجد مباريات قادمة حالياً لهذا الدوري',
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _fixtures.length,
                        itemBuilder: (context, index) {
                          final f = _fixtures[index];
                          final home = f['teams']['home'];
                          final away = f['teams']['away'];
                          final fixtureId = f['fixture']['id'];
                          final matchTitle = '${home['name']} ضد ${away['name']}';

                          return Card(
                            color: const Color(0xFF0F172A),
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: const BorderSide(color: Colors.white10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${home['name']} 🆚 ${away['name']}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              f['fixture']['date']?.toString().substring(0, 10) ?? '',
                                              style: const TextStyle(color: Colors.white54, fontSize: 11),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      // زر التحليل الذكي عبر AI
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: const Color(0xFF10B981),
                                            side: const BorderSide(color: Color(0xFF10B981)),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          onPressed: () => _analyzeAndShowReport(fixtureId, matchTitle),
                                          icon: const Icon(Icons.psychology, size: 16),
                                          label: const Text(
                                            'تحليل السكاوتنج 🧠',
                                            style: TextStyle(fontSize: 11),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // زر نقل التشكيلة للملعب
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF10B981),
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          onPressed: () => _importMatchTo3D(fixtureId, matchTitle),
                                          icon: const Icon(Icons.sports_soccer, size: 16),
                                          label: const Text(
                                            'تنزيل للملعب 3D',
                                            style: TextStyle(fontSize: 11),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
