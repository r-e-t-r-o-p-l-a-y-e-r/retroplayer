package app.retroplayer.ui.library

import android.provider.DocumentsContract
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyListScope
import androidx.compose.foundation.lazy.LazyListState
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.lazy.rememberLazyListState
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
import androidx.compose.material3.ExtendedFloatingActionButton
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.snapshotFlow
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import app.retroplayer.domain.LibraryIndex
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalResources
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.CustomAccessibilityAction
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
import app.retroplayer.ui.components.Swipe
import app.retroplayer.ui.components.SwipeActions
import app.retroplayer.ui.components.addedToQueue
import app.retroplayer.ui.player.PlayerToggleAction
import app.retroplayer.ui.queue.QueueNavAction
import app.retroplayer.ui.theme.LocalRetroPalette
import app.retroplayer.ui.theme.RetroPalette
import kotlinx.coroutines.launch
import sh.calvin.reorderable.ReorderableItem
import sh.calvin.reorderable.rememberReorderableLazyListState

/** Navigation out of a library page. */
data class FolderNavigation(
    val openFolder: (LibraryPath) -> Unit,
    val openCrumb: (Crumb) -> Unit,
    val openAlbum: (AudioAlbum) -> Unit,
    val openQueue: () -> Unit = {},
    val openPlaylist: (LibraryPath) -> Unit = {},
)

/** Everything a library page can ask its view model to do. */
data class FolderActions(
    val play: (LibraryItem) -> Unit = {},
    val playFolder: (LibraryPath?) -> Unit = {},
    val toggleFavorite: (LibraryPath) -> Unit = {},
    val addFolder: () -> Unit = {},
    val removeRoot: (LibraryRoot) -> Unit = {},
    val moveRoot: (from: Int, to: Int) -> Unit = { _, _ -> },
    val moveFavorite: (from: Int, to: Int) -> Unit = { _, _ -> },
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
        listScroll = FolderListScroll(
            viewModel.listScrollIndex(),
            viewModel.listScrollOffset(),
            viewModel::saveListScroll,
        ),
        navigation = navigation,
        actions = FolderActions(
            play = viewModel::play,
            playFolder = viewModel::playFolder,
            toggleFavorite = viewModel::toggleFavorite,
            addFolder = { picker.launch(MUSIC_FOLDER) },
            removeRoot = { viewModel.removeRoot(it.id) },
            moveRoot = viewModel::moveRoot,
            moveFavorite = viewModel::moveFavorite,
            addToQueue = viewModel::addToQueue,
        ),
        snackbar = snackbar,
    )
}

private val MUSIC_FOLDER = DocumentsContract.buildDocumentUri(AbsolutePathMapper.EXTERNAL_STORAGE_AUTHORITY, "primary:Music")

private fun LibraryPath.holds(trackId: String?) = trackId != null && trackId.startsWith(value + "/")

private val LIBRARY_CRUMBS = listOf(Crumb("", null, isLibraryRoot = true))

data class FolderListScroll(
    val initialIndex: Int,
    val initialOffset: Int,
    val onChange: (index: Int, offset: Int) -> Unit,
)

@Composable
private fun rememberFolderListScroll(scroll: FolderListScroll?): LazyListState {
    if (scroll == null) return rememberLazyListState()
    val listState = remember(scroll.initialIndex, scroll.initialOffset) {
        LazyListState(scroll.initialIndex, scroll.initialOffset)
    }
    LaunchedEffect(listState, scroll.onChange) {
        snapshotFlow { listState.firstVisibleItemIndex to listState.firstVisibleItemScrollOffset }
            .collect { (index, offset) -> scroll.onChange(index, offset) }
    }
    return listState
}

@Composable
fun FolderContent(
    state: FolderUiState,
    isRoot: Boolean,
    playingTrackId: String?,
    navigation: FolderNavigation,
    actions: FolderActions,
    snackbar: SnackbarHostState = remember { SnackbarHostState() },
    listScroll: FolderListScroll? = null,
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
                RetroTopBar(
                    stringResource(R.string.library),
                    actions = {
                        QueueNavAction(navigation.openQueue)
                        PlayerToggleAction()
                    },
                )
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
                is FolderUiState.Root -> RootList(state, playingTrackId, navigation, rowActions, listScroll, onRemove = { confirmRemove = it.id })
                is FolderUiState.Folder -> FolderList(state, playingTrackId, navigation, rowActions, listScroll)
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
private fun PlayButton(label: String, onClick: () -> Unit) {
    IconButton(onClick = onClick) { Icon(Icons.Filled.PlayArrow, contentDescription = label) }
}

@Composable
private fun RowTitle(text: String) = Text(text, maxLines = 2, overflow = TextOverflow.Ellipsis)

@Composable
private fun RowSubtitle(text: String) = Text(text, maxLines = 1, overflow = TextOverflow.Ellipsis)

@Composable
private fun queueSwipe(itemId: String, actions: FolderActions) =
    Swipe(Icons.AutoMirrored.Filled.PlaylistAdd, stringResource(R.string.add_to_queue)) { actions.addToQueue(itemId) {} }

@Composable
private fun favoriteSwipe(path: LibraryPath, favorite: Boolean, actions: FolderActions) = Swipe(
    if (favorite) Icons.Outlined.StarBorder else Icons.Filled.Star,
    stringResource(if (favorite) R.string.remove_favorite else R.string.favorite),
) { actions.toggleFavorite(path) }

private fun Modifier.lifted(dragging: Boolean) = if (dragging) shadow(8.dp) else this

/**
 * The order one reorderable section shows. While a drag runs (and until the
 * stored order catches up) it shows its own copy; the stored order is only
 * written once, when the drag ends.
 */
private class DragOrder<T>(private val keyOf: (T) -> String) {
    var stored: List<T> = emptyList()
    private var local by mutableStateOf<List<T>?>(null)
    private var startIndex = -1
    private var held: String? = null

    val shown: List<T> get() = local?.takeIf { it.toSet() == stored.toSet() } ?: stored

    fun start(key: String) {
        local = shown
        startIndex = indexOf(key)
        held = key
    }

    /**
     * The release that ends a long press still reaches the row's click
     * handler (before [stop]); that click must not open the row.
     */
    fun click(key: String, open: () -> Unit) {
        if (held == key) held = null else open()
    }

    fun move(from: Any?, to: Any?) {
        val list = local ?: return
        val f = list.indexOfFirst { keyOf(it) == from }
        val t = list.indexOfFirst { keyOf(it) == to }
        if (f >= 0 && t >= 0) local = list.toMutableList().apply { add(t, removeAt(f)) }
    }

    fun stop(key: String, save: (Int, Int) -> Unit) {
        val end = indexOf(key)
        if (startIndex >= 0 && end >= 0 && end != startIndex) save(startIndex, end)
        startIndex = -1
        held = null
    }

    private fun indexOf(key: String) = (local ?: stored).indexOfFirst { keyOf(it) == key }
}

/** Screen-reader stand-in for dragging the row at [index] of [count]. */
@Composable
private fun moveActions(index: Int, count: Int, move: (from: Int, to: Int) -> Unit): List<CustomAccessibilityAction> {
    val up = stringResource(R.string.move_up)
    val down = stringResource(R.string.move_down)
    return listOfNotNull(
        CustomAccessibilityAction(up) { move(index, index - 1); true }.takeIf { index > 0 },
        CustomAccessibilityAction(down) { move(index, index + 1); true }.takeIf { index < count - 1 },
    )
}

private fun rootKey(root: LibraryRoot) = "root:" + root.id

private fun favoriteKey(link: FavoriteLink) = "fav:" + link.path.value

@Composable
private fun RootList(
    state: FolderUiState.Root,
    playingTrackId: String?,
    navigation: FolderNavigation,
    actions: FolderActions,
    listScroll: FolderListScroll?,
    onRemove: (LibraryRoot) -> Unit,
) {
    if (state.roots.isEmpty()) {
        Message(stringResource(R.string.no_folders_added))
        return
    }
    val removeLabel = stringResource(R.string.remove)
    val haptic = LocalHapticFeedback.current
    val roots = remember { DragOrder(::rootKey) }.apply { stored = state.roots }
    val favorites = remember { DragOrder(::favoriteKey) }.apply { stored = state.favorites }
    val listState = rememberFolderListScroll(listScroll)
    val reorder = rememberReorderableLazyListState(listState) { from, to ->
        roots.move(from.key, to.key)
        favorites.move(from.key, to.key)
    }
    val titles = remember(state) { rootSelectableTitles(state) }
    val labels = remember(titles) { LibraryIndex.labelsFor(titles) }
    val showIndexBar = titles.size > LibraryIndex.MIN_ROWS_FOR_BAR && labels.size > 1
    val scope = rememberCoroutineScope()
    Box(Modifier.fillMaxSize()) {
        LazyColumn(
            state = listState,
            contentPadding = PaddingValues(bottom = 96.dp, end = if (showIndexBar) 44.dp else 0.dp),
        ) {
        item(key = "h:sources") { SectionHeader(stringResource(R.string.library_sources)) }
        val shownRoots = roots.shown
        itemsIndexed(shownRoots, key = { _, root -> rootKey(root) }) { index, root ->
            val key = rootKey(root)
            ReorderableItem(reorder, key = key) { dragging ->
                SwipeActions(
                    modifier = Modifier.lifted(dragging).longPressDraggableHandle(
                        onDragStarted = {
                            haptic.performHapticFeedback(HapticFeedbackType.LongPress)
                            roots.start(key)
                        },
                        onDragStopped = { roots.stop(key, actions.moveRoot) },
                    ),
                    fromEnd = Swipe(Icons.Outlined.Delete, removeLabel) { onRemove(root) },
                    moreActions = moveActions(index, shownRoots.size, actions.moveRoot),
                ) {
                    RetroListRow(
                        title = { RowTitle(root.name) },
                        subtitle = AbsolutePathMapper.displayLocation(root.treeUri)?.let { { RowSubtitle(it) } },
                        leading = { IconChip(Icons.Outlined.Folder) },
                        trailing = { PlayButton(stringResource(R.string.play_folder)) { actions.playFolder(root.path) } },
                        playing = root.path.holds(playingTrackId),
                        onClick = { roots.click(key) { navigation.openFolder(root.path) } },
                    )
                }
            }
        }
        if (state.favorites.isNotEmpty()) {
            item(key = "h:favorites") { SectionHeader(stringResource(R.string.favorites)) }
            val shownFavorites = favorites.shown
            itemsIndexed(shownFavorites, key = { _, link -> favoriteKey(link) }) { index, link ->
                val key = favoriteKey(link)
                ReorderableItem(reorder, key = key) { dragging ->
                    SwipeActions(
                        modifier = Modifier.lifted(dragging).longPressDraggableHandle(
                            onDragStarted = {
                                haptic.performHapticFeedback(HapticFeedbackType.LongPress)
                                favorites.start(key)
                            },
                            onDragStopped = { favorites.stop(key, actions.moveFavorite) },
                        ),
                        fromStart = favoriteSwipe(link.path, favorite = true, actions),
                        fromEnd = queueSwipe(PlaybackItem.folderId(link.path), actions),
                        moreActions = moveActions(index, shownFavorites.size, actions.moveFavorite),
                    ) {
                        RetroListRow(
                            title = { RowTitle(link.label) },
                            subtitle = link.rootName?.let { { RowSubtitle(it) } },
                            leading = { IconChip(Icons.Outlined.FolderSpecial, contentDescription = stringResource(R.string.favorite)) },
                            trailing = { PlayButton(stringResource(R.string.play_folder)) { actions.playFolder(link.path) } },
                            playing = link.path.holds(playingTrackId),
                            onClick = { favorites.click(key) { navigation.openFolder(link.path) } },
                            )
                    }
                }
            }
        }
        }
        if (showIndexBar) {
            AlphabetIndexBar(
                labels = labels,
                modifier = Modifier.align(Alignment.CenterEnd),
                onSelect = { letter ->
                    scope.launch {
                        val row = LibraryIndex.firstMatchingIndex(titles, letter) ?: return@launch
                        val lazyIndex = LibraryIndex.lazyColumnIndexForSelectableRow(
                            row,
                            state.roots.size,
                            state.favorites.size,
                            audioCount = 0,
                        )
                        listState.scrollToItem(lazyIndex)
                    }
                },
            )
        }
    }
}

@Composable
private fun FolderList(
    state: FolderUiState.Folder,
    playingTrackId: String?,
    navigation: FolderNavigation,
    actions: FolderActions,
    listScroll: FolderListScroll?,
) {
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
        val listState = rememberFolderListScroll(listScroll)
        val titles = remember(state) { folderSelectableTitles(state) }
        val labels = remember(titles) { LibraryIndex.labelsFor(titles) }
        val showIndexBar = titles.size > LibraryIndex.MIN_ROWS_FOR_BAR && labels.size > 1
        val scope = rememberCoroutineScope()
        Box(Modifier.fillMaxSize()) {
            LazyColumn(
                state = listState,
                contentPadding = PaddingValues(bottom = 96.dp, end = if (showIndexBar) 44.dp else 0.dp),
            ) {
                folderSection(state, playingTrackId, navigation, actions)
                playlistSection(state.playlists, navigation, actions)
                audioSection(state, playingTrackId, navigation, actions)
            }
            if (showIndexBar) {
                AlphabetIndexBar(
                    labels = labels,
                    modifier = Modifier.align(Alignment.CenterEnd),
                    onSelect = { letter ->
                        scope.launch {
                            val row = LibraryIndex.firstMatchingIndex(titles, letter) ?: return@launch
                            val lazyIndex = LibraryIndex.lazyColumnIndexForSelectableRow(
                                row,
                                state.folders.size,
                                state.playlists.size,
                                state.audio.size,
                            )
                            listState.scrollToItem(lazyIndex)
                        }
                    },
                )
            }
        }
    }
}

private fun rootSelectableTitles(state: FolderUiState.Root): List<String> =
    state.roots.map { it.name } + state.favorites.map { it.label }

private fun folderSelectableTitles(state: FolderUiState.Folder): List<String> =
    state.folders.map { it.entry.path.name } +
        state.playlists.map { it.displayName } +
        state.audio.map { it.title }

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
        SwipeActions(
            fromStart = favoriteSwipe(path, row.isFavorite, actions),
            fromEnd = queueSwipe(PlaybackItem.folderId(path), actions),
        ) {
            RetroListRow(
                title = { RowTitle(path.name) },
                subtitle = { RowSubtitle(parent + "/" + path.name) },
                leading = { FolderChip(row.isFavorite) },
                trailing = { PlayButton(stringResource(R.string.play_folder)) { actions.playFolder(path) } },
                playing = path.holds(playingTrackId),
                onClick = { navigation.openFolder(path) },
            )
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

private fun LazyListScope.playlistSection(playlists: List<PlaylistRef>, navigation: FolderNavigation, actions: FolderActions) {
    if (playlists.isEmpty()) return
    item(key = "h:playlists") { SectionHeader(stringResource(R.string.playlists)) }
    items(playlists, key = { "p:" + it.path.value }) { playlist ->
        val item = LibraryItem.Playlist(playlist)
        SwipeActions(fromEnd = queueSwipe(item.id, actions)) {
            RetroListRow(
                title = { RowTitle(playlist.displayName) },
                leading = { IconChip(Icons.AutoMirrored.Filled.PlaylistPlay) },
                trailing = { PlayButton(stringResource(R.string.play_playlist)) { actions.play(item) } },
                onClick = { navigation.openPlaylist(playlist.path) },
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
        SwipeActions(fromEnd = queueSwipe(item.id, actions)) {
            when (item) {
                is LibraryItem.Album -> AlbumRow(item.album, state.artUri, playingTrackId, navigation, actions)
                is LibraryItem.Track -> TrackRow(item, playingTrackId, actions)
                is LibraryItem.Playlist -> Unit
            }
        }
    }
}

@Composable
private fun AlbumRow(album: AudioAlbum, folderArt: String?, playingTrackId: String?, navigation: FolderNavigation, actions: FolderActions) {
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
    )
}

@Composable
private fun TrackRow(item: LibraryItem.Track, playingTrackId: String?, actions: FolderActions) {
    val track = item.track
    val playing = track.id == playingTrackId
    RetroListRow(
        title = { RowTitle(track.displayTitle) },
        subtitle = { RowSubtitle(track.displayArtist ?: stringResource(R.string.track_fallback)) },
        leading = { IconChip(Icons.Outlined.MusicNote, highlight = playing) },
        playing = playing,
        onClick = { actions.play(item) },
    )
}
