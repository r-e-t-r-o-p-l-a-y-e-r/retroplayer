import 'package:audio_service/audio_service.dart';
import 'package:retroplayer/app_branding.dart';

/// Android [AudioService] notification and foreground-service policy.
///
/// [androidStopForegroundOnPause] must stay false so lockscreen/notification
/// transport can reach the handler while paused (Android 12+).
AudioServiceConfig retroPlayerAndroidAudioServiceConfig() {
  return AudioServiceConfig(
    androidNotificationChannelId: AppBranding.notificationChannelId,
    androidNotificationChannelName: AppBranding.displayName,
    androidNotificationOngoing: false,
    androidStopForegroundOnPause: false,
  );
}
