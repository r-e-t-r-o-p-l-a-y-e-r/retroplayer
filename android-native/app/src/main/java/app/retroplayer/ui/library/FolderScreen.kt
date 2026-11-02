package app.retroplayer.ui.library

import android.provider.DocumentsContract
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyListScope
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.QueueMusic
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Folder
import androidx.compose.material.icons.filled.MusicNote
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material.icons.filled.Star
import androidx.compose.material.icons.filled.StarBorder
import androidx.compose.material.icons.outlined.FolderSpecial
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ExtendedFloatingActionButton
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.ListItem
import androidx.compose.material3.ListItemDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import app.retroplayer.R
import app.retroplayer.data.db.LibraryRoot
import app.retroplayer.data.library.AbsolutePathMapper
import app.retroplayer.domain.Crumb
import app.retroplayer.domain.LibraryPath
import app.retroplayer.domain.model.AudioAlbum
import app.retroplayer.domain.model.LibraryItem
import app.retroplayer.domain.model.PlaylistRef
import app.retroplayer.ui.art.EmbeddedArt
import app.retroplayer.ui.components.AlbumArt
import app.retroplayer.ui.components.BreadcrumbBar
import app.retroplayer.ui.components.SectionHeader
import app.retroplayer.ui.formatDuration
import app.retroplayer.ui.theme.LocalRetroPalette
import kotlinx.coroutines.launch

/** Navigation out of a library page. */
data class FolderNavigation(
    val openFolder: (LibraryPath) -> Unit,
    val openCrumb: (Crumb) -> Unit,
    val openAlbum: (AudioAlbum) -> Unit,
)

/** Everything a library page can ask its view model to do. */
data class FolderActions(
    val play: (LibraryItem) -> Unit = {},
    val playFolder: (LibraryPath?) -> Unit = {},
    val toggleFavorite: (LibraryPath) -> Unit = {},
    val addFolder: () -> Unit = {},
    val removeRoot: (LibraryRoot) -> Unit = {},
)

@Composable
fun FolderScreen(viewModel: FolderViewModel, navigation: FolderNavigation, playingTrackId: String?) {
    val state by viewModel.state.collectAsStateWithLifecycle()
    val snackbar = remember { SnackbarHostState() }
    val scope = rememberCoroutineScope()
    val accessDenied = stringResource(R.string.folder_access_denied)
    val picker = rememberLauncherForActivityResult(ActivityResultContracts.OpenDocumentTree()) { uri ->
        if (uri != null) {
            viewModel.addRoot(uri.toString()) { root ->
                if (root != null) navigation.openFolder(root) else scope.launch { snackbar.showSnackbar(accessDenied) }
            }
        }
    }
    LaunchedEffect(Unit) { viewModel.onShown() }
    FolderContent(
        state = state,
        isRoot = viewModel.path == null,
        playingTrackId = playingTrackId,
        navigation = navigation,
        actions = FolderActions(
            play = viewModel::play,
            playFolder = viewModel::playFolder,
            toggleFavorite = viewModel::toggleFavorite,
            addFolder = { picker.launch(MUSIC_FOLDER) },
            removeRoot = { viewModel.removeRoot(it.id) },
        ),
        snackbar = snackbar,
    )
}

private val MUSIC_FOLDER = DocumentsContract.buildDocumentUri(AbsolutePathMapper.EXTERNAL_STORAGE_AUTHORITY, "primary:Music")

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun FolderContent(
    state: FolderUiState,
    isRoot: Boolean,
    playingTrackId: String?,
    navigation: FolderNavigation,
    actions: FolderActions,
    snackbar: SnackbarHostState = remember { SnackbarHostState() },
) {
    var confirmRemove by rememberSaveable { mutableStateOf<String?>(null) }
    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    when (state) {
                        is FolderUiState.Folder -> BreadcrumbBar(state.crumbs, navigation.openCrumb)
                        else -> Text(stringResource(R.string.library))
                    }
                },
                actions = {
                    if (state is FolderUiState.Folder) {
                        IconButton(onClick = { actions.playFolder(state.path) }) {
                            Icon(Icons.Filled.PlayArrow, contentDescription = stringResource(R.string.play_folder))
                        }
                    }
                },
            )
        },
        floatingActionButton = {
            if (isRoot) {
                ExtendedFloatingActionButton(
                    onClick = actions.addFolder,
                    icon = { Icon(Icons.Filled.Add, contentDescription = null) },
                    text = { Text(stringResource(R.string.add_folder)) },
                )
            }
        },
        snackbarHost = { SnackbarHost(snackbar) },
    ) { padding ->
        Box(Modifier.padding(padding).fillMaxSize()) {
            when (state) {
                FolderUiState.Loading -> LinearProgressIndicator(Modifier.fillMaxWidth())
                FolderUiState.Missing -> Message(stringResource(R.string.folder_missing))
                is FolderUiState.Root -> RootList(state, navigation, onRemove = { confirmRemove = it.id })
                is FolderUiState.Folder -> FolderList(state, playingTrackId, navigation, actions)
            }
        }
    }
    val root = (state as? FolderUiState.Root)?.roots?.firstOrNull { it.id == confirmRemove }
    if (root != null) {
        AlertDialog(
            onDismissRequest = { confirmRemove = null },
            title = { Text(stringResource(R.string.remove_library_folder_title)) },
            text = { Text(stringResource(R.string.remove_library_folder_body, root.name)) },
            confirmButton = {
                TextButton(onClick = {
                    confirmRemove = null
                    actions.removeRoot(root)
                }) { Text(stringResource(R.string.remove)) }
            },
            dismissButton = { TextButton(onClick = { confirmRemove = null }) { Text(stringResource(R.string.cancel)) } },
        )
    }
}

@Composable
private fun Message(text: String) {
    Text(
        text,
        style = MaterialTheme.typography.bodyLarge,
        textAlign = TextAlign.Center,
        color = MaterialTheme.colorScheme.onSurfaceVariant,
        modifier = Modifier.fillMaxSize().padding(32.dp).testTag("message"),
    )
}

@Composable
private fun RootList(state: FolderUiState.Root, navigation: FolderNavigation, onRemove: (LibraryRoot) -> Unit) {
    if (state.roots.isEmpty()) {
        Message(stringResource(R.string.no_folders_added))
        return
    }
    LazyColumn(contentPadding = PaddingValues(bottom = 96.dp)) {
        item { SectionHeader(stringResource(R.string.library_sources)) }
        items(state.roots, key = { "root:" + it.id }) { root ->
            ListItem(
                headlineContent = { Text(root.name, maxLines = 2, overflow = TextOverflow.Ellipsis) },
                leadingContent = { Icon(Icons.Filled.Folder, contentDescription = null) },
                trailingContent = {
                    IconButton(onClick = { onRemove(root) }) {
                        Icon(Icons.Filled.Delete, contentDescription = stringResource(R.string.remove))
                    }
                },
                modifier = Modifier.clickable { navigation.openFolder(root.path) },
            )
        }
        if (state.favorites.isNotEmpty()) {
            item { SectionHeader(stringResource(R.string.favorites)) }
            items(state.favorites, key = { "fav:" + it.path.value }) { link ->
                ListItem(
                    headlineContent = { Text(link.label, maxLines = 2, overflow = TextOverflow.Ellipsis) },
                    supportingContent = link.rootName?.let { { Text(it, maxLines = 1, overflow = TextOverflow.Ellipsis) } },
                    leadingContent = { Icon(Icons.Outlined.FolderSpecial, contentDescription = stringResource(R.string.favorite)) },
                    modifier = Modifier.clickable { navigation.openFolder(link.path) },
                )
            }
        }
    }
}

@Composable
private fun FolderList(state: FolderUiState.Folder, playingTrackId: String?, navigation: FolderNavigation, actions: FolderActions) {
    Column(Modifier.fillMaxSize()) {
        if (!state.complete && state.total > 0) {
            LinearProgressIndicator(
                progress = { state.scanned.toFloat() / state.total },
                modifier = Modifier.fillMaxWidth(),
            )
        }
        if (state.complete && state.folders.isEmpty() && state.playlists.isEmpty() && state.audio.isEmpty()) {
            Message(stringResource(R.string.folder_empty))
            return
        }
        LazyColumn(contentPadding = PaddingValues(bottom = 96.dp), verticalArrangement = Arrangement.Top) {
            folderSection(state.folders, navigation, actions)
            playlistSection(state.playlists, actions)
            audioSection(state, playingTrackId, navigation, actions)
        }
    }
}

private fun LazyListScope.folderSection(folders: List<FolderRow>, navigation: FolderNavigation, actions: FolderActions) {
    if (folders.isEmpty()) return
    item(key = "h:folders") { SectionHeader(stringResource(R.string.folders)) }
    items(folders, key = { "f:" + it.entry.path.value }) { row ->
        ListItem(
            headlineContent = { Text(row.entry.path.name, maxLines = 2, overflow = TextOverflow.Ellipsis) },
            leadingContent = { Icon(Icons.Filled.Folder, contentDescription = null) },
            trailingContent = {
                IconButton(onClick = { actions.toggleFavorite(row.entry.path) }) {
                    Icon(
                        if (row.isFavorite) Icons.Filled.Star else Icons.Filled.StarBorder,
                        contentDescription = stringResource(if (row.isFavorite) R.string.remove_favorite else R.string.favorite),
                        tint = if (row.isFavorite) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.outline,
                    )
                }
            },
            modifier = Modifier.clickable { navigation.openFolder(row.entry.path) },
        )
    }
}

private fun LazyListScope.playlistSection(playlists: List<PlaylistRef>, actions: FolderActions) {
    if (playlists.isEmpty()) return
    item(key = "h:playlists") { SectionHeader(stringResource(R.string.playlists)) }
    items(playlists, key = { "p:" + it.path.value }) { playlist ->
        ListItem(
            headlineContent = { Text(playlist.displayName, maxLines = 2, overflow = TextOverflow.Ellipsis) },
            leadingContent = { Icon(Icons.AutoMirrored.Filled.QueueMusic, contentDescription = null) },
            trailingContent = {
                IconButton(onClick = { actions.play(LibraryItem.Playlist(playlist)) }) {
                    Icon(Icons.Filled.PlayArrow, contentDescription = stringResource(R.string.play_playlist))
                }
            },
            modifier = Modifier.clickable { actions.play(LibraryItem.Playlist(playlist)) },
        )
    }
}

private fun LazyListScope.audioSection(
    state: FolderUiState.Folder,
    playingTrackId: String?,
    navigation: FolderNavigation,
    actions: FolderActions,
) {
    if (state.audio.isEmpty()) return
    item(key = "h:audio") { SectionHeader(stringResource(R.string.audio)) }
    items(state.audio, key = { "a:" + it.id }) { item ->
        when (item) {
            is LibraryItem.Album -> AlbumRow(item.album, state.artUri, playingTrackId, navigation, actions)
            is LibraryItem.Track -> TrackRow(item, playingTrackId, actions)
            is LibraryItem.Playlist -> Unit
        }
    }
}

@Composable
private fun AlbumRow(album: AudioAlbum, folderArt: String?, playingTrackId: String?, navigation: FolderNavigation, actions: FolderActions) {
    val playing = album.tracks.any { it.id == playingTrackId }
    ListItem(
        headlineContent = { Text(album.title, maxLines = 2, overflow = TextOverflow.Ellipsis) },
        supportingContent = {
            Text(
                stringResource(R.string.tracks_count_artist, album.tracks.size, album.artist ?: stringResource(R.string.unknown_artist)),
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
            )
        },
        leadingContent = { AlbumArt(folderArt ?: album.tracks.firstOrNull()?.let { EmbeddedArt(it.uri) }) },
        trailingContent = {
            IconButton(onClick = { actions.play(LibraryItem.Album(album)) }) {
                Icon(Icons.Filled.PlayArrow, contentDescription = stringResource(R.string.play_album))
            }
        },
        colors = highlight(playing),
        modifier = Modifier.clickable { navigation.openAlbum(album) },
    )
}

@Composable
private fun TrackRow(item: LibraryItem.Track, playingTrackId: String?, actions: FolderActions) {
    val track = item.track
    ListItem(
        headlineContent = { Text(track.displayTitle, maxLines = 2, overflow = TextOverflow.Ellipsis) },
        supportingContent = track.displayArtist?.let { { Text(it, maxLines = 1, overflow = TextOverflow.Ellipsis) } },
        leadingContent = { Icon(Icons.Filled.MusicNote, contentDescription = null) },
        trailingContent = track.durationMs?.let { { Text(formatDuration(it), style = MaterialTheme.typography.labelMedium) } },
        colors = highlight(track.id == playingTrackId),
        modifier = Modifier.clickable { actions.play(item) },
    )
}

@Composable
private fun highlight(on: Boolean) =
    if (on) ListItemDefaults.colors(containerColor = LocalRetroPalette.current.playingHighlight) else ListItemDefaults.colors()
