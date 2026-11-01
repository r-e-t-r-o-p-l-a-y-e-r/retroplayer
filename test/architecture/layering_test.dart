/// Layer rules: domain is pure Dart, application talks to data only via ports.
///
/// Evidence:
/// - `domain imports only domain, pure packages and pure dart: libraries`
/// - `application imports only application, domain and pure packages`
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

final _import = RegExp(r'''^(?:import|export)\s+'([^']+)'.*;''', multiLine: true);

Map<String, List<String>> _importsUnder(String dir) => {
      for (final file in Directory(dir)
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart')))
        file.path: [
          for (final m in _import.allMatches(file.readAsStringSync())) m[1]!,
        ],
    };

List<String> _violations(String dir, bool Function(String uri) allowed) => [
      for (final entry in _importsUnder(dir).entries)
        for (final uri in entry.value)
          if (!allowed(uri)) '${entry.key} imports $uri',
    ];

bool _pureDart(String uri) =>
    uri.startsWith('dart:') && uri != 'dart:io' && uri != 'dart:ui';

bool _purePackage(String uri) =>
    uri.startsWith('package:path/') ||
    uri.startsWith('package:charset/') ||
    uri.startsWith('package:freezed_annotation/') ||
    uri.startsWith('package:collection/');

bool _relative(String uri) => !uri.contains(':');

void main() {
  test('domain imports only domain, pure packages and pure dart: libraries',
      () {
    expect(
      _violations(
        'lib/domain',
        (uri) =>
            _pureDart(uri) ||
            _purePackage(uri) ||
            _relative(uri) ||
            uri.startsWith('package:retroplayer/domain/'),
      ),
      isEmpty,
    );
  });

  test('application imports only application, domain and pure packages', () {
    expect(
      _violations(
        'lib/application',
        (uri) =>
            _pureDart(uri) ||
            _purePackage(uri) ||
            _relative(uri) ||
            uri.startsWith('package:retroplayer/domain/') ||
            uri.startsWith('package:retroplayer/application/'),
      ),
      isEmpty,
    );
  });
}
