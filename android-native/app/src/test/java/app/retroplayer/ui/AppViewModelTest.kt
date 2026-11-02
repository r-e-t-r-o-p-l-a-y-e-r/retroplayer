package app.retroplayer.ui

import app.retroplayer.MainDispatcherRule
import app.retroplayer.TestLibrary
import app.retroplayer.domain.AlbumIds
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
}
