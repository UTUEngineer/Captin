import 'package:flutter/material.dart';

enum SimulationMode {
  defensiveBlock(
    icon: Icons.shield_outlined,
    arabicLabel: 'كتلة دفاعية',
  ),
  highPress(
    icon: Icons.speed_outlined,
    arabicLabel: 'ضغط عالي',
  ),
  possessionBuild(
    icon: Icons.hub_outlined,
    arabicLabel: 'بناء استحواذ',
  ),
  counterAttack(
    icon: Icons.bolt_outlined,
    arabicLabel: 'هجمة مرتدة',
  ),
  setPiece(
    icon: Icons.flag_outlined,
    arabicLabel: 'كرة ثابتة',
  );

  const SimulationMode({
    required this.icon,
    required this.arabicLabel,
  });

  final IconData icon;
  final String arabicLabel;
}
