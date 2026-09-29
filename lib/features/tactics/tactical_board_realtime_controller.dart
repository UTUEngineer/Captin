import 'package:supabase_flutter/supabase_flutter.dart';

/// التحكم في المزامنة البثية اللحظية (Supabase Realtime Broadcast & Presence)
/// للوحة التكتيكية وتتبع تحركات اللاعبين وتواجد المدربين والكابتن.
class TacticalBoardRealtimeController {
  final SupabaseClient _supabase = Supabase.instance.client;
  RealtimeChannel? _tacticalChannel;

  final String matchShiftId;
  final Function(Map<String, dynamic> playerMove) onPlayerMoved;
  final Function(List<String> activeUsers) onPresenceUpdated;

  TacticalBoardRealtimeController({
    required this.matchShiftId,
    required this.onPlayerMoved,
    required this.onPresenceUpdated,
  });

  /// 1. الاشتراك في القناة اللحظية للمباراة
  void connectToBoard({required String userName, required String role}) {
    // اسم قناة فريد لكل مباراة/شفت
    _tacticalChannel = _supabase.channel('tactics:$matchShiftId');

    // أ) الاستماع للتحركات والرسومات التكتيكية (Broadcast)
    _tacticalChannel!.onBroadcast(
      event: 'player_move',
      callback: (payload) {
        onPlayerMoved(payload);
      },
    );

    // ب) تتبع المتواجدين على اللوحة (Presence)
    _tacticalChannel!.onPresenceSync((_) {
      final presenceState = _tacticalChannel!.presenceState();
      final users = <String>[];

      for (final state in presenceState) {
        for (final presence in state.presences) {
          final payload = presence.payload;
          if (payload['user_name'] != null) {
            users.add('${payload['user_name']} (${payload['role']})');
          }
        }
      }
      onPresenceUpdated(users);
    });

    // ج) تفعيل الاشتراك وإرسال حالة التواجد
    _tacticalChannel!.subscribe((status, error) async {
      if (status == RealtimeSubscribeStatus.subscribed) {
        await _tacticalChannel!.track({
          'user_name': userName,
          'role': role, // 'Captain' | 'Coach'
          'online_at': DateTime.now().toIso8601String(),
        });
      }
    });
  }

  /// 2. إرسال تحريك لاعب أو تعديل موقع pin لجميع الأجهزة فوراً
  Future<void> broadcastPlayerMove({
    required String playerId,
    required double x,
    required double y,
  }) async {
    if (_tacticalChannel == null) return;

    await _tacticalChannel!.sendBroadcastMessage(
      event: 'player_move',
      payload: {
        'player_id': playerId,
        'x': x,
        'y': y,
        'sender_id': _supabase.auth.currentUser?.id,
      },
    );
  }

  /// 3. إغلاق الاتصال عند مغادرة الشاشة
  void disconnect() {
    if (_tacticalChannel != null) {
      _supabase.removeChannel(_tacticalChannel!);
      _tacticalChannel = null;
    }
  }
}
