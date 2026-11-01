import 'package:flutter/material.dart';
import 'package:retroplayer/l10n/app_localizations.dart';
import 'package:retroplayer/ui/core/retro/retro_palette.dart';
import 'package:retroplayer/ui/core/retro/retro_typography.dart';

/// Minimum touch width for the library A–Z scrubber (Material touch target).
const double libraryAlphabetIndexBarWidth = 44;

/// Vertical A–Z (content-driven) scrubber for jumping in the library list.
class LibraryAlphabetIndexBar extends StatefulWidget {
  const LibraryAlphabetIndexBar({
    super.key,
    required this.labels,
    required this.onSelect,
  });

  final List<String> labels;
  final ValueChanged<String> onSelect;

  @override
  State<LibraryAlphabetIndexBar> createState() =>
      _LibraryAlphabetIndexBarState();
}

class _LibraryAlphabetIndexBarState extends State<LibraryAlphabetIndexBar> {
  String? _active;
  final _barKey = GlobalKey();

  void _selectAtGlobalY(double globalY) {
    if (widget.labels.isEmpty) return;
    final box = _barKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final localY = box.globalToLocal(Offset(0, globalY)).dy;
    final height = box.size.height;
    if (height <= 0) return;
    final fraction = (localY / height).clamp(0.0, 0.999);
    final index = (fraction * widget.labels.length).floor();
    final label = widget.labels[index];
    if (label == _active) return;
    setState(() => _active = label);
    widget.onSelect(label);
  }

  void _clearActive() {
    if (_active == null) return;
    setState(() => _active = null);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.labels.isEmpty) return const SizedBox.shrink();

    final palette = RetroPalette.of(context);

    // [Listener] (not GestureDetector) so vertical moves are not lost to the
    // list's scroll gesture arena — the usual cause of an unusable index bar.
    return Semantics(
      label: AppLocalizations.of(context).libraryIndex,
      child: Material(
        color: palette.screenElevated.withValues(alpha: 0.92),
        child: SizedBox(
          key: _barKey,
          width: libraryAlphabetIndexBarWidth,
          child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (event) => _selectAtGlobalY(event.position.dy),
            onPointerMove: (event) => _selectAtGlobalY(event.position.dy),
            onPointerUp: (_) => _clearActive(),
            onPointerCancel: (_) => _clearActive(),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (final label in widget.labels)
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: RetroTypography.timeLabel(context, compact: true)
                          .copyWith(
                            fontSize: 12,
                            fontWeight: label == _active
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: label == _active
                                ? palette.accent
                                : palette.textSecondary,
                          ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
