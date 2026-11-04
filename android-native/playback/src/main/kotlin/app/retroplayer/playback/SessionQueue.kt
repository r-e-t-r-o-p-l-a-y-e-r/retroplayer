package app.retroplayer.playback

import android.net.Uri
import androidx.media3.common.MediaItem
import app.retroplayer.domain.LibraryPath
import app.retroplayer.domain.model.AudioTrack
import app.retroplayer.domain.model.PlaybackItem
import app.retroplayer.domain.model.SavedPlaybackState
import app.retroplayer.playback.QueueBuilder.toMediaItem

/** Turns controller requests, and the system's resumption request, into ready-to-play queues. */
class SessionQueue(
    private val items: suspend (String) -> PlaybackItem?,
    private val savedState: suspend (String) -> SavedPlaybackState?,
    private val lastItemId: suspend () -> String?,
    private val rememberLastItem: suspend (String) -> Unit,
    private val artwork: (AudioTrack) -> Uri?,
    /** Root id to the picked folder's name. */
    private val rootNames: suspend () -> Map<String, String> = { emptyMap() },
) {
    suspend fun prepare(request: PlaybackRequest): PreparedQueue? {
        val item = items(request.itemId) ?: return null
        val queue = QueueBuilder.build(item, savedState(item.id), request.startTrackId, folderNames(), artwork) ?: return null
        rememberLastItem(item.id)
        return queue
    }

    suspend fun resumption(): PreparedQueue? {
        val id = lastItemId() ?: return null
        val item = items(id) ?: return null
        return QueueBuilder.build(item, savedState(id), null, folderNames(), artwork)
    }

    /**
     * For controllers that add plain media ids (Assistant, Auto search): each
     * id plays its whole item. With [intoItemId] the tracks join that item
     * (queue edits while the queue plays).
     */
    suspend fun expand(mediaIds: List<String>, intoItemId: String? = null): List<MediaItem> {
        val folderName = folderNames()
        return mediaIds.flatMap { id ->
            val item = items(id) ?: return@flatMap emptyList()
            item.tracks.map { it.toMediaItem(intoItemId ?: item.id, artwork(it), folderName(it.directory)) }
        }
    }

    private suspend fun folderNames(): (LibraryPath) -> String {
        val names = rootNames()
        return { path -> if (path.isRoot) names[path.rootId] ?: path.name else path.name }
    }
}
