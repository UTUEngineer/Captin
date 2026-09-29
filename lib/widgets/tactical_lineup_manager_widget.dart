import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Player Slot in Tactical Roster
class PlayerSlot {
  final String id;
  final int number;
  final String name;
  final String role;
  final bool isCaptain;
  final double x; // Percentage on pitch width (0 - 100)
  final double y; // Percentage on pitch height (0 - 100)

  PlayerSlot({
    required this.id,
    required this.number,
    required this.name,
    required this.role,
    this.isCaptain = false,
    required this.x,
    required this.y,
  });

  PlayerSlot copyWith({
    String? id,
    int? number,
    String? name,
    String? role,
    bool? isCaptain,
    double? x,
    double? y,
  }) {
    return PlayerSlot(
      id: id ?? this.id,
      number: number ?? this.number,
      name: name ?? this.name,
      role: role ?? this.role,
      isCaptain: isCaptain ?? this.isCaptain,
      x: x ?? this.x,
      y: y ?? this.y,
    );
  }
}

/// Predefined Tactical Formations
class TacticalFormations {
  static List<PlayerSlot> getFormation(String name) {
    if (name == '4-2-3-1') {
      return [
        PlayerSlot(id: '1', number: 1, name: 'H. Jassim', role: 'GK', x: 50, y: 88),
        PlayerSlot(id: '2', number: 2, name: 'M. Kareem', role: 'RB', x: 82, y: 72),
        PlayerSlot(id: '3', number: 4, name: 'Z. Tahseen', role: 'CB', x: 62, y: 74),
        PlayerSlot(id: '4', number: 5, name: 'S. Natiq', role: 'CB', x: 38, y: 74),
        PlayerSlot(id: '5', number: 3, name: 'A. Adnan', role: 'LB', x: 18, y: 72),
        PlayerSlot(id: '6', number: 6, name: 'O. Rashid', role: 'CDM', x: 62, y: 56),
        PlayerSlot(id: '7', number: 16, name: 'A. Attwan', role: 'CDM', x: 38, y: 56),
        PlayerSlot(id: '8', number: 8, name: 'I. Bayesh', role: 'RM', x: 78, y: 38),
        PlayerSlot(id: '9', number: 10, name: 'A. Saadoon', role: 'CAM', isCaptain: true, x: 50, y: 36),
        PlayerSlot(id: '10', number: 11, name: 'A. Jasim', role: 'LM', x: 22, y: 38),
        PlayerSlot(id: '11', number: 9, name: 'A. Hussein', role: 'ST', x: 50, y: 16),
      ];
    }

    // Default 4-3-3
    return [
      PlayerSlot(id: '1', number: 1, name: 'H. Jassim', role: 'GK', x: 50, y: 88),
      PlayerSlot(id: '2', number: 2, name: 'M. Kareem', role: 'RB', x: 82, y: 70),
      PlayerSlot(id: '3', number: 4, name: 'Z. Tahseen', role: 'CB', x: 62, y: 72),
      PlayerSlot(id: '4', number: 5, name: 'S. Natiq', role: 'CB', x: 38, y: 72),
      PlayerSlot(id: '5', number: 3, name: 'A. Adnan', role: 'LB', x: 18, y: 70),
      PlayerSlot(id: '6', number: 8, name: 'I. Bayesh', role: 'CM', x: 68, y: 48),
      PlayerSlot(id: '7', number: 6, name: 'O. Rashid', role: 'CDM', x: 50, y: 56),
      PlayerSlot(id: '8', number: 10, name: 'A. Saadoon', role: 'CAM', isCaptain: true, x: 32, y: 48),
      PlayerSlot(id: '9', number: 7, name: 'Y. Amyn', role: 'RW', x: 80, y: 24),
      PlayerSlot(id: '10', number: 9, name: 'A. Hussein', role: 'ST', x: 50, y: 16),
      PlayerSlot(id: '11', number: 11, name: 'A. Jasim', role: 'LW', x: 20, y: 24),
    ];
  }
}

/// Tactical Lineup & Formation Board Component
class TacticalLineupManagerWidget extends StatefulWidget {
  final VoidCallback onConfirmRoster;
  final String captainName;
  final String captainTier;

  const TacticalLineupManagerWidget({
    super.key,
    required this.onConfirmRoster,
    this.captainName = 'Captain Tariq',
    this.captainTier = 'First Team',
  });

  @override
  State<TacticalLineupManagerWidget> createState() => _TacticalLineupManagerWidgetState();
}

class _TacticalLineupManagerWidgetState extends State<TacticalLineupManagerWidget> {
  String _formation = '4-3-3';
  String? _selectedPlayerId;
  late List<PlayerSlot> _roster;

  @override
  void initState() {
    super.initState();
    _roster = TacticalFormations.getFormation(_formation);
  }

  void _handleFormationChange(String fmt) {
    HapticFeedback.selectionClick();
    setState(() {
      _formation = fmt;
      _roster = TacticalFormations.getFormation(fmt);
      _selectedPlayerId = null;
    });
  }

  void _handlePlayerClick(String id) {
    HapticFeedback.selectionClick();
    if (_selectedPlayerId == null) {
      setState(() => _selectedPlayerId = id);
      return;
    }

    if (_selectedPlayerId == id) {
      setState(() => _selectedPlayerId = null);
      return;
    }

    // Swap positions and roles between the two selected players
    final idx1 = _roster.indexWhere((p) => p.id == _selectedPlayerId);
    final idx2 = _roster.indexWhere((p) => p.id == id);

    if (idx1 != -1 && idx2 != -1) {
      HapticFeedback.mediumImpact();
      final p1 = _roster[idx1];
      final p2 = _roster[idx2];

      setState(() {
        _roster[idx1] = p1.copyWith(x: p2.x, y: p2.y, role: p2.role);
        _roster[idx2] = p2.copyWith(x: p1.x, y: p1.y, role: p1.role);
        _selectedPlayerId = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        color: const Color(0xFF020617).withValues(alpha: 0.88),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 950, maxHeight: 720),
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF08172B),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.4), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E676).withValues(alpha: 0.25),
                    blurRadius: 40,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final bool isMobile = constraints.maxWidth < 650;
                  return Flex(
                    direction: isMobile ? Axis.vertical : Axis.horizontal,
                    children: [
                      // Left Side: 2D Interactive Pitch Board
                      Expanded(
                        flex: 3,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFF113822), Color(0xFF0C2918)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.5), width: 2),
                          ),
                          child: Stack(
                            children: [
                              // 2D Tactical Pitch Lines
                              CustomPaint(
                                size: Size.infinite,
                                painter: Pitch2DPainter(),
                              ),

                              // Interactive Squad Pins
                              ..._roster.map((player) {
                                final bool isSelected = _selectedPlayerId == player.id;
                                return Positioned(
                                  left: (player.x / 100.0) * (constraints.maxWidth * (isMobile ? 0.9 : 0.6)) - 24,
                                  top: (player.y / 100.0) * (constraints.maxHeight * (isMobile ? 0.5 : 0.85)) - 24,
                                  child: GestureDetector(
                                    onTap: () => _handlePlayerClick(player.id),
                                    child: AnimatedScale(
                                      scale: isSelected ? 1.25 : 1.0,
                                      duration: const Duration(milliseconds: 200),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              Container(
                                                width: 38,
                                                height: 38,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: player.isCaptain
                                                      ? const Color(0xFFFBBF24)
                                                      : (isSelected
                                                          ? const Color(0xFF00E676)
                                                          : const Color(0xFF0F2D4A)),
                                                  border: Border.all(
                                                    color: player.isCaptain
                                                        ? Colors.amberAccent
                                                        : (isSelected ? Colors.white : const Color(0xFF38BDF8)),
                                                    width: 2,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: player.isCaptain
                                                          ? Colors.amber.withValues(alpha: 0.8)
                                                          : (isSelected
                                                              ? const Color(0xFF00E676).withValues(alpha: 0.8)
                                                              : Colors.black45),
                                                      blurRadius: isSelected || player.isCaptain ? 14 : 4,
                                                    ),
                                                  ],
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    '${player.number}',
                                                    style: TextStyle(
                                                      color: player.isCaptain || isSelected
                                                          ? const Color(0xFF020617)
                                                          : const Color(0xFF38BDF8),
                                                      fontWeight: FontWeight.w900,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              if (player.isCaptain)
                                                Positioned(
                                                  top: -3,
                                                  right: -3,
                                                  child: Container(
                                                    width: 16,
                                                    height: 16,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.redAccent,
                                                      border: Border.all(color: Colors.white, width: 1.5),
                                                    ),
                                                    child: const Center(
                                                      child: Text(
                                                        'C',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 9,
                                                          fontWeight: FontWeight.w900,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 3),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withValues(alpha: 0.8),
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: Colors.white12),
                                            ),
                                            child: Text(
                                              '${player.name} • ${player.role}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 20, height: 20),

                      // Right Side: Controls & Confirmation
                      SizedBox(
                        width: isMobile ? double.infinity : 280,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${widget.captainName} • ${widget.captainTier}',
                                          style: const TextStyle(
                                            color: Color(0xFF00E676),
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                        const Text(
                                          'Starting XI Lineup',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.amber.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.amber),
                                      ),
                                      child: const Text(
                                        'Armband Active',
                                        style: TextStyle(
                                          color: Colors.amber,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // Formation Selection Grid
                                const Text(
                                  'SHAPE & FORMATION',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: ['4-3-3', '4-2-3-1'].map((fmt) {
                                    final bool isSelected = _formation == fmt;
                                    return Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                        child: GestureDetector(
                                          onTap: () => _handleFormationChange(fmt),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? const Color(0xFF00E676).withValues(alpha: 0.2)
                                                  : const Color(0xFF0F243E),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: isSelected ? const Color(0xFF00E676) : Colors.white12,
                                                width: 1.5,
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                fmt,
                                                style: TextStyle(
                                                  color: isSelected ? const Color(0xFF00E676) : Colors.white70,
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 20),

                                // Tactical Switch Guide Card
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0F243E).withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: Colors.white12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'Tactical Switch:',
                                        style: TextStyle(
                                          color: Color(0xFF00E676),
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Tap any two player pins on the pitch to swap their positions and tactical assignments.',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 11,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Confirm Button Action
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00E676),
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 8,
                                ),
                                onPressed: () {
                                  HapticFeedback.heavyImpact();
                                  widget.onConfirmRoster();
                                },
                                child: const Text(
                                  'CONFIRM LINEUP & KICK OFF',
                                  style: TextStyle(
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
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom 2D Tactical Pitch Painter for Markings
class Pitch2DPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFF10B981).withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Pitch Perimeter Boundary
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(12, 12, size.width - 24, size.height - 24),
        const Radius.circular(8),
      ),
      linePaint,
    );

    // Halfway Line
    final halfY = size.height / 2;
    canvas.drawLine(Offset(12, halfY), Offset(size.width - 12, halfY), linePaint);

    // Center Circle
    canvas.drawCircle(Offset(size.width / 2, halfY), size.width * 0.18, linePaint);
    canvas.drawCircle(Offset(size.width / 2, halfY), 3, linePaint);

    // Penalty Boxes (Top & Bottom)
    final boxWidth = size.width * 0.55;
    final boxHeight = size.height * 0.18;

    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.width / 2, 12 + boxHeight / 2),
        width: boxWidth,
        height: boxHeight,
      ),
      linePaint,
    );

    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height - 12 - boxHeight / 2),
        width: boxWidth,
        height: boxHeight,
      ),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
