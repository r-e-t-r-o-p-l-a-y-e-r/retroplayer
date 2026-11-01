/// P0 audio formats supported on all platforms.
class SupportedFormats {
  SupportedFormats._();

  static const extensions = ['.mp3', '.m4a', '.m4b', '.flac', '.wav'];

  /// Optional P2 formats (Android/Linux only).
  static const optionalExtensions = ['.ogg', '.opus'];

  static bool isSupported(String filePath) {
    final lower = filePath.toLowerCase();
    return extensions.any(lower.endsWith) ||
        optionalExtensions.any(lower.endsWith);
  }

  static const playlistExtensions = ['.m3u', '.m3u8'];

  static bool isPlaylist(String filePath) {
    final lower = filePath.toLowerCase();
    return playlistExtensions.any(lower.endsWith);
  }

  static bool isP0(String filePath) {
    final lower = filePath.toLowerCase();
    return extensions.any(lower.endsWith);
  }
}
