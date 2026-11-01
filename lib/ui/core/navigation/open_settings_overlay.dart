import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:retroplayer/ui/core/app_router.dart';
import 'package:retroplayer/ui/features/library/view_models/library_view_model.dart';

/// Opens Settings on the root navigator and persists overlay + scroll state.
void openSettingsOverlay(BuildContext context) {
  context.read<LibraryViewModel>().rememberBrowseScrollOffset();
  unawaited(context.read<LibraryViewModel>().saveSettingsOverlayOpen(true));
  context.push(AppRouter.settings);
}
