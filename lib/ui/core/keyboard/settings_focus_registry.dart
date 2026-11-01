import 'package:flutter/foundation.dart';

/// Vertical focus lines on the Settings screen.
class SettingsFocusRegistry extends ChangeNotifier {
  final _lines = <int, VoidCallback>{};
  int? _currentLineIndex;

  int? get currentLineIndex => _currentLineIndex;

  void registerLine(int lineIndex, VoidCallback focusLine) {
    _lines[lineIndex] = focusLine;
  }

  void unregisterLine(int lineIndex) {
    _lines.remove(lineIndex);
    if (_currentLineIndex == lineIndex) {
      _currentLineIndex = null;
    }
  }

  void moveLine(int delta) {
    if (_lines.isEmpty) return;
    final sorted = _lines.keys.toList()..sort();
    if (_currentLineIndex == null) {
      _focusLine(sorted.first);
      return;
    }
    final currentIdx = sorted.indexOf(_currentLineIndex!);
    if (currentIdx < 0) {
      _focusLine(sorted.first);
      return;
    }
    final nextIdx = (currentIdx + delta).clamp(0, sorted.length - 1);
    _focusLine(sorted[nextIdx]);
  }

  void _focusLine(int lineIndex) {
    _currentLineIndex = lineIndex;
    _lines[lineIndex]?.call();
    notifyListeners();
  }

  void noteLineFocused(int lineIndex) {
    if (_currentLineIndex == lineIndex) return;
    _currentLineIndex = lineIndex;
    notifyListeners();
  }
}
