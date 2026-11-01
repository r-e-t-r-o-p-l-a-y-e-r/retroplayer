/// Title, subtitle and cover for whatever is playing. No Flutter types.
class NowPlayingInfo {
  const NowPlayingInfo({
    this.title = '',
    this.subtitle = '',
    this.coverArtPath,
    this.itemId,
  });

  final String title;
  final String subtitle;
  final String? coverArtPath;
  final String? itemId;
}
