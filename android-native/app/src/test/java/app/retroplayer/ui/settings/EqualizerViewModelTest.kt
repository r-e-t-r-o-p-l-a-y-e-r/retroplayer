package app.retroplayer.ui.settings

import app.retroplayer.MainDispatcherRule
import app.retroplayer.TestLibrary
import app.retroplayer.domain.settings.EqualizerPreset
import app.retroplayer.domain.settings.EqualizerSettings
import app.retroplayer.playback.EqualizerAvailability
import app.retroplayer.playback.EqualizerInfo
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
class EqualizerViewModelTest {
    @get:Rule val main = MainDispatcherRule()
    @get:Rule val tmp = TemporaryFolder()

    private lateinit var lib: TestLibrary
    private val availability = EqualizerAvailability()

    @Before
    fun setUp() {
        lib = TestLibrary(tmp)
    }

    @After
    fun tearDown() = lib.close()

    private fun viewModel() = EqualizerViewModel(lib.settings, availability)

    private suspend fun stored() = lib.settings.settings.first().equalizer

    @Test
    fun `moving a band switches to manual`() = main.runVmTest {
        lib.settings.setEqualizer(EqualizerSettings(enabled = true, preset = EqualizerPreset.BASS_BOOST))
        val vm = viewModel()
        advanceUntilIdle()
        vm.setBand(0, 3f)
        advanceUntilIdle()
        assertThat(stored().preset).isEqualTo(EqualizerPreset.MANUAL)
        assertThat(stored().manualGainsDb).containsExactly(3f, 4f, 1f, 0f, 0f).inOrder()
    }

    @Test
    fun `choosing a preset stores it`() = main.runVmTest {
        val vm = viewModel()
        vm.choosePreset(EqualizerPreset.VOICE)
        advanceUntilIdle()
        assertThat(stored().preset).isEqualTo(EqualizerPreset.VOICE)
    }

    @Test
    fun `switching on stores it`() = main.runVmTest {
        val vm = viewModel()
        vm.setEnabled(true)
        advanceUntilIdle()
        assertThat(stored().enabled).isTrue()
    }

    @Test
    fun `reset to flat leaves no stored keys`() = main.runVmTest {
        val vm = viewModel()
        vm.setBand(2, -6f)
        advanceUntilIdle()
        vm.reset()
        advanceUntilIdle()
        assertThat(lib.settingsData.data.first().asMap()).isEmpty()
    }

    @Test
    fun `the page is available once the device reports its bands`() = main.runVmTest {
        val vm = viewModel()
        assertThat(vm.state.first().available).isFalse()
        availability.report(EqualizerInfo(listOf(60, 230, 910, 3600, 14000), -15f..15f))
        assertThat(vm.state.first { it.available }.available).isTrue()
    }
}
