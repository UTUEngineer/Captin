import 'dart:io';

class SelectedVideoFile {
  const SelectedVideoFile({
    required this.path,
    required this.name,
    required this.sizeBytes,
  });

  factory SelectedVideoFile.fromPath(String path) {
    final file = File(path);
    return SelectedVideoFile(
      path: path,
      name: file.uri.pathSegments.last,
      sizeBytes: file.lengthSync(),
    );
  }

  final String path;
  final String name;
  final int sizeBytes;

  String get formattedSize {
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
