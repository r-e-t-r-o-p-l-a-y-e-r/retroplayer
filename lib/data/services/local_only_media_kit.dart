import 'package:just_audio_media_kit/just_audio_media_kit.dart';

/// Restricts MPV to local `file` protocol only (no http/https/streaming).
///
/// Call before [JustAudioMediaKit.ensureInitialized].
void configureLocalOnlyMediaKit() {
  JustAudioMediaKit.protocolWhitelist = const ['file'];
}
