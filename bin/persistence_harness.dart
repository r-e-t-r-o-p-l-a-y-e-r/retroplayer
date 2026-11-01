#!/usr/bin/env dart
/// CLI harness for playback persistence across separate process runs.
///
/// Uses a real SQLite file — no Flutter UI, no MPV. Simulates "quit app" by
/// closing the database between commands.
library;

import 'dart:io';

import 'package:retroplayer/dev/persistence_harness.dart';

Future<void> main(List<String> args) async {
  if (args.isEmpty || args.first == 'help' || args.first == '--help') {
    _printUsage();
    exit(0);
  }

  final command = args.first;
  final rest = args.sublist(1);

  try {
    final code = switch (command) {
      'demo' => await _cmdDemo(rest),
      'save' => await _cmdSave(rest),
      'verify' => await _cmdVerify(rest),
      _ => _usageError('Unknown command: $command'),
    };
    exit(code);
  } on _HarnessException catch (e) {
    stderr.writeln('Error: ${e.message}');
    exit(1);
  }
}

Future<int> _cmdDemo(List<String> args) async {
  final dbPath = _option(args, '--db');
  final result = await runPersistenceDemo(dbPath: dbPath);
  final path = dbPath ??
      '${Directory.systemTemp.path}/retroplayer_persistence_harness.db';

  stdout.writeln('Persistence harness demo');
  stdout.writeln('  Database: $path');
  stdout.writeln('  Session 1: saved $demoTrackId @ ${demoPositionMs}ms');
  stdout.writeln(
    '  Session 2: resume index=${result.startIndex} '
    'track=${result.trackId} '
    'position=${result.initialPosition?.inMilliseconds ?? 0}ms '
    'speed=${result.speed}',
  );

  if (result.startIndex != 1 ||
      result.initialPosition != const Duration(seconds: 45) ||
      result.speed != demoSpeed ||
      result.trackId != demoTrackId) {
    stderr.writeln('FAIL: resume values do not match saved state');
    return 1;
  }

  stdout.writeln('OK');
  return 0;
}

Future<int> _cmdSave(List<String> args) async {
  final dbPath = _requireOption(args, '--db');
  final itemId = _option(args, '--item-id') ?? demoAlbumId;
  final trackId = _option(args, '--track-id') ?? demoTrackId;
  final positionMs =
      int.parse(_option(args, '--position-ms') ?? '$demoPositionMs');
  final speed = double.parse(_option(args, '--speed') ?? '$demoSpeed');

  await savePlaybackSession(
    dbPath: dbPath,
    itemId: itemId,
    trackId: trackId,
    positionMs: positionMs,
    speed: speed,
  );

  stdout.writeln('Saved playback state to $dbPath');
  stdout.writeln('  item:  $itemId');
  stdout.writeln('  track: $trackId');
  stdout.writeln('  position: ${positionMs}ms');
  stdout.writeln('  speed: $speed');
  stdout.writeln('Run verify after a full quit (separate process):');
  stdout.writeln('  dart run bin/persistence_harness.dart verify --db $dbPath');
  return 0;
}

Future<int> _cmdVerify(List<String> args) async {
  final dbPath = _requireOption(args, '--db');
  if (!File(dbPath).existsSync()) {
    throw _HarnessException('Database not found: $dbPath (run save first)');
  }

  final result = await verifyPlaybackResume(dbPath: dbPath, album: demoAlbum());

  stdout.writeln('Resume from $dbPath');
  stdout.writeln('  start index: ${result.startIndex}');
  stdout.writeln('  track:       ${result.trackId}');
  stdout.writeln(
    '  position:    ${result.initialPosition?.inMilliseconds ?? 0}ms',
  );
  stdout.writeln('  speed:       ${result.speed}');
  return 0;
}

String? _option(List<String> args, String name) {
  final i = args.indexOf(name);
  if (i < 0 || i + 1 >= args.length) return null;
  return args[i + 1];
}

String _requireOption(List<String> args, String name) {
  final value = _option(args, name);
  if (value == null) {
    throw _HarnessException('Missing required option: $name');
  }
  return value;
}

int _usageError(String message) {
  stderr.writeln('Error: $message');
  stderr.writeln('');
  _printUsage();
  return 64;
}

void _printUsage() {
  stdout.writeln('''
Playback persistence harness (native SQLite, no UI)

Usage:
  dart run bin/persistence_harness.dart demo [--db PATH]
  dart run bin/persistence_harness.dart save --db PATH [--position-ms MS] ...
  dart run bin/persistence_harness.dart verify --db PATH

Commands:
  demo    Save state, close DB, reopen, and verify resume in one run
  save    Write playback state and close DB (simulates quitting the app)
  verify  Reopen DB and print what PlayAlbum would resume

Compile a standalone binary:
  dart build cli -o build/persistence_harness
  ./build/persistence_harness/bundle/bin/persistence_harness demo

Two-process manual test (simulates separate application runs):
  dart run bin/persistence_harness.dart save --db /tmp/rpc-persist.db
  dart run bin/persistence_harness.dart verify --db /tmp/rpc-persist.db
''');
}

class _HarnessException implements Exception {
  _HarnessException(this.message);
  final String message;
}
