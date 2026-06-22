import 'package:flutter/material.dart';

enum TimelineEventType {
  goal(
    color: Color(0xFF66BB6A),
    icon: Icons.sports_soccer,
    arabicLabel: 'هدف',
  ),
  yellowCard(
    color: Color(0xFFFFEE58),
    icon: Icons.square,
    arabicLabel: 'بطاقة صفراء',
  ),
  redCard(
    color: Color(0xFFE53935),
    icon: Icons.square,
    arabicLabel: 'بطاقة حمراء',
  ),
  substitution(
    color: Color(0xFF42A5F5),
    icon: Icons.swap_horiz,
    arabicLabel: 'تبديل',
  ),
  tacticalChange(
    color: Color(0xFFAB47BC),
    icon: Icons.auto_graph_outlined,
    arabicLabel: 'تغيير تكتيكي',
  ),
  keyMoment(
    color: Color(0xFFFF7043),
    icon: Icons.star_outline,
    arabicLabel: 'لحظة مفتاحية',
  ),
  pressureMoment(
    color: Color(0xFF26C6DA),
    icon: Icons.speed,
    arabicLabel: 'لحظة ضغط',
  ),
  setpiece(
    color: Color(0xFF8D6E63),
    icon: Icons.flag_outlined,
    arabicLabel: 'كرة ثابتة',
  ),
  halfTime(
    color: Color(0xFF90A4AE),
    icon: Icons.pause_circle_outline,
    arabicLabel: 'استراحة',
  );

  const TimelineEventType({
    required this.color,
    required this.icon,
    required this.arabicLabel,
  });

  final Color color;
  final IconData icon;
  final String arabicLabel;
}

extension TimelineEventTypeJson on TimelineEventType {
  String get wireName => name;

  static TimelineEventType? fromWire(String value) {
    for (final type in TimelineEventType.values) {
      if (type.name == value) return type;
    }
    return null;
  }
}
