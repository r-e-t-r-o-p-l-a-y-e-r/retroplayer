package app.retroplayer.ui.album

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import app.retroplayer.data.db.LibraryStore
import app.retroplayer.data.library.LibraryRepository
import app.retroplayer.data.settings.SettingsStore
import app.retroplayer.domain.AlbumSortSelection
import app.retroplayer.domain.Breadcrumbs
import app.retroplayer.domain.Crumb
import app.retroplayer.domain.model.AlbumSortChoice
import app.retroplayer.domain.model.AlbumSortMode
import app.retroplayer.domain.model.AudioAlbum
import app.retroplayer.domain.model.AudioTrack
import app.retroplayer.playback.PlaybackControls
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import javax.inject.Inject

sealed interface AlbumUiState {
    data object Loading : AlbumUiState
    data object NotFound : AlbumUiState
    data class Ready(
        val album: AudioAlbum,
        val tracks: List<AudioTrack>,
        val mode: AlbumSortMode,
        val tagsUsable: Boolean,
        val crumbs: List<Crumb>,
    ) : AlbumUiState
}

/** Album detail: tracks in the album's effective order, with a per-album sort choice. */
@HiltViewModel
class AlbumViewModel @Inject constructor(
    savedState: SavedStateHandle,
    private val repository: LibraryRepository,
    private val store: LibraryStore,
    private val settings: SettingsStore,
    private val playback: PlaybackControls,
) : ViewModel() {
    val albumId: String = checkNotNull(savedState.get<String>(ALBUM_ID_ARG))

    private val ordering = repository.albumOrdering()
    private var album: AudioAlbum? = null

    val state: StateFlow<AlbumUiState> = combine(
        flow { emit(repository.album(albumId).also { album = it }) },
        store.albumSorts,
        store.roots,
    ) { album, sorts, roots ->
        if (album == null) return@combine AlbumUiState.NotFound
        val choice = sorts[albumId] ?: AlbumSortChoice.AUTOMATIC
        val names = roots.associate { it.id to it.name }
        AlbumUiState.Ready(
            album = album,
            tracks = ordering.order(album.tracks, choice),
            mode = ordering.effectiveMode(album.tracks, choice),
            tagsUsable = ordering.tagsUsable(album.tracks),
            crumbs = Breadcrumbs.library(album.directory) { names[it] },
        )
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(STOP_TIMEOUT_MS), AlbumUiState.Loading)

    private val pendingConfirm = MutableStateFlow<Int?>(null)

    /** Number of tracks without a track number while "sort by tag anyway?" is being asked. */
    val confirmTagOrder: StateFlow<Int?> = pendingConfirm.asStateFlow()

    fun selectSort(mode: AlbumSortMode) {
        val tracks = album?.tracks ?: return
        when (val selection = ordering.select(mode, tracks)) {
            is AlbumSortSelection.Store -> store(selection.choice)
            is AlbumSortSelection.ConfirmTagOrder -> pendingConfirm.value = selection.missingTrackNumbers
        }
    }

    fun confirmTagOrder() {
        pendingConfirm.value = null
        store(AlbumSortChoice.TAG_FORCED)
    }

    fun dismissTagOrder() {
        pendingConfirm.value = null
    }

    fun play(track: AudioTrack) = playback.play(albumId, track.id)

    fun playAll() = playback.play(albumId)

    fun onShown() {
        viewModelScope.launch { settings.setOpenAlbum(albumId) }
    }

    fun onClosed() {
        viewModelScope.launch { settings.setOpenAlbum(null) }
    }

    private fun store(choice: AlbumSortChoice) {
        viewModelScope.launch { store.setAlbumSort(albumId, choice) }
    }

    companion object {
        const val ALBUM_ID_ARG = "albumId"
        private const val STOP_TIMEOUT_MS = 5_000L
    }
}
