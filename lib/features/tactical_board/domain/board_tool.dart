import 'package:captain/features/tactical_board/domain/arrow.dart';
import 'package:flutter/material.dart';

enum BoardTool {
  select,
  passArrow,
  runArrow,
  dribbleArrow,
  shotArrow,
  pressArrow,
  curvedRun,
  line,
  zone,
  freeZone,
  circle,
  ball,
  textNote,
  eraser,
}

extension BoardToolX on BoardTool {
  bool get isSelect => this == BoardTool.select;

  bool get isArrowTool => arrowType != null;

  ArrowType? get arrowType => switch (this) {
        BoardTool.passArrow => ArrowType.pass,
        BoardTool.runArrow => ArrowType.run,
        BoardTool.dribbleArrow => ArrowType.dribble,
        BoardTool.shotArrow => ArrowType.shot,
        BoardTool.pressArrow => ArrowType.press,
        BoardTool.curvedRun => ArrowType.curvedRun,
        BoardTool.line => ArrowType.line,
        _ => null,
      };

  bool get isDragDrawTool =>
      isArrowTool ||
      this == BoardTool.zone ||
      this == BoardTool.freeZone ||
      this == BoardTool.circle;

  bool get isTapTool =>
      this == BoardTool.textNote ||
      this == BoardTool.eraser ||
      this == BoardTool.ball;

  bool get usesZoneColor =>
      this == BoardTool.zone ||
      this == BoardTool.freeZone ||
      this == BoardTool.circle;

  IconData get icon => switch (this) {
        BoardTool.select => Icons.near_me_outlined,
        BoardTool.passArrow => Icons.arrow_forward_rounded,
        BoardTool.runArrow => Icons.directions_run_rounded,
        BoardTool.dribbleArrow => Icons.gesture_rounded,
        BoardTool.shotArrow => Icons.sports_soccer_rounded,
        BoardTool.pressArrow => Icons.keyboard_double_arrow_up_rounded,
        BoardTool.curvedRun => Icons.turn_slight_right_rounded,
        BoardTool.line => Icons.horizontal_rule_rounded,
        BoardTool.zone => Icons.crop_square_rounded,
        BoardTool.freeZone => Icons.draw_outlined,
        BoardTool.circle => Icons.circle_outlined,
        BoardTool.ball => Icons.sports_soccer_outlined,
        BoardTool.textNote => Icons.text_fields_rounded,
        BoardTool.eraser => Icons.auto_fix_off_outlined,
      };

  String label({required bool arabic}) => switch (this) {
        BoardTool.select => arabic ? 'تحديد' : 'Select',
        BoardTool.passArrow => arabic ? 'تمريرة' : 'Pass',
        BoardTool.runArrow => arabic ? 'جري' : 'Run',
        BoardTool.dribbleArrow => arabic ? 'مراوغة' : 'Dribble',
        BoardTool.shotArrow => arabic ? 'تسديدة' : 'Shot',
        BoardTool.pressArrow => arabic ? 'ضغط' : 'Press',
        BoardTool.curvedRun => arabic ? 'منحنى' : 'Curve',
        BoardTool.line => arabic ? 'خط' : 'Line',
        BoardTool.zone => arabic ? 'منطقة' : 'Zone',
        BoardTool.freeZone => arabic ? 'منطقة حرة' : 'Free zone',
        BoardTool.circle => arabic ? 'دائرة' : 'Circle',
        BoardTool.ball => arabic ? 'الكرة' : 'Ball',
        BoardTool.textNote => arabic ? 'نص' : 'Text',
        BoardTool.eraser => arabic ? 'ممحاة' : 'Eraser',
      };
}
