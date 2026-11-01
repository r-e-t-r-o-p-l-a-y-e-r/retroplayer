#!/usr/bin/env dart
// Writes lib/build_info.dart from pubspec.yaml version, git, and current UTC time.
// That file is gitignored — stamp before builds/tests; do not commit it.
// Usage: dart run scripts/stamp_build_info.dart

import 'dart:io';

String _dartString(String value) =>
    value.replaceAll(r'\', r'\\').replaceAll("'", r"\'");

String _git(Directory root, List<String> args) {
  final result = Process.runSync(
    'git',
    args,
    workingDirectory: root.path,
    runInShell: false,
  );
  if (result.exitCode != 0) {
    return '';
  }
  return (result.stdout as String).trim();
}

String _utcStamp(DateTime utc) {
  final y = utc.year.toString().padLeft(4, '0');
  final mo = utc.month.toString().padLeft(2, '0');
  final d = utc.day.toString().padLeft(2, '0');
  final h = utc.hour.toString().padLeft(2, '0');
  final mi = utc.minute.toString().padLeft(2, '0');
  final s = utc.second.toString().padLeft(2, '0');
  return '$y-$mo-${d}T$h:$mi:${s}Z';
}

void main() {
  final root = Directory.current;
  final pubspec = File('${root.path}/pubspec.yaml');
  if (!pubspec.existsSync()) {
    stderr.writeln('Run from the project root (pubspec.yaml not found).');
    exit(1);
  }

  final versionLine = pubspec
      .readAsLinesSync()
      .map((line) => line.trim())
      .firstWhere(
        (line) => line.startsWith('version:'),
        orElse: () => '',
      );
  if (versionLine.isEmpty) {
    stderr.writeln('No version: line in pubspec.yaml');
    exit(1);
  }

  final raw = versionLine.substring('version:'.length).trim();
  final parts = raw.split('+');
  final version = parts.first;
  final buildNumber = parts.length > 1 ? parts[1] : '0';
  final iso = _utcStamp(DateTime.now().toUtc());

  var gitBranch = _git(root, ['rev-parse', '--abbrev-ref', 'HEAD']);
  if (gitBranch.isEmpty) {
    gitBranch = 'unknown';
  }
  var gitHash = _git(root, ['rev-parse', '--short', 'HEAD']);
  if (gitHash.isEmpty) {
    gitHash = 'unknown';
  } else if (_git(root, ['status', '--porcelain']).isNotEmpty) {
    gitHash = '$gitHash*';
  }

  final out = File('${root.path}/lib/build_info.dart');
  out.writeAsStringSync('''
/// App version and build stamp.
///
/// GENERATED — do not edit or commit. Regenerate with:
/// `dart run scripts/stamp_build_info.dart`
abstract final class BuildInfo {
  static const version = '${_dartString(version)}';
  static const buildNumber = '${_dartString(buildNumber)}';
  static const versionLabel = '${_dartString(raw)}';

  /// UTC instant when this stamp was written, `YYYY-MM-DDTHH:MM:SSZ`.
  static const buildTimeIso = '$iso';

  /// Branch name at stamp time (`HEAD` when detached).
  static const gitBranch = '${_dartString(gitBranch)}';

  /// Short commit hash at stamp time; trailing `*` means a dirty working tree.
  static const gitHash = '${_dartString(gitHash)}';

  static DateTime get buildTime => DateTime.parse(buildTimeIso);
}
''');

  stdout.writeln('Wrote ${out.path}');
  stdout.writeln(
    '  versionLabel=$raw  buildTimeIso=$iso  '
    'gitBranch=$gitBranch  gitHash=$gitHash',
  );
}
