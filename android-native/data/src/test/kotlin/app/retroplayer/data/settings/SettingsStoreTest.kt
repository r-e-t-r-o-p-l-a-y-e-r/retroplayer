package app.retroplayer.data.settings

import androidx.datastore.preferences.core.PreferenceDataStoreFactory
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.core.DataStore
import app.retroplayer.domain.LibraryPath
import app.retroplayer.domain.settings.EqualizerPreset
import app.retroplayer.domain.settings.EqualizerSettings
import app.retroplayer.domain.settings.HeadsetSettings
import app.retroplayer.domain.settings.ThemePreference
import com.google.common.truth.Truth.assertThat
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.test.TestScope
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import kotlinx.coroutines.test.runTest
import org.junit.Rule
import org.junit.Test
import org.junit.rules.TemporaryFolder

class SettingsStoreTest {
    @get:Rule
    val tmp = TemporaryFolder()

    private fun TestScope.store(): Pair<SettingsStore, DataStore<Preferences>> {
        val ds = PreferenceDataStoreFactory.create(scope = backgroundScope) { tmp.newFile("s.preferences_pb").also { it.delete() } }
        return SettingsStore(ds) to ds
    }

    @Test
    fun `fresh store reports defaults and holds no keys`() = runTest(UnconfinedTestDispatcher()) {
        val (store, ds) = store()
        val settings = store.settings.first()
        assertThat(settings.theme).isEqualTo(ThemePreference.SYSTEM)
        assertThat(settings.equalizer).isEqualTo(EqualizerSettings.DEFAULT)
        assertThat(ds.data.first().asMap()).isEmpty()
    }

    @Test
    fun `non default values are stored and setting the default removes the key`() = runTest(UnconfinedTestDispatcher()) {
        val (store, ds) = store()
        store.setTheme(ThemePreference.DARK)
        assertThat(store.settings.first().theme).isEqualTo(ThemePreference.DARK)
        assertThat(ds.data.first().asMap()).hasSize(1)

        store.setTheme(ThemePreference.SYSTEM)
        assertThat(ds.data.first().asMap()).isEmpty()
    }

    @Test
    fun `equalizer round trips and flat off equalizer leaves no entry`() = runTest(UnconfinedTestDispatcher()) {
        val (store, ds) = store()
        val eq = EqualizerSettings(enabled = true, preset = EqualizerPreset.MANUAL, manualGainsDb = listOf(1f, -2f, 3.5f, 0f, 0f))
        store.setEqualizer(eq)
        assertThat(store.settings.first().equalizer).isEqualTo(eq)
        store.setEqualizer(EqualizerSettings.DEFAULT)
        assertThat(ds.data.first().asMap()).isEmpty()
    }

    @Test
    fun `headset settings store only changed fields`() = runTest(UnconfinedTestDispatcher()) {
        val (store, ds) = store()
        store.setHeadset(HeadsetSettings.DEFAULT.copy(resumeOnReconnect = true))
        assertThat(store.settings.first().headset.resumeOnReconnect).isTrue()
        assertThat(ds.data.first().asMap()).hasSize(1)
        store.setHeadset(HeadsetSettings.DEFAULT)
        assertThat(ds.data.first().asMap()).isEmpty()
    }

    @Test
    fun `session state round trips and clears`() = runTest(UnconfinedTestDispatcher()) {
        val (store, ds) = store()
        store.setBrowsePath(LibraryPath("1/Books"))
        store.setOpenAlbum("dir:1/books/dune")
        store.setLastItem("queue")
        store.setQueue(listOf(LibraryPath("1/a.mp3"), LibraryPath("1/b c.mp3")))
        val session = store.session.first()
        assertThat(session.browsePath).isEqualTo(LibraryPath("1/Books"))
        assertThat(session.openAlbumId).isEqualTo("dir:1/books/dune")
        assertThat(session.lastItemId).isEqualTo("queue")
        assertThat(session.queue).containsExactly(LibraryPath("1/a.mp3"), LibraryPath("1/b c.mp3")).inOrder()

        store.setBrowsePath(null)
        store.setOpenAlbum(null)
        store.setLastItem(null)
        store.setQueue(emptyList())
        assertThat(ds.data.first().asMap()).isEmpty()
    }

    @Test
    fun `reset removes everything`() = runTest(UnconfinedTestDispatcher()) {
        val (store, ds) = store()
        store.setTheme(ThemePreference.LIGHT)
        store.setBrowsePath(LibraryPath("1"))
        store.reset()
        assertThat(ds.data.first().asMap()).isEmpty()
    }
}
