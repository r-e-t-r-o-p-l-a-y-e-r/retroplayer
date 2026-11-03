package app.retroplayer.ui.settings

import app.retroplayer.ui.components.DialogBody
import androidx.compose.foundation.clickable
import androidx.compose.foundation.selection.selectable
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowForward
import androidx.compose.material.icons.outlined.Settings
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.ListItem
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.RadioButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.unit.dp
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import app.retroplayer.BuildConfig
import app.retroplayer.R
import app.retroplayer.domain.settings.ThemePreference
import app.retroplayer.ui.components.BackButton
import app.retroplayer.ui.components.RetroTopBar
import app.retroplayer.ui.components.SectionHeader

const val SETTINGS_SCREEN_TAG = "settingsScreen"
const val SETTINGS_RESET_TAG = "settingsReset"

data class SettingsActions(
    val back: () -> Unit = {},
    val openDataStorage: () -> Unit = {},
    val openLicenses: () -> Unit = {},
    val openAbout: () -> Unit = {},
    val openEqualizer: () -> Unit = {},
    val setTheme: (ThemePreference) -> Unit = {},
    val setLanguage: (String?) -> Unit = {},
    val resetDatabase: (keepRoots: Boolean) -> Unit = {},
)

@Composable
fun SettingsScreen(
    viewModel: SettingsViewModel = hiltViewModel(),
    back: () -> Unit,
    openDataStorage: () -> Unit,
    openLicenses: () -> Unit,
    openAbout: () -> Unit,
    openEqualizer: () -> Unit,
) {
    val state by viewModel.state.collectAsStateWithLifecycle()
    SettingsContent(
        state = state,
        actions = SettingsActions(
            back = back,
            openDataStorage = openDataStorage,
            openLicenses = openLicenses,
            openAbout = openAbout,
            openEqualizer = openEqualizer,
            setTheme = viewModel::setTheme,
            setLanguage = viewModel::setLanguage,
            resetDatabase = viewModel::resetDatabase,
        ),
    )
}

@Composable
fun SettingsContent(state: SettingsUiState, actions: SettingsActions) {
    var confirmReset by remember { mutableStateOf(false) }
    Scaffold(
        modifier = Modifier.testTag(SETTINGS_SCREEN_TAG),
        topBar = {
            RetroTopBar(
                stringResource(R.string.settings),
                navigationIcon = { BackButton(actions.back) },
            )
        },
    ) { padding ->
        LazyColumn(
            Modifier.padding(padding).fillMaxSize(),
            contentPadding = PaddingValues(bottom = 96.dp),
        ) {
            item { SectionHeader(stringResource(R.string.appearance)) }
            item { ThemeSection(state.theme, actions.setTheme) }
            item { HorizontalDivider(Modifier.padding(vertical = 16.dp)) }
            item { SectionHeader(stringResource(R.string.language)) }
            item(key = "system") {
                RadioRow(stringResource(R.string.language_system), state.languageTag == null) { actions.setLanguage(null) }
            }
            items(state.languages, key = { it.tag }) { option ->
                RadioRow(option.label, option.tag == state.languageTag) { actions.setLanguage(option.tag) }
            }
            item { HorizontalDivider(Modifier.padding(vertical = 16.dp)) }
            item {
                NavigationRow(stringResource(R.string.equalizer), actions.openEqualizer)
            }
            item {
                NavigationRow(stringResource(R.string.data_storage), actions.openDataStorage)
            }
            item {
                NavigationRow(stringResource(R.string.open_source_licenses), actions.openLicenses)
            }
            item {
                ListItem(
                    headlineContent = { Text(stringResource(R.string.reset_database)) },
                    modifier = Modifier
                        .clickable { confirmReset = true }
                        .testTag(SETTINGS_RESET_TAG),
                )
            }
            item {
                NavigationRow(stringResource(R.string.app_name), actions.openAbout)
            }
        }
    }
    if (confirmReset) {
        AlertDialog(
            onDismissRequest = { confirmReset = false },
            title = { Text(stringResource(R.string.reset_database_title)) },
            text = {
                DialogBody {
                    Text(stringResource(R.string.reset_database_body))
                    TextButton(onClick = {
                        confirmReset = false
                        actions.resetDatabase(true)
                    }) { Text(stringResource(R.string.reset_database_keep_folders)) }
                }
            },
            confirmButton = {
                TextButton(onClick = {
                    confirmReset = false
                    actions.resetDatabase(false)
                }) { Text(stringResource(R.string.reset_database_clear_everything)) }
            },
            dismissButton = {
                TextButton(onClick = { confirmReset = false }) { Text(stringResource(R.string.cancel)) }
            },
        )
    }
}

@Composable
private fun ThemeSection(theme: ThemePreference, onTheme: (ThemePreference) -> Unit) {
    ThemeRadio(R.string.theme_system, ThemePreference.SYSTEM, theme, onTheme)
    ThemeRadio(R.string.theme_light, ThemePreference.LIGHT, theme, onTheme)
    ThemeRadio(R.string.theme_dark, ThemePreference.DARK, theme, onTheme)
}

@Composable
private fun ThemeRadio(label: Int, value: ThemePreference, selected: ThemePreference, onSelect: (ThemePreference) -> Unit) {
    RadioRow(stringResource(label), selected == value) { onSelect(value) }
}

@Composable
private fun RadioRow(label: String, selected: Boolean, onSelect: () -> Unit) {
    ListItem(
        headlineContent = { Text(label) },
        leadingContent = { RadioButton(selected = selected, onClick = null) },
        modifier = Modifier.selectable(selected = selected, role = Role.RadioButton, onClick = onSelect),
    )
}

@Composable
private fun NavigationRow(title: String, onClick: () -> Unit) {
    ListItem(
        headlineContent = { Text(title) },
        trailingContent = { Icon(Icons.AutoMirrored.Filled.ArrowForward, contentDescription = null) },
        modifier = Modifier.clickable(onClick = onClick),
    )
}

@Composable
fun SettingsDataScreen(viewModel: SettingsViewModel = hiltViewModel(), back: () -> Unit) {
    val state by viewModel.state.collectAsStateWithLifecycle()
    SettingsDataContent(state, back)
}

@Composable
fun SettingsDataContent(state: SettingsUiState, back: () -> Unit) {
    Scaffold(
        topBar = {
            RetroTopBar(
                stringResource(R.string.data_storage),
                navigationIcon = { BackButton(back) },
            )
        },
    ) { padding ->
        LazyColumn(Modifier.padding(padding).fillMaxSize(), contentPadding = PaddingValues(16.dp, bottom = 96.dp)) {
            item { Text(stringResource(R.string.data_storage_intro)) }
            item { StorageSection(stringResource(R.string.data_storage_app_data_title), stringResource(R.string.data_storage_app_data_body, state.databaseFileName, state.databasePath)) }
            item { StorageSection(stringResource(R.string.data_storage_library_title), stringResource(R.string.data_storage_library_body)) }
            item { StorageSection(stringResource(R.string.data_storage_playlists_title), stringResource(R.string.data_storage_playlists_body)) }
            item {
                StorageSection(
                    stringResource(R.string.data_storage_platform_title, "Android"),
                    stringResource(R.string.data_storage_platform_body_android),
                )
            }
            item { StorageSection(stringResource(R.string.data_storage_android_permissions_title), stringResource(R.string.data_storage_android_permissions_body)) }
            item { StorageSection(stringResource(R.string.data_storage_android_playback_title), stringResource(R.string.data_storage_android_playback_body)) }
        }
    }
}

@Composable
private fun StorageSection(title: String, body: String) {
    Column(Modifier.padding(vertical = 12.dp)) {
        Text(title, style = MaterialTheme.typography.titleSmall)
        Text(body, Modifier.padding(top = 4.dp))
    }
}

@Composable
fun SettingsLicensesScreen(back: () -> Unit) {
    Scaffold(
        topBar = {
            RetroTopBar(
                stringResource(R.string.open_source_licenses),
                navigationIcon = { BackButton(back) },
            )
        },
    ) { padding ->
        LazyColumn(Modifier.padding(padding).fillMaxSize(), contentPadding = PaddingValues(bottom = 96.dp)) {
            item {
                Text(
                    stringResource(R.string.open_source_legalese),
                    Modifier.padding(16.dp),
                )
            }
            items(OpenSourceCatalog.entries, key = { it.catalogKey }) { entry ->
                ListItem(
                    headlineContent = { Text(entry.displayName) },
                    supportingContent = { Text(entry.license) },
                )
            }
        }
    }
}

@Composable
fun SettingsAboutScreen(back: () -> Unit) {
    Scaffold(
        topBar = {
            RetroTopBar(
                stringResource(R.string.app_name),
                navigationIcon = { BackButton(back) },
            )
        },
    ) { padding ->
        Column(Modifier.padding(padding).fillMaxSize().padding(16.dp)) {
            Text(stringResource(R.string.app_name), style = MaterialTheme.typography.headlineSmall)
            Text(stringResource(R.string.about_subtitle), Modifier.padding(top = 8.dp))
            Text(stringResource(R.string.about_version) + ": " + BuildConfig.VERSION_NAME, Modifier.padding(top = 16.dp))
            Text(stringResource(R.string.about_build_date) + ": " + BuildConfig.BUILD_DATE, Modifier.padding(top = 4.dp))
            Text(stringResource(R.string.about_git_branch) + ": " + BuildConfig.GIT_BRANCH, Modifier.padding(top = 4.dp))
            Text(stringResource(R.string.about_git_commit) + ": " + BuildConfig.GIT_COMMIT, Modifier.padding(top = 4.dp))
        }
    }
}

/** Settings gear for library top bars. */
@Composable
fun SettingsNavAction(onClick: () -> Unit) {
    IconButton(onClick = onClick) {
        Icon(Icons.Outlined.Settings, contentDescription = stringResource(R.string.settings))
    }
}
