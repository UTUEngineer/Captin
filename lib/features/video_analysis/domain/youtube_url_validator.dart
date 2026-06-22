/// Validates common YouTube URL formats before submitting to the backend.
abstract final class YoutubeUrlValidator {
  static final RegExp _pattern = RegExp(
    r'^(https?://)?(www\.|m\.)?(youtube\.com/(watch\?v=|embed/|shorts/)|youtu\.be/)[\w-]{6,}',
    caseSensitive: false,
  );

  static bool isValid(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return false;
    return _pattern.hasMatch(trimmed);
  }
}
