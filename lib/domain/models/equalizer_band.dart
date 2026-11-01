/// Fixed 5-band equalizer layout shared across platforms.
class EqualizerBand {
  const EqualizerBand({required this.centerHz, required this.gainDb});

  final int centerHz;
  final double gainDb;

  static const standardFrequencies = [60, 230, 910, 3600, 14000];

  static const minGainDb = -12.0;
  static const maxGainDb = 12.0;

  static List<EqualizerBand> flat() => [
        for (final hz in standardFrequencies) EqualizerBand(centerHz: hz, gainDb: 0),
      ];

  EqualizerBand clampGain() => EqualizerBand(
        centerHz: centerHz,
        gainDb: gainDb.clamp(minGainDb, maxGainDb),
      );

  Map<String, dynamic> toJson() => {
        'hz': centerHz,
        'gainDb': gainDb,
      };

  factory EqualizerBand.fromJson(Map<String, dynamic> json) {
    return EqualizerBand(
      centerHz: (json['hz'] as num).toInt(),
      gainDb: (json['gainDb'] as num).toDouble(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EqualizerBand &&
          centerHz == other.centerHz &&
          gainDb == other.gainDb;

  @override
  int get hashCode => Object.hash(centerHz, gainDb);
}
