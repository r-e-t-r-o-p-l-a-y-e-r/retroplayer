import 'dart:io';

/// Neutral Android start folder for the system directory picker (Add folder).
///
/// Avoids reusing the last SAF location from unrelated pickers (e.g. old
/// playlist file dialogs). Returns null on non-Android or if no candidate exists.
String? androidPrimaryStoragePath() {
  if (!Platform.isAndroid) return null;
  const candidates = <String>[
    '/storage/emulated/0',
    '/sdcard',
  ];
  for (final path in candidates) {
    if (Directory(path).existsSync()) return path;
  }
  return null;
}
