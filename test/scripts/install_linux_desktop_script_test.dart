/// install-linux-desktop.sh must not shadow the system hicolor theme.
///
/// Evidence:
/// - `script forbids gtk-update-icon-cache on user hicolor`
/// - `script does not copy index.theme to user hicolor`
/// - `script uses logical Icon name`
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  late String scriptPath;
  late String scriptContents;

  setUp(() {
    final root = Directory.current.path;
    scriptPath = p.join(root, 'scripts', 'install-linux-desktop.sh');
    scriptContents = File(scriptPath).readAsStringSync();
  });

  test('script forbids gtk-update-icon-cache on user hicolor', () {
    expect(
      RegExp(r'^\s*gtk-update-icon-cache', multiLine: true)
          .hasMatch(scriptContents),
      isFalse,
    );
  });

  test('script does not copy index.theme to user hicolor', () {
    expect(
      RegExp(r'cp\s+.*index\.theme').hasMatch(scriptContents),
      isFalse,
    );
    expect(
      RegExp(r'>\s*"\$ICON_ROOT/index\.theme"').hasMatch(scriptContents),
      isFalse,
    );
    expect(
      scriptContents.contains(r'rm -f "$ICON_ROOT/index.theme"'),
      isTrue,
    );
  });

  test('script uses logical Icon name', () {
    expect(scriptContents.contains(r'Icon=$APP_ID'), isTrue);
    expect(
      scriptContents.contains('Icon=/'),
      isFalse,
    );
  });
}
