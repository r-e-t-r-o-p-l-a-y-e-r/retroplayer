package app.retroplayer.ui.widget

import android.content.Context
import android.graphics.Bitmap
import androidx.annotation.OptIn
import androidx.core.graphics.scale
import androidx.core.net.toUri
import androidx.glance.appwidget.updateAll
import androidx.media3.common.util.UnstableApi
import app.retroplayer.playback.ApplicationScope
import app.retroplayer.playback.EmbeddedArtBitmapLoader
import app.retroplayer.playback.NowPlayingSink
import app.retroplayer.playback.NowPlayingSnapshot
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import javax.inject.Inject
import javax.inject.Singleton

/** Keeps the session's snapshot for the widget and redraws placed widgets when it changes. */
@OptIn(UnstableApi::class)
@Singleton
class WidgetUpdater @Inject constructor(
    @ApplicationContext private val context: Context,
    @ApplicationScope private val scope: CoroutineScope,
) : NowPlayingSink {
    private val state = MutableStateFlow<NowPlayingSnapshot?>(null)
    val current: StateFlow<NowPlayingSnapshot?> = state

    private val artLoader by lazy { EmbeddedArtBitmapLoader(context) }
    private var redraw: Job? = null

    override fun update(snapshot: NowPlayingSnapshot) {
        if (state.value == snapshot) return
        state.value = snapshot
        redraw?.cancel()
        redraw = scope.launch { RetroWidget().updateAll(context) }
    }

    /** Cover for the widget, small enough for the launcher's bitmap budget; null when it cannot load. */
    suspend fun loadArt(uri: String): Bitmap? = withContext(Dispatchers.IO) {
        runCatching { artLoader.loadBitmap(uri.toUri()).get() }.getOrNull()?.let(::shrink)
    }

    private fun shrink(bitmap: Bitmap): Bitmap {
        val scale = ART_PX.toFloat() / maxOf(bitmap.width, bitmap.height)
        if (scale >= 1f) return bitmap
        return bitmap.scale((bitmap.width * scale).toInt(), (bitmap.height * scale).toInt())
    }

    private companion object {
        const val ART_PX = 192
    }
}
