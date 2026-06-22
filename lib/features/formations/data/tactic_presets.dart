import 'package:captain/core/theme/app_colors.dart';
import 'package:captain/features/formations/domain/tactic_board_template.dart';
import 'package:captain/features/tactical_board/domain/arrow.dart';
import 'package:captain/features/tactical_board/domain/formation.dart';
import 'package:captain/features/tactical_board/domain/formation_presets.dart';
import 'package:captain/features/tactical_board/domain/player.dart';
import 'package:captain/features/tactical_board/domain/zone.dart';
import 'package:flutter/material.dart';

abstract final class TacticPresets {
  static final List<TacticBoardTemplate> all = [
    _highPress433,
    _midBlock541,
    _diamond442,
    _buildUp4231,
    _wide343,
  ];
}

TacticBoardTemplate _buildPreset({
  required String id,
  required String name,
  required String description,
  required FormationType formation,
  required List<Arrow> arrows,
  List<Zone> zones = const [],
}) {
  final slots = formationSlotsFor(formation);
  final homePlayers = slots.asMap().entries.map((entry) {
    final slot = entry.value;
    return Player(
      id: 'preset-$id-home-${entry.key}',
      number: slot.number,
      x: slot.x,
      y: slot.y,
      label: slot.label,
      isHomeTeam: true,
    );
  }).toList();

  final awayPlayers = slots.asMap().entries.map((entry) {
    final slot = entry.value;
    return Player(
      id: 'preset-$id-away-${entry.key}',
      number: slot.number,
      x: slot.x,
      y: 1 - slot.y,
      label: slot.label,
      isHomeTeam: false,
    );
  }).toList();

  return TacticBoardTemplate(
    id: id,
    name: name,
    description: description,
    updatedAt: DateTime(2026, 1, 1),
    isPreset: true,
    formation: formation,
    players: [...homePlayers, ...awayPlayers],
    arrows: arrows,
    zones: zones,
  );
}

final _highPress433 = _buildPreset(
  id: 'preset-433-press',
  name: '4-3-3 High Press',
  description: 'Aggressive high press with wide forwards cutting passing lanes.',
  formation: FormationType.f433,
  arrows: [
    Arrow(
      id: 'preset-433-press-arrow-1',
      startX: 0.5,
      startY: 0.35,
      endX: 0.5,
      endY: 0.18,
      type: ArrowType.press,
      colorValue: AppColors.accentRed.toARGB32(),
    ),
    Arrow(
      id: 'preset-433-press-arrow-2',
      startX: 0.15,
      startY: 0.28,
      endX: 0.35,
      endY: 0.42,
      type: ArrowType.run,
      colorValue: AppColors.textPrimary.toARGB32(),
    ),
  ],
  zones: [
    Zone(
      id: 'preset-433-press-zone',
      x: 0.18,
      y: 0.12,
      width: 0.64,
      height: 0.28,
      colorValue: AppColors.accentRed.toARGB32(),
    ),
  ],
);

final _midBlock541 = _buildPreset(
  id: 'preset-541-block',
  name: '5-4-1 Mid Block',
  description: 'Compact mid block with a low defensive line and counter lane.',
  formation: FormationType.f352,
  arrows: [
    Arrow(
      id: 'preset-541-block-arrow-1',
      startX: 0.5,
      startY: 0.55,
      endX: 0.5,
      endY: 0.72,
      type: ArrowType.press,
      colorValue: AppColors.accentRed.toARGB32(),
    ),
  ],
  zones: [
    Zone(
      id: 'preset-541-block-zone',
      x: 0.12,
      y: 0.48,
      width: 0.76,
      height: 0.28,
      colorValue: const Color(0xFF42A5F5).toARGB32(),
    ),
  ],
);

final _diamond442 = _buildPreset(
  id: 'preset-442-diamond',
  name: '4-4-2 Diamond',
  description: 'Narrow midfield diamond with overlapping fullbacks.',
  formation: FormationType.f442,
  arrows: [
    Arrow(
      id: 'preset-442-diamond-arrow-1',
      startX: 0.18,
      startY: 0.48,
      endX: 0.18,
      endY: 0.28,
      type: ArrowType.run,
      colorValue: AppColors.textPrimary.toARGB32(),
    ),
    Arrow(
      id: 'preset-442-diamond-arrow-2',
      startX: 0.62,
      startY: 0.52,
      endX: 0.5,
      endY: 0.22,
      type: ArrowType.pass,
      colorValue: AppColors.textPrimary.toARGB32(),
    ),
  ],
);

final _buildUp4231 = _buildPreset(
  id: 'preset-4231-build',
  name: '4-2-3-1 Build-up',
  description: 'Controlled build-up through double pivot and advanced 10.',
  formation: FormationType.f4231,
  arrows: [
    Arrow(
      id: 'preset-4231-build-arrow-1',
      startX: 0.38,
      startY: 0.58,
      endX: 0.5,
      endY: 0.38,
      type: ArrowType.pass,
      colorValue: AppColors.textPrimary.toARGB32(),
    ),
  ],
);

final _wide343 = _buildPreset(
  id: 'preset-343-wide',
  name: '3-4-3 Wide Overload',
  description: 'Wide rotations with wingbacks joining the final third.',
  formation: FormationType.f343,
  arrows: [
    Arrow(
      id: 'preset-343-wide-arrow-1',
      startX: 0.18,
      startY: 0.48,
      endX: 0.18,
      endY: 0.22,
      type: ArrowType.curvedRun,
      curved: true,
      colorValue: AppColors.accentOrange.toARGB32(),
    ),
  ],
);
