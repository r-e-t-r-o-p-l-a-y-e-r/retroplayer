package app.retroplayer.playback

import android.content.ComponentName
import android.content.Context
import androidx.annotation.OptIn
import androidx.media3.common.MediaItem
import androidx.media3.common.Player
import androidx.media3.common.util.UnstableApi
import androidx.media3.session.MediaController
import androidx.media3.session.SessionToken
import app.retroplayer.data.db.LibraryStore
import app.retroplayer.data.settings.SettingsStore
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.guava.await
import kotlinx.coroutines.launch
import javax.inject.Inject
import javax.inject.Singleton

/** Connects the UI to [PlaybackService] through a Media3 controller. Main thread only. */
@Singleton
class PlayerConnection @Inject constructor(
    @ApplicationContext private val context: Context,
    @ApplicationScope private val scope: CoroutineScope,
    private val store: LibraryStore,
    private val settings: SettingsStore,
) : PlaybackControls {
    private val state = MutableStateFlow(NowPlaying())
    override val nowPlaying: StateFlow<NowPlaying> = state

    private var controller: MediaController? = null
    private var pending: (MediaController.() -> Unit)? = null
    private var ticker: Job? = null

    private val listener = object : Player.Listener {
        override fun onEvents(player: Player, events: Player.Events) {
            publish()
            updateTicker()
        }
    }

    init {
        scope.launch { connect() }
    }

    @OptIn(UnstableApi::class)
    private suspend fun connect() {
        val token = SessionToken(context, ComponentName(context, PlaybackService::class.java))
        val connected = runCatching { MediaController.Builder(context, token).buildAsync().await() }.getOrNull() ?: return
        controller = connected
        connected.addListener(listener)
        if (connected.mediaItemCount == 0) restoreLastItem(connected)
        pending?.invoke(connected)
        pending = null
        publish()
        updateTicker()
    }

    /** UC-01: the last item comes back paused at its bookmark; its saved title shows until the engine is ready. */
    private suspend fun restoreLastItem(controller: MediaController) {
        val lastItem = settings.session.first().lastItemId ?: return
        store.playback(lastItem)?.let { saved ->
            state.value = NowPlaying(
                itemId = lastItem,
                trackId = saved.trackId,
                title = saved.displayTitle,
                subtitle = saved.subtitle,
                positionMs = saved.positionMs,
                durationMs = saved.durationMs ?: 0,
                speed = saved.speed,
            )
        }
        if (pending == null) {
            controller.setMediaItem(PlaybackRequests.request(lastItem))
            controller.prepare()
        }
    }

    override fun play(itemId: String, startTrackId: String?) = withController {
        if (PlaybackRequests.itemIdOf(currentMediaItem) == itemId) {
            val index = startTrackId?.let { id -> (0 until mediaItemCount).firstOrNull { getMediaItemAt(it).mediaId == id } }
            if (index != null && index != currentMediaItemIndex) seekTo(index, 0)
            play()
        } else {
            setMediaItem(PlaybackRequests.request(itemId, startTrackId))
            prepare()
            play()
        }
    }

    private fun withController(action: MediaController.() -> Unit) {
        val current = controller
        if (current != null) current.action() else pending = action
    }

    private fun publish() {
        val c = controller ?: return
        val item: MediaItem = c.currentMediaItem ?: return
        val metadata = c.mediaMetadata
        state.value = NowPlaying(
            itemId = PlaybackRequests.itemIdOf(item),
            trackId = item.mediaId,
            title = metadata.title?.toString(),
            subtitle = (metadata.artist ?: metadata.albumTitle)?.toString(),
            artworkUri = metadata.artworkUri?.toString(),
            isPlaying = c.isPlaying,
            hasTrack = c.playbackState != Player.STATE_IDLE,
            positionMs = c.currentPosition.coerceAtLeast(0),
            durationMs = c.duration.coerceAtLeast(0),
            speed = c.playbackParameters.speed,
        )
    }

    private fun updateTicker() {
        val playing = controller?.isPlaying == true
        if (playing && ticker?.isActive != true) {
            ticker = scope.launch {
                while (true) {
                    delay(POSITION_TICK_MS)
                    publish()
                }
            }
        } else if (!playing) {
            ticker?.cancel()
            ticker = null
        }
    }

    private companion object {
        const val POSITION_TICK_MS = 500L
    }
}
