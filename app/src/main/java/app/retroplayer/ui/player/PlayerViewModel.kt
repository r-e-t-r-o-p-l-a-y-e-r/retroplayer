package app.retroplayer.ui.player

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import app.retroplayer.data.chapters.ChapterRepository
import app.retroplayer.data.db.LibraryStore
import app.retroplayer.domain.Breadcrumbs
import app.retroplayer.domain.ChapterNavigation
import app.retroplayer.domain.Crumb
import app.retroplayer.domain.LibraryPath
import app.retroplayer.domain.TransportRules
import app.retroplayer.domain.model.AudioTrack
import app.retroplayer.domain.model.Chapter
import app.retroplayer.domain.model.TrackMetadata
import app.retroplayer.playback.NowPlaying
import app.retroplayer.playback.PlaybackControls
import app.retroplayer.ui.art.EmbeddedArt
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.mapLatest
import kotlinx.coroutines.flow.stateIn
import javax.inject.Inject

data class PlayerUiState(
    val nowPlaying: NowPlaying = NowPlaying(),
    val crumbs: List<Crumb> = emptyList(),
    val chapters: List<Chapter> = emptyList(),
) {
    val currentChapter: Chapter? get() = ChapterNavigation.current(chapters, nowPlaying.positionMs)

    /** The player shows once something is loaded or restored. */
    val visible: Boolean get() = nowPlaying.hasTrack || nowPlaying.title != null

    /** Folder picture uri, or the track itself when the service fell back to its embedded picture. */
    val artModel: Any? get() = nowPlaying.artworkUri?.let { if (it == nowPlaying.trackUri) EmbeddedArt(it) else it }
}

@OptIn(ExperimentalCoroutinesApi::class)
@HiltViewModel
class PlayerViewModel @Inject constructor(
    private val controls: PlaybackControls,
    store: LibraryStore,
    chapterRepository: ChapterRepository,
) : ViewModel() {
    private val chapters = controls.nowPlaying
        .map { it.trackUri to it.trackId }
        .distinctUntilChanged()
        .mapLatest { (uri, id) -> if (uri == null || id == null) emptyList() else chapterRepository.chapters(uri, LibraryPath(id).name) }

    val state: StateFlow<PlayerUiState> = combine(controls.nowPlaying, store.roots, chapters) { now, roots, chapters ->
        val names = roots.associate { it.id to it.name }
        PlayerUiState(now, crumbs(now) { names[it] }, chapters)
    }.stateIn(viewModelScope, SharingStarted.Eagerly, PlayerUiState())

    fun toggle() = controls.togglePlayPause()

    fun previous() = controls.skipToPrevious()

    fun next() = controls.skipToNext()

    fun seekTo(positionMs: Long) = controls.seekTo(positionMs)

    fun jumpBack() = controls.jumpBack()

    fun jumpForward() = controls.jumpForward()

    fun previousChapter() {
        chapterTarget(ChapterNavigation::previous)?.let(controls::seekTo)
    }

    fun nextChapter() {
        chapterTarget(ChapterNavigation::next)?.let(controls::seekTo)
    }

    private fun chapterTarget(target: (List<Chapter>, Long) -> Long?): Long? =
        state.value.let { target(it.chapters, it.nowPlaying.positionMs) }

    fun setSpeed(speed: Float) = controls.setSpeed(speed)

    fun speedDown() = setSpeed(TransportRules.clampSpeed(controls.nowPlaying.value.speed - 0.25f))

    fun speedUp() = setSpeed(TransportRules.clampSpeed(controls.nowPlaying.value.speed + 0.25f))

    private fun crumbs(now: NowPlaying, rootName: (String) -> String?): List<Crumb> {
        val trackId = now.trackId ?: return emptyList()
        val track = AudioTrack(LibraryPath(trackId), now.trackUri.orEmpty(), TrackMetadata(title = now.title))
        return Breadcrumbs.playback(track, now.itemId, rootName)
    }
}
