import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/app_config.dart';

/// خدمة الاتصال المباشر بـ Vision Backend (خادم التحليل الذكي للرؤية الحاسوبية)
class VisionService {
  VisionService._();
  static final VisionService instance = VisionService._();
  factory VisionService() => instance;

  /// الرابط الأساسي للسيرفر (يتم جلبه تلقائياً من AppConfig / .env)
  String get baseUrl => AppConfig.visionApiBaseUrl;

  /// فحص حالة وتشغيل سيرفر الرؤية (Health Check)
  Future<bool> checkHealth({String? token}) async {
    try {
      final uri = Uri.parse('$baseUrl/health');
      final response = await http
          .get(uri, headers: _buildHeaders(token: token))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Vision Backend health check failed: $e');
      return false;
    }
  }

  /// إرسال ملف (فيديو أو صورة أو لقطة تكتيكية) إلى سيرفر الرؤية
  /// الـ Endpoint الافتراضي في سيرفر Captain Vision هو: `/api/v1/videos/upload`
  Future<Map<String, dynamic>> uploadMedia({
    required File file,
    String? token,
    String endpoint = '/api/v1/videos/upload',
    Map<String, dynamic>? extraFields,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      debugPrint('جاري رفع الوسائط إلى سيرفر الرؤية: $uri');

      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(_buildHeaders(token: token, isJson: false));

      // إضافة الملف (باسم الحقل 'file' كما يتوقعه FastAPI في vision_backend/main.py)
      request.files.add(
        await http.MultipartFile.fromPath('file', file.path),
      );

      // إضافة أي حقول إضافية
      if (extraFields != null) {
        extraFields.forEach((key, value) {
          request.fields[key] = value.toString();
        });
      }

      final streamedResponse = await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      debugPrint('خطأ في رفع الملف لسيرفر الرؤية: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// دالة عامة لإرسال واستقبال بيانات من سيرفر الرؤية (JSON أو Multipart)
  Future<Map<String, dynamic>> sendDataToVisionBackend({
    String? token,
    String endpoint = '/api/v1/analyze-tactics',
    Map<String, dynamic>? requestData,
    File? imageFile,
  }) async {
    try {
      final Uri uri = Uri.parse('$baseUrl$endpoint');
      debugPrint('جاري الإرسال إلى سيرفر الرؤية: $uri');

      if (imageFile != null) {
        return uploadMedia(
          file: imageFile,
          token: token,
          endpoint: endpoint,
          extraFields: requestData,
        );
      } else {
        final response = await http.post(
          uri,
          headers: _buildHeaders(token: token, isJson: true),
          body: jsonEncode(requestData ?? {}),
        ).timeout(const Duration(seconds: 30));

        return _handleResponse(response);
      }
    } catch (e) {
      debugPrint('خطأ في الاتصال بسيرفر الرؤية: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// جلب نتيجة تحليل فيديو تكتيكي محدد بالـ ID
  Future<Map<String, dynamic>> getAnalysisResult(
    String videoId, {
    String? token,
    String resolution = 'medium',
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/v1/videos/$videoId/result?resolution=$resolution');
      final response = await http
          .get(uri, headers: _buildHeaders(token: token))
          .timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// بناء الهيدرز بما يشمل التوكن و Auth Header
  Map<String, String> _buildHeaders({String? token, bool isJson = false}) {
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (isJson) {
      headers['Content-Type'] = 'application/json';
    }

    // استخدام التوكن الممرر أو جلبه تلقائياً من جلسة Supabase الحالية إذا توفرت
    String? activeToken = token;
    if (activeToken == null || activeToken.isEmpty) {
      if (AppConfig.isSupabaseConfigured) {
        try {
          activeToken = Supabase.instance.client.auth.currentSession?.accessToken;
        } catch (_) {}
      }
    }

    if (activeToken != null && activeToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $activeToken';
    }

    return headers;
  }

  /// معالجة استجابة السيرفر
  Map<String, dynamic> _handleResponse(http.Response response) {
    debugPrint('رمز استجابة سيرفر الرؤية: ${response.statusCode}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final decodedData = jsonDecode(response.body);
        return {
          'success': true,
          'data': decodedData,
        };
      } catch (e) {
        return {
          'success': true,
          'data': response.body,
        };
      }
    } else {
      return {
        'success': false,
        'status_code': response.statusCode,
        'error': response.body,
      };
    }
  }
}
