import 'package:flutter/material.dart';

enum TrainingPropType {
  cone(
    icon: Icons.change_history,
    label: 'Cone',
    arabicLabel: 'مخروط',
    defaultColor: Color(0xFFFF7043),
  ),
  ball(
    icon: Icons.sports_soccer,
    label: 'Ball',
    arabicLabel: 'كرة',
    defaultColor: Colors.white,
  ),
  smallGoal(
    icon: Icons.crop_landscape,
    label: 'Small goal',
    arabicLabel: 'مرمى صغير',
    defaultColor: Colors.white,
  ),
  fullGoal(
    icon: Icons.crop_16_9,
    label: 'Full goal',
    arabicLabel: 'مرمى كامل',
    defaultColor: Colors.white,
  ),
  mannequin(
    icon: Icons.accessibility_new,
    label: 'Mannequin',
    arabicLabel: 'دمية',
    defaultColor: Color(0xFFFFEE58),
  ),
  pole(
    icon: Icons.vertical_align_top,
    label: 'Pole',
    arabicLabel: 'عمود',
    defaultColor: Color(0xFF42A5F5),
  ),
  ladder(
    icon: Icons.deck_outlined,
    label: 'Ladder',
    arabicLabel: 'سلم',
    defaultColor: Color(0xFFFFEE58),
  ),
  hurdle(
    icon: Icons.architecture_outlined,
    label: 'Hurdle',
    arabicLabel: 'حاجز',
    defaultColor: Color(0xFFAB47BC),
  ),
  disc(
    icon: Icons.circle,
    label: 'Disc',
    arabicLabel: 'قرص',
    defaultColor: Color(0xFF66BB6A),
  );

  const TrainingPropType({
    required this.icon,
    required this.label,
    required this.arabicLabel,
    required this.defaultColor,
  });

  final IconData icon;
  final String label;
  final String arabicLabel;
  final Color defaultColor;
}

extension TrainingPropTypeJson on TrainingPropType {
  String get wireName => name;

  static TrainingPropType? fromWire(String value) {
    for (final type in TrainingPropType.values) {
      if (type.name == value) return type;
    }
    return null;
  }
}
