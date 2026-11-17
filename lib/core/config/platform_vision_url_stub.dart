String platformDefaultVisionApiUrl() => 'http://127.0.0.1:8000';

String adaptLoopbackUrlForPlatform(String url) {
  final trimmed = url.trim();
  final uri = Uri.tryParse(trimmed);
  if (uri == null || uri.host.isEmpty) return trimmed;
  if (uri.host == '10.0.2.2') {
    return uri.replace(host: '127.0.0.1').toString();
  }
  return trimmed;
}
