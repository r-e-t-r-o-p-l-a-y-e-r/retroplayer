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
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.map
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
        /** Listed folders whose every track is selected. */
        val checkedFolders: Set<LibraryPath> = emptySet(),
    ) : AddTracksUiState

    data class AlbumTracks(
        val album: AudioAlbum,
        val crumbs: List<Crumb>,
        val tracks: List<AudioTrack>,
        val selected: Set<LibraryPath>,
    ) : AddTracksUiState
}

private sealed interface PickLocation {
    data class Folder(val path: LibraryPath) : PickLocation
    data class Album(val album: AudioAlbum) : PickLocation
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
    private val location = MutableStateFlow<PickLocation?>(savedState.get<String>(PATH_ARG)?.let { PickLocation.Folder(LibraryPath(it)) })
    private val history = MutableStateFlow(emptyList<PickLocation?>())

    /** True while [back] steps inside the picker instead of closing it. */
    val canStepBack: StateFlow<Boolean> = history.map { it.isNotEmpty() }
        .stateIn(viewModelScope, SharingStarted.Eagerly, false)
    private val selected = MutableStateFlow(emptySet<LibraryPath>())
    private val folderTracks = MutableStateFlow(emptyMap<LibraryPath, List<LibraryPath>>())

    val state: StateFlow<AddTracksUiState> = location.flatMapLatest { at ->
        when (at) {
            null -> combine(store.roots, selected) { roots, picked -> AddTracksUiState.PickRoot(roots, picked) }
            is PickLocation.Folder -> browse(at.path)
            is PickLocation.Album -> pickInAlbum(at.album)
        }
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), AddTracksUiState.Loading)

    private fun browse(path: LibraryPath) =
        combine(repository.folder(path), store.roots, selected, folderTracks) { view, roots, picked, underFolders ->
            if (!view.exists) AddTracksUiState.Loading
            else {
                val names = roots.associate { it.id to it.name }
                val folders = view.folders.map { it.path }
                AddTracksUiState.Browse(
                    path = path,
                    crumbs = Breadcrumbs.library(path) { names[it] },
                    folders = folders,
                    audio = view.items.filterNot { it is LibraryItem.Playlist },
                    selected = picked,
                    complete = view.complete,
                    checkedFolders = folders.filter { folder ->
                        underFolders[folder]?.let { it.isNotEmpty() && picked.containsAll(it) } == true
                    }.toSet(),
                )
            }
        }

    private fun pickInAlbum(album: AudioAlbum) =
        combine(flow { emit(albumTracks(album)) }, store.roots, selected) { tracks, roots, picked ->
            val names = roots.associate { it.id to it.name }
            AddTracksUiState.AlbumTracks(album, Breadcrumbs.library(album.directory) { names[it] }, tracks, picked)
        }

    fun openRoot(root: LibraryRoot) = go(PickLocation.Folder(LibraryPath.root(root.id)))

    fun openFolder(path: LibraryPath) = go(PickLocation.Folder(path))

    fun openAlbum(album: AudioAlbum) = go(PickLocation.Album(album))

    fun openCrumb(crumb: Crumb) = go(crumb.path?.let(PickLocation::Folder))

    /** Steps back to the previous place; false when the picker should close. */
    fun back(): Boolean {
        val previous = history.value
        if (previous.isEmpty()) return false
        history.value = previous.dropLast(1)
        location.value = previous.last()
        return true
    }

    private fun go(to: PickLocation?) {
        if (to == location.value) return
        history.value += location.value
        location.value = to
    }

    fun toggleTrack(path: LibraryPath) {
        selected.value = selected.value.toggle(path)
    }

    /** Selects every track under [folder] in play order, or clears them when all are selected. */
    fun toggleFolder(folder: LibraryPath) {
        viewModelScope.launch {
            val paths = folderTracks.value[folder] ?: repository.folderQueue(folder).map { it.path }.also { tracks ->
                folderTracks.value += folder to tracks
            }
            selected.value = if (paths.all { it in selected.value }) selected.value - paths.toSet() else selected.value + paths
        }
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
