package app.retroplayer.ui.library

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import app.retroplayer.data.db.LibraryRoot
import app.retroplayer.data.db.LibraryStore
import app.retroplayer.data.library.FolderEntry
import app.retroplayer.data.library.LibraryRepository
import app.retroplayer.data.library.QueueRepository
import app.retroplayer.playback.PlaybackItemResolver
import app.retroplayer.data.settings.SettingsStore
import app.retroplayer.domain.Breadcrumbs
import app.retroplayer.domain.Crumb
import app.retroplayer.domain.LibraryPath
import app.retroplayer.domain.model.LibraryItem
import app.retroplayer.domain.model.PlaybackItem
import app.retroplayer.domain.model.PlaylistRef
import app.retroplayer.library.RootAccess
import app.retroplayer.playback.PlaybackControls
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import javax.inject.Inject

data class FavoriteLink(val path: LibraryPath, val label: String, val rootName: String?)

data class FolderRow(val entry: FolderEntry, val isFavorite: Boolean)

sealed interface FolderUiState {
    data object Loading : FolderUiState
    data object Missing : FolderUiState
    data class Root(val roots: List<LibraryRoot>, val favorites: List<FavoriteLink>) : FolderUiState
    data class Folder(
        val path: LibraryPath,
        val crumbs: List<Crumb>,
        val folders: List<FolderRow>,
        val playlists: List<PlaylistRef>,
        val audio: List<LibraryItem>,
        val artUri: String?,
        val scanned: Int,
        val total: Int,
        val complete: Boolean,
    ) : FolderUiState
}

/** One library page: the virtual root (path null) or a folder below a root. */
@HiltViewModel
class FolderViewModel @Inject constructor(
    savedState: SavedStateHandle,
    private val repository: LibraryRepository,
    private val store: LibraryStore,
    private val settings: SettingsStore,
    private val playback: PlaybackControls,
    private val access: RootAccess,
    private val items: PlaybackItemResolver,
    private val queue: QueueRepository,
) : ViewModel() {
    val path: LibraryPath? = savedState.get<String>(PATH_ARG)?.let(::LibraryPath)

    val state: StateFlow<FolderUiState> = run {
        val path = path
        if (path == null) {
            combine(store.roots, store.favorites) { roots, favorites ->
                val names = roots.associate { it.id to it.name }
                FolderUiState.Root(roots, favorites.map { FavoriteLink(it, it.name, names[it.rootId]) })
            }
        } else {
            combine(repository.folder(path), store.favorites, store.roots) { view, favorites, roots ->
                if (!view.exists) return@combine FolderUiState.Missing
                val names = roots.associate { it.id to it.name }
                val favoriteSet = favorites.toSet()
                FolderUiState.Folder(
                    path = path,
                    crumbs = Breadcrumbs.library(path) { names[it] },
                    folders = view.folders.map { FolderRow(it, it.path in favoriteSet) },
                    playlists = view.items.filterIsInstance<LibraryItem.Playlist>().map { it.playlist },
                    audio = view.items.filterNot { it is LibraryItem.Playlist },
                    artUri = view.artUri,
                    scanned = view.scanned,
                    total = view.total,
                    complete = view.complete,
                )
            }
        }
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(STOP_TIMEOUT_MS), FolderUiState.Loading)

    /** Remembers this page for the next start; a library page on screen means no album is open. */
    fun onShown() {
        viewModelScope.launch {
            settings.setBrowsePath(path)
            settings.setOpenAlbum(null)
        }
    }

    fun toggleFavorite(folder: LibraryPath) {
        viewModelScope.launch { store.toggleFavorite(folder) }
    }

    fun moveRoot(from: Int, to: Int) {
        viewModelScope.launch { store.moveRoot(from, to) }
    }

    fun moveFavorite(from: Int, to: Int) {
        viewModelScope.launch { store.moveFavorite(from, to) }
    }

    fun play(item: LibraryItem) = playback.play(item.id)

    fun playFolder(folder: LibraryPath? = path) {
        folder?.let { playback.play(PlaybackItem.folderId(it)) }
    }

    /**
     * Appends the tracks the playback item [itemId] would play, in play order,
     * to the stored queue without touching what plays; [onAdded] gets the
     * number of tracks that were new.
     */
    fun addToQueue(itemId: String, onAdded: (Int) -> Unit = {}) {
        viewModelScope.launch {
            val tracks = items.resolve(itemId)?.tracks.orEmpty()
            onAdded(queue.add(tracks.map { it.path }))
        }
    }

    /** [onAdded] gets the new root, or null when access was not granted. */
    fun addRoot(treeUri: String, onAdded: (LibraryPath?) -> Unit = {}) {
        viewModelScope.launch { onAdded(access.add(treeUri)?.let(LibraryPath::root)) }
    }

    fun removeRoot(rootId: String) {
        viewModelScope.launch { access.remove(rootId) }
    }

    companion object {
        const val PATH_ARG = "path"
        private const val STOP_TIMEOUT_MS = 5_000L
    }
}
