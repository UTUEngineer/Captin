import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  /// الحصول على المستخدم الحالي
  User? get currentUser => _client.auth.currentUser;

  /// تسجيل الدخول بالبريد وكلمة المرور
  Future<AuthResponse> signIn({required String email, required String password}) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// إنشاء حساب جديد
  Future<AuthResponse> signUp({required String email, required String password}) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  /// تسجيل الخروج
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// الاستماع لتغير حالة الجلسة (Auto Login/Logout Listener)
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});
