import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Points MPV/FFmpeg temp and cache dirs at app-writable locations on Linux.
///
/// Without this, lavf may fail to create its file cache when the process
/// cannot write to the default system temp or XDG cache paths.
///
/// [tempPath] and [cachePath] are for tests only; production uses
/// [getTemporaryDirectory] and [getApplicationCacheDirectory].
Future<void> configureLinuxPlaybackEnvironment({
  String? tempPath,
  String? cachePath,
}) async {
  if (!Platform.isLinux) return;

  final temp = tempPath ?? (await getTemporaryDirectory()).path;
  final cache = cachePath ?? (await getApplicationCacheDirectory()).path;
  await Directory(p.join(cache, 'mpv')).create(recursive: true);

  _setEnv('TMPDIR', temp);
  _setEnv('TEMP', temp);
  _setEnv('TMP', temp);
  _setEnv('XDG_CACHE_HOME', cache);
}

@visibleForTesting
String? getProcessEnvForTesting(String key) => _getEnv(key);

@visibleForTesting
void setProcessEnvForTesting(String key, String value) => _setEnv(key, value);

void _setEnv(String key, String value) {
  final setenv = DynamicLibrary.process().lookupFunction<
      Int32 Function(Pointer<Utf8>, Pointer<Utf8>, Int32),
      int Function(Pointer<Utf8>, Pointer<Utf8>, int)>('setenv');
  final keyPtr = key.toNativeUtf8();
  final valuePtr = value.toNativeUtf8();
  try {
    final result = setenv(keyPtr, valuePtr, 1);
    if (result != 0) {
      throw StateError('setenv($key) failed with code $result');
    }
  } finally {
    malloc.free(keyPtr);
    malloc.free(valuePtr);
  }
}

String? _getEnv(String key) {
  final getenv = DynamicLibrary.process().lookupFunction<
      Pointer<Utf8> Function(Pointer<Utf8>),
      Pointer<Utf8> Function(Pointer<Utf8>)>('getenv');
  final keyPtr = key.toNativeUtf8();
  try {
    final valuePtr = getenv(keyPtr);
    if (valuePtr == nullptr) return null;
    return valuePtr.toDartString();
  } finally {
    malloc.free(keyPtr);
  }
}
