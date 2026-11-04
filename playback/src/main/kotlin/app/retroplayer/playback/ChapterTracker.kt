package app.retroplayer.playback

import androidx.media3.common.MediaItem
import androidx.media3.common.Player
import app.retroplayer.domain.ChapterNavigation
import app.retroplayer.domain.model.Chapter
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch

/** Chapters of the track [player] is on; loaded with [load] when the track changes, reported to [onChange]. Main thread. */
class ChapterTracker(
    private val player: Player,
    private val scope: CoroutineScope,
    private val load: suspend (MediaItem) -> List<Chapter>,
    private val onChange: (List<Chapter>) -> Unit = {},
) {
    var chapters: List<Chapter> = emptyList()
        private set

    private var loading: Job? = null

    init {
        player.addListener(object : Player.Listener {
            override fun onMediaItemTransition(mediaItem: MediaItem?, reason: Int) = refresh()
        })
        refresh()
    }

    fun previousTarget(): Long? = ChapterNavigation.previous(chapters, player.currentPosition)

    fun nextTarget(): Long? = ChapterNavigation.next(chapters, player.currentPosition)

    private fun refresh() {
        loading?.cancel()
        update(emptyList())
        val item = player.currentMediaItem ?: return
        loading = scope.launch {
            val loaded = load(item)
            if (player.currentMediaItem?.mediaId == item.mediaId) update(loaded)
        }
    }

    private fun update(new: List<Chapter>) {
        if (new == chapters) return
        chapters = new
        onChange(new)
    }
}
