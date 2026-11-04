package app.retroplayer.ui.settings

import android.app.Application
import androidx.test.core.app.ApplicationProvider
import com.google.common.truth.Truth.assertThat
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class LocaleTagsTest {
    @Test
    fun `every configured locale is offered`() {
        val tags = localeTagsFromConfig(ApplicationProvider.getApplicationContext<Application>())
        assertThat(tags).contains("de")
        assertThat(tags).hasSize(LOCALES)
    }

    @Test
    fun `a locale is named in its own language`() {
        assertThat(displayNameForLocaleTag("de")).isEqualTo("Deutsch")
    }

    private companion object {
        const val LOCALES = 46
    }
}
