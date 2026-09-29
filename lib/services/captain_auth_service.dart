import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/app_config.dart';
import '../core/supabase_client.dart';

/// Telemetry structure captured when 3D Goal Sensor triggers
class KickTelemetry {
  final double speed;
  final double powerPercent;
  final double curlSpin;

  KickTelemetry({
    required this.speed,
    required this.powerPercent,
    required this.curlSpin,
  });

  Map<String, dynamic> toJson() => {
        'speed': speed,
        'powerPercent': powerPercent,
        'curlSpin': curlSpin,
      };
}

/// Result returned from Captain Auth verification
class CaptainAuthResult {
  final Session? session;
  final Map<String, dynamic> captain;
  final Map<String, dynamic> activeShift;

  CaptainAuthResult({
    this.session,
    required this.captain,
    required this.activeShift,
  });

  bool get success => captain.isNotEmpty || session != null;
  String get captainName => (captain['full_name'] as String?) ?? 'Captain Tariq';
  String get armbandTier => (activeShift['tier'] as String?) ?? 'First Team';

  factory CaptainAuthResult.fromJson(Map<String, dynamic> json) {
    return CaptainAuthResult(
      captain: json['captain'] as Map<String, dynamic>? ?? {},
      activeShift: json['activeShift'] as Map<String, dynamic>? ?? {},
    );
  }
}

class CaptainAuthService {
  final SupabaseClient _supabase;

  CaptainAuthService(this._supabase);

  /// Send Phone SMS verification OTP to captain
  Future<bool> requestOtp(String phone) async {
    try {
      await _supabase.auth.signInWithOtp(phone: phone);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Called when 3D Goal Sensor triggers to verify OTP + physics shot telemetry via Edge Function
  Future<CaptainAuthResult?> finalizeKickoff({
    required String phone,
    required String otpCode,
    required String tier,
    required KickTelemetry telemetry,
  }) async {
    final baseUrl = AppConfig.supabaseUrl.isNotEmpty
        ? AppConfig.supabaseUrl
        : 'https://YOUR_PROJECT_ID.supabase.co';
    final anonKey = AppConfig.supabaseAnonKey.isNotEmpty
        ? AppConfig.supabaseAnonKey
        : 'YOUR_ANON_KEY';

    final uri = Uri.parse('$baseUrl/functions/v1/verify-captain-kickoff');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'apikey': anonKey,
      },
      body: jsonEncode({
        'phone': phone,
        'otpToken': otpCode,
        'tier': tier,
        'telemetry': telemetry.toJson(),
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      
      // Persist session tokens into local Supabase client if available
      final sessionRaw = data['session'] as Map<String, dynamic>?;
      if (sessionRaw != null && sessionRaw['access_token'] != null) {
        await _supabase.auth.setSession(sessionRaw['access_token']);
      }

      return CaptainAuthResult.fromJson(data);
    } else {
      final err = jsonDecode(response.body);
      throw Exception(err['error'] ?? 'Kick-off verification failed (${response.statusCode})');
    }
  }

  /// Called to verify 4-digit Captain PIN fallback + physics shot telemetry via Edge Function
  Future<CaptainAuthResult?> verifyPinKickoff({
    required String phone,
    required String pin,
    required String tier,
    required KickTelemetry telemetry,
  }) async {
    final baseUrl = AppConfig.supabaseUrl.isNotEmpty
        ? AppConfig.supabaseUrl
        : 'https://YOUR_PROJECT_ID.supabase.co';
    final anonKey = AppConfig.supabaseAnonKey.isNotEmpty
        ? AppConfig.supabaseAnonKey
        : 'YOUR_ANON_KEY';

    final uri = Uri.parse('$baseUrl/functions/v1/verify-captain-pin');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'apikey': anonKey,
      },
      body: jsonEncode({
        'phone': phone,
        'pin': pin,
        'tier': tier,
        'telemetry': telemetry.toJson(),
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      final hashedToken = data['hashedToken'] as String?;
      if (hashedToken != null && hashedToken.isNotEmpty) {
        try {
          await _supabase.auth.verifyOTP(
            tokenHash: hashedToken,
            type: OtpType.magiclink,
          );
        } catch (_) {}
      }

      return CaptainAuthResult.fromJson(data);
    } else {
      final err = jsonDecode(response.body);
      throw Exception(err['error'] ?? 'PIN authentication failed (${response.statusCode})');
    }
  }
}

final captainAuthServiceProvider = Provider<CaptainAuthService>((ref) {
  final client = ref.watch(supabaseProvider);
  return CaptainAuthService(client);
});
