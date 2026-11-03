package app.retroplayer.ui.settings

import android.app.Application
import androidx.test.core.app.ApplicationProvider
import app.retroplayer.MainDispatcherRule
import app.retroplayer.TestLibrary
import app.retroplayer.domain.settings.ThemePreference
import app.retroplayer.runVmTest
import com.google.common.truth.Truth.assertThat
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.test.advanceUntilIdle
import org.junit.After
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.rules.TemporaryFolder
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class SettingsViewModelTest {
    @get:Rule val main = MainDispatcherRule()
    @get:Rule val tmp = TemporaryFolder()

    private lateinit var lib: TestLibrary

    @Before
    fun setUp() = main.runVmTest {
        lib = TestLibrary(tmp)
        lib.addRoot()
    }

    @After
    fun tearDown() = lib.close()

    private fun viewModel(): SettingsViewModel {
        val app = ApplicationProvider.getApplicationContext<Application>()
        return SettingsViewModel(app, lib.settings, lib.store, lib.playback, lib.access)
    }

    @Test
    fun `choosing the default theme leaves no stored key`() = main.runVmTest {
        val vm = viewModel()
        vm.setTheme(ThemePreference.DARK)
        advanceUntilIdle()
        assertThat(lib.settings.settings.first().theme).isEqualTo(ThemePreference.DARK)
        vm.setTheme(ThemePreference.SYSTEM)
        advanceUntilIdle()
        assertThat(lib.settings.settings.first().theme).isEqualTo(ThemePreference.SYSTEM)
    }

    @Test
    fun `reset keeping folders keeps roots`() = main.runVmTest {
        val vm = viewModel()
        vm.resetDatabaseNow(keepRoots = true)
        assertThat(lib.store.allRoots()).hasSize(1)
    }

    @Test
    fun `clear everything removes roots and grants`() = main.runVmTest {
        val vm = viewModel()
        val rootId = lib.rootId
        vm.resetDatabaseNow(keepRoots = false)
        assertThat(lib.store.allRoots()).isEmpty()
        assertThat(lib.access.removed).containsExactly(rootId)
    }

    @Test
    fun `reset stops playback`() = main.runVmTest {
        val vm = viewModel()
        vm.resetDatabaseNow(keepRoots = true)
        assertThat(lib.playback.calls).containsExactly("stop")
    }
}
