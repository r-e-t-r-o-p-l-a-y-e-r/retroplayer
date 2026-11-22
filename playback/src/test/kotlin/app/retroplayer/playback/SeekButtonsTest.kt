package app.retroplayer.playback

import androidx.media3.common.Player
import androidx.media3.session.CommandButton
import app.retroplayer.domain.model.Chapter
import com.google.common.truth.Truth.assertThat
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class SeekButtonsTest {
    private val seekLabels = SeekLabels(back = "Back 15 seconds", forward = "Forward 15 seconds")
    private val chapterLabels = ChapterLabels(previous = "Previous chapter", next = "Next chapter")

    @Test
    fun `the seek buttons use the 15 second icons in the overflow slot`() {
        val buttons = SeekButtons.buttons(seekLabels)

        assertThat(buttons.map { it.icon }).containsExactly(CommandButton.ICON_SKIP_BACK_15, CommandButton.ICON_SKIP_FORWARD_15).inOrder()
        assertThat(buttons.map { it.playerCommand }).containsExactly(Player.COMMAND_SEEK_BACK, Player.COMMAND_SEEK_FORWARD).inOrder()
        assertThat(buttons.map { it.displayName.toString() }).containsExactly("Back 15 seconds", "Forward 15 seconds").inOrder()
        assertThat(buttons.map { it.slots.get(0) }).containsExactly(CommandButton.SLOT_OVERFLOW, CommandButton.SLOT_OVERFLOW)
    }

    @Test
    fun `chapter buttons come first and seek buttons follow`() {
        val buttons = SeekButtons.mediaButtons(listOf(Chapter(0, "One"), Chapter(60_000, "Two")), chapterLabels, seekLabels)

        assertThat(buttons.map { it.displayName.toString() })
            .containsExactly("Previous chapter", "Next chapter", "Back 15 seconds", "Forward 15 seconds").inOrder()
        assertThat(SeekButtons.mediaButtons(emptyList(), chapterLabels, seekLabels).map { it.icon })
            .containsExactly(CommandButton.ICON_SKIP_BACK_15, CommandButton.ICON_SKIP_FORWARD_15).inOrder()
    }
}
