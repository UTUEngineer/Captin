import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/router/app_router.dart';
import '../services/match_events_service.dart';

/// Match Player Model
class MatchPlayer {
  final String id;
  final int number;
  final String name;
  final String role;
  final int yellowCards;
  final bool redCard;

  MatchPlayer({
    required this.id,
    required this.number,
    required this.name,
    required this.role,
    this.yellowCards = 0,
    this.redCard = false,
  });

  MatchPlayer copyWith({
    String? id,
    int? number,
    String? name,
    String? role,
    int? yellowCards,
    bool? redCard,
  }) {
    return MatchPlayer(
      id: id ?? this.id,
      number: number ?? this.number,
      name: name ?? this.name,
      role: role ?? this.role,
      yellowCards: yellowCards ?? this.yellowCards,
      redCard: redCard ?? this.redCard,
    );
  }
}

/// Local Incident Display Model
class MatchEventItem {
  final String id;
  final int minute;
  final String type; // 'goal' | 'yellow_card' | 'red_card' | 'sub'
  final String player;
  final String? detail;

  MatchEventItem({
    required this.id,
    required this.minute,
    required this.type,
    required this.player,
    this.detail,
  });
}

/// Live In-Match Captain Dashboard Screen Component
class LiveMatchDashboardScreen extends ConsumerStatefulWidget {
  final String? shiftId;
  final List<MatchPlayer>? initialStarters;
  final List<MatchPlayer>? initialBench;

  const LiveMatchDashboardScreen({
    super.key,
    this.shiftId,
    this.initialStarters,
    this.initialBench,
  });

  @override
  ConsumerState<LiveMatchDashboardScreen> createState() => _LiveMatchDashboardScreenState();
}

class _LiveMatchDashboardScreenState extends ConsumerState<LiveMatchDashboardScreen> {
  // Match Clock State
  int _secondsElapsed = 0;
  bool _isRunning = true;
  String _half = '1st Half'; // '1st Half' | 'HT' | '2nd Half' | 'FT'
  Timer? _clockTimer;

  // Score State
  int _scoreHome = 0;
  int _scoreAway = 0;

  // Roster State
  late List<MatchPlayer> _pitchPlayers;
  late List<MatchPlayer> _benchPlayers;

  // Incidents Timeline State
  final List<MatchEventItem> _events = [];

  // Selection & Modal States
  MatchPlayer? _selectedPitchPlayer;
  MatchPlayer? _selectedSubPlayer;
  MatchPlayer? _cardModalPlayer;

  @override
  void initState() {
    super.initState();

    _pitchPlayers = widget.initialStarters ??
        [
          MatchPlayer(id: 'p1', number: 1, name: 'H. Jassim', role: 'GK'),
          MatchPlayer(id: 'p2', number: 2, name: 'M. Kareem', role: 'RB'),
          MatchPlayer(id: 'p3', number: 4, name: 'Z. Tahseen', role: 'CB', yellowCards: 1),
          MatchPlayer(id: 'p4', number: 5, name: 'S. Natiq', role: 'CB'),
          MatchPlayer(id: 'p5', number: 3, name: 'A. Adnan', role: 'LB'),
          MatchPlayer(id: 'p6', number: 8, name: 'I. Bayesh', role: 'CM'),
          MatchPlayer(id: 'p7', number: 6, name: 'O. Rashid', role: 'CDM'),
          MatchPlayer(id: 'p8', number: 10, name: 'A. Saadoon', role: 'CAM'),
          MatchPlayer(id: 'p9', number: 7, name: 'Y. Amyn', role: 'RW'),
          MatchPlayer(id: 'p10', number: 9, name: 'A. Hussein', role: 'ST'),
          MatchPlayer(id: 'p11', number: 11, name: 'A. Jasim', role: 'LW'),
        ];

    _benchPlayers = widget.initialBench ??
        [
          MatchPlayer(id: 's1', number: 12, name: 'J. Talib', role: 'GK'),
          MatchPlayer(id: 's2', number: 14, name: 'Z. Hashim', role: 'CB'),
          MatchPlayer(id: 's3', number: 15, name: 'D. Ismail', role: 'LB'),
          MatchPlayer(id: 's4', number: 17, name: 'B. Rasan', role: 'CM'),
          MatchPlayer(id: 's5', number: 19, name: 'M. Dawood', role: 'ST'),
        ];

    _startClock();
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  void _startClock() {
    _clockTimer?.cancel();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isRunning && _half != 'HT' && _half != 'FT') {
        if (mounted) {
          setState(() {
            _secondsElapsed += 1;
          });
        }
      }
    });
  }

  int get _currentMinute => (math.min(90, (_secondsElapsed ~/ 60) + 1));

  String get _formattedTimer {
    final mins = (_secondsElapsed ~/ 60).toString().padLeft(2, '0');
    final secs = (_secondsElapsed % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  // Incident Logging Helper & Supabase Sync
  Future<void> _logIncident(
    String type,
    MatchPlayer player, [
    String? detail,
  ]) async {
    final item = MatchEventItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      minute: _currentMinute,
      type: type,
      player: '#${player.number} ${player.name}',
      detail: detail,
    );

    setState(() {
      _events.insert(0, item);
    });

    if (widget.shiftId != null && widget.shiftId!.isNotEmpty) {
      final service = ref.read(matchEventsServiceProvider);
      await service.logIncident(
        shiftId: widget.shiftId,
        minute: _currentMinute,
        eventType: type == 'sub' ? 'substitution' : type,
        playerId: player.id,
        playerName: player.name,
        playerNumber: player.number,
        detail: detail,
      );
    }
  }

  // Goal Handler
  void _handleScoreGoal(MatchPlayer player) {
    HapticFeedback.heavyImpact();
    SystemSound.play(SystemSoundType.click);

    setState(() {
      _scoreHome += 1;
    });

    _logIncident('goal', player, 'Goal Scored');
  }

  // Disciplinary Handlers
  void _handleAssignYellow(MatchPlayer player) {
    HapticFeedback.mediumImpact();
    final updatedYellows = player.yellowCards + 1;
    final isNowRed = updatedYellows >= 2;

    setState(() {
      _pitchPlayers = _pitchPlayers.map((p) {
        if (p.id == player.id) {
          return p.copyWith(yellowCards: updatedYellows, redCard: isNowRed);
        }
        return p;
      }).toList();
      _cardModalPlayer = null;
    });

    _logIncident('yellow_card', player, isNowRed ? 'Second yellow -> Sent off' : 'Tactical foul');
    if (isNowRed) {
      _logIncident('red_card', player, 'Red Card (Double Yellow)');
    }
  }

  void _handleAssignStraightRed(MatchPlayer player) {
    HapticFeedback.heavyImpact();
    setState(() {
      _pitchPlayers = _pitchPlayers.map((p) {
        if (p.id == player.id) {
          return p.copyWith(redCard: true);
        }
        return p;
      }).toList();
      _cardModalPlayer = null;
    });

    _logIncident('red_card', player, 'Straight Red Card');
  }

  // Quick-Sub Execution Handler
  void _executeSubstitution() {
    if (_selectedPitchPlayer == null || _selectedSubPlayer == null) return;

    final offPlayer = _selectedPitchPlayer!;
    final onPlayer = _selectedSubPlayer!;

    HapticFeedback.heavyImpact();

    setState(() {
      _pitchPlayers = _pitchPlayers.map((p) => p.id == offPlayer.id ? onPlayer : p).toList();
      _benchPlayers = _benchPlayers.map((p) => p.id == onPlayer.id ? offPlayer : p).toList();

      _selectedPitchPlayer = null;
      _selectedSubPlayer = null;
    });

    _logIncident('sub', onPlayer, 'IN for #${offPlayer.number} ${offPlayer.name}');
  }

  @override
  Widget build(BuildContext context) {
    final activeOnPitchCount = _pitchPlayers.where((p) => !p.redCard).length;

    return Scaffold(
      backgroundColor: const Color(0xFF06101E),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header Bar: Match Clock & Live Scoreboard
            Container(
              height: 72,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF0A192F).withValues(alpha: 0.9),
                border: Border(bottom: BorderSide(color: const Color(0xFF00E676).withValues(alpha: 0.2))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Timer & Period Indicator
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isRunning ? const Color(0xFF00E676) : Colors.amberAccent,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _half,
                        style: const TextStyle(
                          color: Color(0xFF00E676),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Text(
                          _formattedTimer,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          setState(() => _isRunning = !_isRunning);
                        },
                        icon: Icon(
                          _isRunning ? Icons.pause_circle : Icons.play_circle,
                          color: Colors.white70,
                          size: 26,
                        ),
                      ),
                    ],
                  ),

                  // Central Scoreboard
                  Row(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          Text('AZ-ZAWR\'A SC', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 13, fontWeight: FontWeight.w900)),
                          Text('HOME', style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.4)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00E676).withValues(alpha: 0.2),
                              blurRadius: 16,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Text('$_scoreHome', style: const TextStyle(color: Color(0xFF00E676), fontSize: 24, fontWeight: FontWeight.w900)),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text('-', style: TextStyle(color: Colors.white38, fontSize: 18)),
                            ),
                            Text('$_scoreAway', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('AL-QUWA AL-JAWIYA', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900)),
                          Text('AWAY', style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),

                  // Period Switcher Buttons
                  Row(
                    children: [
                      ...['1st Half', 'HT', '2nd Half', 'FT'].map((period) {
                        final bool isSelected = _half == period;
                        return Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _half = period);
                              if (period == 'FT') {
                                context.go(AppRoutes.postMatchReport);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF00E676).withValues(alpha: 0.25)
                                    : const Color(0xFF0F243E),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF00E676) : Colors.white12,
                                ),
                              ),
                              child: Text(
                                period,
                                style: TextStyle(
                                  color: isSelected ? const Color(0xFF00E676) : Colors.white60,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          context.go(AppRoutes.postMatchReport);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF38BDF8),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 4,
                        ),
                        icon: const Icon(Icons.assessment_rounded, size: 14),
                        label: const Text(
                          'REVIEW REPORT',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 2. Main Dashboard Layout (Active Pitch XI & Bench/Incidents Sidebar)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Left Section: Active Pitch XI Grid
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B1C33).withValues(alpha: 0.7),
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
                                    Text(
                                      'ACTIVE PITCH XI',
                                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900),
                                    ),
                                    Text(
                                      'Tap player card to log Goal, Card, or select for Sub',
                                      style: TextStyle(color: Colors.white54, fontSize: 11),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00E676).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: const Color(0xFF00E676)),
                                  ),
                                  child: Text(
                                    '$activeOnPitchCount On Pitch',
                                    style: const TextStyle(
                                      color: Color(0xFF00E676),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Pitch Squad Grid (11 Starters)
                            Expanded(
                              child: GridView.builder(
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  childAspectRatio: 1.9,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                                itemCount: _pitchPlayers.length,
                                itemBuilder: (context, index) {
                                  final player = _pitchPlayers[index];
                                  final isSelected = _selectedPitchPlayer?.id == player.id;

                                  return Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: player.redCard
                                          ? Colors.red.withValues(alpha: 0.15)
                                          : (isSelected
                                              ? const Color(0xFF00E676).withValues(alpha: 0.2)
                                              : const Color(0xFF0F243E)),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: player.redCard
                                            ? Colors.redAccent
                                            : (isSelected ? const Color(0xFF00E676) : Colors.white12),
                                        width: isSelected ? 1.5 : 1.0,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  width: 26,
                                                  height: 26,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: const Color(0xFF06101E),
                                                    border: Border.all(color: const Color(0xFF38BDF8)),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      '${player.number}',
                                                      style: const TextStyle(
                                                        color: Color(0xFF38BDF8),
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.w900,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      player.name,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      player.role,
                                                      style: const TextStyle(
                                                        color: Colors.white54,
                                                        fontSize: 9,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),

                                            // Card Chips
                                            Row(
                                              children: [
                                                if (player.yellowCards > 0)
                                                  Container(
                                                    width: 10,
                                                    height: 14,
                                                    margin: const EdgeInsets.only(right: 2),
                                                    decoration: BoxDecoration(
                                                      color: Colors.amber,
                                                      borderRadius: BorderRadius.circular(2),
                                                    ),
                                                  ),
                                                if (player.redCard)
                                                  Container(
                                                    width: 10,
                                                    height: 14,
                                                    decoration: BoxDecoration(
                                                      color: Colors.redAccent,
                                                      borderRadius: BorderRadius.circular(2),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),

                                        // Quick Action Buttons
                                        if (!player.redCard)
                                          Row(
                                            children: [
                                              Expanded(
                                                child: GestureDetector(
                                                  onTap: () => _handleScoreGoal(player),
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFF10B981).withValues(alpha: 0.2),
                                                      borderRadius: BorderRadius.circular(6),
                                                      border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                                                    ),
                                                    child: const Center(
                                                      child: Text(
                                                        'GOAL',
                                                        style: TextStyle(
                                                          color: Color(0xFF00E676),
                                                          fontSize: 9,
                                                          fontWeight: FontWeight.w900,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: GestureDetector(
                                                  onTap: () => setState(() => _cardModalPlayer = player),
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.amber.withValues(alpha: 0.2),
                                                      borderRadius: BorderRadius.circular(6),
                                                      border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                                                    ),
                                                    child: const Center(
                                                      child: Text(
                                                        'CARD',
                                                        style: TextStyle(
                                                          color: Colors.amber,
                                                          fontSize: 9,
                                                          fontWeight: FontWeight.w900,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: GestureDetector(
                                                  onTap: () {
                                                    HapticFeedback.selectionClick();
                                                    setState(() {
                                                      _selectedPitchPlayer = isSelected ? null : player;
                                                    });
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: isSelected
                                                          ? const Color(0xFF00E676)
                                                          : const Color(0xFF06101E),
                                                      borderRadius: BorderRadius.circular(6),
                                                      border: Border.all(
                                                        color: isSelected ? const Color(0xFF00E676) : Colors.white24,
                                                      ),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        'SUB',
                                                        style: TextStyle(
                                                          color: isSelected ? Colors.black : Colors.white70,
                                                          fontSize: 9,
                                                          fontWeight: FontWeight.w900,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
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

                            // Quick Sub Confirmation Bar
                            if (_selectedPitchPlayer != null)
                              Container(
                                margin: const EdgeInsets.only(top: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F243E),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFF00E676)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Subbing OFF: #${_selectedPitchPlayer!.number} ${_selectedPitchPlayer!.name}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        if (_selectedSubPlayer != null)
                                          Padding(
                                            padding: const EdgeInsets.only(right: 12),
                                            child: Text(
                                              'IN: #${_selectedSubPlayer!.number} ${_selectedSubPlayer!.name}',
                                              style: const TextStyle(
                                                color: Color(0xFF00E676),
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF00E676),
                                            foregroundColor: Colors.black,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                          onPressed: _selectedSubPlayer != null ? _executeSubstitution : null,
                                          child: const Text(
                                            'CONFIRM SUB',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Right Section: Bench & Match Incident Log Sidebar
                    SizedBox(
                      width: 320,
                      child: Column(
                        children: [
                          // Bench Substitutes Panel
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0B1C33).withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'BENCH SUBSTITUTES (${_benchPlayers.length})',
                                    style: const TextStyle(
                                      color: Color(0xFF00E676),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: _benchPlayers.length,
                                      itemBuilder: (context, index) {
                                        final sub = _benchPlayers[index];
                                        final isSubSelected = _selectedSubPlayer?.id == sub.id;

                                        return GestureDetector(
                                          onTap: () {
                                            HapticFeedback.selectionClick();
                                            setState(() {
                                              _selectedSubPlayer = isSubSelected ? null : sub;
                                            });
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.only(bottom: 6),
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: isSubSelected
                                                  ? const Color(0xFF00E676).withValues(alpha: 0.2)
                                                  : const Color(0xFF0F243E),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: isSubSelected ? const Color(0xFF00E676) : Colors.white12,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      width: 22,
                                                      height: 22,
                                                      decoration: const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Colors.black,
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          '${sub.number}',
                                                          style: const TextStyle(
                                                            color: Color(0xFF38BDF8),
                                                            fontSize: 10,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      sub.name,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white10,
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    sub.role,
                                                    style: const TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 9,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
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
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Match Incidents Log Panel
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0B1C33).withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'MATCH INCIDENT LOG (${_events.length})',
                                    style: const TextStyle(
                                      color: Color(0xFF00E676),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Expanded(
                                    child: _events.isEmpty
                                        ? const Center(
                                            child: Text(
                                              'No incidents logged yet',
                                              style: TextStyle(color: Colors.white38, fontSize: 11),
                                            ),
                                          )
                                        : ListView.builder(
                                            itemCount: _events.length,
                                            itemBuilder: (context, index) {
                                              final ev = _events[index];
                                              return Container(
                                                margin: const EdgeInsets.only(bottom: 6),
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF0F243E),
                                                  borderRadius: BorderRadius.circular(10),
                                                  border: Border.all(color: Colors.white12),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(
                                                          "${ev.minute}'",
                                                          style: const TextStyle(
                                                            color: Color(0xFF00E676),
                                                            fontWeight: FontWeight.w900,
                                                            fontSize: 11,
                                                          ),
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              ev.player,
                                                              style: const TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 11,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                            if (ev.detail != null)
                                                              Text(
                                                                ev.detail!,
                                                                style: const TextStyle(
                                                                  color: Colors.white54,
                                                                  fontSize: 9,
                                                                ),
                                                              ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    _buildEventBadge(ev.type),
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
          ],
        ),
      ),

      // 3. Disciplinary Modal Card (Yellow / Red Assignment)
      bottomSheet: _cardModalPlayer == null
          ? null
          : Container(
              color: Colors.black.withValues(alpha: 0.8),
              child: Center(
                child: Container(
                  width: 320,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C1F38),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.4), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00E676).withValues(alpha: 0.3),
                        blurRadius: 30,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'LOG DISCIPLINARY INCIDENT',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Target: #${_cardModalPlayer!.number} ${_cardModalPlayer!.name}',
                        style: const TextStyle(color: Color(0xFF00E676), fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber.withValues(alpha: 0.2),
                                foregroundColor: Colors.amber,
                                side: const BorderSide(color: Colors.amber),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: () => _handleAssignYellow(_cardModalPlayer!),
                              child: Column(
                                children: [
                                  Container(width: 14, height: 20, decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(2))),
                                  const SizedBox(height: 6),
                                  const Text('YELLOW CARD', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.withValues(alpha: 0.2),
                                foregroundColor: Colors.redAccent,
                                side: const BorderSide(color: Colors.redAccent),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: () => _handleAssignStraightRed(_cardModalPlayer!),
                              child: Column(
                                children: [
                                  Container(width: 14, height: 20, decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(2))),
                                  const SizedBox(height: 6),
                                  const Text('STRAIGHT RED', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => setState(() => _cardModalPlayer = null),
                        child: const Text('Cancel', style: TextStyle(color: Colors.white54, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildEventBadge(String type) {
    switch (type) {
      case 'goal':
        return const Text('⚽ GOAL', style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 10));
      case 'yellow_card':
        return const Text('🟨 YELLOW', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 10));
      case 'red_card':
        return const Text('🟥 RED', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 10));
      case 'sub':
        return const Text('🔄 SUB', style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 10));
      default:
        return const SizedBox.shrink();
    }
  }
}
