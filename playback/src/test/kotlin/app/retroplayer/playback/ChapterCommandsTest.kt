package app.retroplayer.playback

import androidx.media3.session.CommandButton
import app.retroplayer.domain.model.Chapter
import com.google.common.truth.Truth.assertThat
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class ChapterCommandsTest {
    private val labels = ChapterLabels(previous = "Previous chapter", next = "Next chapter")

    @Test
    fun `a track without chapters has no chapter buttons`() {
        assertThat(ChapterCommands.buttons(emptyList(), labels)).isEmpty()
    }

    @Test
    fun `a track with chapters gets previous and next chapter in the back and forward slots`() {
        val buttons = ChapterCommands.buttons(listOf(Chapter(0, "One"), Chapter(60_000, "Two")), labels)

        assertThat(buttons.map { it.sessionCommand }).containsExactly(ChapterCommands.PREVIOUS, ChapterCommands.NEXT).inOrder()
        assertThat(buttons.map { it.displayName.toString() }).containsExactly("Previous chapter", "Next chapter").inOrder()
        assertThat(buttons.map { it.icon }).containsExactly(CommandButton.ICON_PREVIOUS, CommandButton.ICON_NEXT).inOrder()
        assertThat(buttons[0].slots.get(0)).isEqualTo(CommandButton.SLOT_BACK)
        assertThat(buttons[1].slots.get(0)).isEqualTo(CommandButton.SLOT_FORWARD)
    }

    @Test
    fun `the chapter commands are added to the session commands`() {
        val commands = ChapterCommands.addTo(androidx.media3.session.SessionCommands.EMPTY)

        assertThat(commands.contains(ChapterCommands.PREVIOUS)).isTrue()
        assertThat(commands.contains(ChapterCommands.NEXT)).isTrue()
    }
}
