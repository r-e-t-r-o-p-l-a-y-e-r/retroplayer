package app.retroplayer.ui.settings

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowForward
import androidx.compose.material.icons.filled.ArrowDropDown
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.outlined.Settings
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.ListItem
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.selected
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import app.retroplayer.BuildConfig
import app.retroplayer.R
import app.retroplayer.domain.settings.ThemePreference
import app.retroplayer.ui.components.BackButton
import app.retroplayer.ui.components.DialogText
import app.retroplayer.ui.components.RetroSegmentedRow
import app.retroplayer.ui.components.RetroTopBar
import app.retroplayer.ui.components.SectionHeader
import app.retroplayer.ui.theme.LocalRetroPalette

const val SETTINGS_SCREEN_TAG = "settingsScreen"
const val SETTINGS_RESET_TAG = "settingsReset"
const val LANGUAGE_DROPDOWN_TAG = "languageDropdown"

data class SettingsActions(
    val back: () -> Unit = {},
    val openDataStorage: () -> Unit = {},
    val openLicenses: () -> Unit = {},
    val setTheme: (ThemePreference) -> Unit = {},
    val setLanguage: (String?) -> Unit = {},
    val resetDatabase: (keepRoots: Boolean) -> Unit = {},
)

@Composable
fun SettingsScreen(
    back: () -> Unit,
    openDataStorage: () -> Unit,
    openLicenses: () -> Unit,
    viewModel: SettingsViewModel = hiltViewModel(),
    equalizerViewModel: EqualizerViewModel = hiltViewModel(),
) {
    val state by viewModel.state.collectAsStateWithLifecycle()
    val equalizer by equalizerViewModel.state.collectAsStateWithLifecycle()
    SettingsContent(
        state = state,
        actions = SettingsActions(
            back = back,
            openDataStorage = openDataStorage,
            openLicenses = openLicenses,
            setTheme = viewModel::setTheme,
            setLanguage = viewModel::setLanguage,
            resetDatabase = viewModel::resetDatabase,
        ),
        equalizer = equalizer,
        equalizerActions = EqualizerActions(
            choosePreset = equalizerViewModel::choosePreset,
            setBand = equalizerViewModel::setBand,
            reset = equalizerViewModel::reset,
        ),
    )
}

@Composable
fun SettingsContent(
    state: SettingsUiState,
    actions: SettingsActions,
    equalizer: EqualizerUiState = EqualizerUiState(),
    equalizerActions: EqualizerActions = EqualizerActions(),
) {
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
            item { SectionHeader(stringResource(R.string.language)) }
            item { LanguageDropdown(state, actions.setLanguage) }
            item { HorizontalDivider(Modifier.padding(vertical = 8.dp)) }
            item { EqualizerSection(equalizer, equalizerActions) }
            item { HorizontalDivider(Modifier.padding(vertical = 8.dp)) }
            item { NavigationRow(stringResource(R.string.data_storage), actions.openDataStorage) }
            item { NavigationRow(stringResource(R.string.open_source_licenses), actions.openLicenses) }
            item {
                ListItem(
                    headlineContent = { Text(stringResource(R.string.reset_database)) },
                    modifier = Modifier
                        .clickable { confirmReset = true }
                        .testTag(SETTINGS_RESET_TAG),
                )
            }
            item { HorizontalDivider(Modifier.padding(vertical = 8.dp)) }
            item { AboutSection() }
        }
    }
    if (confirmReset) {
        val reset = { keepRoots: Boolean ->
            confirmReset = false
            actions.resetDatabase(keepRoots)
        }
        AlertDialog(
            onDismissRequest = { confirmReset = false },
            title = { Text(stringResource(R.string.reset_database_title)) },
            text = { DialogText(stringResource(R.string.reset_database_body)) },
            confirmButton = {
                Column(horizontalAlignment = Alignment.End) {
                    TextButton(onClick = { reset(true) }) { Text(stringResource(R.string.reset_database_keep_folders)) }
                    TextButton(onClick = { reset(false) }) { Text(stringResource(R.string.reset_database_clear_everything)) }
                    TextButton(onClick = { confirmReset = false }) { Text(stringResource(R.string.cancel)) }
                }
            },
        )
    }
}

@Composable
private fun ThemeSection(theme: ThemePreference, onTheme: (ThemePreference) -> Unit) {
    val options = listOf(
        ThemePreference.LIGHT to R.string.theme_light,
        ThemePreference.DARK to R.string.theme_dark,
        ThemePreference.SYSTEM to R.string.theme_system,
    )
    RetroSegmentedRow(
        labels = options.map { stringResource(it.second) },
        selected = options.indexOfFirst { it.first == theme },
        onSelect = { onTheme(options[it].first) },
        modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp),
    )
}

@Composable
private fun LanguageDropdown(state: SettingsUiState, onLanguage: (String?) -> Unit) {
    var open by remember { mutableStateOf(false) }
    val system = stringResource(R.string.language_system)
    val current = state.languages.firstOrNull { it.tag == state.languageTag }?.label ?: system
    val choose = { tag: String? ->
        open = false
        onLanguage(tag)
    }
    Box {
        ListItem(
            headlineContent = { Text(current) },
            trailingContent = { Icon(Icons.Filled.ArrowDropDown, contentDescription = null) },
            modifier = Modifier.clickable(role = Role.DropdownList) { open = true }.testTag(LANGUAGE_DROPDOWN_TAG),
        )
        DropdownMenu(expanded = open, onDismissRequest = { open = false }) {
            LanguageItem(system, state.languageTag == null) { choose(null) }
            state.languages.forEach { option ->
                LanguageItem(option.label, option.tag == state.languageTag) { choose(option.tag) }
            }
        }
    }
}

@Composable
private fun LanguageItem(label: String, selected: Boolean, onClick: () -> Unit) {
    DropdownMenuItem(
        text = { Text(label) },
        onClick = onClick,
        leadingIcon = { if (selected) Icon(Icons.Filled.Check, contentDescription = null) },
        modifier = Modifier.semantics { this.selected = selected },
    )
}

@OptIn(ExperimentalLayoutApi::class)
@Composable
private fun AboutSection() {
    val palette = LocalRetroPalette.current
    SectionHeader(stringResource(R.string.about))
    Column(Modifier.padding(horizontal = 16.dp)) {
        Text(stringResource(R.string.app_name), style = MaterialTheme.typography.titleLarge)
        Text(stringResource(R.string.about_subtitle), color = palette.textMuted, modifier = Modifier.padding(top = 4.dp, bottom = 12.dp))
        listOf(
            R.string.about_version to BuildConfig.VERSION_NAME,
            R.string.about_build_date to buildTimeLabel(BuildConfig.BUILD_TIME),
            R.string.about_git_branch to BuildConfig.GIT_BRANCH,
            R.string.about_git_commit to BuildConfig.GIT_COMMIT,
        ).forEach { (label, value) ->
            FlowRow(Modifier.fillMaxWidth().padding(vertical = 2.dp)) {
                Text(
                    stringResource(label),
                    style = MaterialTheme.typography.labelMedium,
                    color = palette.textMuted,
                    modifier = Modifier.widthIn(min = 120.dp),
                )
                Text(value, style = MaterialTheme.typography.bodyMedium)
            }
        }
    }
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

/** Settings gear for library top bars. */
@Composable
fun SettingsNavAction(onClick: () -> Unit) {
    IconButton(onClick = onClick) {
        Icon(Icons.Outlined.Settings, contentDescription = stringResource(R.string.settings))
    }
}
