import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:retroplayer/l10n/app_localizations.dart';
import 'package:retroplayer/ui/core/keyboard/shortcut_labels.dart';
import 'package:retroplayer/ui/core/retro/retro_palette.dart';
import 'package:retroplayer/ui/core/retro/retro_spacing.dart';
import 'package:retroplayer/ui/core/retro/retro_typography.dart';
import 'package:retroplayer/ui/features/player/view_models/player_view_model.dart';
import 'package:retroplayer/ui/features/player/widgets/album_art_frame.dart';
import 'package:retroplayer/ui/features/player/widgets/player_focus.dart';

/// Album art with a 15-second jump on each side.
///
/// A double tap on the left or right half of the art jumps the same way.
/// [onArtTap] stays the single-tap action, such as locating the track.
class AlbumArtWithJumps extends StatelessWidget {
  const AlbumArtWithJumps({
    super.key,
    required this.viewModel,
    required this.artSize,
    this.onArtTap,
    this.artOrder,
  });

  final PlayerViewModel viewModel;
  final double artSize;
  final VoidCallback? onArtTap;
  final NumericFocusOrder? artOrder;

  void _jump(bool back) {
    viewModel.jumpBy(back ? -playbackJumpStep : playbackJumpStep);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) => _buildRow(context),
    );
  }

  Widget _buildRow(BuildContext context) {
    final art = AlbumArtFrame(size: artSize, imagePath: viewModel.coverArtPath);
    final order = artOrder;
    final gestures = _ArtTapGestures(
      width: artSize,
      onSingleTap: onArtTap,
      onDoubleTapHalf: _jump,
      child: art,
    );
    final framed = order == null
        ? gestures
        : PlayerFocusChrome(
            key: const ValueKey('player_art_focus'),
            focusKey: const ValueKey('player_art_focus_node'),
            order: order,
            onActivate: onArtTap ?? () {},
            handlePointerTap: false,
            child: gestures,
          );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _JumpButton(forward: false, onPressed: () => _jump(true)),
        SizedBox(width: artSize < 160 ? 8 : 16),
        framed,
        SizedBox(width: artSize < 160 ? 8 : 16),
        _JumpButton(forward: true, onPressed: () => _jump(false)),
      ],
    );
  }
}

/// Single tap runs immediately; a second tap on the same half within
/// [kDoubleTapTimeout] jumps instead of firing [onSingleTap] again.
class _ArtTapGestures extends StatefulWidget {
  const _ArtTapGestures({
    required this.width,
    required this.onDoubleTapHalf,
    required this.child,
    this.onSingleTap,
  });

  final double width;
  final VoidCallback? onSingleTap;
  final void Function(bool leftHalf) onDoubleTapHalf;
  final Widget child;

  @override
  State<_ArtTapGestures> createState() => _ArtTapGesturesState();
}

class _ArtTapGesturesState extends State<_ArtTapGestures> {
  DateTime? _lastTapUp;
  bool? _lastLeftHalf;

  bool _isLeftHalf(double x) => x < widget.width / 2;

  void _handleTapUp(TapUpDetails details) {
    final now = DateTime.now();
    final left = _isLeftHalf(details.localPosition.dx);
    if (_lastTapUp != null &&
        _lastLeftHalf == left &&
        now.difference(_lastTapUp!) <= kDoubleTapTimeout) {
      _lastTapUp = null;
      _lastLeftHalf = null;
      widget.onDoubleTapHalf(left);
      return;
    }
    _lastTapUp = now;
    _lastLeftHalf = left;
    widget.onSingleTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: _handleTapUp,
      child: widget.child,
    );
  }
}

class _JumpButton extends StatelessWidget {
  const _JumpButton({required this.forward, required this.onPressed});

  final bool forward;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = RetroPalette.of(context);
    // Same gray as a disabled Save and the equalizer Reset label.
    final ink = palette.textMuted;
    final label = forward ? l10n.jumpForward : l10n.jumpBack;
    const size = RetroSpacing.transportSkipSize;

    return Focus(
      child: Tooltip(
        message: withDesktopShortcut(
          context,
          label,
          shortcut: forward
              ? DesktopShortcuts.seekForward
              : DesktopShortcuts.seekBack,
        ),
        child: Material(
          color: palette.iconChip,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: SizedBox(
              width: size,
              height: size,
              child: CustomPaint(
                painter: _JumpArcPainter(forward: forward, color: ink),
                child: Center(
                  child: Text(
                    forward ? '+15' : '-15',
                    style: RetroTypography.jumpSecondsLabel(ink),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Three-quarter circle, open on the left for back and on the right for
/// forward, with the arrowhead on the top end.
class _JumpArcPainter extends CustomPainter {
  const _JumpArcPainter({required this.forward, required this.color});

  final bool forward;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    // Far enough out that the ±15 sits clear of the stroke.
    final radius = size.shortestSide * 0.36;
    final strokeWidth = size.shortestSide * 0.065;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    // Back sweeps counterclockwise and ends at the upper-left tip.
    // Forward sweeps clockwise and ends at the upper-right tip.
    final start = forward ? math.pi / 4 : 3 * math.pi / 4;
    final sweep = forward ? 3 * math.pi / 2 : -3 * math.pi / 2;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      sweep,
      false,
      stroke,
    );

    final end = start + sweep;
    final tangent = forward
        ? Offset(-math.sin(end), math.cos(end))
        : Offset(math.sin(end), -math.cos(end));
    // Base sits on the stroke end, wider than the line so the join is centered.
    final base = center + Offset(math.cos(end), math.sin(end)) * radius;
    final headLen = size.shortestSide * 0.16;
    final headHalf = strokeWidth * 1.35;
    final normal = Offset(-tangent.dy, tangent.dx);
    final tip = base + tangent * headLen;
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(
        base.dx + normal.dx * headHalf,
        base.dy + normal.dy * headHalf,
      )
      ..lineTo(
        base.dx - normal.dx * headHalf,
        base.dy - normal.dy * headHalf,
      )
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_JumpArcPainter oldDelegate) =>
      oldDelegate.forward != forward || oldDelegate.color != color;
}
