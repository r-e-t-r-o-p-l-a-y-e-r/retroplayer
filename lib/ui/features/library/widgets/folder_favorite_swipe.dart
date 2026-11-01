import 'package:flutter/material.dart';
import 'package:retroplayer/l10n/app_localizations.dart';

/// Horizontal drags starting within this distance of the screen's left edge
/// do not toggle favorites (reserved for system / predictive back).
const kFolderFavoriteBackEdgeSlop = 24.0;

/// Release past this fraction of the row width to toggle favorite, matching
/// [Dismissible]'s default dismiss threshold (`0.4`).
const kFolderFavoriteDismissThreshold = 0.4;

/// Swipe-right toggle for folder favorites; ignores back-edge horizontal drags.
class FolderFavoriteSwipe extends StatefulWidget {
  const FolderFavoriteSwipe({
    super.key,
    required this.isFavorite,
    required this.onToggle,
    required this.child,
  });

  final bool isFavorite;
  final Future<void> Function() onToggle;
  final Widget child;

  @override
  State<FolderFavoriteSwipe> createState() => _FolderFavoriteSwipeState();
}

class _FolderFavoriteSwipeState extends State<FolderFavoriteSwipe> {
  double _dragExtent = 0;
  bool _dragEligible = false;

  void _onHorizontalDragStart(DragStartDetails details) {
    _dragEligible = details.globalPosition.dx >= kFolderFavoriteBackEdgeSlop;
    if (!_dragEligible) return;
    setState(() => _dragExtent = 0);
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (!_dragEligible) return;
    setState(() {
      // Match [Dismissible]: 1:1 with the finger, no hard cap while dragging.
      final next = _dragExtent + details.delta.dx;
      _dragExtent = next < 0 ? 0 : next;
    });
  }

  Future<void> _onHorizontalDragEnd(DragEndDetails details) async {
    if (!_dragEligible) {
      _dragEligible = false;
      return;
    }
    final rowWidth = context.size?.width ?? 0;
    final commitThreshold = rowWidth * kFolderFavoriteDismissThreshold;
    final committed =
        rowWidth > 0 && _dragExtent >= commitThreshold;
    setState(() => _dragExtent = 0);
    _dragEligible = false;
    if (committed) {
      await widget.onToggle();
    }
  }

  void _onHorizontalDragCancel() {
    _dragEligible = false;
    if (_dragExtent != 0) {
      setState(() => _dragExtent = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final label = widget.isFavorite ? l10n.removeFavorite : l10n.favorite;

    return ClipRect(
      child: Stack(
        clipBehavior: Clip.hardEdge,
        fit: StackFit.passthrough,
        children: [
          if (_dragExtent > 0)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: _dragExtent,
              child: _FavoriteRevealBackground(
                color: scheme.primary,
                iconColor: scheme.onPrimary,
                label: label,
              ),
            ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: _onHorizontalDragStart,
            onHorizontalDragUpdate: _onHorizontalDragUpdate,
            onHorizontalDragEnd: _onHorizontalDragEnd,
            onHorizontalDragCancel: _onHorizontalDragCancel,
            child: Transform.translate(
              offset: Offset(_dragExtent, 0),
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteRevealBackground extends StatelessWidget {
  const _FavoriteRevealBackground({
    required this.color,
    required this.iconColor,
    required this.label,
  });

  final Color color;
  final Color iconColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: color,
      child: ClipRect(
        child: OverflowBox(
          maxWidth: double.infinity,
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, color: iconColor),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: iconColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
