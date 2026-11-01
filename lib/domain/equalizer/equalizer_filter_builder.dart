import 'package:retroplayer/domain/models/equalizer_settings.dart';

/// Builds MPV `af` filter chains from [EqualizerSettings].
class EqualizerFilterBuilder {
  const EqualizerFilterBuilder();

  String? toMpvAfChain(EqualizerSettings settings) {
    if (!settings.isEnabled) return null;

    final filters = <String>[];
    for (final band in settings.effectiveBands()) {
      if (band.gainDb.abs() < 0.01) continue;
      filters.add(
        'equalizer=f=${band.centerHz}:width_type=o:width=${_widthFor(band.centerHz)}:g=${_formatGain(band.gainDb)}',
      );
    }
    if (filters.isEmpty) return null;
    return filters.join(',');
  }

  int _widthFor(int centerHz) => centerHz < 500 ? 1 : 2;

  String _formatGain(double gainDb) {
    final rounded = (gainDb * 10).round() / 10;
    if (rounded == rounded.roundToDouble()) {
      return rounded.toInt().toString();
    }
    return rounded.toString();
  }
}
