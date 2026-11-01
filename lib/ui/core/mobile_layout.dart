import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:retroplayer/ui/core/retro/retro_palette.dart';
import 'package:retroplayer/ui/core/retro/retro_decorations.dart';
import 'package:retroplayer/ui/core/retro/retro_spacing.dart';

/// Constrains the app to a phone-sized column on large desktop screens only.
class MobileLayout extends StatelessWidget {
  const MobileLayout({super.key, required this.child});

  static const double maxWidth = 430;
  static const double maxHeight = 920;

  final Widget child;

  static bool _isDesktopHost() {
    if (kIsWeb) return false;
    return Platform.isLinux || Platform.isWindows || Platform.isMacOS;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isDesktopHost()) {
      return child;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final useLetterbox =
            constraints.maxWidth > maxWidth || constraints.maxHeight > maxHeight;

        if (!useLetterbox) return child;

        final palette = RetroPalette.of(context);
        final frameWidth = constraints.maxWidth.clamp(0, maxWidth).toDouble();
        final frameHeight = constraints.maxHeight.clamp(0, maxHeight).toDouble();
        final content = SizedBox(
          width: frameWidth,
          height: frameHeight,
          child: child,
        );

        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [palette.deskDark, palette.deskLight],
            ),
          ),
          child: Center(
            child: DecoratedBox(
              decoration: RetroDecorations.deviceBezel(palette),
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(RetroSpacing.deviceRadius),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: frameWidth,
                      height: RetroSpacing.deviceForehead,
                      color: palette.chrome.withValues(alpha: 0.85),
                    ),
                    content,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
