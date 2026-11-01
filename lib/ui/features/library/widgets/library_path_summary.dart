import 'package:flutter/material.dart';
import 'package:retroplayer/domain/library_paths.dart';
import 'package:retroplayer/l10n/app_localizations.dart';
import 'package:retroplayer/ui/core/retro/retro_palette.dart';

/// Shows the current library folder as a breadcrumb trail.
class LibraryPathSummary extends StatelessWidget {
  const LibraryPathSummary({
    super.key,
    required this.breadcrumbs,
    this.onNavigate,
    this.interactive = true,
    this.tapCurrentSegment = false,
    this.focusOrderStart,
  });

  final List<BrowseBreadcrumb> breadcrumbs;
  final ValueChanged<String?>? onNavigate;

  /// When false, segments are display-only.
  final bool interactive;

  /// When true, the last segment is also tappable (for the now-playing file).
  final bool tapCurrentSegment;

  /// When set, tappable segments participate in keyboard traversal with
  /// [NumericFocusOrder] starting at this value.
  final int? focusOrderStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final accent = theme.colorScheme.primary;
    final palette = RetroPalette.of(context);
    final l10n = AppLocalizations.of(context);

    return Material(
      color: palette.chrome.withValues(alpha: 0.55),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (breadcrumbs.isEmpty) {
                return const SizedBox(width: double.infinity);
              }
              final lastIndex = breadcrumbs.length - 1;
              final trail = _trail(
                context,
                l10nLibrary: l10n.library,
                muted: muted,
                accent: accent,
                ellipsisCurrent: false,
              );
              // A trail that fits starts at the left and grows to the right.
              // A wider trail pins the current segment and scrolls the rest,
              // opening on the parent beside that segment.
              if (_trailWidth(context, l10n.library) <= constraints.maxWidth) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Row(mainAxisSize: MainAxisSize.min, children: trail),
                );
              }

              const chevronSlot = 24.0;
              final currentMax = breadcrumbs.length == 1
                  ? constraints.maxWidth
                  : (constraints.maxWidth - chevronSlot).clamp(
                      0.0,
                      constraints.maxWidth,
                    );
              final prefix = _trail(
                context,
                l10nLibrary: l10n.library,
                muted: muted,
                accent: accent,
                end: lastIndex,
              );
              return Row(
                children: [
                  if (prefix.isNotEmpty)
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        reverse: true,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: prefix,
                        ),
                      ),
                    ),
                  if (prefix.isNotEmpty) _chevron(muted),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: currentMax),
                    child: _chip(
                      context,
                      breadcrumb: breadcrumbs[lastIndex],
                      index: lastIndex,
                      isCurrent: true,
                      ellipsis: true,
                      l10nLibrary: l10n.library,
                      muted: muted,
                      accent: accent,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  List<Widget> _trail(
    BuildContext context, {
    required String l10nLibrary,
    required Color muted,
    required Color accent,
    int start = 0,
    int? end,
    bool ellipsisCurrent = false,
  }) {
    final last = (end ?? breadcrumbs.length) - 1;
    if (last < start) return const [];
    return [
      for (var i = start; i <= last; i++) ...[
        if (i > start) _chevron(muted),
        _chip(
          context,
          breadcrumb: breadcrumbs[i],
          index: i,
          isCurrent: i == breadcrumbs.length - 1,
          ellipsis: ellipsisCurrent && i == breadcrumbs.length - 1,
          l10nLibrary: l10nLibrary,
          muted: muted,
          accent: accent,
        ),
      ],
    ];
  }

  /// Width of the whole trail, including chevrons, used to choose alignment.
  double _trailWidth(BuildContext context, String l10nLibrary) {
    final base = Theme.of(context).textTheme.labelLarge;
    var width = 0.0;
    for (var i = 0; i < breadcrumbs.length; i++) {
      if (i > 0) width += 24;
      final crumb = breadcrumbs[i];
      final current = i == breadcrumbs.length - 1;
      final tappable =
          interactive && onNavigate != null && (tapCurrentSegment || !current);
      final painter = TextPainter(
        text: TextSpan(
          text: crumb.isLibraryRoot ? l10nLibrary : crumb.label,
          style: base?.copyWith(
            fontWeight: current ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();
      width += painter.width.ceilToDouble() + (tappable ? 4 : 0);
      painter.dispose();
    }
    return width;
  }

  Widget _chevron(Color muted) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Icon(Icons.chevron_right, size: 16, color: muted),
    );
  }

  Widget _chip(
    BuildContext context, {
    required BrowseBreadcrumb breadcrumb,
    required int index,
    required bool isCurrent,
    required String l10nLibrary,
    required Color muted,
    required Color accent,
    bool ellipsis = false,
  }) {
    return _BreadcrumbChip(
      label: breadcrumb.isLibraryRoot ? l10nLibrary : breadcrumb.label,
      isCurrent: isCurrent,
      ellipsis: ellipsis,
      onTap:
          interactive && onNavigate != null && (tapCurrentSegment || !isCurrent)
          ? () => onNavigate!(breadcrumb.path)
          : null,
      mutedColor: muted,
      accentColor: accent,
      focusOrder: focusOrderStart != null
          ? NumericFocusOrder((focusOrderStart! + index).toDouble())
          : null,
    );
  }
}

class _BreadcrumbChip extends StatelessWidget {
  const _BreadcrumbChip({
    required this.label,
    required this.isCurrent,
    required this.onTap,
    required this.mutedColor,
    required this.accentColor,
    this.ellipsis = false,
    this.focusOrder,
  });

  final String label;
  final bool isCurrent;
  final VoidCallback? onTap;
  final Color mutedColor;
  final Color accentColor;
  final bool ellipsis;
  final NumericFocusOrder? focusOrder;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelLarge?.copyWith(
      color: isCurrent ? accentColor : mutedColor,
      fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
    );

    final child = Text(
      label,
      style: style,
      maxLines: ellipsis ? 1 : null,
      overflow: ellipsis ? TextOverflow.ellipsis : null,
    );

    if (onTap == null) return child;

    final chip = Actions(
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            onTap!();
            return null;
          },
        ),
      },
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          child: child,
        ),
      ),
    );

    if (focusOrder == null) return chip;

    return FocusTraversalOrder(
      order: focusOrder!,
      child: Focus(
        child: Builder(
          builder: (context) {
            final focused = Focus.of(context).hasFocus;
            return DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: focused
                    ? Border.all(color: accentColor, width: 2)
                    : null,
              ),
              child: chip,
            );
          },
        ),
      ),
    );
  }
}
