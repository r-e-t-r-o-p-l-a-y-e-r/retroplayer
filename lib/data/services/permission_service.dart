import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

/// Requests storage/audio permissions needed for local library access.
class PermissionService {
  Future<bool> requestLibraryAccess() async {
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      return true;
    }
    if (Platform.isAndroid) {
      final audio = await Permission.audio.request();
      if (!audio.isGranted) return false;
      // Sidecar covers (cover.jpg, …) need image access on Android 13+.
      // Best-effort: library still works if the user denies photos.
      await Permission.photos.request();
      return true;
    }
    if (Platform.isIOS) {
      // Folder picker uses security-scoped URLs; no broad library permission needed.
      return true;
    }
    return true;
  }
}
