import 'package:captain/features/tactical_board/domain/formation.dart';

class FormationSlot {
  const FormationSlot({
    required this.number,
    required this.x,
    required this.y,
    this.label,
  });

  final int number;
  final double x;
  final double y;
  final String? label;
}

const _formationSlots = <FormationType, List<FormationSlot>>{
  FormationType.f433: [
    FormationSlot(number: 1, x: 0.50, y: 0.92, label: 'GK'),
    FormationSlot(number: 2, x: 0.82, y: 0.72, label: 'RB'),
    FormationSlot(number: 3, x: 0.62, y: 0.75, label: 'CB'),
    FormationSlot(number: 4, x: 0.38, y: 0.75, label: 'CB'),
    FormationSlot(number: 5, x: 0.18, y: 0.72, label: 'LB'),
    FormationSlot(number: 6, x: 0.68, y: 0.55, label: 'CM'),
    FormationSlot(number: 7, x: 0.50, y: 0.52, label: 'CM'),
    FormationSlot(number: 8, x: 0.32, y: 0.55, label: 'CM'),
    FormationSlot(number: 9, x: 0.85, y: 0.25, label: 'RW'),
    FormationSlot(number: 10, x: 0.50, y: 0.18, label: 'ST'),
    FormationSlot(number: 11, x: 0.15, y: 0.25, label: 'LW'),
  ],
  FormationType.f4231: [
    FormationSlot(number: 1, x: 0.50, y: 0.92, label: 'GK'),
    FormationSlot(number: 2, x: 0.82, y: 0.72, label: 'RB'),
    FormationSlot(number: 3, x: 0.62, y: 0.75, label: 'CB'),
    FormationSlot(number: 4, x: 0.38, y: 0.75, label: 'CB'),
    FormationSlot(number: 5, x: 0.18, y: 0.72, label: 'LB'),
    FormationSlot(number: 6, x: 0.62, y: 0.58, label: 'CDM'),
    FormationSlot(number: 7, x: 0.38, y: 0.58, label: 'CDM'),
    FormationSlot(number: 8, x: 0.82, y: 0.38, label: 'RM'),
    FormationSlot(number: 9, x: 0.50, y: 0.38, label: 'CAM'),
    FormationSlot(number: 10, x: 0.18, y: 0.38, label: 'LM'),
    FormationSlot(number: 11, x: 0.50, y: 0.18, label: 'ST'),
  ],
  FormationType.f442: [
    FormationSlot(number: 1, x: 0.50, y: 0.92, label: 'GK'),
    FormationSlot(number: 2, x: 0.82, y: 0.72, label: 'RB'),
    FormationSlot(number: 3, x: 0.62, y: 0.75, label: 'CB'),
    FormationSlot(number: 4, x: 0.38, y: 0.75, label: 'CB'),
    FormationSlot(number: 5, x: 0.18, y: 0.72, label: 'LB'),
    FormationSlot(number: 6, x: 0.82, y: 0.48, label: 'RM'),
    FormationSlot(number: 7, x: 0.62, y: 0.52, label: 'CM'),
    FormationSlot(number: 8, x: 0.38, y: 0.52, label: 'CM'),
    FormationSlot(number: 9, x: 0.18, y: 0.48, label: 'LM'),
    FormationSlot(number: 10, x: 0.62, y: 0.22, label: 'ST'),
    FormationSlot(number: 11, x: 0.38, y: 0.22, label: 'ST'),
  ],
  FormationType.f352: [
    FormationSlot(number: 1, x: 0.50, y: 0.92, label: 'GK'),
    FormationSlot(number: 2, x: 0.72, y: 0.75, label: 'CB'),
    FormationSlot(number: 3, x: 0.50, y: 0.78, label: 'CB'),
    FormationSlot(number: 4, x: 0.28, y: 0.75, label: 'CB'),
    FormationSlot(number: 5, x: 0.88, y: 0.55, label: 'RWB'),
    FormationSlot(number: 6, x: 0.62, y: 0.52, label: 'CM'),
    FormationSlot(number: 7, x: 0.50, y: 0.48, label: 'CM'),
    FormationSlot(number: 8, x: 0.38, y: 0.52, label: 'CM'),
    FormationSlot(number: 9, x: 0.12, y: 0.55, label: 'LWB'),
    FormationSlot(number: 10, x: 0.62, y: 0.22, label: 'ST'),
    FormationSlot(number: 11, x: 0.38, y: 0.22, label: 'ST'),
  ],
  FormationType.f4141: [
    FormationSlot(number: 1, x: 0.50, y: 0.92, label: 'GK'),
    FormationSlot(number: 2, x: 0.82, y: 0.72, label: 'RB'),
    FormationSlot(number: 3, x: 0.62, y: 0.75, label: 'CB'),
    FormationSlot(number: 4, x: 0.38, y: 0.75, label: 'CB'),
    FormationSlot(number: 5, x: 0.18, y: 0.72, label: 'LB'),
    FormationSlot(number: 6, x: 0.50, y: 0.58, label: 'CDM'),
    FormationSlot(number: 7, x: 0.82, y: 0.42, label: 'RM'),
    FormationSlot(number: 8, x: 0.62, y: 0.45, label: 'CM'),
    FormationSlot(number: 9, x: 0.38, y: 0.45, label: 'CM'),
    FormationSlot(number: 10, x: 0.18, y: 0.42, label: 'LM'),
    FormationSlot(number: 11, x: 0.50, y: 0.18, label: 'ST'),
  ],
  FormationType.f343: [
    FormationSlot(number: 1, x: 0.50, y: 0.92, label: 'GK'),
    FormationSlot(number: 2, x: 0.72, y: 0.75, label: 'CB'),
    FormationSlot(number: 3, x: 0.50, y: 0.78, label: 'CB'),
    FormationSlot(number: 4, x: 0.28, y: 0.75, label: 'CB'),
    FormationSlot(number: 5, x: 0.82, y: 0.48, label: 'RM'),
    FormationSlot(number: 6, x: 0.62, y: 0.52, label: 'CM'),
    FormationSlot(number: 7, x: 0.38, y: 0.52, label: 'CM'),
    FormationSlot(number: 8, x: 0.18, y: 0.48, label: 'LM'),
    FormationSlot(number: 9, x: 0.82, y: 0.22, label: 'RW'),
    FormationSlot(number: 10, x: 0.50, y: 0.18, label: 'ST'),
    FormationSlot(number: 11, x: 0.18, y: 0.22, label: 'LW'),
  ],
};

List<FormationSlot> formationSlotsFor(FormationType type) {
  return _formationSlots[type] ?? _formationSlots[FormationType.f433]!;
}
