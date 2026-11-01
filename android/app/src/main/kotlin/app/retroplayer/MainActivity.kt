package app.retroplayer

import com.ryanheise.audioservice.AudioServiceActivity
import com.ryanheise.audioservice.AudioServicePlugin
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : AudioServiceActivity() {
    private val equalizerPlugin = EqualizerPlugin()
    private val playbackLifecyclePlugin = PlaybackLifecyclePlugin()

    override fun getCachedEngineId(): String {
        AudioServicePlugin.getFlutterEngine(this)
        return AudioServicePlugin.getFlutterEngineId()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        equalizerPlugin.register(flutterEngine)
        playbackLifecyclePlugin.register(flutterEngine)
    }

    override fun onStop() {
        if (isFinishing) {
            playbackLifecyclePlugin.notifyActivityTaskRemoved()
        }
        super.onStop()
    }
}
