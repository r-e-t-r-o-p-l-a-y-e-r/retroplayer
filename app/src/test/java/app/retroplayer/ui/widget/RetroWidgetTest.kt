package app.retroplayer.ui.widget

import android.content.Context
import androidx.compose.ui.unit.DpSize
import androidx.glance.testing.unit.hasContentDescription
import androidx.glance.testing.unit.hasText
import androidx.glance.appwidget.testing.unit.runGlanceAppWidgetUnitTest
import androidx.test.core.app.ApplicationProvider
import app.retroplayer.R
import app.retroplayer.playback.NowPlayingSnapshot
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class RetroWidgetTest {
    private val context = ApplicationProvider.getApplicationContext<Context>()
    private val paused = NowPlayingSnapshot(title = "Song", subtitle = "Band", isPlaying = false)

    private fun string(id: Int) = context.getString(id)

    private fun show(snapshot: NowPlayingSnapshot, size: DpSize, check: androidx.glance.appwidget.testing.unit.GlanceAppWidgetUnitTest.() -> Unit) =
        runGlanceAppWidgetUnitTest {
            setContext(context)
            setAppWidgetSize(size)
            provideComposable { WidgetContent(snapshot, art = null) }
            check()
        }

    @Test
    fun `shows title and play button when paused`() = show(paused, RetroWidget.WIDE) {
        onNode(hasText("Song")).assertExists()
        onNode(hasText("Band")).assertExists()
        onNode(hasContentDescription(string(R.string.play))).assertExists()
        onNode(hasContentDescription(string(R.string.pause))).assertDoesNotExist()
    }

    @Test
    fun `shows pause button while playing`() = show(paused.copy(isPlaying = true), RetroWidget.WIDE) {
        onNode(hasContentDescription(string(R.string.pause))).assertExists()
        onNode(hasContentDescription(string(R.string.play))).assertDoesNotExist()
    }

    @Test
    fun `small size shows only title and play pause`() = show(paused, RetroWidget.SMALL) {
        onNode(hasText("Song")).assertExists()
        onNode(hasContentDescription(string(R.string.play))).assertExists()
        listOf(R.string.previous, R.string.next, R.string.jump_back, R.string.jump_forward).forEach {
            onNode(hasContentDescription(string(it))).assertDoesNotExist()
        }
    }

    @Test
    fun `one row adds the jumps`() = show(paused, RetroWidget.ROW) {
        onNode(hasContentDescription(string(R.string.jump_back))).assertExists()
        onNode(hasContentDescription(string(R.string.jump_forward))).assertExists()
        onNode(hasContentDescription(string(R.string.previous))).assertDoesNotExist()
    }

    @Test
    fun `wide size shows all controls`() = show(paused, RetroWidget.WIDE) {
        listOf(R.string.previous, R.string.jump_back, R.string.play, R.string.jump_forward, R.string.next).forEach {
            onNode(hasContentDescription(string(it))).assertExists()
        }
    }

    @Test
    fun `nothing played yet shows the app name`() = show(NowPlayingSnapshot(), RetroWidget.WIDE) {
        onNode(hasText(string(R.string.app_name))).assertExists()
        onNode(hasContentDescription(string(R.string.play))).assertExists()
    }
}
