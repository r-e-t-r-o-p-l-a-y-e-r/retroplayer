import 'package:flutter/material.dart';
import 'package:retroplayer/ui/core/format.dart';
import 'package:retroplayer/ui/core/retro/retro_spacing.dart';
import 'package:retroplayer/ui/core/retro/retro_typography.dart';
import 'package:retroplayer/ui/features/player/view_models/player_view_model.dart';

/// Thin scrubber with monospace elapsed/total time labels.
class RetroProgressBar extends StatefulWidget {
  const RetroProgressBar({
    super.key,
    required this.viewModel,
    this.compact = false,
  });

  final PlayerViewModel viewModel;
  final bool compact;

  @override
  State<RetroProgressBar> createState() => _RetroProgressBarState();
}

class _RetroProgressBarState extends State<RetroProgressBar> {
  double? _dragMs;

  void _clearDrag() {
    if (_dragMs == null) return;
    setState(() => _dragMs = null);
  }

  @override
  Widget build(BuildContext context) {
    // Listen here so elapsed time keeps updating even if a parent only `read`s
    // the view model (or rebuilds are skipped during sheet transitions).
    return ListenableBuilder(
      listenable: Listenable.merge([
        widget.viewModel,
        widget.viewModel.positionListenable,
      ]),
      builder: (context, _) => _buildBar(context),
    );
  }

  Widget _buildBar(BuildContext context) {
    final vm = widget.viewModel;
    if (!vm.hasSession) return const SizedBox.shrink();

    final maxMs = vm.duration.inMilliseconds;
    final enabled = maxMs > 0;
    final rawPositionMs = vm.position.inMilliseconds;
    // When duration is still unknown, keep showing elapsed time instead of
    // clamping to 0 (which looked like a frozen progress bar).
    final positionMs = _dragMs ??
        (enabled ? rawPositionMs.clamp(0, maxMs) : rawPositionMs).toDouble();
    final sliderMax = enabled ? maxMs.toDouble() : 1.0;
    final sliderValue =
        enabled ? positionMs.clamp(0.0, sliderMax).toDouble() : 0.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: widget.compact
                ? RetroSpacing.progressTrackHeight
                : RetroSpacing.progressTrackHeight + 1,
            thumbShape: RoundSliderThumbShape(
              enabledThumbRadius: widget.compact
                  ? RetroSpacing.progressThumbRadius - 1
                  : RetroSpacing.progressThumbRadius,
            ),
            overlayShape: RoundSliderOverlayShape(
              overlayRadius: widget.compact ? 12 : 16,
            ),
          ),
          child: Listener(
            onPointerCancel: (_) => _clearDrag(),
            child: Slider(
              value: sliderValue,
              max: sliderMax,
              onChangeStart: enabled
                  ? (v) => setState(() => _dragMs = v)
                  : null,
              onChanged: enabled ? (v) => setState(() => _dragMs = v) : null,
              onChangeEnd: enabled
                  ? (v) {
                      setState(() => _dragMs = null);
                      vm.seek(Duration(milliseconds: v.round()));
                    }
                  : null,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: widget.compact ? 4 : 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatDuration(Duration(milliseconds: positionMs.round())),
                style: RetroTypography.timeLabel(
                  context,
                  compact: widget.compact,
                ),
              ),
              Text(
                formatDuration(vm.duration),
                style: RetroTypography.timeLabel(
                  context,
                  compact: widget.compact,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Backwards-compatible alias used by existing imports.
typedef PlaybackProgressBar = RetroProgressBar;
