import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

/// Matches [NativeReferenceHolder.kReferenceBufferSize] in package:media_kit.
const _referenceBufferSize = 512;

const _holderFilePrefix = 'com.alexmercerind.media_kit.NativeReferenceHolder';

/// Time to wait after sending `quit` to stale MPV handles on hot restart.
const mpvTeardownSettleDelay = Duration(milliseconds: 1000);

/// Sends `quit` to MPV instances left from a prior Dart isolate (hot restart).
///
/// media_kit's [NativeReferenceHolder] does this asynchronously during
/// [MediaKit.ensureInitialized], which races with new player creation. We run
/// synchronous cleanup first so MPV callbacks are gone before a new isolate
/// creates players.
Future<void> teardownStaleMpvPlayers({
  Duration settleDelay = mpvTeardownSettleDelay,
}) async {
  if (kIsWeb || !Platform.isLinux || !kDebugMode) return;

  final holderFile = File(nativeReferenceHolderFilePath());
  if (!await holderFile.exists()) return;

  final addressText = (await holderFile.readAsString()).trim();
  final bufferAddress = int.tryParse(addressText);
  if (bufferAddress == null || bufferAddress == 0) return;

  final buffer = Pointer<IntPtr>.fromAddress(bufferAddress);
  final handles = <Pointer<Void>>[];
  for (var i = 0; i < _referenceBufferSize; i++) {
    final slot = buffer + i;
    final handleAddress = slot.value;
    slot.value = 0;
    if (handleAddress != 0) {
      handles.add(Pointer<Void>.fromAddress(handleAddress));
    }
  }

  if (handles.isEmpty) return;

  final commandString = _loadMpvCommandString();
  final quit = 'quit'.toNativeUtf8();
  try {
    for (final handle in handles) {
      try {
        commandString(handle, quit);
      } on Object {
        // Best effort — handle may already be invalid.
      }
    }
  } finally {
    malloc.free(quit);
  }

  if (settleDelay > Duration.zero) {
    await Future<void>.delayed(settleDelay);
  }
}

typedef _MpvCommandStringNative = Int32 Function(
  Pointer<Void> handle,
  Pointer<Utf8> command,
);

typedef _MpvCommandString = int Function(
  Pointer<Void> handle,
  Pointer<Utf8> command,
);

_MpvCommandString _loadMpvCommandString() {
  for (final name in ['libmpv.so', 'libmpv.so.2', 'libmpv.so.1']) {
    try {
      final lib = DynamicLibrary.open(name);
      return lib.lookupFunction<_MpvCommandStringNative, _MpvCommandString>(
        'mpv_command_string',
      );
    } on Object {
      continue;
    }
  }
  throw StateError('libmpv not found for stale player teardown');
}

@visibleForTesting
int referenceBufferSizeForTesting() => _referenceBufferSize;

@visibleForTesting
String nativeReferenceHolderFilePath() =>
    p.join(Directory.systemTemp.path, '$_holderFilePrefix.$pid');

@visibleForTesting
String nativeReferenceHolderPathForTesting() => nativeReferenceHolderFilePath();
