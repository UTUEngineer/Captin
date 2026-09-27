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
