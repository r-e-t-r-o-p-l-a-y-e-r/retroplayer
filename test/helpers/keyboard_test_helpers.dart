import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> ensureShortcutFocus(WidgetTester tester) async {
  final focusFinder = find.byKey(const Key('desktop_shortcut_focus'));
  if (focusFinder.evaluate().isEmpty) return;

  final focusWidget = tester.widget<Focus>(focusFinder);
  focusWidget.focusNode?.requestFocus();
  await tester.pump();
}

Future<void> sendShortcut(
  WidgetTester tester, {
  required LogicalKeyboardKey key,
  bool control = false,
  bool shift = false,
  bool alt = false,
}) async {
  await ensureShortcutFocus(tester);
  final held = <LogicalKeyboardKey>[
    if (control) LogicalKeyboardKey.controlLeft,
    if (shift) LogicalKeyboardKey.shiftLeft,
    if (alt) LogicalKeyboardKey.altLeft,
  ];
  for (final modifier in held) {
    await tester.sendKeyDownEvent(modifier);
  }
  await tester.sendKeyDownEvent(key);
  await tester.sendKeyUpEvent(key);
  for (final modifier in held.reversed) {
    await tester.sendKeyUpEvent(modifier);
  }
  await tester.pump();
}

Future<void> sendPlainKey(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyDownEvent(key);
  await tester.sendKeyUpEvent(key);
  await tester.pump();
}
