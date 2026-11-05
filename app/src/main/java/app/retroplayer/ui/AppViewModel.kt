package app.retroplayer.ui

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import app.retroplayer.data.db.LibraryStore
import app.retroplayer.data.library.LibraryRepository
import app.retroplayer.domain.AlbumIds
import app.retroplayer.domain.LibraryPath
import app.retroplayer.domain.model.PlaybackItem
import app.retroplayer.data.settings.SettingsStore
import app.retroplayer.domain.settings.ThemePreference
import app.retroplayer.playback.NowPlaying
import app.retroplayer.playback.PlaybackControls
import app.retroplayer.ui.navigation.StartupRoutes
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharedFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class AppViewModel @Inject constructor(
    private val settings: SettingsStore,
    private val store: LibraryStore,
    private val playback: PlaybackControls,
    private val library: LibraryRepository,
) : ViewModel() {
    val theme: StateFlow<ThemePreference> = settings.settings.map { it.theme }
        .stateIn(viewModelScope, SharingStarted.Eagerly, ThemePreference.SYSTEM)

    val nowPlaying: StateFlow<NowPlaying> = playback.nowPlaying

    val playRequests: SharedFlow<String> = playback.playRequests

    private val _locatedTrackId = MutableStateFlow<String?>(null)
    val locatedTrackId: StateFlow<String?> = _locatedTrackId.asStateFlow()

    private val _locateRoutes = MutableSharedFlow<List<Any>>(extraBufferCapacity = 1)
    val locateRoutes: SharedFlow<List<Any>> = _locateRoutes.asSharedFlow()

    /** The back stack to show on a cold start (UC-01); null until read. */
    val startRoutes: StateFlow<List<Any>?> = MutableStateFlow<List<Any>?>(null).also { routes ->
        viewModelScope.launch {
            val session = settings.session.first()
            val roots = store.allRoots().map { it.id }.toSet()
            routes.value = StartupRoutes.build(session.browsePath, session.openAlbumId, roots)
        }
    }

    fun locate(now: NowPlaying = playback.nowPlaying.value) {
        viewModelScope.launch {
            now.trackId?.let { _locatedTrackId.value = it }
            val roots = store.allRoots().map { it.id }.toSet()
            val item = now.itemId.orEmpty()
            val ownAlbumOrPlaylist = AlbumIds.directoryOf(item) != null || PlaybackItem.playlistPathFromId(item) != null
            val album = now.trackId?.takeUnless { ownAlbumOrPlaylist }?.let { library.albumOf(LibraryPath(it)) }
            _locateRoutes.emit(StartupRoutes.locate(now, roots, album))
        }
    }

    fun onUserBrowsing() {
        _locatedTrackId.value = null
    }
}
