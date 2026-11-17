import 'dart:io';

String platformDefaultVisionApiUrl() {
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:8000';
  }
  if (Platform.isIOS) {
    return 'http://127.0.0.1:8000';
  }
  return 'http://127.0.0.1:8000';
}

String adaptLoopbackUrlForPlatform(String url) {
  final trimmed = url.trim();
  final uri = Uri.tryParse(trimmed);
  if (uri == null || uri.host.isEmpty) return trimmed;

  final host = uri.host;
  final isLoopback =
      host == '127.0.0.1' || host == 'localhost' || host == '10.0.2.2';
  if (!isLoopback) return trimmed;

  if (Platform.isAndroid) {
    if (host != '10.0.2.2') {
      return uri.replace(host: '10.0.2.2').toString();
    }
  } else {
    if (host == '10.0.2.2') {
      return uri.replace(host: '127.0.0.1').toString();
    }
  }
  return trimmed;
}
