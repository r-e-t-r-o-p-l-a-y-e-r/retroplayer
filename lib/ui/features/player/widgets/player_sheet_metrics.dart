import 'package:flutter/widgets.dart';

/// Content height of the collapsed mini player, excluding the system inset.
///
/// Includes the drag handle. The library swipe sheet uses this as its minimum
/// extent so collapsed chrome is not clipped.
const double playerCollapsedContentHeight = 148;

/// [playerCollapsedContentHeight] plus the system bottom inset.
double playerCollapsedExtent(BuildContext context) {
  return playerCollapsedContentHeight + MediaQuery.paddingOf(context).bottom;
}

/// Normalized expand blend: 0 at [minChildSize], 1 at full height.
double sheetBlendT({
  required double extent,
  required double minChildSize,
}) {
  final span = (1.0 - minChildSize).clamp(1e-6, double.infinity);
  return ((extent - minChildSize) / span).clamp(0.0, 1.0);
}
