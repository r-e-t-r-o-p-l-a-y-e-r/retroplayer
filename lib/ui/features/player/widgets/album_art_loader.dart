import 'dart:io';
import 'dart:typed_data';

/// Reads album/folder cover bytes from [path].
///
/// Returns null when the file is missing, empty, or unreadable. Callers should
/// show a placeholder icon in that case — never an empty grey art frame.
Future<Uint8List?> loadAlbumArtBytes(String path) async {
  if (path.isEmpty) return null;
  try {
    final file = File(path);
    if (!await file.exists()) return null;
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) return null;
    return Uint8List.fromList(bytes);
  } on Object {
    return null;
  }
}
