package app.retroplayer.ui

import app.retroplayer.MainDispatcherRule
import app.retroplayer.TestLibrary
import app.retroplayer.domain.AlbumIds
import app.retroplayer.playback.NowPlaying
import app.retroplayer.runVmTest
import app.retroplayer.ui.navigation.AlbumRoute
import app.retroplayer.ui.navigation.FolderRoute
import com.google.common.truth.Truth.assertThat
import kotlinx.coroutines.flow.filterNotNull
import kotlinx.coroutines.flow.first
import org.junit.After
import org.junit.Rule
import org.junit.Test
import org.junit.rules.TemporaryFolder
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class AppViewModelTest {
    @get:Rule val main = MainDispatcherRule()
    @get:Rule val tmp = TemporaryFolder()

    private lateinit var lib: TestLibrary

    @After
    fun tearDown() = lib.close()

    @Test
    fun `start routes are the saved folder chain plus the open album`() = main.runVmTest {
        lib = TestLibrary(tmp)
        val root = lib.addRoot()
        val album = AlbumIds.folder(lib.p("A"))
        lib.settings.setBrowsePath(lib.p("A"))
        lib.settings.setOpenAlbum(album)

        val viewModel = AppViewModel(lib.settings, lib.store, lib.playback)
        val routes = viewModel.startRoutes.filterNotNull().first()
        assertThat(routes).containsExactly(FolderRoute(), FolderRoute(root), FolderRoute(lib.p("A").value), AlbumRoute(album)).inOrder()
    }

    @Test
    fun `start routes are read once and ignore later session changes`() = main.runVmTest {
        lib = TestLibrary(tmp)
        lib.addRoot()
        lib.settings.setBrowsePath(lib.p("A"))
        val viewModel = AppViewModel(lib.settings, lib.store, lib.playback)
        val routes = viewModel.startRoutes.filterNotNull().first()

        lib.settings.setBrowsePath(null)
        assertThat(viewModel.startRoutes.value).isEqualTo(routes)
    }

    @Test
    fun `locate sets the located track`() = main.runVmTest {
        lib = TestLibrary(tmp)
        lib.addRoot()
        val track = lib.p("Rock/Album/01 Song.mp3").value
        val album = AlbumIds.folder(lib.p("Rock/Album"))
        lib.playback.nowPlaying.value = NowPlaying(trackId = track, itemId = album, hasTrack = true)
        val viewModel = AppViewModel(lib.settings, lib.store, lib.playback)
        viewModel.locate()
        assertThat(viewModel.locatedTrackId.filterNotNull().first()).isEqualTo(track)
    }

    @Test
    fun `manual navigation clears the located track`() = main.runVmTest {
        lib = TestLibrary(tmp)
        lib.addRoot()
        lib.playback.nowPlaying.value = NowPlaying(trackId = lib.p("A/t.mp3").value, hasTrack = true)
        val viewModel = AppViewModel(lib.settings, lib.store, lib.playback)
        viewModel.locate()
        assertThat(viewModel.locatedTrackId.filterNotNull().first()).isNotNull()
        viewModel.onUserBrowsing()
        assertThat(viewModel.locatedTrackId.value).isNull()
    }
}
