import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// True on Linux, Windows, and macOS (not web or mobile).
bool isDesktopHost() {
  if (kIsWeb) return false;
  return Platform.isLinux || Platform.isWindows || Platform.isMacOS;
}
