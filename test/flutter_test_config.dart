import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

/// Loads Roboto + Material Icons from the Flutter SDK for readable tutorial PNGs.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await _loadMaterialFontsFromSdk();
  await testMain();
}

String _flutterSdkRoot() {
  final fromEnv = Platform.environment['FLUTTER_ROOT'];
  if (fromEnv != null && fromEnv.isNotEmpty) {
    return p.normalize(fromEnv);
  }
  final which = Process.runSync('which', ['flutter']);
  if (which.exitCode != 0) return '';
  final bin = which.stdout.toString().trim();
  if (bin.isEmpty) return '';
  return p.normalize(p.join(p.dirname(bin), '..'));
}

Future<ByteData> _readFontFile(String path) async {
  final bytes = await File(path).readAsBytes();
  return ByteData.sublistView(Uint8List.fromList(bytes));
}

Future<void> _loadMaterialFontsFromSdk() async {
  final root = _flutterSdkRoot();
  if (root.isEmpty) return;

  final fontDir = p.join(root, 'bin', 'cache', 'artifacts', 'material_fonts');
  final roboto = FontLoader('Roboto')
    ..addFont(_readFontFile(p.join(fontDir, 'Roboto-Regular.ttf')))
    ..addFont(_readFontFile(p.join(fontDir, 'Roboto-Medium.ttf')))
    ..addFont(_readFontFile(p.join(fontDir, 'Roboto-Bold.ttf')));
  await roboto.load();

  // App uses fontFamily: monospace for paths and time labels (RetroTypography).
  final mono = FontLoader('monospace')
    ..addFont(_readFontFile(p.join(fontDir, 'Roboto-Regular.ttf')))
    ..addFont(_readFontFile(p.join(fontDir, 'Roboto-Medium.ttf')));
  await mono.load();

  final iconsPath = p.join(root, 'bin', 'cache', 'artifacts', 'material_fonts', 'MaterialIcons-Regular.otf');
  if (File(iconsPath).existsSync()) {
    final icons = FontLoader('MaterialIcons')
      ..addFont(_readFontFile(iconsPath));
    await icons.load();
  }
}
