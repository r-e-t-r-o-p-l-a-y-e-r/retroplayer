/// EqualizerSettings to MPV af filter-chain mapping.
///
/// Evidence:
/// - `manual flat settings produce no mpv filter`
/// - `bass preset produces low-frequency mpv filters`
/// - `custom bands skip near-zero gains`
library;
import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/domain/equalizer/equalizer_filter_builder.dart';
import 'package:retroplayer/domain/models/equalizer_band.dart';
import 'package:retroplayer/domain/models/equalizer_preset.dart';
import 'package:retroplayer/domain/models/equalizer_settings.dart';

void main() {
  const builder = EqualizerFilterBuilder();

  test('manual flat settings produce no mpv filter', () {
    expect(builder.toMpvAfChain(EqualizerSettings.manual()), isNull);
  });

  test('bass preset produces low-frequency mpv filters', () {
    final chain = builder.toMpvAfChain(
      EqualizerSettings.fromPreset(EqualizerPreset.bassBoost),
    );
    expect(chain, isNotNull);
    expect(chain, contains('equalizer=f=60'));
    expect(chain, contains('equalizer=f=230'));
  });

  test('custom bands skip near-zero gains', () {
    final chain = builder.toMpvAfChain(
      EqualizerSettings.custom([
        const EqualizerBand(centerHz: 60, gainDb: 6),
        const EqualizerBand(centerHz: 230, gainDb: 0),
        const EqualizerBand(centerHz: 910, gainDb: 0),
        const EqualizerBand(centerHz: 3600, gainDb: 0),
        const EqualizerBand(centerHz: 14000, gainDb: 0),
      ]),
    );
    expect(chain, 'equalizer=f=60:width_type=o:width=1:g=6');
  });
}
