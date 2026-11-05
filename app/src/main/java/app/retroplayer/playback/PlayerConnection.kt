package app.retroplayer.playback

import androidx.annotation.OptIn
import androidx.media3.common.MediaItem
import androidx.media3.common.Player
import androidx.media3.common.util.UnstableApi
import androidx.media3.common.util.Util
import app.retroplayer.data.db.LibraryStore
import app.retroplayer.data.settings.SettingsStore
import app.retroplayer.domain.LibraryPath
import app.retroplayer.domain.TransportRules
import app.retroplayer.domain.model.PlaybackItem
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharedFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.launch
import javax.inject.Inject
import javax.inject.Singleton

/** Connects the UI to [PlaybackService] through a Media3 controller. Main thread only. */
@Singleton
class PlayerConnection @Inject constructor(
    @ApplicationScope private val scope: CoroutineScope,
    private val store: LibraryStore,
    private val settings: SettingsStore,
    private val connector: PlayerConnector,
) : PlaybackControls {
    private val state = MutableStateFlow(NowPlaying())
    override val nowPlaying: StateFlow<NowPlaying> = state

    private val requests = MutableSharedFlow<String>(extraBufferCapacity = 8)
    override val playRequests: SharedFlow<String> = requests

    private var controller: Player? = null
    private var pending = listOf<Player.() -> Unit>()
    private var ticker: Job? = null

    private val listener = object : Player.Listener {
        override fun onEvents(player: Player, events: Player.Events) {
            publish()
            updateTicker()
        }
    }

    init {
        scope.launch { connect() }
        scope.launch { followStoredQueue() }
    }

    /** UC-08: edits of the stored queue reach the live player while the queue plays, without interrupting it. */
    private suspend fun followStoredQueue() {
        var last: List<LibraryPath>? = null
        settings.session.map { it.queue }.distinctUntilChanged().collect { queue ->
            last?.let { before -> withController { syncQueue(before, queue) } }
            last = queue
        }
    }

    private fun Player.syncQueue(before: List<LibraryPath>, after: List<LibraryPath>) {
        if (PlaybackRequests.itemIdOf(currentMediaItem) != PlaybackItem.QUEUE_ID) return
        if (after.isEmpty()) {
            stop()
            clearMediaItems()
            return
        }
        val wanted = after.map { it.value }
        val keep = wanted.toSet()
        for (index in mediaItemCount - 1 downTo 0) {
            if (getMediaItemAt(index).mediaId !in keep) removeMediaItem(index)
        }
        wanted.filter { it in mediaIds() }.forEachIndexed { to, id ->
            val from = mediaIds().indexOf(id)
            if (from != to) moveMediaItem(from, to)
        }
        // Only paths new to the stored queue: missing files that never resolved are not retried.
        val known = before.map { it.value }.toSet() + mediaIds()
        val added = wanted.filter { it !in known }
        if (added.isNotEmpty()) addMediaItems(added.map { PlaybackRequests.addition(it, PlaybackItem.QUEUE_ID) })
    }

    private fun Player.mediaIds() = List(mediaItemCount) { getMediaItemAt(it).mediaId }

    private suspend fun connect() {
        val connected = connector.connect() ?: return
        controller = connected
        connected.addListener(listener)
        if (connected.mediaItemCount == 0) restoreLastItem(connected)
        pending.forEach { connected.it() }
        pending = emptyList()
        publish()
        updateTicker()
    }

    /** UC-01: the last item comes back paused at its bookmark; its saved title shows until the engine is ready. */
    private suspend fun restoreLastItem(controller: Player) {
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
        if (pending.isEmpty()) {
            controller.setMediaItem(PlaybackRequests.request(lastItem))
            controller.prepare()
        }
    }

    override fun play(itemId: String, startTrackId: String?) {
        requests.tryEmit(itemId)
        load(itemId, startTrackId)
    }

    private fun load(itemId: String, startTrackId: String?) = withController {
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

    @OptIn(UnstableApi::class)
    override fun togglePlayPause() = withController { Util.handlePlayPauseButtonAction(this) }

    override fun seekTo(positionMs: Long) = withController { seekTo(positionMs.coerceAtLeast(0)) }

    override fun jumpBack() = withController { seekBack() }

    override fun jumpForward() = withController { seekForward() }

    override fun skipToPrevious() = withController { seekToPrevious() }

    override fun skipToNext() = withController { seekToNext() }

    override fun setSpeed(speed: Float) = withController { setPlaybackSpeed(TransportRules.clampSpeed(speed)) }

    override fun stop() = withController {
        stop()
        clearMediaItems()
    }

    private fun withController(action: Player.() -> Unit) {
        val current = controller
        if (current != null) current.action() else pending += action
    }

    private fun publish() {
        val c = controller ?: return
        val item: MediaItem = c.currentMediaItem ?: run {
            state.value = NowPlaying()
            return
        }
        val itemId = PlaybackRequests.itemIdOf(item)
        if (itemId == null) {
            // Still the unexpanded request: keep the restored snapshot.
            state.value = state.value.copy(isPlaying = c.isPlaying)
            return
        }
        val metadata = c.mediaMetadata
        state.value = NowPlaying(
            itemId = itemId,
            trackId = item.mediaId,
            title = metadata.title?.toString(),
            subtitle = (metadata.artist ?: metadata.albumTitle)?.toString(),
            artworkUri = metadata.artworkUri?.toString(),
            trackUri = PlaybackRequests.trackUriOf(item),
            isPlaying = c.isPlaying,
            hasTrack = c.playbackState != Player.STATE_IDLE,
            positionMs = c.currentPosition.coerceAtLeast(0),
            durationMs = c.duration.coerceAtLeast(0),
            speed = c.playbackParameters.speed,
            queueIndex = c.currentMediaItemIndex,
            queueSize = c.mediaItemCount,
            hasPrevious = c.hasPreviousMediaItem(),
            hasNext = c.hasNextMediaItem(),
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
