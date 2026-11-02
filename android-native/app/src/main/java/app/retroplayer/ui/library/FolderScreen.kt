package app.retroplayer.ui.library

import android.provider.DocumentsContract
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import android.content.res.Resources
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyListScope
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.PlaylistAdd
import androidx.compose.material.icons.automirrored.filled.PlaylistPlay
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material.icons.filled.Star
import androidx.compose.material.icons.outlined.Album
import androidx.compose.material.icons.outlined.Delete
import androidx.compose.material.icons.outlined.StarBorder
import androidx.compose.material.icons.outlined.Folder
import androidx.compose.material.icons.outlined.FolderOpen
import androidx.compose.material.icons.outlined.FolderSpecial
import androidx.compose.material.icons.outlined.MusicNote
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ExtendedFloatingActionButton
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
import androidx.compose.material3.SwipeToDismissBox
import androidx.compose.material3.rememberSwipeToDismissBoxState
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
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
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalResources
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.CustomAccessibilityAction
import androidx.compose.ui.semantics.customActions
import androidx.compose.ui.semantics.semantics
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
import app.retroplayer.domain.model.PlaybackItem
import app.retroplayer.domain.model.PlaylistRef
import app.retroplayer.ui.art.EmbeddedArt
import app.retroplayer.ui.components.AlbumArt
import app.retroplayer.ui.components.BreadcrumbStrip
import app.retroplayer.ui.components.IconChip
import app.retroplayer.ui.components.RetroListRow
import app.retroplayer.ui.components.RetroTopBar
import app.retroplayer.ui.components.SectionHeader
import app.retroplayer.ui.player.PlayerToggleAction
import app.retroplayer.ui.theme.LocalRetroPalette
import app.retroplayer.ui.theme.RetroPalette
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
    /** Queues what the playback item would play; the callback gets how many tracks were new. */
    val addToQueue: (itemId: String, onAdded: (Int) -> Unit) -> Unit = { _, _ -> },
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
            addToQueue = viewModel::addToQueue,
        ),
        snackbar = snackbar,
    )
}

private val MUSIC_FOLDER = DocumentsContract.buildDocumentUri(AbsolutePathMapper.EXTERNAL_STORAGE_AUTHORITY, "primary:Music")

private fun LibraryPath.holds(trackId: String?) = trackId != null && trackId.startsWith(value + "/")

private val LIBRARY_CRUMBS = listOf(Crumb("", null, isLibraryRoot = true))

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
    val resources = LocalResources.current
    val scope = rememberCoroutineScope()
    val rowActions = actions.copy(
        addToQueue = { id, onAdded ->
            actions.addToQueue(id) { count ->
                onAdded(count)
                scope.launch { snackbar.showSnackbar(resources.addedToQueue(count)) }
            }
        },
    )
    Scaffold(
        topBar = {
            Column {
                RetroTopBar(stringResource(R.string.library), actions = { PlayerToggleAction() })
                BreadcrumbStrip((state as? FolderUiState.Folder)?.crumbs ?: LIBRARY_CRUMBS, navigation.openCrumb)
            }
        },
        floatingActionButton = {
            if (isRoot) {
                val palette = LocalRetroPalette.current
                ExtendedFloatingActionButton(
                    onClick = actions.addFolder,
                    icon = { Icon(Icons.Outlined.FolderOpen, contentDescription = null) },
                    text = { Text(stringResource(R.string.add_folder)) },
                    containerColor = palette.accent,
                    contentColor = if (palette == RetroPalette.Dark) palette.textPrimary else Color.White,
                    shape = RoundedCornerShape(24.dp),
                )
            }
        },
        snackbarHost = { SnackbarHost(snackbar) },
    ) { padding ->
        Box(Modifier.padding(padding).fillMaxSize()) {
            when (state) {
                FolderUiState.Loading -> LinearProgressIndicator(Modifier.fillMaxWidth())
                FolderUiState.Missing -> Message(stringResource(R.string.folder_missing))
                is FolderUiState.Root -> RootList(state, playingTrackId, navigation, rowActions, onRemove = { confirmRemove = it.id })
                is FolderUiState.Folder -> FolderList(state, playingTrackId, navigation, rowActions)
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

private fun Resources.addedToQueue(count: Int) = when (count) {
    0 -> getString(R.string.added_to_queue_eq0)
    1 -> getString(R.string.added_to_queue_eq1)
    else -> getString(R.string.added_to_queue_other, count)
}

/** Gives [row] a long-press that opens a menu adding [itemId] to the queue. */
@Composable
private fun QueueMenu(itemId: String, actions: FolderActions, row: @Composable (openMenu: () -> Unit) -> Unit) {
    var open by remember { mutableStateOf(false) }
    Box {
        row { open = true }
        DropdownMenu(expanded = open, onDismissRequest = { open = false }) {
            DropdownMenuItem(
                text = { Text(stringResource(R.string.add_to_queue)) },
                leadingIcon = { Icon(Icons.AutoMirrored.Filled.PlaylistAdd, contentDescription = null) },
                onClick = {
                    open = false
                    actions.addToQueue(itemId) {}
                },
            )
        }
    }
}

/**
 * One-way swipe that runs [onSwiped] and snaps back; [label] names the same
 * action for accessibility services.
 */
@Composable
private fun SwipeAction(
    fromStart: Boolean,
    icon: ImageVector,
    label: String,
    onSwiped: () -> Unit,
    content: @Composable () -> Unit,
) {
    val palette = LocalRetroPalette.current
    val state = rememberSwipeToDismissBoxState()
    val scope = rememberCoroutineScope()
    SwipeToDismissBox(
        state = state,
        modifier = Modifier.semantics { customActions = listOf(CustomAccessibilityAction(label) { onSwiped(); true }) },
        enableDismissFromStartToEnd = fromStart,
        enableDismissFromEndToStart = !fromStart,
        onDismiss = {
            onSwiped()
            scope.launch { state.reset() }
        },
        backgroundContent = {
            Box(
                Modifier.fillMaxSize().background(palette.chrome).padding(horizontal = 24.dp),
                contentAlignment = if (fromStart) Alignment.CenterStart else Alignment.CenterEnd,
            ) { Icon(icon, contentDescription = null, tint = palette.accent) }
        },
    ) { Box(Modifier.background(palette.screen)) { content() } }
}

@Composable
private fun PlayButton(label: String, onClick: () -> Unit) {
    IconButton(onClick = onClick) { Icon(Icons.Filled.PlayArrow, contentDescription = label) }
}

@Composable
private fun RowTitle(text: String) = Text(text, maxLines = 2, overflow = TextOverflow.Ellipsis)

@Composable
private fun RowSubtitle(text: String) = Text(text, maxLines = 1, overflow = TextOverflow.Ellipsis)

@Composable
private fun RootList(
    state: FolderUiState.Root,
    playingTrackId: String?,
    navigation: FolderNavigation,
    actions: FolderActions,
    onRemove: (LibraryRoot) -> Unit,
) {
    if (state.roots.isEmpty()) {
        Message(stringResource(R.string.no_folders_added))
        return
    }
    val removeLabel = stringResource(R.string.remove)
    val addLabel = stringResource(R.string.add_to_queue)
    LazyColumn(contentPadding = PaddingValues(bottom = 96.dp)) {
        item { SectionHeader(stringResource(R.string.library_sources)) }
        items(state.roots, key = { "root:" + it.id }) { root ->
            SwipeAction(fromStart = false, icon = Icons.Outlined.Delete, label = removeLabel, onSwiped = { onRemove(root) }) {
                QueueMenu(PlaybackItem.folderId(root.path), actions) { openMenu ->
                    RetroListRow(
                        title = { RowTitle(root.name) },
                        subtitle = AbsolutePathMapper.displayLocation(root.treeUri)?.let { { RowSubtitle(it) } },
                        leading = { IconChip(Icons.Outlined.Folder) },
                        trailing = { PlayButton(stringResource(R.string.play_folder)) { actions.playFolder(root.path) } },
                        playing = root.path.holds(playingTrackId),
                        onClick = { navigation.openFolder(root.path) },
                        onLongClick = openMenu,
                        onLongClickLabel = addLabel,
                    )
                }
            }
        }
        if (state.favorites.isNotEmpty()) {
            item { SectionHeader(stringResource(R.string.favorites)) }
            items(state.favorites, key = { "fav:" + it.path.value }) { link ->
                QueueMenu(PlaybackItem.folderId(link.path), actions) { openMenu ->
                    RetroListRow(
                        title = { RowTitle(link.label) },
                        subtitle = link.rootName?.let { { RowSubtitle(it) } },
                        leading = { IconChip(Icons.Outlined.FolderSpecial, contentDescription = stringResource(R.string.favorite)) },
                        trailing = { PlayButton(stringResource(R.string.play_folder)) { actions.playFolder(link.path) } },
                        playing = link.path.holds(playingTrackId),
                        onClick = { navigation.openFolder(link.path) },
                        onLongClick = openMenu,
                        onLongClickLabel = addLabel,
                    )
                }
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
        LazyColumn(contentPadding = PaddingValues(bottom = 96.dp)) {
            folderSection(state, playingTrackId, navigation, actions)
            playlistSection(state.playlists, actions)
            audioSection(state, playingTrackId, navigation, actions)
        }
    }
}

private fun LazyListScope.folderSection(
    state: FolderUiState.Folder,
    playingTrackId: String?,
    navigation: FolderNavigation,
    actions: FolderActions,
) {
    if (state.folders.isEmpty()) return
    val parent = state.crumbs.filterNot { it.isLibraryRoot }.joinToString("/", prefix = "/") { it.label }
    item(key = "h:folders") { SectionHeader(stringResource(R.string.folders)) }
    items(state.folders, key = { "f:" + it.entry.path.value }) { row ->
        val path = row.entry.path
        SwipeAction(
            fromStart = true,
            icon = if (row.isFavorite) Icons.Outlined.StarBorder else Icons.Filled.Star,
            label = stringResource(if (row.isFavorite) R.string.remove_favorite else R.string.favorite),
            onSwiped = { actions.toggleFavorite(path) },
        ) {
            QueueMenu(PlaybackItem.folderId(path), actions) { openMenu ->
                RetroListRow(
                    title = { RowTitle(path.name) },
                    subtitle = { RowSubtitle(parent + "/" + path.name) },
                    leading = { FolderChip(row.isFavorite) },
                    trailing = { PlayButton(stringResource(R.string.play_folder)) { actions.playFolder(path) } },
                    playing = path.holds(playingTrackId),
                    onClick = { navigation.openFolder(path) },
                    onLongClick = openMenu,
                    onLongClickLabel = stringResource(R.string.add_to_queue),
                )
            }
        }
    }
}

@Composable
private fun FolderChip(favorite: Boolean) {
    Box {
        IconChip(Icons.Outlined.Folder)
        if (favorite) {
            Icon(
                Icons.Filled.Star,
                contentDescription = stringResource(R.string.favorite),
                tint = LocalRetroPalette.current.accent,
                modifier = Modifier.size(16.dp).align(Alignment.TopEnd),
            )
        }
    }
}

private fun LazyListScope.playlistSection(playlists: List<PlaylistRef>, actions: FolderActions) {
    if (playlists.isEmpty()) return
    item(key = "h:playlists") { SectionHeader(stringResource(R.string.playlists)) }
    items(playlists, key = { "p:" + it.path.value }) { playlist ->
        val item = LibraryItem.Playlist(playlist)
        QueueMenu(item.id, actions) { openMenu ->
            RetroListRow(
                title = { RowTitle(playlist.displayName) },
                leading = { IconChip(Icons.AutoMirrored.Filled.PlaylistPlay) },
                trailing = { PlayButton(stringResource(R.string.play_playlist)) { actions.play(item) } },
                onClick = { actions.play(item) },
                onLongClick = openMenu,
                onLongClickLabel = stringResource(R.string.add_to_queue),
            )
        }
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
    QueueMenu(LibraryItem.Album(album).id, actions) { openMenu ->
    RetroListRow(
        title = { RowTitle(album.title) },
        subtitle = {
            RowSubtitle(stringResource(R.string.tracks_count_artist, album.tracks.size, album.artist ?: stringResource(R.string.unknown_artist)))
        },
        leading = {
            AlbumArt(folderArt ?: album.tracks.firstOrNull()?.let { EmbeddedArt(it.uri) }, size = 40.dp, placeholderIcon = Icons.Outlined.Album)
        },
        trailing = { PlayButton(stringResource(R.string.play_album)) { actions.play(LibraryItem.Album(album)) } },
        playing = album.tracks.any { it.id == playingTrackId },
        onClick = { navigation.openAlbum(album) },
        onLongClick = openMenu,
        onLongClickLabel = stringResource(R.string.add_to_queue),
    )
    }
}

@Composable
private fun TrackRow(item: LibraryItem.Track, playingTrackId: String?, actions: FolderActions) {
    val track = item.track
    val playing = track.id == playingTrackId
    QueueMenu(item.id, actions) { openMenu ->
    RetroListRow(
        title = { RowTitle(track.displayTitle) },
        subtitle = { RowSubtitle(track.displayArtist ?: stringResource(R.string.track_fallback)) },
        leading = { IconChip(Icons.Outlined.MusicNote, highlight = playing) },
        playing = playing,
        onClick = { actions.play(item) },
        onLongClick = openMenu,
        onLongClickLabel = stringResource(R.string.add_to_queue),
    )
    }
}
