import 'package:flutter/material.dart';
import 'package:retroplayer/ui/core/retro/retro_palette.dart';

/// Visible keyboard focus ring for player chrome (album art, title block, etc.).
class PlayerFocusChrome extends StatefulWidget {
  const PlayerFocusChrome({
    super.key,
    required this.order,
    required this.onActivate,
    this.onDoubleTapDown,
    required this.child,
    this.focusKey,
    this.borderRadius = 8,
    this.padding = EdgeInsets.zero,
    this.handlePointerTap = true,
  });

  final NumericFocusOrder order;
  final VoidCallback onActivate;
  final GestureTapDownCallback? onDoubleTapDown;
  final Widget child;
  final Key? focusKey;
  final double borderRadius;
  final EdgeInsets padding;

  /// When false, [child] handles pointer taps (keyboard [onActivate] still works).
  final bool handlePointerTap;

  @override
  State<PlayerFocusChrome> createState() => _PlayerFocusChromeState();
}

class _PlayerFocusChromeState extends State<PlayerFocusChrome> {
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = RetroPalette.of(context);

    return FocusTraversalOrder(
      order: widget.order,
      child: Actions(
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onActivate();
              return null;
            },
          ),
        },
        child: Focus(
          key: widget.focusKey,
          focusNode: _focusNode,
          child: Builder(
            builder: (context) {
              final focused = Focus.of(context).hasFocus;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (_) => _focusNode.requestFocus(),
                onTap: widget.handlePointerTap ? widget.onActivate : null,
                onDoubleTapDown:
                    widget.handlePointerTap ? widget.onDoubleTapDown : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  padding: widget.padding,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    border: focused
                        ? Border.all(color: palette.accent, width: 2)
                        : null,
                  ),
                  child: widget.child,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
