import 'package:json_annotation/json_annotation.dart';

enum DrillPathStyle {
  run(
    label: 'Run',
    arabicLabel: 'جري',
  ),
  pass(
    label: 'Pass',
    arabicLabel: 'تمرير',
  ),
  shot(
    label: 'Shot',
    arabicLabel: 'تسديد',
  );

  const DrillPathStyle({
    required this.label,
    required this.arabicLabel,
  });

  final String label;
  final String arabicLabel;
}

extension DrillPathStyleJson on DrillPathStyle {
  String get wireName => name;

  static DrillPathStyle? fromWire(String value) {
    for (final style in DrillPathStyle.values) {
      if (style.name == value) return style;
    }
    return null;
  }
}

class DrillPathStyleConverter implements JsonConverter<DrillPathStyle, String> {
  const DrillPathStyleConverter();

  @override
  DrillPathStyle fromJson(String json) {
    return DrillPathStyleJson.fromWire(json) ?? DrillPathStyle.run;
  }

  @override
  String toJson(DrillPathStyle object) => object.wireName;
}
