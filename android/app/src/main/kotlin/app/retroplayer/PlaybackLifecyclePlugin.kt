package app.retroplayer

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Notifies Dart when the launcher activity is finishing (Recents swipe).
 */
class PlaybackLifecyclePlugin {
    private var channel: MethodChannel? = null

    fun register(flutterEngine: FlutterEngine) {
        channel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL,
        )
    }

    fun notifyActivityTaskRemoved() {
        channel?.invokeMethod(METHOD_ACTIVITY_TASK_REMOVED, null)
    }

    companion object {
        const val CHANNEL = "app.retroplayer/playback_lifecycle"
        const val METHOD_ACTIVITY_TASK_REMOVED = "activityTaskRemoved"
    }
}
