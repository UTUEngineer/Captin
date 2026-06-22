import 'package:captain/features/export/data/board_state_codec.dart';
import 'package:captain/features/formations/domain/tactic_board_template.dart';
import 'package:captain/features/tactical_board/domain/formation.dart';
import 'package:captain/features/tactical_board/domain/pitch_orientation.dart';
import 'package:captain/features/tactical_board/domain/pitch_style.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const codec = BoardStateCodec();

  final template = TacticBoardTemplate(
    id: 'test-board',
    name: '4-3-3 Press',
    updatedAt: DateTime(2026, 6, 20),
    formation: FormationType.f433,
    orientation: PitchOrientation.vertical,
    pitchStyle: PitchStyle.striped,
  );

  test('encodeShareLink produces captainapp deep link', () {
    final link = codec.encodeShareLink(template);

    expect(link.startsWith('captainapp://board/'), isTrue);
    expect(link.length, greaterThan('captainapp://board/'.length));
  });

  test('decodeShareLink round-trips board template', () {
    final link = codec.encodeShareLink(template);
    final decoded = codec.decodeShareLink(link);

    expect(decoded, isNotNull);
    expect(decoded!.id, template.id);
    expect(decoded.name, template.name);
    expect(decoded.formation, template.formation);
    expect(decoded.orientation, template.orientation);
    expect(decoded.pitchStyle, template.pitchStyle);
  });

  test('decodeShareLink returns null for invalid payload', () {
    expect(codec.decodeShareLink('captainapp://board/not-valid-base64'), isNull);
    expect(codec.decodeShareLink('https://example.com'), isNull);
  });
}
