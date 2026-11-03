package app.retroplayer.ui.queue

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import app.retroplayer.data.db.LibraryRoot
import app.retroplayer.data.db.LibraryStore
import app.retroplayer.data.library.LibraryRepository
import app.retroplayer.data.library.PlaylistFiles
import app.retroplayer.data.library.QueueRepository
import app.retroplayer.data.settings.SettingsStore
import app.retroplayer.domain.Breadcrumbs
import app.retroplayer.domain.Crumb
import app.retroplayer.domain.LibraryPath
import app.retroplayer.domain.PlaylistEntries
import app.retroplayer.domain.model.AudioAlbum
import app.retroplayer.domain.model.AudioTrack
import app.retroplayer.domain.model.LibraryItem
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.flatMapLatest
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import javax.inject.Inject

sealed interface AddTracksConfirmResult {
    data class Added(val count: Int) : AddTracksConfirmResult
    data object NothingSelected : AddTracksConfirmResult
    data object NothingAdded : AddTracksConfirmResult
}

sealed interface AddTracksUiState {
    data object Loading : AddTracksUiState

    data class PickRoot(val roots: List<LibraryRoot>, val selected: Set<LibraryPath>) : AddTracksUiState

    data class Browse(
        val path: LibraryPath,
        val crumbs: List<Crumb>,
        val folders: List<LibraryPath>,
        val audio: List<LibraryItem>,
        val selected: Set<LibraryPath>,
        val complete: Boolean,
    ) : AddTracksUiState
}

@OptIn(ExperimentalCoroutinesApi::class)
@HiltViewModel
class AddTracksViewModel @Inject constructor(
    savedState: SavedStateHandle,
    private val repository: LibraryRepository,
    private val store: LibraryStore,
    private val queue: QueueRepository,
    private val settings: SettingsStore,
    private val playlists: PlaylistFiles,
) : ViewModel() {
    private val ordering = repository.albumOrdering()
    private val appendPlaylist = savedState.get<String>(PLAYLIST_PATH_ARG)?.let(::LibraryPath)
    private val browsePath = MutableStateFlow(savedState.get<String>(PATH_ARG)?.let(::LibraryPath))
    private val selected = MutableStateFlow(emptySet<LibraryPath>())

    val state: StateFlow<AddTracksUiState> = browsePath.flatMapLatest { path ->
        if (path == null) {
            combine(store.roots, selected) { roots, picked -> AddTracksUiState.PickRoot(roots, picked) }
        } else {
            combine(repository.folder(path), store.roots, selected) { view, roots, picked ->
                if (!view.exists) AddTracksUiState.Loading
                else {
                    val names = roots.associate { it.id to it.name }
                    AddTracksUiState.Browse(
                        path = path,
                        crumbs = Breadcrumbs.library(path) { names[it] },
                        folders = view.folders.map { it.path },
                        audio = view.items.filterNot { it is LibraryItem.Playlist },
                        selected = picked,
                        complete = view.complete,
                    )
                }
            }
        }
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), AddTracksUiState.Loading)

    fun openRoot(root: LibraryRoot) {
        browsePath.value = LibraryPath.root(root.id)
    }

    fun openFolder(path: LibraryPath) {
        browsePath.value = path
    }

    fun openCrumb(crumb: Crumb) {
        browsePath.value = crumb.path
    }

    fun toggleTrack(path: LibraryPath) {
        selected.value = selected.value.toggle(path)
    }

    fun toggleAlbum(album: AudioAlbum) {
        viewModelScope.launch {
            val paths = albumTracks(album).map { it.path }.toSet()
            selected.value = if (paths.all { it in selected.value }) selected.value - paths else selected.value + paths
        }
    }

    fun confirm(onResult: (AddTracksConfirmResult) -> Unit) {
        viewModelScope.launch {
            val picks = selected.value.toList()
            if (picks.isEmpty()) {
                onResult(AddTracksConfirmResult.NothingSelected)
                return@launch
            }
            val playlist = appendPlaylist
            if (playlist != null) {
                val existing = playlists.read(playlist).entries.map { it.path }.toSet()
                val roots = store.allRoots().map { LibraryPath.root(it.id) }
                val newPaths = PlaylistEntries.filterNew(picks, roots, existing)
                if (newPaths.isEmpty()) {
                    onResult(AddTracksConfirmResult.NothingAdded)
                    return@launch
                }
                val merged = existing.toList() + newPaths
                if (!playlists.overwrite(playlist, merged)) {
                    onResult(AddTracksConfirmResult.NothingAdded)
                    return@launch
                }
                onResult(AddTracksConfirmResult.Added(newPaths.size))
            } else {
                val existing = settings.session.first().queue.toSet()
                val roots = store.allRoots().map { LibraryPath.root(it.id) }
                val newPaths = PlaylistEntries.filterNew(picks, roots, existing)
                if (newPaths.isEmpty()) {
                    onResult(AddTracksConfirmResult.NothingAdded)
                    return@launch
                }
                onResult(AddTracksConfirmResult.Added(queue.add(newPaths)))
            }
        }
    }

    suspend fun selectedAlbumTrackPaths(album: AudioAlbum): List<LibraryPath> =
        albumTracks(album).map { it.path }.filter { it in selected.value }

    private suspend fun albumTracks(album: AudioAlbum): List<AudioTrack> =
        ordering.order(album.tracks, store.albumSort(album.id))

    private fun Set<LibraryPath>.toggle(path: LibraryPath): Set<LibraryPath> =
        if (path in this) this - path else this + path

    companion object {
        const val PATH_ARG = "path"
        const val PLAYLIST_PATH_ARG = "playlistPath"
    }
}
