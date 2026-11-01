import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:retroplayer/domain/models/equalizer_band.dart';
import 'package:retroplayer/domain/models/equalizer_preset.dart';
import 'package:retroplayer/l10n/app_localizations.dart';
import 'package:retroplayer/ui/core/retro/retro_palette.dart';
import 'package:retroplayer/ui/l10n/l10n_extensions.dart';
import 'package:retroplayer/ui/core/retro/retro_typography.dart';
import 'package:retroplayer/ui/features/settings/view_models/equalizer_view_model.dart';
import 'package:retroplayer/ui/features/settings/widgets/settings_focus.dart';

/// Inline equalizer controls for the Settings screen.
class EqualizerSection extends StatelessWidget {
  const EqualizerSection({
    super.key,
    this.presetLineIndex = 2,
    this.resetLineIndex = 3,
    this.firstBandLineIndex = 4,
  });

  final int presetLineIndex;
  final int resetLineIndex;
  final int firstBandLineIndex;

  String _formatHz(int hz) {
    if (hz >= 1000) {
      final k = hz / 1000;
      return k == k.roundToDouble() ? '${k.toInt()}k' : '${k.toStringAsFixed(1)}k';
    }
    return '$hz';
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EqualizerViewModel>();
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!vm.isSupported)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              l10n.equalizerUnavailable,
              style: TextStyle(color: RetroPalette.of(context).textMuted),
            ),
          ),
        SettingsFocusLine(
          lineIndex: presetLineIndex,
          child: SegmentedButton<EqualizerPreset>(
            showSelectedIcon: false,
            segments: [
              for (final preset in EqualizerPreset.values)
                ButtonSegment(
                  value: preset,
                  label: Text(preset.label(l10n)),
                ),
            ],
            selected: {vm.selectedPreset},
            onSelectionChanged: vm.isSupported
                ? (selection) => vm.selectPreset(selection.first)
                : null,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(l10n.bands, style: RetroTypography.sectionHeader(context)),
                  const Spacer(),
                  SettingsFocusLine(
                    lineIndex: resetLineIndex,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: vm.isSupported ? vm.resetBands : null,
                      child: Text(
                        l10n.reset,
                        style: RetroTypography.sectionHeader(context),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              for (var i = 0; i < vm.bands.length; i++)
                SettingsFocusLine(
                  lineIndex: firstBandLineIndex + i,
                  child: _BandSlider(
                    band: vm.bands[i],
                    label: _formatHz(vm.bands[i].centerHz),
                    enabled: vm.isSupported,
                    onChanged: (gain) =>
                        vm.setBandGain(vm.bands[i].centerHz, gain),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BandSlider extends StatefulWidget {
  const _BandSlider({
    required this.band,
    required this.label,
    required this.enabled,
    required this.onChanged,
  });

  final EqualizerBand band;
  final String label;
  final bool enabled;
  final ValueChanged<double> onChanged;

  @override
  State<_BandSlider> createState() => _BandSliderState();
}

class _BandSliderState extends State<_BandSlider> {
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  double get _step =>
      (EqualizerBand.maxGainDb - EqualizerBand.minGainDb) / 24;

  void _nudge(int direction) {
    if (!widget.enabled) return;
    final next = (widget.band.gainDb + direction * _step)
        .clamp(EqualizerBand.minGainDb, EqualizerBand.maxGainDb);
    widget.onChanged(next);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent || !widget.enabled) {
      return KeyEventResult.ignored;
    }

    return switch (event.logicalKey) {
      LogicalKeyboardKey.arrowLeft => () {
          _nudge(-1);
          return KeyEventResult.handled;
        }(),
      LogicalKeyboardKey.arrowRight => () {
          _nudge(1);
          return KeyEventResult.handled;
        }(),
      LogicalKeyboardKey.arrowUp => () {
          SettingsFocusRegistryProvider.of(context).moveLine(-1);
          return KeyEventResult.handled;
        }(),
      LogicalKeyboardKey.arrowDown => () {
          SettingsFocusRegistryProvider.of(context).moveLine(1);
          return KeyEventResult.handled;
        }(),
      _ => KeyEventResult.ignored,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              widget.label,
              style: RetroTypography.timeLabel(context, compact: true),
            ),
          ),
          Expanded(
            child: Focus(
              focusNode: _focusNode,
              onKeyEvent: _onKey,
              child: Builder(
                builder: (context) {
                  final focused = Focus.of(context).hasFocus;
                  final palette = RetroPalette.of(context);
                  return Listener(
                    onPointerDown: (_) => _focusNode.requestFocus(),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: focused
                            ? Border.all(color: palette.accent, width: 2)
                            : null,
                      ),
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 2,
                          overlayShape:
                              const RoundSliderOverlayShape(overlayRadius: 10),
                        ),
                        child: ExcludeFocus(
                          child: Slider(
                            value: widget.band.gainDb,
                            min: EqualizerBand.minGainDb,
                            max: EqualizerBand.maxGainDb,
                            divisions: 24,
                            label: '${widget.band.gainDb.round()} dB',
                            onChanged:
                                widget.enabled ? widget.onChanged : null,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(
            width: 48,
            child: Text(
              '${widget.band.gainDb.round()} dB',
              style: RetroTypography.timeLabel(context, compact: true),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
