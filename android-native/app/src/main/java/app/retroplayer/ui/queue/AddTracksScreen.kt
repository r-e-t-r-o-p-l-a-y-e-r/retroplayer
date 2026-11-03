package app.retroplayer.ui.queue

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Album
import androidx.compose.material.icons.outlined.Folder
import androidx.compose.material.icons.outlined.MusicNote
import androidx.compose.material3.Checkbox
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.Scaffold
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalResources
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import app.retroplayer.R
import app.retroplayer.data.db.LibraryRoot
import app.retroplayer.domain.Crumb
import app.retroplayer.domain.LibraryPath
import app.retroplayer.domain.model.AudioAlbum
import app.retroplayer.domain.model.LibraryItem
import app.retroplayer.ui.components.BackButton
import app.retroplayer.ui.components.BreadcrumbStrip
import app.retroplayer.ui.components.IconChip
import app.retroplayer.ui.components.RetroListRow
import app.retroplayer.ui.components.RetroTopBar
import app.retroplayer.ui.components.SectionHeader
import app.retroplayer.ui.components.addedToQueue
import kotlinx.coroutines.launch

data class AddTracksActions(
    val back: () -> Unit = {},
    val openRoot: (LibraryRoot) -> Unit = {},
    val openFolder: (LibraryPath) -> Unit = {},
    val openCrumb: (Crumb) -> Unit = {},
    val toggleTrack: (LibraryPath) -> Unit = {},
    val toggleAlbum: (AudioAlbum) -> Unit = {},
    val confirm: () -> Unit = {},
)

@Composable
fun AddTracksScreen(viewModel: AddTracksViewModel, back: () -> Unit, onDone: () -> Unit) {
    val state = viewModel.state.collectAsStateWithLifecycle().value
    val snackbar = remember { SnackbarHostState() }
    val resources = LocalResources.current
    val scope = rememberCoroutineScope()
    val selectedCount = (state as? AddTracksUiState.PickRoot)?.selected?.size
        ?: (state as? AddTracksUiState.Browse)?.selected?.size
        ?: 0
    AddTracksContent(
        state = state,
        confirmLabel = if (selectedCount == 0) {
            stringResource(R.string.add_tracks)
        } else {
            stringResource(R.string.add_tracks_confirm, selectedCount)
        },
        actions = AddTracksActions(
            back = back,
            openRoot = viewModel::openRoot,
            openFolder = viewModel::openFolder,
            openCrumb = viewModel::openCrumb,
            toggleTrack = viewModel::toggleTrack,
            toggleAlbum = viewModel::toggleAlbum,
            confirm = {
                viewModel.confirm { result ->
                    scope.launch {
                        when (result) {
                            AddTracksConfirmResult.NothingSelected ->
                                snackbar.showSnackbar(resources.getString(R.string.add_tracks_nothing_selected))
                            AddTracksConfirmResult.NothingAdded ->
                                snackbar.showSnackbar(resources.getString(R.string.add_tracks_nothing_added))
                            is AddTracksConfirmResult.Added -> {
                                snackbar.showSnackbar(resources.addedToQueue(result.count))
                                if (result.count > 0) onDone()
                            }
                        }
                    }
                }
            },
        ),
        snackbar = snackbar,
    )
}

@Composable
fun AddTracksContent(
    state: AddTracksUiState,
    confirmLabel: String,
    actions: AddTracksActions,
    snackbar: SnackbarHostState = remember { SnackbarHostState() },
) {
    Scaffold(
        topBar = {
            Column {
                RetroTopBar(
                    stringResource(R.string.add_tracks),
                    navigationIcon = { BackButton(actions.back) },
                    actions = { TextButton(onClick = actions.confirm, enabled = state !is AddTracksUiState.Loading) { Text(confirmLabel) } },
                )
                if (state is AddTracksUiState.Browse) {
                    BreadcrumbStrip(state.crumbs, actions.openCrumb)
                }
            }
        },
        snackbarHost = { SnackbarHost(snackbar) },
    ) { padding ->
        Box(Modifier.padding(padding).fillMaxSize()) {
            when (state) {
                AddTracksUiState.Loading -> LinearProgressIndicator(Modifier.fillMaxWidth())
                is AddTracksUiState.PickRoot -> RootPicker(state, actions)
                is AddTracksUiState.Browse -> FolderPicker(state, actions)
            }
        }
    }
}

@Composable
private fun RootPicker(state: AddTracksUiState.PickRoot, actions: AddTracksActions) {
    LazyColumn(contentPadding = PaddingValues(bottom = 96.dp)) {
        item { SectionHeader(stringResource(R.string.library_sources)) }
        items(state.roots, key = { it.id }) { root ->
            RetroListRow(
                title = { Text(root.name, maxLines = 2, overflow = TextOverflow.Ellipsis) },
                leading = { IconChip(Icons.Outlined.Folder) },
                onClick = { actions.openRoot(root) },
                contentDescription = root.name,
            )
        }
    }
}

@Composable
private fun FolderPicker(state: AddTracksUiState.Browse, actions: AddTracksActions) {
    Column(Modifier.fillMaxSize()) {
        if (!state.complete) LinearProgressIndicator(Modifier.fillMaxWidth())
        LazyColumn(contentPadding = PaddingValues(bottom = 96.dp)) {
            if (state.folders.isNotEmpty()) {
                item { SectionHeader(stringResource(R.string.folders)) }
                items(state.folders, key = { "f:$it" }) { path ->
                    RetroListRow(
                        title = { Text(path.name, maxLines = 2, overflow = TextOverflow.Ellipsis) },
                        leading = { IconChip(Icons.Outlined.Folder) },
                        onClick = { actions.openFolder(path) },
                        contentDescription = path.name,
                    )
                }
            }
            if (state.audio.isNotEmpty()) {
                item { SectionHeader(stringResource(R.string.audio)) }
                items(state.audio, key = { it.id }) { item ->
                    when (item) {
                        is LibraryItem.Album -> AlbumPickRow(item.album, state.selected, actions)
                        is LibraryItem.Track -> TrackPickRow(item.track.path, item.track.displayTitle, state.selected, actions)
                        is LibraryItem.Playlist -> Unit
                    }
                }
            }
        }
    }
}

@Composable
private fun AlbumPickRow(album: AudioAlbum, selected: Set<LibraryPath>, actions: AddTracksActions) {
    val paths = album.tracks.map { it.path }
    val checked = paths.isNotEmpty() && paths.all { it in selected }
    RetroListRow(
        title = { Text(album.title, maxLines = 2, overflow = TextOverflow.Ellipsis) },
        subtitle = { Text(stringResource(R.string.tracks_count_artist, album.tracks.size, album.artist ?: stringResource(R.string.unknown_artist))) },
        leading = { IconChip(Icons.Outlined.Album) },
        trailing = { Checkbox(checked, onCheckedChange = { actions.toggleAlbum(album) }) },
        onClick = { actions.toggleAlbum(album) },
        contentDescription = album.title,
    )
}

@Composable
private fun TrackPickRow(path: LibraryPath, title: String, selected: Set<LibraryPath>, actions: AddTracksActions) {
    RetroListRow(
        title = { Text(title, maxLines = 2, overflow = TextOverflow.Ellipsis) },
        leading = { IconChip(Icons.Outlined.MusicNote) },
        trailing = { Checkbox(path in selected, onCheckedChange = { actions.toggleTrack(path) }) },
        onClick = { actions.toggleTrack(path) },
    )
}
