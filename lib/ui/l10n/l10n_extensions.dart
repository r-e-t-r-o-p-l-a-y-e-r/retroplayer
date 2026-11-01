import 'package:retroplayer/domain/models/equalizer_preset.dart';
import 'package:retroplayer/l10n/app_localizations.dart';

extension EqualizerPresetL10n on EqualizerPreset {
  String label(AppLocalizations l10n) => switch (this) {
    EqualizerPreset.manual => l10n.eqManually,
    EqualizerPreset.bassBoost => l10n.eqBass,
    EqualizerPreset.trebleBoost => l10n.eqTreble,
    EqualizerPreset.voice => l10n.eqVoice,
  };
}
