import 'dart:async';

import 'package:flutter/material.dart';

/// How [PlayerPanelViewModel] moves a bound [DraggableScrollableController].
///
/// Widget tests inject [JumpSheetAnimator] so expand/collapse never start a
/// ticker the fake binding will not pump.
abstract class SheetAnimator {
  const SheetAnimator();

  void move(DraggableScrollableController sheet, double size);
}

/// Production animation: ease the sheet to [size].
class AnimatedSheetAnimator extends SheetAnimator {
  const AnimatedSheetAnimator({
    this.duration = const Duration(milliseconds: 280),
    this.curve = Curves.easeOutCubic,
  });

  final Duration duration;
  final Curve curve;

  @override
  void move(DraggableScrollableController sheet, double size) {
    if (!sheet.isAttached) return;
    unawaited(sheet.animateTo(size, duration: duration, curve: curve));
  }
}

/// Instant move, used by widget tests.
class JumpSheetAnimator extends SheetAnimator {
  const JumpSheetAnimator();

  @override
  void move(DraggableScrollableController sheet, double size) {
    if (!sheet.isAttached) return;
    sheet.jumpTo(size);
  }
}
