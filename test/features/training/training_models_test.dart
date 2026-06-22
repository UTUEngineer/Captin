import 'package:captain/features/training/data/drill_templates.dart';
import 'package:captain/features/training/domain/drill_path_style.dart';
import 'package:captain/features/training/domain/training_prop.dart';
import 'package:captain/features/training/domain/training_prop_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('DrillTemplates includes 8 built-in drills', () {
    expect(DrillTemplates.all.length, 8);
    expect(DrillTemplates.all.first.name, contains('تمرين'));
  });

  test('TrainingProp serializes type and position', () {
    const prop = TrainingProp(
      id: 'p1',
      type: TrainingPropType.cone,
      x: 0.5,
      y: 0.5,
      rotation: 45,
      colorValue: 0xFFFF7043,
    );

    final restored = TrainingProp.fromJson(prop.toJson());
    expect(restored.type, TrainingPropType.cone);
    expect(restored.x, 0.5);
    expect(restored.rotation, 45);
  });

  test('DrillPathStyle wire names round-trip', () {
    for (final style in DrillPathStyle.values) {
      expect(DrillPathStyleJson.fromWire(style.wireName), style);
    }
  });
}
