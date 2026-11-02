package app.retroplayer.data.settings

import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.MutablePreferences
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.intPreferencesKey
import androidx.datastore.preferences.core.stringPreferencesKey
import app.retroplayer.domain.LibraryPath
import app.retroplayer.domain.settings.AppSettings
import app.retroplayer.domain.settings.EqualizerPreset
import app.retroplayer.domain.settings.EqualizerSettings
import app.retroplayer.domain.settings.HeadsetSettings
import app.retroplayer.domain.settings.ThemePreference
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.map

data class SessionState(
    val browsePath: LibraryPath? = null,
    val openAlbumId: String? = null,
    val lastItemId: String? = null,
    val queue: List<LibraryPath> = emptyList(),
)

/**
 * Settings and session state. A value equal to its default is removed rather
 * than written, so a fresh or reset install holds no keys at all.
 */
class SettingsStore(private val dataStore: DataStore<Preferences>) {
    private object Keys {
        val theme = stringPreferencesKey("theme")
        val eqEnabled = booleanPreferencesKey("eq_enabled")
        val eqPreset = stringPreferencesKey("eq_preset")
        val eqGains = stringPreferencesKey("eq_manual_gains")
        val autoRewind = booleanPreferencesKey("headset_auto_rewind")
        val autoRewindSeconds = intPreferencesKey("headset_auto_rewind_seconds")
        val resumeOnReconnect = booleanPreferencesKey("headset_resume_on_reconnect")
        val browsePath = stringPreferencesKey("browse_path")
        val openAlbum = stringPreferencesKey("open_album")
        val lastItem = stringPreferencesKey("last_item")
        val queue = stringPreferencesKey("queue")
    }

    val settings: Flow<AppSettings> = dataStore.data.map { p ->
        val defaults = AppSettings.DEFAULT
        AppSettings(
            theme = ThemePreference.fromStorage(p[Keys.theme]),
            languageTag = null,
            equalizer = EqualizerSettings(
                enabled = p[Keys.eqEnabled] ?: defaults.equalizer.enabled,
                preset = p[Keys.eqPreset]?.let { name -> EqualizerPreset.entries.firstOrNull { it.name == name } }
                    ?: defaults.equalizer.preset,
                manualGainsDb = p[Keys.eqGains]?.let(::parseGains) ?: defaults.equalizer.manualGainsDb,
            ),
            headset = HeadsetSettings(
                autoRewind = p[Keys.autoRewind] ?: defaults.headset.autoRewind,
                autoRewindSeconds = p[Keys.autoRewindSeconds] ?: defaults.headset.autoRewindSeconds,
                resumeOnReconnect = p[Keys.resumeOnReconnect] ?: defaults.headset.resumeOnReconnect,
            ),
        )
    }.distinctUntilChanged()

    val session: Flow<SessionState> = dataStore.data.map { p ->
        SessionState(
            browsePath = p[Keys.browsePath]?.let(::LibraryPath),
            openAlbumId = p[Keys.openAlbum],
            lastItemId = p[Keys.lastItem],
            queue = parseQueue(p[Keys.queue]),
        )
    }.distinctUntilChanged()

    suspend fun setTheme(theme: ThemePreference) = dataStore.edit {
        it.put(Keys.theme, theme.storage, ThemePreference.SYSTEM.storage)
    }

    suspend fun setEqualizer(eq: EqualizerSettings) = dataStore.edit {
        val d = EqualizerSettings.DEFAULT
        it.put(Keys.eqEnabled, eq.enabled, d.enabled)
        it.put(Keys.eqPreset, eq.preset.name, d.preset.name)
        it.put(Keys.eqGains, eq.manualGainsDb.joinToString(","), d.manualGainsDb.joinToString(","))
    }

    suspend fun setHeadset(headset: HeadsetSettings) = dataStore.edit {
        val d = HeadsetSettings.DEFAULT
        it.put(Keys.autoRewind, headset.autoRewind, d.autoRewind)
        it.put(Keys.autoRewindSeconds, headset.autoRewindSeconds, d.autoRewindSeconds)
        it.put(Keys.resumeOnReconnect, headset.resumeOnReconnect, d.resumeOnReconnect)
    }

    suspend fun setBrowsePath(path: LibraryPath?) = dataStore.edit { it.put(Keys.browsePath, path?.value, null) }

    suspend fun setOpenAlbum(albumId: String?) = dataStore.edit { it.put(Keys.openAlbum, albumId, null) }

    suspend fun setLastItem(itemId: String?) = dataStore.edit { it.put(Keys.lastItem, itemId, null) }

    suspend fun setQueue(paths: List<LibraryPath>) = updateQueue { paths }

    /** Reads and writes the queue in one DataStore transaction, so concurrent edits do not overwrite each other. */
    suspend fun updateQueue(transform: (List<LibraryPath>) -> List<LibraryPath>) = dataStore.edit {
        val updated = transform(parseQueue(it[Keys.queue]))
        it.put(Keys.queue, updated.joinToString("\n") { p -> p.value }.ifEmpty { null }, null)
    }

    private fun parseQueue(raw: String?): List<LibraryPath> =
        raw?.split('\n')?.filter { it.isNotEmpty() }?.map(::LibraryPath).orEmpty()

    suspend fun reset() = dataStore.edit { it.clear() }

    private fun <T> MutablePreferences.put(key: Preferences.Key<T>, value: T?, default: T?) {
        if (value == null || value == default) remove(key) else this[key] = value
    }

    private fun parseGains(raw: String): List<Float>? =
        raw.split(',').map { it.toFloatOrNull() ?: return null }.takeIf { it.size == EqualizerSettings.BAND_HZ.size }
}
