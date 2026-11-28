package app.retroplayer

import org.junit.Assert.assertEquals
import org.junit.Test

class AppIdTest {
    // F-Droid rejects app ids that match a domain owned by someone else; retroplayer.app is taken.
    @Test
    fun `the app id is in the author's gitlab namespace`() {
        assertEquals("io.gitlab.freier_fall.retroplayer.debug", BuildConfig.APPLICATION_ID)
    }
}
