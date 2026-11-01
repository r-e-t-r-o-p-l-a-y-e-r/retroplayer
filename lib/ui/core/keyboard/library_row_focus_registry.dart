import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Registered focus target for one library list row.
class LibraryRowFocusEntry {
  LibraryRowFocusEntry({
    required this.focusNode,
    required this.contextGetter,
  });

  final FocusNode focusNode;
  final BuildContext Function() contextGetter;
}

/// Maps keyboard row index to body [FocusNode] for arrow/focus sync.
class LibraryRowFocusRegistry {
  final _rows = <int, LibraryRowFocusEntry>{};

  void register(int index, LibraryRowFocusEntry entry) {
    _rows[index] = entry;
  }

  void unregister(int index) {
    _rows.remove(index);
  }

  void focusRow(
    int index, {
    bool scrollIntoView = true,
    VoidCallback? ensureBuilt,
    int remainingAttempts = 8,
  }) {
    final entry = _rows[index];
    if (entry == null) {
      if (remainingAttempts <= 0) return;
      ensureBuilt?.call();
      SchedulerBinding.instance.addPostFrameCallback((_) {
        focusRow(
          index,
          scrollIntoView: scrollIntoView,
          ensureBuilt: ensureBuilt,
          remainingAttempts: remainingAttempts - 1,
        );
      });
      return;
    }
    entry.focusNode.requestFocus();
    if (!scrollIntoView) return;
    final context = entry.contextGetter();
    if (!context.mounted) return;
    Scrollable.ensureVisible(
      context,
      alignment: 0.3,
      duration: Duration.zero,
    );
  }

  bool hasRow(int index) => _rows.containsKey(index);
}
