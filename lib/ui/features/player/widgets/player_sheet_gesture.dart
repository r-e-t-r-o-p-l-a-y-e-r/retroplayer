import 'package:flutter/widgets.dart';

/// Vertical drags starting in the system navigation band must not expand the
/// collapsed player sheet (Android gesture nav). Same idea as
/// [kFolderFavoriteBackEdgeSlop] for predictive back — no extra layout padding.
bool isPlayerSheetVerticalDragEligible(
  BuildContext context,
  Offset globalPosition,
) {
  final slop = MediaQuery.systemGestureInsetsOf(context).bottom;
  if (slop <= 0) return true;
  final maxY = MediaQuery.sizeOf(context).height - slop;
  return globalPosition.dy < maxY;
}
