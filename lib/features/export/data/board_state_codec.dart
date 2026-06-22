import 'dart:convert';

import 'package:captain/features/formations/domain/tactic_board_template.dart';

class BoardStateCodec {
  const BoardStateCodec();

  String encodeShareLink(TacticBoardTemplate template) {
    final json = jsonEncode(template.toJson());
    final encoded = base64Url.encode(utf8.encode(json));
    return 'captainapp://board/$encoded';
  }

  TacticBoardTemplate? decodeShareLink(String link) {
    final uri = Uri.tryParse(link.trim());
    if (uri == null) return null;

    String payload;
    if (uri.scheme == 'captainapp' && uri.host == 'board') {
      payload = uri.pathSegments.isNotEmpty
          ? uri.pathSegments.first
          : uri.path.replaceFirst('/', '');
    } else {
      payload = link.trim();
    }

    if (payload.isEmpty) return null;

    try {
      final normalized = base64Url.normalize(payload);
      final json =
          jsonDecode(utf8.decode(base64Url.decode(normalized))) as Map<String, dynamic>;
      return TacticBoardTemplate.fromJson(json);
    } catch (_) {
      return null;
    }
  }
}
