import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/router/app_router.dart';
import '../services/match_reports_service.dart';

/// Interactive Post-Match Summary Report & Player Evaluation Screen
class PostMatchReportScreen extends ConsumerStatefulWidget {
  final String? shiftId;
  final String? captainId;
  final int scoreHome;
  final int scoreAway;

  const PostMatchReportScreen({
    super.key,
    this.shiftId,
    this.captainId,
    this.scoreHome = 2,
    this.scoreAway = 1,
  });

  @override
  ConsumerState<PostMatchReportScreen> createState() => _PostMatchReportScreenState();
}

class _PostMatchReportScreenState extends ConsumerState<PostMatchReportScreen> {
  // Configurable Match Statistics
  late MatchStatsModel _stats;

  // Squad Performance & Player Ratings
  late List<PlayerEvaluation> _evaluations;

  bool _isExporting = false;
  bool _exportSuccess = false;

  @override
  void initState() {
    super.initState();

    _stats = MatchStatsModel(
      possessionHome: 56,
      possessionAway: 44,
      shotsHome: 14,
      shotsAway: 8,
      shotsOnTargetHome: 6,
      shotsOnTargetAway: 3,
      foulsHome: 9,
      foulsAway: 12,
    );

    _evaluations = [
      PlayerEvaluation(id: 'p1', number: 1, name: 'H. Jassim', role: 'GK', rating: 7.8, notes: 'Solid command of the box'),
      PlayerEvaluation(id: 'p2', number: 2, name: 'M. Kareem', role: 'RB', rating: 7.2, notes: 'Good overlapping runs'),
      PlayerEvaluation(id: 'p3', number: 4, name: 'Z. Tahseen', role: 'CB', rating: 8.1, notes: 'Key defensive aerial duels'),
      PlayerEvaluation(id: 'p4', number: 5, name: 'S. Natiq', role: 'CB', rating: 7.5, notes: 'Disciplined positioning'),
      PlayerEvaluation(id: 'p5', number: 3, name: 'A. Adnan', role: 'LB', rating: 7.0, notes: 'Recovered well on counter'),
      PlayerEvaluation(id: 'p6', number: 8, name: 'I. Bayesh', role: 'CM', rating: 8.4, notes: 'High press engine'),
      PlayerEvaluation(id: 'p7', number: 6, name: 'O. Rashid', role: 'CDM', rating: 7.9, notes: 'Controlled tempo in midfield'),
      PlayerEvaluation(id: 'p8', number: 10, name: 'A. Saadoon', role: 'CAM', rating: 9.2, notes: 'Match-winning assist & brace'),
      PlayerEvaluation(id: 'p9', number: 7, name: 'Y. Amyn', role: 'RW', rating: 7.6, notes: 'Dangerous down the wing'),
      PlayerEvaluation(id: 'p10', number: 9, name: 'A. Hussein', role: 'ST', rating: 8.6, notes: 'Clinical header finish'),
      PlayerEvaluation(id: 'p11', number: 11, name: 'A. Jasim', role: 'LW', rating: 7.4, notes: 'Created 3 key chances'),
    ];
  }

  // Automatically compute Player of the Match (MVP)
  PlayerEvaluation get _mvpPlayer {
    return _evaluations.reduce((prev, current) => current.rating > prev.rating ? current : prev);
  }

  String get _matchOutcome {
    if (widget.scoreHome > widget.scoreAway) return 'win';
    if (widget.scoreHome < widget.scoreAway) return 'loss';
    return 'draw';
  }

  void _updateRating(String id, double delta) {
    HapticFeedback.selectionClick();
    setState(() {
      _evaluations = _evaluations.map((item) {
        if (item.id == id) {
          final newRating = (item.rating + delta).clamp(1.0, 10.0);
          final rounded = (newRating * 10).round() / 10.0;
          return PlayerEvaluation(
            id: item.id,
            number: item.number,
            name: item.name,
            role: item.role,
            rating: rounded,
            notes: item.notes,
          );
        }
        return item;
      }).toList();
    });
  }

  void _updateNotes(String id, String notes) {
    setState(() {
      _evaluations = _evaluations.map((item) {
        if (item.id == id) {
          return PlayerEvaluation(
            id: item.id,
            number: item.number,
            name: item.name,
            role: item.role,
            rating: item.rating,
            notes: notes,
          );
        }
        return item;
      }).toList();
    });
  }

  // Export & Finalize Report to Supabase Cloud
  Future<void> _handleSupabaseExport() async {
    HapticFeedback.heavyImpact();
    setState(() {
      _isExporting = true;
    });

    final payload = MatchReportPayload(
      shiftId: widget.shiftId,
      captainId: widget.captainId,
      scoreHome: widget.scoreHome,
      scoreAway: widget.scoreAway,
      matchOutcome: _matchOutcome,
      stats: _stats,
      playerEvaluations: _evaluations.map((item) {
        return PlayerEvaluation(
          id: item.id,
          number: item.number,
          name: item.name,
          role: item.role,
          rating: item.rating,
          notes: item.notes,
          isMvp: item.id == _mvpPlayer.id,
        );
      }).toList(),
      mvpPlayerId: _mvpPlayer.id,
    );

    final service = ref.read(matchReportsServiceProvider);
    await service.exportMatchReport(payload);

    if (mounted) {
      setState(() {
        _isExporting = false;
        _exportSuccess = true;
      });

      Future.delayed(const Duration(milliseconds: 1800), () {
        if (mounted) {
          GoRouter.of(context).go(AppRoutes.hub);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mvp = _mvpPlayer;
    final outcome = _matchOutcome;

    return Scaffold(
      backgroundColor: const Color(0xFF061120),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // 1. Top Header Card: Match Outcome & Final Score
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          CircleAvatar(radius: 4, backgroundColor: Color(0xFF00E676)),
                          SizedBox(width: 8),
                          Text(
                            'FULL TIME REVIEW',
                            style: TextStyle(
                              color: Color(0xFF00E676),
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'MATCH PERFORMANCE REPORT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),

                  // Final Result Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A1B32),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.4)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00E676).withValues(alpha: 0.2),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Text('AZ-ZAWR\'A SC', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 12),
                        Text(
                          '${widget.scoreHome} - ${widget.scoreAway}',
                          style: const TextStyle(color: Color(0xFF00E676), fontSize: 22, fontWeight: FontWeight.w900, fontFamily: 'monospace'),
                        ),
                        const SizedBox(width: 12),
                        const Text('AL-QUWA AL-JAWIYA', style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: outcome == 'win'
                                ? const Color(0xFF10B981).withValues(alpha: 0.2)
                                : (outcome == 'loss' ? Colors.red.withValues(alpha: 0.2) : Colors.amber.withValues(alpha: 0.2)),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: outcome == 'win'
                                  ? const Color(0xFF10B981)
                                  : (outcome == 'loss' ? Colors.redAccent : Colors.amber),
                            ),
                          ),
                          child: Text(
                            outcome.toUpperCase(),
                            style: TextStyle(
                              color: outcome == 'win'
                                  ? const Color(0xFF10B981)
                                  : (outcome == 'loss' ? Colors.redAccent : Colors.amber),
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 2. Main Grid: Analytics Column & Player Evaluations Column
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column: Match Analytics (MVP, Possession, Stats, Export)
                    Expanded(
                      flex: 5,
                      child: Column(
                        children: [
                          // MVP Spotlight Banner
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.amber.withValues(alpha: 0.25),
                                  Colors.amber.withValues(alpha: 0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.amber.withValues(alpha: 0.15),
                                  blurRadius: 25,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        color: Colors.amber,
                                        border: Border.all(color: Colors.amberAccent, width: 2),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '#${mvp.number}',
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'PLAYER OF THE MATCH (MVP)',
                                          style: TextStyle(
                                            color: Colors.amber,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                        Text(
                                          mvp.name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        Text(
                                          '${mvp.role} • ${mvp.notes}',
                                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      mvp.rating.toStringAsFixed(1),
                                      style: const TextStyle(
                                        color: Colors.amber,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                    const Text(
                                      'RATING',
                                      style: TextStyle(color: Colors.amber, fontSize: 9, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Possession Bar Card
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0B1C33).withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Home ${_stats.possessionHome}%', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                    const Text('BALL POSSESSION', style: TextStyle(color: Color(0xFF00E676), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                                    Text('Away ${_stats.possessionAway}%', style: const TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: SizedBox(
                                    height: 10,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: _stats.possessionHome,
                                          child: Container(color: const Color(0xFF00E676)),
                                        ),
                                        Expanded(
                                          flex: _stats.possessionAway,
                                          child: Container(color: Colors.blueGrey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Tactical Stat Comparison Tiles
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0B1C33).withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'TACTICAL MATCH STATS',
                                  style: TextStyle(color: Color(0xFF00E676), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                                ),
                                const SizedBox(height: 12),
                                _buildStatRow('Total Shots', _stats.shotsHome, _stats.shotsAway),
                                const SizedBox(height: 10),
                                _buildStatRow('Shots on Target', _stats.shotsOnTargetHome, _stats.shotsOnTargetAway),
                                const SizedBox(height: 10),
                                _buildStatRow('Fouls Committed', _stats.foulsHome, _stats.foulsAway),
                              ],
                            ),
                          ),

                          const Spacer(),

                          // Export & Submit Action CTA Button
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _exportSuccess ? const Color(0xFF10B981) : const Color(0xFF00E676),
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 8,
                              ),
                              onPressed: _isExporting || _exportSuccess ? null : _handleSupabaseExport,
                              child: _isExporting
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                                  : Text(
                                      _exportSuccess ? 'REPORT SAVED TO SUPABASE CLOUD!' : 'EXPORT & FINALIZE REPORT',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 13,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 20),

                    // Right Column: Player Evaluation & Rating Stepper Grid
                    Expanded(
                      flex: 7,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B1C33).withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text('CAPTAIN PLAYER EVALUATIONS', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900)),
                                    Text('Adjust ratings & captain remarks before cloud export', style: TextStyle(color: Colors.white54, fontSize: 11)),
                                  ],
                                ),
                                Text('${_evaluations.length} Evaluated', style: const TextStyle(color: Color(0xFF00E676), fontSize: 11, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Player Rating List
                            Expanded(
                              child: ListView.builder(
                                itemCount: _evaluations.length,
                                itemBuilder: (context, index) {
                                  final p = _evaluations[index];
                                  final isMvp = p.id == mvp.id;

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isMvp
                                          ? Colors.amber.withValues(alpha: 0.12)
                                          : const Color(0xFF0F243E),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isMvp ? Colors.amber : Colors.white12,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        // Player Number & Name
                                        SizedBox(
                                          width: 160,
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 30,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: const Color(0xFF06101E),
                                                  border: Border.all(color: const Color(0xFF38BDF8)),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    '${p.number}',
                                                    style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 11, fontWeight: FontWeight.w900),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(p.name, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                                      if (isMvp) ...[
                                                        const SizedBox(width: 4),
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                                          decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(4)),
                                                          child: const Text('MVP', style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.w900)),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                  Text(p.role, style: const TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.bold)),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Remarks Input Field
                                        Expanded(
                                          child: TextField(
                                            onChanged: (val) => _updateNotes(p.id, val),
                                            controller: TextEditingController(text: p.notes)
                                              ..selection = TextSelection.fromPosition(TextPosition(offset: p.notes.length)),
                                            style: const TextStyle(color: Colors.white, fontSize: 11),
                                            decoration: InputDecoration(
                                              hintText: 'Add captain remarks...',
                                              hintStyle: const TextStyle(color: Colors.white24, fontSize: 11),
                                              filled: true,
                                              fillColor: Colors.black.withValues(alpha: 0.3),
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(10),
                                                borderSide: BorderSide.none,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),

                                        // Stepper Rating Controls
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () => _updateRating(p.id, -0.5),
                                              child: Container(
                                                width: 28,
                                                height: 28,
                                                decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                                                child: const Center(child: Text('-', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 44,
                                              child: Center(
                                                child: Text(
                                                  p.rating.toStringAsFixed(1),
                                                  style: TextStyle(
                                                    color: p.rating >= 8.5
                                                        ? const Color(0xFF10B981)
                                                        : (p.rating >= 7.0 ? const Color(0xFF38BDF8) : Colors.amber),
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w900,
                                                    fontFamily: 'monospace',
                                                  ),
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () => _updateRating(p.id, 0.5),
                                              child: Container(
                                                width: 28,
                                                height: 28,
                                                decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                                                child: const Center(child: Text('+', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, int home, int away) {
    final total = math.max(1, home + away);
    final homePercent = ((home / total) * 100).round();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$home', style: const TextStyle(color: Color(0xFF00E676), fontSize: 12, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
            Text('$away', style: const TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 6,
            child: Row(
              children: [
                Expanded(
                  flex: homePercent,
                  child: Container(color: const Color(0xFF00E676)),
                ),
                Expanded(
                  flex: 100 - homePercent,
                  child: Container(color: Colors.blueGrey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
