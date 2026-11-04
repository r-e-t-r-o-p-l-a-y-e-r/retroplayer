package app.retroplayer.playback

import android.os.Bundle
import androidx.media3.common.util.UnstableApi
import androidx.media3.session.CommandButton
import androidx.media3.session.SessionCommand
import androidx.media3.session.SessionCommands
import app.retroplayer.domain.model.Chapter

data class ChapterLabels(val previous: String, val next: String)

/** Previous/next chapter as custom session commands, shown in the notification for tracks with chapters. */
@UnstableApi
object ChapterCommands {
    val PREVIOUS = SessionCommand("app.retroplayer.CHAPTER_PREV", Bundle.EMPTY)
    val NEXT = SessionCommand("app.retroplayer.CHAPTER_NEXT", Bundle.EMPTY)

    fun addTo(commands: SessionCommands): SessionCommands = commands.buildUpon().add(PREVIOUS).add(NEXT).build()

    fun buttons(chapters: List<Chapter>, labels: ChapterLabels): List<CommandButton> {
        if (chapters.isEmpty()) return emptyList()
        return listOf(
            button(CommandButton.ICON_PREVIOUS, PREVIOUS, labels.previous, CommandButton.SLOT_BACK),
            button(CommandButton.ICON_NEXT, NEXT, labels.next, CommandButton.SLOT_FORWARD),
        )
    }

    private fun button(icon: Int, command: SessionCommand, label: String, slot: Int) =
        CommandButton.Builder(icon).setSessionCommand(command).setDisplayName(label).setSlots(slot).build()
}
