package app.retroplayer.ui.player

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import app.retroplayer.data.db.LibraryStore
import app.retroplayer.domain.Breadcrumbs
import app.retroplayer.domain.Crumb
import app.retroplayer.domain.LibraryPath
import app.retroplayer.domain.model.AudioTrack
import app.retroplayer.domain.model.TrackMetadata
import app.retroplayer.playback.NowPlaying
import app.retroplayer.playback.PlaybackControls
import app.retroplayer.ui.art.EmbeddedArt
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.stateIn
import javax.inject.Inject

data class PlayerUiState(
    val nowPlaying: NowPlaying = NowPlaying(),
    val crumbs: List<Crumb> = emptyList(),
) {
    /** The player shows once something is loaded or restored. */
    val visible: Boolean get() = nowPlaying.hasTrack || nowPlaying.title != null

    /** Folder picture uri, or the track itself when the service fell back to its embedded picture. */
    val artModel: Any? get() = nowPlaying.artworkUri?.let { if (it == nowPlaying.trackUri) EmbeddedArt(it) else it }
}

@HiltViewModel
class PlayerViewModel @Inject constructor(
    private val controls: PlaybackControls,
    store: LibraryStore,
) : ViewModel() {
    val state: StateFlow<PlayerUiState> = combine(controls.nowPlaying, store.roots) { now, roots ->
        val names = roots.associate { it.id to it.name }
        PlayerUiState(now, crumbs(now) { names[it] })
    }.stateIn(viewModelScope, SharingStarted.Eagerly, PlayerUiState())

    fun toggle() = controls.togglePlayPause()

    fun previous() = controls.skipToPrevious()

    fun next() = controls.skipToNext()

    fun seekTo(positionMs: Long) = controls.seekTo(positionMs)

    private fun crumbs(now: NowPlaying, rootName: (String) -> String?): List<Crumb> {
        val trackId = now.trackId ?: return emptyList()
        val track = AudioTrack(LibraryPath(trackId), now.trackUri.orEmpty(), TrackMetadata(title = now.title))
        return Breadcrumbs.playback(track, now.itemId, rootName)
    }
}
