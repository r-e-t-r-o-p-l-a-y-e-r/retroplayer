package app.retroplayer.ui.queue

import androidx.activity.compose.BackHandler
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.imePadding
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Folder
import androidx.compose.material3.Button
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewModelScope
import app.retroplayer.R
import app.retroplayer.data.db.LibraryStore
import app.retroplayer.data.library.LibraryRepository
import app.retroplayer.data.library.PlaylistFiles
import app.retroplayer.data.library.SaveResult
import app.retroplayer.data.settings.SettingsStore
import app.retroplayer.domain.LibraryPath
import app.retroplayer.library.RootAccess
import app.retroplayer.library.writeAccessIntent
import app.retroplayer.ui.components.BackButton
import app.retroplayer.ui.components.IconChip
import app.retroplayer.ui.components.RetroListRow
import app.retroplayer.ui.components.RetroTextField
import app.retroplayer.ui.components.RetroTopBar
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.flatMapLatest
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import javax.inject.Inject

sealed interface SavePlaylistOutcome {
    data object NotInFolder : SavePlaylistOutcome
    data class NeedsWrite(val rootId: String, val treeUri: String?) : SavePlaylistOutcome
    data class Saved(val path: LibraryPath) : SavePlaylistOutcome
    data object NameTaken : SavePlaylistOutcome
    data object InvalidName : SavePlaylistOutcome
    data object Failed : SavePlaylistOutcome
}

data class SaveFolderChoice(val path: LibraryPath, val name: String)

/** [folder] null lists the library sources, which are not a folder to save into. */
data class SavePlaylistUiState(
    val folder: LibraryPath?,
    val title: String?,
    val folders: List<SaveFolderChoice>,
    val loading: Boolean,
) {
    val canSaveHere: Boolean get() = folder != null
}

/** Picks a folder in the library and writes the queue there as an `.m3u` the app owns. */
@OptIn(ExperimentalCoroutinesApi::class)
@HiltViewModel
class SavePlaylistViewModel @Inject constructor(
    private val savedState: SavedStateHandle,
    private val repository: LibraryRepository,
    private val store: LibraryStore,
    private val settings: SettingsStore,
    private val playlists: PlaylistFiles,
    private val access: RootAccess,
) : ViewModel() {
    private val folder = savedState.getStateFlow<String?>(FOLDER, null)

    val state: StateFlow<SavePlaylistUiState> = folder.flatMapLatest { value ->
        val path = value?.let(::LibraryPath)
        if (path == null) {
            store.roots.map { roots ->
                SavePlaylistUiState(null, null, roots.map { SaveFolderChoice(LibraryPath(it.id), it.name) }, loading = false)
            }
        } else {
            combine(store.roots, repository.folder(path)) { roots, view ->
                val title = if (path.isRoot) roots.firstOrNull { it.id == path.rootId }?.name ?: path.name else path.name
                SavePlaylistUiState(path, title, view.folders.map { SaveFolderChoice(it.path, it.path.name) }, loading = !view.complete)
            }
        }
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), SavePlaylistUiState(null, null, emptyList(), loading = true))

    fun open(path: LibraryPath) {
        savedState[FOLDER] = path.value
    }

    /** One level up; false at the library sources, where back leaves the picker. */
    fun up(): Boolean {
        val path = folder.value?.let(::LibraryPath) ?: return false
        savedState[FOLDER] = path.parent?.value
        return true
    }

    suspend fun save(name: String): SavePlaylistOutcome {
        val target = folder.value?.let(::LibraryPath) ?: return SavePlaylistOutcome.NotInFolder
        return when (val result = playlists.save(target, name, settings.session.first().queue)) {
            is SaveResult.Saved -> SavePlaylistOutcome.Saved(result.path)
            is SaveResult.NeedsWriteAccess -> SavePlaylistOutcome.NeedsWrite(result.rootId, store.root(result.rootId)?.treeUri)
            SaveResult.NameTaken -> SavePlaylistOutcome.NameTaken
            SaveResult.InvalidName -> SavePlaylistOutcome.InvalidName
            SaveResult.Failed -> SavePlaylistOutcome.Failed
        }
    }

    /** Saves on the main thread and reports there, so [onOutcome] may navigate. */
    fun confirmSave(name: String, onOutcome: (SavePlaylistOutcome) -> Unit) {
        viewModelScope.launch { onOutcome(save(name)) }
    }

    /** After the user granted write access to [rootId] in the system picker; false if they picked another folder. */
    fun grantWriteAndSave(rootId: String, pickedTreeUri: String, name: String, onOutcome: (SavePlaylistOutcome?) -> Unit) {
        viewModelScope.launch {
            onOutcome(if (access.grantWrite(rootId, pickedTreeUri)) save(name) else null)
        }
    }

    private companion object {
        const val FOLDER = "saveFolder"
    }
}

data class SavePlaylistActions(
    val back: () -> Unit = {},
    val open: (LibraryPath) -> Unit = {},
    val save: (String) -> Unit = {},
)

@Composable
fun SavePlaylistScreen(viewModel: SavePlaylistViewModel, close: () -> Unit, onSaved: () -> Unit) {
    val state by viewModel.state.collectAsStateWithLifecycle()
    val snackbar = remember { SnackbarHostState() }
    val scope = rememberCoroutineScope()
    val accessDenied = stringResource(R.string.folder_access_denied)
    var pending by remember { mutableStateOf<Pair<String, String>?>(null) }
    lateinit var handle: (SavePlaylistOutcome?, String) -> Unit
    val writeLauncher = rememberLauncherForActivityResult(ActivityResultContracts.StartActivityForResult()) { result ->
        val (rootId, name) = pending ?: return@rememberLauncherForActivityResult
        pending = null
        val uri = result.data?.data?.toString() ?: return@rememberLauncherForActivityResult
        viewModel.grantWriteAndSave(rootId, uri, name) { handle(it, name) }
    }
    handle = { outcome, name ->
        when (outcome) {
            is SavePlaylistOutcome.Saved -> onSaved()
            is SavePlaylistOutcome.NeedsWrite -> {
                pending = outcome.rootId to name
                outcome.treeUri?.let { writeLauncher.launch(writeAccessIntent(it)) }
                    ?: scope.launch { snackbar.showSnackbar(accessDenied) }
            }
            null -> scope.launch { snackbar.showSnackbar(accessDenied) }
            else -> Unit
        }
    }
    val save: (String) -> Unit = { name -> viewModel.confirmSave(name) { handle(it, name) } }
    BackHandler(enabled = state.folder != null) { viewModel.up() }
    SavePlaylistContent(
        state,
        SavePlaylistActions(back = { if (!viewModel.up()) close() }, open = viewModel::open, save = save),
        snackbar,
    )
}

@Composable
fun SavePlaylistContent(
    state: SavePlaylistUiState,
    actions: SavePlaylistActions,
    snackbar: SnackbarHostState = remember { SnackbarHostState() },
) {
    var name by rememberSaveable { mutableStateOf("") }
    val canSave = state.canSaveHere && name.isNotBlank()
    val save = { if (canSave) actions.save(name.trim()) }
    Scaffold(
        snackbarHost = { SnackbarHost(snackbar) },
        topBar = {
            RetroTopBar(state.title ?: stringResource(R.string.library), navigationIcon = { BackButton(actions.back) })
        },
        bottomBar = {
            Button(
                onClick = save,
                enabled = canSave,
                modifier = Modifier.fillMaxWidth().imePadding().navigationBarsPadding().padding(16.dp),
            ) { Text(stringResource(R.string.save)) }
        },
    ) { padding ->
        Column(Modifier.padding(padding).fillMaxSize()) {
            Text(
                stringResource(R.string.save_as_playlist),
                style = MaterialTheme.typography.titleMedium,
                modifier = Modifier.padding(start = 16.dp, end = 16.dp, top = 12.dp, bottom = 8.dp),
            )
            if (!state.canSaveHere) {
                Text(
                    stringResource(R.string.choose_playlist_folder),
                    style = MaterialTheme.typography.bodyMedium,
                    modifier = Modifier.padding(horizontal = 16.dp).padding(bottom = 8.dp),
                )
            }
            RetroTextField(
                value = name,
                onValueChange = { name = it },
                label = stringResource(R.string.new_playlist_name),
                modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp),
                onDone = save,
            )
            Box(Modifier.weight(1f).fillMaxWidth().padding(top = 8.dp)) {
                if (state.loading) LinearProgressIndicator(Modifier.fillMaxWidth())
                LazyColumn {
                    items(state.folders, key = { it.path.value }) { choice ->
                        RetroListRow(
                            title = { Text(choice.name, maxLines = 2, overflow = TextOverflow.Ellipsis) },
                            leading = { IconChip(Icons.Outlined.Folder) },
                            onClick = { actions.open(choice.path) },
                        )
                    }
                }
            }
        }
    }
}
