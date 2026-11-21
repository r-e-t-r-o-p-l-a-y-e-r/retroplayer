package app.retroplayer.playback

import androidx.media3.common.Player
import androidx.media3.common.util.UnstableApi
import androidx.media3.session.CommandButton
import app.retroplayer.domain.model.Chapter

data class SeekLabels(val back: String, val forward: String)

/** ±15 s as extra buttons in the notification and on the lock screen; previous/next keep their slots. */
@UnstableApi
object SeekButtons {
    fun buttons(labels: SeekLabels): List<CommandButton> = listOf(
        button(CommandButton.ICON_SKIP_BACK_15, Player.COMMAND_SEEK_BACK, labels.back),
        button(CommandButton.ICON_SKIP_FORWARD_15, Player.COMMAND_SEEK_FORWARD, labels.forward),
    )

    /** Everything the session offers besides the default transport. */
    fun mediaButtons(chapters: List<Chapter>, chapterLabels: ChapterLabels, seekLabels: SeekLabels): List<CommandButton> =
        ChapterCommands.buttons(chapters, chapterLabels) + buttons(seekLabels)

    private fun button(icon: Int, command: Int, label: String) =
        CommandButton.Builder(icon).setPlayerCommand(command).setDisplayName(label).setSlots(CommandButton.SLOT_OVERFLOW).build()
}
