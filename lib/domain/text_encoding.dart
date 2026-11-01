import 'dart:convert';

import 'package:charset/charset.dart';

/// Repairs text that was decoded as Latin-1 / ISO-8859-1 but was actually
/// UTF-8 or Windows-1250 (common for Slavic tags: ć, č, š, ž, đ, …).
///
/// Many ID3v2 frames claim encoding 0 (ISO-8859-1) while the bytes are UTF-8
/// or Windows-1250. Decoding as Latin-1 then yields mojibake. Recover the
/// original bytes via Latin-1 round-trip and re-decode with a better charset.
String? repairMetadataText(String? value) {
  if (value == null || value.isEmpty) return value;
  if (value.codeUnits.every((c) => c < 0x80)) return value;

  late final List<int> bytes;
  try {
    bytes = latin1.encode(value);
  } on ArgumentError {
    // Already contains code points > 255 — treat as correct Unicode.
    return value;
  }

  // 1) UTF-8 mislabeled as Latin-1 (very common).
  if (_looksLikeUtf8(bytes)) {
    try {
      final asUtf8 = utf8.decode(bytes);
      if (asUtf8 != value) return asUtf8;
    } on FormatException {
      // Not valid UTF-8.
    }
  }

  // 2) Windows-1250 (Central European) mislabeled as Latin-1.
  try {
    final as1250 = windows1250.decode(bytes);
    if (as1250 != value && _hasCentralEuropeanLetters(as1250)) {
      return as1250;
    }
  } on Object {
    // Charset decode failed.
  }

  return value;
}

bool _looksLikeUtf8(List<int> bytes) {
  // Multi-byte UTF-8 lead bytes (C2–F4); pure ASCII is already handled.
  return bytes.any((b) => b >= 0xC2 && b <= 0xF4);
}

bool _hasCentralEuropeanLetters(String value) {
  // Latin Extended-A / Central European letters used in South Slavic, etc.
  const markers = 'ćčšžđĆČŠŽĐąęłńóśźżĄĘŁŃÓŚŹŻáéíóúýÁÉÍÓÚÝäöüÄÖÜřťďňľŘŤĎŇĽ';
  for (final unit in value.codeUnits) {
    if (markers.contains(String.fromCharCode(unit))) return true;
  }
  return false;
}
