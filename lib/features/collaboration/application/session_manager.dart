import 'package:captain/features/collaboration/domain/collaboration_session.dart';
import 'package:captain/features/collaboration/domain/session_code.dart';

class SessionManager {
  const SessionManager();

  CollaborationSession createSession({required String hostId}) {
    final code = generateSessionCode();
    return CollaborationSession(
      id: sessionIdFromCode(code),
      code: code,
      hostId: hostId,
    );
  }

  CollaborationSession sessionFromCode({
    required String code,
    required String hostId,
  }) {
    final normalized = normalizeSessionCode(code);
    return CollaborationSession(
      id: sessionIdFromCode(normalized),
      code: normalized,
      hostId: hostId,
    );
  }

  bool validateJoinCode(String code) => isValidSessionCode(code);
}
