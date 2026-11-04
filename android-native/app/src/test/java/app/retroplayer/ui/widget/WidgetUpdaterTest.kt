package app.retroplayer.ui.widget

import android.content.Context
import androidx.test.core.app.ApplicationProvider
import app.retroplayer.playback.NowPlayingSnapshot
import com.google.common.truth.Truth.assertThat
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@OptIn(ExperimentalCoroutinesApi::class)
@RunWith(RobolectricTestRunner::class)
class WidgetUpdaterTest {
    private val updater = WidgetUpdater(ApplicationProvider.getApplicationContext<Context>(), CoroutineScope(UnconfinedTestDispatcher()))

    @Test
    fun `nothing is known before the service reports`() {
        assertThat(updater.current.value).isNull()
    }

    @Test
    fun `keeps the latest snapshot, also without placed widgets`() {
        updater.update(NowPlayingSnapshot(title = "One", isPlaying = true))
        updater.update(NowPlayingSnapshot(title = "One", isPlaying = false))
        assertThat(updater.current.value).isEqualTo(NowPlayingSnapshot(title = "One", isPlaying = false))
    }

    @Test
    fun `a missing cover loads as none`() = kotlinx.coroutines.test.runTest {
        assertThat(updater.loadArt("content://nowhere/cover.jpg")).isNull()
    }
}
