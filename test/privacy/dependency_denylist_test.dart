/// pubspec.yaml direct dependencies must not include network/telemetry SDKs.
///
/// Evidence:
/// - `pubspec.yaml has no denied network/telemetry direct dependencies`
library;
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Direct dependency names that imply network, ads, or telemetry.
const _deniedDirectDependencies = <String>{
  'http',
  'dio',
  'chopper',
  'firebase_core',
  'firebase_analytics',
  'firebase_crashlytics',
  'firebase_messaging',
  'sentry',
  'sentry_flutter',
  'crashlytics',
  'amplitude',
  'mixpanel_flutter',
  'posthog_flutter',
  'segment_analytics',
  'connectivity_plus',
  'url_launcher',
  'webview_flutter',
  'google_mobile_ads',
  'admob',
};

void main() {
  test('pubspec.yaml has no denied network/telemetry direct dependencies', () {
    final pubspec = File('pubspec.yaml');
    expect(pubspec.existsSync(), isTrue);
    final names = _directDependencyNames(pubspec.readAsStringSync());
    final violations = names.intersection(_deniedDirectDependencies);
    expect(
      violations,
      isEmpty,
      reason: 'Denied direct dependencies found: $violations',
    );
  });
}

Set<String> _directDependencyNames(String yaml) {
  final names = <String>{};
  var inDependencies = false;
  for (final raw in yaml.split('\n')) {
    final line = raw.replaceFirst(RegExp(r'#.*$'), '');
    if (line.trim().isEmpty) continue;

    if (!line.startsWith(' ') && !line.startsWith('\t')) {
      final key = line.split(':').first.trim();
      inDependencies = key == 'dependencies';
      continue;
    }

    if (!inDependencies) continue;
    if (!(line.startsWith('  ') || line.startsWith('\t'))) continue;
    // Nested keys under a dependency (e.g. path:) are indented further.
    if (line.startsWith('    ') || line.startsWith('\t\t')) continue;

    final match = RegExp(r'^\s+([A-Za-z0-9_]+)\s*:').firstMatch(line);
    if (match == null) continue;
    final name = match.group(1)!;
    if (name == 'flutter' || name == 'sdk') continue;
    names.add(name);
  }
  return names;
}
