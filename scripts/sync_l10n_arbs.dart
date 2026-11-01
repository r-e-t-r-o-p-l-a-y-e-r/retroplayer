// Syncs message keys from app_en.arb into every catalog locale file.
//
// Usage: dart run scripts/sync_l10n_arbs.dart
// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

const _catalogCodes = [
  'en', 'zh', 'hi', 'es', 'fr', 'ar', 'bn', 'pt', 'ru', 'ja', 'de', 'ko',
  'tr', 'vi', 'it', 'id', 'pl', 'nl', 'ur', 'fa', 'he', 'th', 'uk', 'ro',
  'el', 'cs', 'sv', 'hu', 'da', 'fi', 'nb', 'is', 'bg', 'hr', 'sk', 'sl',
  'sr', 'lt', 'lv', 'et', 'ga', 'mt', 'sq', 'mk', 'bs', 'ca',
];

void main() {
  final root = Directory.current.path;
  final l10nDir = p.join(root, 'lib', 'l10n');
  final templatePath = p.join(l10nDir, 'app_en.arb');
  final templateBytes = File(templatePath).readAsBytesSync();
  final templateText = utf8.decode(templateBytes);
  final template = jsonDecode(templateText) as Map<String, dynamic>;

  final messageKeys = template.keys
      .where((k) => !k.startsWith('@') && k != '@@locale')
      .toList();

  for (final code in _catalogCodes) {
    if (code == 'en') continue;
    final path = p.join(l10nDir, 'app_$code.arb');
    final existing = File(path).existsSync()
        ? jsonDecode(utf8.decode(File(path).readAsBytesSync()))
            as Map<String, dynamic>
        : <String, dynamic>{};

    final out = <String, dynamic>{'@@locale': code};
    for (final key in messageKeys) {
      if (key.startsWith('@')) continue;
      final metaKey = '@$key';
      if (template.containsKey(metaKey)) {
        out[metaKey] = template[metaKey];
      }
      out[key] = existing[key] ?? template[key];
    }

    final encoded = const JsonEncoder.withIndent('  ').convert(out);
    File(path).writeAsStringSync('$encoded\n', encoding: utf8);
    print('Wrote $path');
  }
  print('Done. Run: flutter gen-l10n');
}
