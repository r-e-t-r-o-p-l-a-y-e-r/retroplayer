package app.retroplayer.ui.playlist

import android.content.Context
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithContentDescription
import androidx.compose.ui.test.performClick
import androidx.test.core.app.ApplicationProvider
import app.retroplayer.R
import app.retroplayer.domain.LibraryPath
import app.retroplayer.ui.theme.RetroTheme
import com.google.common.truth.Truth.assertThat
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class PlaylistContentTest {
    @get:Rule val compose = createComposeRule()

    private val context = ApplicationProvider.getApplicationContext<Context>()
    private val playlist = PlaylistUiState.Ready(
        title = "Road trip",
        entries = listOf(PlaylistEntryUi(LibraryPath("1/gone.mp3"), null)),
        editable = true,
        selectMode = false,
        selectedIndices = emptySet(),
        confirmRemove = null,
        confirmDelete = false,
        playingTrackId = null,
    )

    @Test
    fun `add tracks is a floating button`() {
        val calls = mutableListOf<String>()
        compose.setContent { RetroTheme { PlaylistContent(playlist, PlaylistActions(addTracks = { calls += "add" })) } }
        compose.onNodeWithContentDescription(context.getString(R.string.add_tracks)).assertIsDisplayed().performClick()
        assertThat(calls).containsExactly("add")
    }

    @Test
    fun `read only and selecting playlists offer no adding`() {
        compose.setContent { RetroTheme { PlaylistContent(playlist.copy(editable = false), PlaylistActions()) } }
        compose.onNodeWithContentDescription(context.getString(R.string.add_tracks)).assertDoesNotExist()
    }
}
