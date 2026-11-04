package app.retroplayer.ui.settings

import android.content.Context
import androidx.appcompat.app.AppCompatDelegate
import androidx.core.os.LocaleListCompat
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import app.retroplayer.data.db.LibraryStore
import app.retroplayer.data.settings.SettingsStore
import app.retroplayer.domain.settings.ThemePreference
import app.retroplayer.library.RootAccess
import app.retroplayer.playback.PlaybackControls
import dagger.hilt.android.lifecycle.HiltViewModel
import dagger.hilt.android.qualifiers.ApplicationContext
import javax.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

/** A locale the app is translated into, named in its own language. */
data class LanguageOption(val tag: String, val label: String)

data class SettingsUiState(
    val theme: ThemePreference = ThemePreference.SYSTEM,
    val languageTag: String? = null,
    val languages: List<LanguageOption> = emptyList(),
    val databaseFileName: String = "",
    val databasePath: String = "",
)

@HiltViewModel
class SettingsViewModel @Inject constructor(
    @ApplicationContext context: Context,
    private val settings: SettingsStore,
    private val store: LibraryStore,
    private val playback: PlaybackControls,
    private val access: RootAccess,
) : ViewModel() {
    private val localeTags = localeTagsFromConfig(context)
    private val databaseFile = context.getDatabasePath("retroplayer.db")

    private val languageOptions = localeTags.map { LanguageOption(it, displayNameForLocaleTag(it)) }

    /** Not part of [settings]: AppCompat stores the app language itself. */
    private val languageTag = MutableStateFlow(currentAppLocaleTag())

    val state: StateFlow<SettingsUiState> = combine(settings.settings, languageTag) { app, language ->
        SettingsUiState(
            theme = app.theme,
            languageTag = language,
            languages = languageOptions,
            databaseFileName = databaseFile.name,
            databasePath = databaseFile.absolutePath,
        )
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), SettingsUiState())

    fun setTheme(theme: ThemePreference) {
        viewModelScope.launch { settings.setTheme(theme) }
    }

    fun setLanguage(tag: String?) {
        AppCompatDelegate.setApplicationLocales(
            if (tag.isNullOrEmpty()) LocaleListCompat.getEmptyLocaleList() else LocaleListCompat.forLanguageTags(tag),
        )
        languageTag.value = tag?.takeIf { it.isNotEmpty() }
    }

    fun resetDatabase(keepRoots: Boolean) {
        viewModelScope.launch { resetDatabaseNow(keepRoots) }
    }

    internal suspend fun resetDatabaseNow(keepRoots: Boolean) {
        playback.stop()
        // Grants first: RootAccess.remove needs the root row to find its tree.
        if (!keepRoots) store.allRoots().forEach { access.remove(it.id) }
        settings.reset()
        store.reset(keepRoots)
        if (!keepRoots) setLanguage(null)
    }

    companion object {
        fun currentAppLocaleTag(): String? {
            val tags = AppCompatDelegate.getApplicationLocales().toLanguageTags()
            return tags.takeIf { it.isNotEmpty() }
        }
    }
}
