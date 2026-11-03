package app.retroplayer.ui.settings

import android.content.Context
import androidx.appcompat.app.AppCompatDelegate
import androidx.core.os.LocaleListCompat
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import app.retroplayer.R
import app.retroplayer.data.db.LibraryStore
import app.retroplayer.data.settings.SettingsStore
import app.retroplayer.domain.settings.ThemePreference
import app.retroplayer.library.RootAccess
import app.retroplayer.playback.PlaybackControls
import dagger.hilt.android.lifecycle.HiltViewModel
import dagger.hilt.android.qualifiers.ApplicationContext
import javax.inject.Inject
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import kotlinx.coroutines.Dispatchers

data class LanguageOption(val tag: String?, val label: String)

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

    private val languageOptions = buildLanguageOptions(context, localeTags)

    val state: StateFlow<SettingsUiState> = settings.settings.map { app ->
        SettingsUiState(
            theme = app.theme,
            languageTag = currentAppLocaleTag(),
            languages = languageOptions,
            databaseFileName = databaseFile.name,
            databasePath = databaseFile.absolutePath,
        )
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), SettingsUiState())

    fun setTheme(theme: ThemePreference) {
        viewModelScope.launch { settings.setTheme(theme) }
    }

    fun setLanguage(tag: String?) {
        viewModelScope.launch {
            withContext(Dispatchers.Main) {
                val locales = if (tag.isNullOrEmpty()) {
                    LocaleListCompat.getEmptyLocaleList()
                } else {
                    LocaleListCompat.forLanguageTags(tag)
                }
                AppCompatDelegate.setApplicationLocales(locales)
            }
        }
    }

    fun resetDatabase(keepRoots: Boolean) {
        viewModelScope.launch { resetDatabaseNow(keepRoots) }
    }

    internal suspend fun resetDatabaseNow(keepRoots: Boolean) {
        playback.stop()
        val roots = if (keepRoots) emptyList() else store.allRoots()
        settings.reset()
        store.reset(keepRoots)
        if (!keepRoots) {
            roots.forEach { access.remove(it.id) }
            withContext(Dispatchers.Main) {
                AppCompatDelegate.setApplicationLocales(LocaleListCompat.getEmptyLocaleList())
            }
        }
    }

    private fun buildLanguageOptions(context: Context, tags: List<String>): List<LanguageOption> =
        listOf(LanguageOption(null, context.getString(R.string.language_system))) + tags.map { tag ->
            LanguageOption(tag, displayNameForLocaleTag(tag))
        }

    companion object {
        fun currentAppLocaleTag(): String? {
            val tags = AppCompatDelegate.getApplicationLocales().toLanguageTags()
            return tags.takeIf { it.isNotEmpty() }
        }
    }
}
