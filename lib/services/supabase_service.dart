import 'package:captain/core/config/app_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseClient? get _safeClient {
    if (!AppConfig.isSupabaseConfigured) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  User? get currentUser => _safeClient?.auth.currentUser;

  // 1. إنشاء حساب جديد للكابتن (Sign Up)
  Future<AuthResponse?> signUpCoach({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final client = _safeClient;
    if (client == null) throw Exception("Supabase is not configured");
    return await client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
  }

  // 2. تسجيل الدخول (Sign In)
  Future<AuthResponse?> signInCoach({
    required String email,
    required String password,
  }) async {
    final client = _safeClient;
    if (client == null) throw Exception("Supabase is not configured");
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // 3. تسجيل الخروج (Sign Out)
  Future<void> signOut() async {
    await _safeClient?.auth.signOut();
  }

  // 4. جلب كافة خطط الكابتن المسجل الدخول
  Future<List<Map<String, dynamic>>> fetchCoachTacticalBoards() async {
    final client = _safeClient;
    if (client == null) return [];

    try {
      final userId = client.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await client
          .from('tactical_boards')
          .select()
          .eq('user_id', userId)
          .order('updated_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (_) {
      return [];
    }
  }

  // 5. حفظ أو تحديث خطة تكتيكية من تطبيق Flutter مباشرة
  Future<void> saveTacticalBoard({
    String? boardId,
    required String title,
    required String formation,
    List<Map<String, dynamic>>? players,
    Map<String, dynamic>? boardData,
    String pitchType = '2D',
  }) async {
    final client = _safeClient;
    if (client == null) throw Exception("Supabase is not configured");

    final userId = client.auth.currentUser?.id;
    if (userId == null) throw Exception('المستخدم غير مسجل الدخول');

    final dataToSave = boardData ?? {'players': players ?? []};

    final payload = {
      'user_id': userId,
      'title': title,
      'formation': formation,
      'pitch_type': pitchType,
      'board_data': dataToSave,
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (boardId != null && boardId.isNotEmpty) {
      await client.from('tactical_boards').update(payload).eq('id', boardId);
    } else {
      await client.from('tactical_boards').insert(payload);
    }
  }

  // 6. حفظ لوحة تكتيكية 3D سحابياً
  Future<void> save3DTacticalBoard({
    String? boardId,
    required String title,
    required String formation,
    required Map<String, dynamic> board3DStateJson,
  }) async {
    await saveTacticalBoard(
      boardId: boardId,
      title: title,
      formation: formation,
      boardData: board3DStateJson,
      pitchType: '3D',
    );
  }

  // 7. حذف تشكيلة تكتيكية
  Future<void> deleteTacticalBoard(String boardId) async {
    final client = _safeClient;
    if (client == null) throw Exception("Supabase is not configured");

    final userId = client.auth.currentUser?.id;
    if (userId == null) throw Exception('المستخدم غير مسجل الدخول');

    await client
        .from('tactical_boards')
        .delete()
        .eq('id', boardId)
        .eq('user_id', userId);
  }
}
