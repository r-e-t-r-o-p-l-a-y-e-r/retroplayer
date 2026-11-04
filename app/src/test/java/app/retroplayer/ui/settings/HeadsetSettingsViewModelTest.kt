package app.retroplayer.ui.settings

import app.retroplayer.MainDispatcherRule
import app.retroplayer.TestLibrary
import app.retroplayer.domain.settings.HeadsetSettings
import app.retroplayer.runVmTest
import com.google.common.truth.Truth.assertThat
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.test.advanceUntilIdle
import org.junit.After
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.rules.TemporaryFolder
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@OptIn(ExperimentalCoroutinesApi::class)
@RunWith(RobolectricTestRunner::class)
class HeadsetSettingsViewModelTest {
    @get:Rule val main = MainDispatcherRule()
    @get:Rule val tmp = TemporaryFolder()

    private lateinit var lib: TestLibrary

    @Before
    fun setUp() {
        lib = TestLibrary(tmp)
    }

    @After
    fun tearDown() = lib.close()

    private fun viewModel() = HeadsetSettingsViewModel(lib.settings)

    private suspend fun storedKeys() = lib.settingsData.data.first().asMap().keys.map { it.name }

    @Test
    fun `shows the defaults`() = main.runVmTest {
        assertThat(viewModel().state.first()).isEqualTo(HeadsetSettings.DEFAULT)
    }

    @Test
    fun `default values leave no stored keys`() = main.runVmTest {
        val vm = viewModel()
        vm.setAutoRewind(false)
        advanceUntilIdle()
        vm.setAutoRewind(true)
        vm.setAutoRewindSeconds(HeadsetSettings.DEFAULT.autoRewindSeconds)
        vm.setResumeOnReconnect(false)
        advanceUntilIdle()
        assertThat(storedKeys().filter { it.startsWith("headset_") }).isEmpty()
    }

    @Test
    fun `turning resume on stores it`() = main.runVmTest {
        val vm = viewModel()
        vm.setResumeOnReconnect(true)
        advanceUntilIdle()
        assertThat(lib.settings.settings.first().headset.resumeOnReconnect).isTrue()
        assertThat(vm.state.first { it.resumeOnReconnect }.resumeOnReconnect).isTrue()
    }

    @Test
    fun `choosing rewind seconds stores them and keeps the other options`() = main.runVmTest {
        val vm = viewModel()
        vm.setResumeOnReconnect(true)
        advanceUntilIdle()
        vm.setAutoRewindSeconds(15)
        advanceUntilIdle()
        assertThat(lib.settings.settings.first().headset).isEqualTo(HeadsetSettings(autoRewindSeconds = 15, resumeOnReconnect = true))
    }
}
