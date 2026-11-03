package app.retroplayer.ui.playlist

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import app.retroplayer.data.db.LibraryStore
import app.retroplayer.data.library.LibraryScanner
import app.retroplayer.data.library.PlaylistFiles
import app.retroplayer.domain.LibraryPath
import app.retroplayer.domain.model.AudioTrack
import app.retroplayer.domain.model.PlaybackItem
import app.retroplayer.playback.PlaybackControls
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import javax.inject.Inject

data class PlaylistEntryUi(val path: LibraryPath, val track: AudioTrack?)

sealed interface PlaylistUiState {
    data object Loading : PlaylistUiState

    data class Ready(
        val title: String,
        val entries: List<PlaylistEntryUi>,
        val editable: Boolean,
        val selectMode: Boolean,
        val selectedIndices: Set<Int>,
        val confirmRemove: Set<Int>?,
        val confirmDelete: Boolean,
        val playingTrackId: String?,
    ) : PlaylistUiState
}

@HiltViewModel
class PlaylistViewModel @Inject constructor(
    savedState: SavedStateHandle,
    private val playlists: PlaylistFiles,
    private val scanner: LibraryScanner,
    private val store: LibraryStore,
    private val playback: PlaybackControls,
) : ViewModel() {
    val path: LibraryPath = LibraryPath(checkNotNull(savedState.get<String>(PATH_ARG)))

    private val paths = MutableStateFlow<List<LibraryPath>?>(null)
    private val entries = MutableStateFlow<List<PlaylistEntryUi>>(emptyList())
    private val editable = MutableStateFlow(false)
    private val selectMode = MutableStateFlow(false)
    private val selected = MutableStateFlow(emptySet<Int>())
    private val confirmRemove = MutableStateFlow<Set<Int>?>(null)
    private val confirmDelete = MutableStateFlow(false)

    private data class Core(
        val paths: List<LibraryPath>?,
        val entries: List<PlaylistEntryUi>,
        val editable: Boolean,
        val selectMode: Boolean,
        val selected: Set<Int>,
    )

    val state: StateFlow<PlaylistUiState> = combine(
        combine(paths, entries, editable, selectMode, selected) { pathList, ent, edit, selecting, picked ->
            Core(pathList, ent, edit, selecting, picked)
        },
        confirmRemove,
        confirmDelete,
        playback.nowPlaying,
    ) { core, removing, deleting, now ->
        if (core.paths == null) PlaylistUiState.Loading
        else {
            val playing = if (now.itemId == PlaybackItem.playlistId(path)) now.trackId else null
            PlaylistUiState.Ready(
                title = path.baseName,
                entries = core.entries,
                editable = core.editable,
                selectMode = core.selectMode,
                selectedIndices = core.selected,
                confirmRemove = removing,
                confirmDelete = deleting,
                playingTrackId = playing,
            )
        }
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), PlaylistUiState.Loading)

    init {
        viewModelScope.launch { reload() }
    }

    fun play(entry: PlaylistEntryUi) = playback.play(PlaybackItem.playlistId(path), entry.path.value)

    fun removeIndices(indices: Set<Int>) {
        if (!editable.value || indices.isEmpty()) return
        viewModelScope.launch {
            val next = paths.value.orEmpty().filterIndexed { index, _ -> index !in indices }
            if (!playlists.overwrite(path, next)) return@launch
            paths.value = next
            syncEntries()
            selected.value = selected.value - indices
            if (selected.value.isEmpty()) selectMode.value = false
        }
    }

    fun move(from: Int, to: Int) {
        if (!editable.value) return
        viewModelScope.launch {
            val list = paths.value.orEmpty().toMutableList()
            if (from !in list.indices || to !in list.indices || from == to) return@launch
            list.add(to, list.removeAt(from))
            if (!playlists.overwrite(path, list)) return@launch
            paths.value = list
            syncEntries()
        }
    }

    fun toggleSelectMode() {
        if (!editable.value) return
        selectMode.value = !selectMode.value
        if (!selectMode.value) selected.value = emptySet()
    }

    fun toggleSelected(index: Int) {
        if (!selectMode.value) return
        selected.value = selected.value.toggle(index)
    }

    fun selectAll() {
        if (!selectMode.value) return
        selected.value = paths.value.orEmpty().indices.toSet()
    }

    fun deselectAll() {
        selected.value = emptySet()
    }

    fun requestRemove(indices: Set<Int>) {
        if (!editable.value || indices.isEmpty()) return
        confirmRemove.value = indices
    }

    fun dismissRemove() {
        confirmRemove.value = null
    }

    fun confirmRemove() {
        val indices = confirmRemove.value ?: return
        confirmRemove.value = null
        removeIndices(indices)
    }

    fun requestDelete() {
        if (!editable.value) return
        confirmDelete.value = true
    }

    fun dismissDelete() {
        confirmDelete.value = false
    }

    fun confirmDelete(onDeleted: () -> Unit) {
        if (!editable.value) return
        viewModelScope.launch {
            if (playlists.delete(path)) onDeleted()
            confirmDelete.value = false
        }
    }

    fun reload() {
        viewModelScope.launch { reloadFromDisk() }
    }

    private suspend fun reloadFromDisk() {
        val content = playlists.read(path)
        paths.value = content.entries.map { it.path }
        editable.value = content.editable && store.root(path.rootId)?.canWrite == true
        syncEntries()
    }

    private suspend fun syncEntries() {
        val list = paths.value.orEmpty()
        entries.value = list.zip(scanner.tracksAt(list)) { p, t -> PlaylistEntryUi(p, t) }
    }

    private fun Set<Int>.toggle(index: Int): Set<Int> = if (index in this) this - index else this + index

    companion object {
        const val PATH_ARG = "path"
    }
}
