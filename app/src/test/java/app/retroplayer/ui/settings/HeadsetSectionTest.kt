package app.retroplayer.ui.settings

import android.content.Context
import androidx.compose.ui.test.assertIsEnabled
import androidx.compose.ui.test.assertIsNotEnabled
import androidx.compose.ui.test.assertIsOff
import androidx.compose.ui.test.assertIsOn
import androidx.compose.ui.test.assertIsSelected
import androidx.compose.ui.test.hasText
import androidx.compose.ui.test.isToggleable
import androidx.compose.ui.test.junit4.v2.createComposeRule
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.test.core.app.ApplicationProvider
import app.retroplayer.R
import app.retroplayer.domain.settings.HeadsetSettings
import app.retroplayer.ui.theme.RetroTheme
import com.google.common.truth.Truth.assertThat
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class HeadsetSectionTest {
    @get:Rule val compose = createComposeRule()

    private val context = ApplicationProvider.getApplicationContext<Context>()
    private val calls = mutableListOf<String>()
    private val actions = HeadsetActions(
        setAutoRewind = { calls += "rewind:$it" },
        setAutoRewindSeconds = { calls += "seconds:$it" },
        setResumeOnReconnect = { calls += "resume:$it" },
    )

    private fun show(settings: HeadsetSettings = HeadsetSettings.DEFAULT) = compose.setContent {
        RetroTheme { HeadsetSection(settings, actions) }
    }

    private fun seconds(n: Int) = compose.onNode(hasText(context.getString(R.string.seconds_short, n)))

    private fun switch(label: Int) = compose.onNode(isToggleable() and hasText(context.getString(label), substring = true))

    @Test
    fun `defaults show rewind on, five seconds and resume off`() {
        show()
        compose.onNodeWithText(context.getString(R.string.headphones)).assertExists()
        switch(R.string.auto_rewind).assertIsOn()
        seconds(5).assertIsSelected()
        switch(R.string.resume_on_reconnect).assertIsOff()
    }

    @Test
    fun `switches and seconds report the new values`() {
        show()
        switch(R.string.auto_rewind).performClick()
        seconds(15).performClick()
        switch(R.string.resume_on_reconnect).performClick()
        assertThat(calls).containsExactly("rewind:false", "seconds:15", "resume:true").inOrder()
    }

    @Test
    fun `rewind seconds are disabled while rewinding is off`() {
        show(HeadsetSettings(autoRewind = false))
        listOf(5, 10, 15, 30).forEach { seconds(it).assertIsNotEnabled() }
    }

    @Test
    fun `rewind seconds are enabled while rewinding is on`() {
        show()
        listOf(5, 10, 15, 30).forEach { seconds(it).assertIsEnabled() }
    }
}
