package app.retroplayer.ui.queue

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import app.retroplayer.data.library.QueueRepository
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
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import javax.inject.Inject

data class QueueEntry(val path: LibraryPath, val track: AudioTrack?)

sealed interface QueueUiState {
    data object Loading : QueueUiState

    data class Ready(
        val entries: List<QueueEntry>,
        val playingTrackId: String?,
        val confirmClear: Boolean,
    ) : QueueUiState
}

@HiltViewModel
class QueueViewModel @Inject constructor(
    private val queue: QueueRepository,
    private val settings: SettingsStore,
    private val playback: PlaybackControls,
) : ViewModel() {
    private val confirmClear = MutableStateFlow(false)

    val state: StateFlow<QueueUiState> = combine(
        queue.queue,
        settings.session,
        playback.nowPlaying,
        confirmClear,
    ) { tracks, session, now, clearing ->
        val paths = session.queue
        val entries = paths.zip(tracks) { path, track -> QueueEntry(path, track) }
        val playing = if (now.itemId == PlaybackItem.QUEUE_ID) now.trackId else null
        QueueUiState.Ready(entries, playing, clearing)
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
}
