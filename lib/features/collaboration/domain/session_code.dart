import 'dart:math';

const _sessionCodeChars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

String generateSessionCode({Random? random}) {
  final source = random ?? Random.secure();
  String segment(int length) {
    return List.generate(
      length,
      (_) => _sessionCodeChars[source.nextInt(_sessionCodeChars.length)],
    ).join();
  }

  return '${segment(3)}-${segment(3)}';
}

bool isValidSessionCode(String code) {
  final normalized = code.trim().toUpperCase();
  return RegExp(r'^[A-Z0-9]{3}-[A-Z0-9]{3}$').hasMatch(normalized);
}

String normalizeSessionCode(String code) => code.trim().toUpperCase();

String sessionIdFromCode(String code) =>
    normalizeSessionCode(code).replaceAll('-', '');
