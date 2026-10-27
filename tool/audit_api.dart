import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> main() async {
  await generateCaptinAuditReport();
}

/// فحص الاتصال الشامل لتطبيق كابتن (Captin Integration Audit)
Future<void> generateCaptinAuditReport({
  String? footballApiKey,
  String? supabaseUrl,
  String? supabaseAnonKey,
}) async {
  // قراءة المفاتيح من ملف .env إن وجد إذا لم تُمرر يدوياً
  final envVars = _loadLocalEnv();
  final apiKey = footballApiKey ?? envVars['API_FOOTBALL_KEY'] ?? '';
  final sbUrl = supabaseUrl ?? envVars['SUPABASE_URL'] ?? 'https://woagzfxxggfpexgbmobw.supabase.co';
  final sbAnonKey = supabaseAnonKey ?? envVars['SUPABASE_ANON_KEY'] ?? '';

  print('======================================================');
  print('          CAPTIN APP - INTEGRATION AUDIT              ');
  print('======================================================');

  // 1. فحص نطاق Spaceship العام
  await _checkPublicDomain('https://cap-tin.xyz');

  // 2. فحص اتصال API-Football المباشر (الاتحاد / الدوريات)
  await _checkFootballApi(apiKey);

  // 3. فحص اتصال Supabase والدوال السحابية (Edge Function: football-data)
  await _checkSupabaseConnection(sbUrl, sbAnonKey);

  print('\n======================================================');
  print('                 انتهى التقرير التشخيصي               ');
  print('======================================================\n');
}

/// فحص النطاق العام (Spaceship)
Future<void> _checkPublicDomain(String domainUrl) async {
  print('\n[1/3 فحص النطاق العام (Spaceship Domain)]');
  print('- الرابط: $domainUrl');
  try {
    final startTime = DateTime.now();
    final response = await http.get(Uri.parse(domainUrl)).timeout(const Duration(seconds: 8));
    final duration = DateTime.now().difference(startTime).inMilliseconds;

    print('- رمز الاستجابة (Status): ${response.statusCode}');
    print('- سرعة الاستجابة: ${duration}ms');
    if (response.statusCode >= 200 && response.statusCode < 400) {
      print('  الحالة: [النطاق متصل ويعمل بنجاح Connected ✅]');
    } else {
      print('  الحالة: [النطاق يستجيب ولكن برمز غير متوقع (${response.statusCode}) ⚠️]');
    }
  } catch (e) {
    print('  الحالة: [فشل الاتصال بالنطاق ❌]');
    print('  السبب التقني: $e');
    print('  ملاحظة: إذا كان الخطأ "Failed host lookup" فهذا يعني أن سجلات الـ DNS (A Record / CNAME) لم تُربط بعد في لوحة Spaceship.');
  }
}

/// فحص اتصال API-Football (بيانات الاتحاد العراقي والمباريات)
Future<void> _checkFootballApi(String apiKey) async {
  print('\n[2/3 فحص API الاتحاد والدوريات (API-Football / API-Sports)]');
  
  if (apiKey.isEmpty || apiKey == 'YOUR_KEY_HERE') {
    print('  تنبيه: مفتاح API_FOOTBALL_KEY غير مُعرّف في ملف .env!');
    print('  يمكنك إضافة المفتاح في ملف .env تحت API_FOOTBALL_KEY=xxx');
    return;
  }

  final headers = {
    'x-apisports-key': apiKey,
    'Accept': 'application/json',
  };

  // أ. فحص التوثيق وحالة الحساب والـ Quota
  final statusUri = Uri.parse('https://v3.football.api-sports.io/status');
  print('- أ. فحص مصادقة الحساب والـ Quota: $statusUri');
  try {
    final startTime = DateTime.now();
    final response = await http.get(statusUri, headers: headers).timeout(const Duration(seconds: 10));
    final duration = DateTime.now().difference(startTime).inMilliseconds;

    print('  رمز الاستجابة: ${response.statusCode} (${duration}ms)');
    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      final errors = jsonBody['errors'];
      if (errors is List && errors.isNotEmpty || errors is Map && errors.isNotEmpty) {
        print('  الحالة: [مفتاح الربط غير صالح أو منتهي الصلاحية ⚠️: $errors]');
      } else {
        print('  الحالة: [المصادقة ناجحة والحساب نشط ✅]');
      }
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      print('  الحالة: [فشل التوثيق - الـ Token / Key غير صالح ❌]');
    } else {
      print('  الحالة: [خطأ من الخادم (${response.statusCode}) ❌]');
    }
  } catch (e) {
    print('  الحالة: [فشل الاتصال بالسيرفر: $e ❌]');
  }

  // ب. فحص جلب مباريات دوري نجوم العراق (دوري 290 لموسم 2025)
  final fixturesUri = Uri.parse('https://v3.football.api-sports.io/fixtures?league=290&season=2025&next=5');
  print('- ب. جلب قائمة مباريات دوري نجوم العراق: $fixturesUri');
  try {
    final startTime = DateTime.now();
    final response = await http.get(fixturesUri, headers: headers).timeout(const Duration(seconds: 10));
    final duration = DateTime.now().difference(startTime).inMilliseconds;

    print('  رمز الاستجابة: ${response.statusCode} (${duration}ms)');
    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      final results = jsonBody['results'] ?? 0;
      print('  الحالة: [تم جلب البيانات بنجاح ✅ - عدد المباريات المستلمة: $results]');
    } else {
      print('  الحالة: [فشل جلب المباريات (${response.statusCode}) ❌]');
    }
  } catch (e) {
    print('  الحالة: [فشل الاتصال: $e ❌]');
  }
}

/// فحص اتصال Supabase و Edge Function
Future<void> _checkSupabaseConnection(String sbUrl, String sbAnonKey) async {
  print('\n[3/3 فحص اتصال Supabase & Edge Functions]');
  print('- رابط مشروع Supabase: $sbUrl');

  if (sbUrl.isEmpty || sbAnonKey.isEmpty) {
    print('  تنبيه: SUPABASE_URL أو SUPABASE_ANON_KEY غير محدد.');
    return;
  }

  // فحص صحة خدمة Supabase
  final healthUri = Uri.parse('$sbUrl/rest/v1/');
  try {
    final response = await http.get(healthUri, headers: {
      'apikey': sbAnonKey,
      'Authorization': 'Bearer $sbAnonKey',
    }).timeout(const Duration(seconds: 8));

    if (response.statusCode >= 200 && response.statusCode < 400) {
      print('  حالة Supabase REST API: [متصل ويعمل بنجاح ✅]');
    } else {
      print('  حالة Supabase REST API: [رمز الاستجابة: ${response.statusCode} ⚠️]');
    }
  } catch (e) {
    print('  حالة Supabase: [فشل الاتصال: $e ❌]');
  }
}

/// قراءة بسيطة لملف .env في مسار المشروع
Map<String, String> _loadLocalEnv() {
  final envMap = <String, String>{};
  final envFile = File('.env');
  if (envFile.existsSync()) {
    final lines = envFile.readAsLinesSync();
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
      final idx = trimmed.indexOf('=');
      if (idx > 0) {
        final key = trimmed.substring(0, idx).trim();
        final value = trimmed.substring(idx + 1).trim();
        envMap[key] = value;
      }
    }
  }
  return envMap;
}
