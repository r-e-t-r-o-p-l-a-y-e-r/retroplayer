package app.retroplayer.ui.queue

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import app.retroplayer.data.db.LibraryStore
import app.retroplayer.data.library.PlaylistFiles
import app.retroplayer.library.RootAccess
import app.retroplayer.data.library.QueueRepository
import app.retroplayer.data.library.SaveResult
import app.retroplayer.data.settings.SettingsStore
import app.retroplayer.domain.LibraryPath
import app.retroplayer.domain.model.AudioTrack
import app.retroplayer.domain.model.PlaybackItem
import app.retroplayer.playback.PlaybackControls
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch
import javax.inject.Inject

data class QueueEntry(val path: LibraryPath, val track: AudioTrack?)

sealed interface QueueUiState {
    data object Loading : QueueUiState

    data class Ready(
        val entries: List<QueueEntry>,
        val playingTrackId: String?,
        val confirmClear: Boolean,
        val showSaveDialog: Boolean,
    ) : QueueUiState
}

sealed interface SavePlaylistOutcome {
    data object NotInFolder : SavePlaylistOutcome
    data class NeedsWrite(val rootId: String, val treeUri: String?) : SavePlaylistOutcome
    data class Saved(val path: LibraryPath) : SavePlaylistOutcome
    data object NameTaken : SavePlaylistOutcome
    data object InvalidName : SavePlaylistOutcome
    data object Failed : SavePlaylistOutcome
}

@HiltViewModel
class QueueViewModel @Inject constructor(
    private val queue: QueueRepository,
    private val settings: SettingsStore,
    private val playback: PlaybackControls,
    private val playlists: PlaylistFiles,
    private val store: LibraryStore,
    private val access: RootAccess,
) : ViewModel() {
    private val confirmClear = MutableStateFlow(false)
    private val showSaveDialog = MutableStateFlow(false)

    val canSaveAsPlaylist = settings.session.map { it.browsePath != null }
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), false)

    val state: StateFlow<QueueUiState> = combine(
        queue.queue,
        settings.session,
        playback.nowPlaying,
        confirmClear,
        showSaveDialog,
    ) { tracks, session, now, clearing, saving ->
        val paths = session.queue
        val entries = paths.zip(tracks) { path, track -> QueueEntry(path, track) }
        val playing = if (now.itemId == PlaybackItem.QUEUE_ID) now.trackId else null
        QueueUiState.Ready(entries, playing, clearing, saving)
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), QueueUiState.Loading)

    fun play(entry: QueueEntry) = playback.play(PlaybackItem.QUEUE_ID, entry.path.value)

    fun remove(index: Int) {
        viewModelScope.launch { queue.remove(index) }
    }

    fun move(from: Int, to: Int) {
        viewModelScope.launch { queue.move(from, to) }
    }

    fun requestClear() {
        confirmClear.value = true
    }

    fun dismissClear() {
        confirmClear.value = false
    }

    fun confirmClear() {
        viewModelScope.launch {
            queue.clear()
            confirmClear.value = false
        }
    }

    fun requestSaveAsPlaylist() {
        showSaveDialog.value = true
    }

    fun dismissSaveAsPlaylist() {
        showSaveDialog.value = false
    }

    suspend fun saveAsPlaylist(name: String): SavePlaylistOutcome {
        val session = settings.session.first()
        val folder = session.browsePath ?: return SavePlaylistOutcome.NotInFolder
        return when (val result = playlists.save(folder, name, session.queue)) {
            is SaveResult.Saved -> SavePlaylistOutcome.Saved(result.path)
            is SaveResult.NeedsWriteAccess -> SavePlaylistOutcome.NeedsWrite(
                result.rootId,
                store.root(result.rootId)?.treeUri,
            )
            SaveResult.NameTaken -> SavePlaylistOutcome.NameTaken
            SaveResult.InvalidName -> SavePlaylistOutcome.InvalidName
            SaveResult.Failed -> SavePlaylistOutcome.Failed
        }
    }

    fun confirmSaveAsPlaylist(name: String, onOutcome: (SavePlaylistOutcome) -> Unit) {
        viewModelScope.launch {
            val outcome = saveAsPlaylist(name)
            if (outcome !is SavePlaylistOutcome.NeedsWrite) showSaveDialog.value = false
            onOutcome(outcome)
        }
    }

    suspend fun grantWrite(rootId: String, pickedTreeUri: String): Boolean = access.grantWrite(rootId, pickedTreeUri)
}
