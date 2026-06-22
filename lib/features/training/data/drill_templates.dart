import 'package:captain/features/training/domain/drill_path.dart';
import 'package:captain/features/training/domain/drill_path_style.dart';
import 'package:captain/features/training/domain/drill_template.dart';
import 'package:captain/features/training/domain/training_prop.dart';
import 'package:captain/features/training/domain/training_prop_type.dart';

TrainingProp _prop(
  String id,
  TrainingPropType type,
  double x,
  double y, {
  double rotation = 0,
}) {
  return TrainingProp(
    id: id,
    type: type,
    x: x,
    y: y,
    rotation: rotation,
    colorValue: type.defaultColor.toARGB32(),
  );
}

DrillPath _path(
  String id,
  double sx,
  double sy,
  double ex,
  double ey,
  DrillPathStyle style,
) {
  return DrillPath(
    id: id,
    startX: sx,
    startY: sy,
    endX: ex,
    endY: ey,
    style: style,
    colorValue: 0xFF2E7D32,
  );
}

abstract final class DrillTemplates {
  static final all = <DrillTemplate>[
    DrillTemplate(
      id: 'press-high',
      name: 'تمرين الضغط العالي',
      description: 'ضغط جماعي على حامل الكرة مع مسارات جري',
      recommendedPlayers: 10,
      props: [
        _prop('p1', TrainingPropType.cone, 0.25, 0.55),
        _prop('p2', TrainingPropType.cone, 0.50, 0.55),
        _prop('p3', TrainingPropType.cone, 0.75, 0.55),
        _prop('p4', TrainingPropType.mannequin, 0.50, 0.35),
      ],
      paths: [
        _path('r1', 0.20, 0.70, 0.30, 0.50, DrillPathStyle.run),
        _path('r2', 0.80, 0.70, 0.70, 0.50, DrillPathStyle.run),
      ],
    ),
    DrillTemplate(
      id: 'build-up',
      name: 'تمرين البناء من الخلف',
      description: 'تمريرات متدرجة من الدفاع إلى الهجوم',
      recommendedPlayers: 8,
      props: [
        _prop('b1', TrainingPropType.disc, 0.35, 0.75),
        _prop('b2', TrainingPropType.disc, 0.50, 0.65),
        _prop('b3', TrainingPropType.disc, 0.65, 0.55),
        _prop('b4', TrainingPropType.cone, 0.50, 0.40),
      ],
      paths: [
        _path('b-p1', 0.35, 0.75, 0.50, 0.65, DrillPathStyle.pass),
        _path('b-p2', 0.50, 0.65, 0.65, 0.55, DrillPathStyle.pass),
        _path('b-p3', 0.65, 0.55, 0.50, 0.40, DrillPathStyle.pass),
      ],
    ),
    DrillTemplate(
      id: 'between-lines',
      name: 'تمرين التحرك بين الخطوط',
      description: 'تحرك اللاعبين بين خطوط الفريق المنافس',
      recommendedPlayers: 12,
      props: [
        _prop('l1', TrainingPropType.pole, 0.30, 0.50),
        _prop('l2', TrainingPropType.pole, 0.50, 0.50),
        _prop('l3', TrainingPropType.pole, 0.70, 0.50),
        _prop('l4', TrainingPropType.cone, 0.40, 0.30),
        _prop('l5', TrainingPropType.cone, 0.60, 0.30),
      ],
      paths: [
        _path('l-r1', 0.40, 0.70, 0.40, 0.30, DrillPathStyle.run),
        _path('l-r2', 0.60, 0.70, 0.60, 0.30, DrillPathStyle.run),
      ],
    ),
    DrillTemplate(
      id: 'set-pieces',
      name: 'تمرين الكرات الثابتة',
      description: 'تنظيم الركلات الركنية والركلات الحرة',
      recommendedPlayers: 11,
      props: [
        _prop('s1', TrainingPropType.ball, 0.85, 0.15),
        _prop('s2', TrainingPropType.cone, 0.70, 0.20),
        _prop('s3', TrainingPropType.cone, 0.78, 0.28),
        _prop('s4', TrainingPropType.smallGoal, 0.50, 0.08),
      ],
      paths: [
        _path('s-p1', 0.85, 0.15, 0.50, 0.12, DrillPathStyle.pass),
      ],
    ),
    DrillTemplate(
      id: 'dribbling',
      name: 'تمرين المراوغة',
      description: 'مسار مراوغة بين المخاريط',
      recommendedPlayers: 6,
      props: [
        _prop('d1', TrainingPropType.cone, 0.30, 0.60),
        _prop('d2', TrainingPropType.cone, 0.42, 0.48),
        _prop('d3', TrainingPropType.cone, 0.54, 0.60),
        _prop('d4', TrainingPropType.cone, 0.66, 0.48),
        _prop('d5', TrainingPropType.ball, 0.22, 0.72),
      ],
      paths: [
        _path('d-r1', 0.22, 0.72, 0.30, 0.60, DrillPathStyle.run),
        _path('d-r2', 0.30, 0.60, 0.42, 0.48, DrillPathStyle.run),
        _path('d-r3', 0.42, 0.48, 0.54, 0.60, DrillPathStyle.run),
        _path('d-r4', 0.54, 0.60, 0.66, 0.48, DrillPathStyle.run),
      ],
    ),
    DrillTemplate(
      id: 'rondo',
      name: 'تمرين التمريرات المتسلسلة',
      description: 'روندو 4 ضد 2 مع تمريرات سريعة',
      recommendedPlayers: 6,
      props: [
        _prop('r1', TrainingPropType.disc, 0.35, 0.50),
        _prop('r2', TrainingPropType.disc, 0.50, 0.42),
        _prop('r3', TrainingPropType.disc, 0.65, 0.50),
        _prop('r4', TrainingPropType.disc, 0.50, 0.58),
        _prop('r5', TrainingPropType.ball, 0.50, 0.50),
      ],
      paths: [
        _path('r-p1', 0.35, 0.50, 0.50, 0.42, DrillPathStyle.pass),
        _path('r-p2', 0.50, 0.42, 0.65, 0.50, DrillPathStyle.pass),
        _path('r-p3', 0.65, 0.50, 0.50, 0.58, DrillPathStyle.pass),
        _path('r-p4', 0.50, 0.58, 0.35, 0.50, DrillPathStyle.pass),
      ],
    ),
    DrillTemplate(
      id: 'finishing',
      name: 'تمرين التشطيب',
      description: 'تسديدات على المرمى من مواقع مختلفة',
      recommendedPlayers: 8,
      props: [
        _prop('f1', TrainingPropType.fullGoal, 0.50, 0.08),
        _prop('f2', TrainingPropType.ball, 0.35, 0.35),
        _prop('f3', TrainingPropType.ball, 0.50, 0.40),
        _prop('f4', TrainingPropType.ball, 0.65, 0.35),
        _prop('f5', TrainingPropType.cone, 0.50, 0.55),
      ],
      paths: [
        _path('f-s1', 0.35, 0.35, 0.50, 0.12, DrillPathStyle.shot),
        _path('f-s2', 0.50, 0.40, 0.50, 0.12, DrillPathStyle.shot),
        _path('f-s3', 0.65, 0.35, 0.50, 0.12, DrillPathStyle.shot),
      ],
    ),
    DrillTemplate(
      id: 'free-kicks',
      name: 'تمرين الضربات الحرة',
      description: 'ضربات حرة مع حائط ومرمى',
      recommendedPlayers: 7,
      props: [
        _prop('fk1', TrainingPropType.ball, 0.50, 0.45),
        _prop('fk2', TrainingPropType.mannequin, 0.42, 0.30),
        _prop('fk3', TrainingPropType.mannequin, 0.46, 0.30),
        _prop('fk4', TrainingPropType.mannequin, 0.54, 0.30),
        _prop('fk5', TrainingPropType.mannequin, 0.58, 0.30),
        _prop('fk6', TrainingPropType.fullGoal, 0.50, 0.08),
      ],
      paths: [
        _path('fk-s1', 0.50, 0.45, 0.50, 0.12, DrillPathStyle.shot),
      ],
    ),
  ];
}
