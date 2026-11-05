package app.retroplayer.ui.playlist

import app.retroplayer.ui.components.RetroFab
import androidx.compose.material.icons.automirrored.outlined.PlaylistAdd
import app.retroplayer.ui.components.DialogText
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Delete
import androidx.compose.material.icons.outlined.MusicNote
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.CustomAccessibilityAction
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.compose.LocalLifecycleOwner
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import app.retroplayer.R
import app.retroplayer.ui.components.BackButton
import app.retroplayer.ui.components.IconChip
import app.retroplayer.ui.components.RetroListRow
import app.retroplayer.ui.components.RetroTopBar
import app.retroplayer.ui.components.Swipe
import app.retroplayer.ui.components.SwipeActions
import app.retroplayer.ui.components.SwipeStyle
import app.retroplayer.ui.formatDuration
import app.retroplayer.ui.player.PlayerToggleAction
import sh.calvin.reorderable.ReorderableItem
import sh.calvin.reorderable.rememberReorderableLazyListState

const val PLAYLIST_EMPTY_TAG = "playlistEmpty"

data class PlaylistActions(
    val back: () -> Unit = {},
    val play: (PlaylistEntryUi) -> Unit = {},
    val move: (Int, Int) -> Unit = { _, _ -> },
    val addTracks: () -> Unit = {},
    val toggleSelectMode: () -> Unit = {},
    val toggleSelected: (Int) -> Unit = {},
    val selectAll: () -> Unit = {},
    val deselectAll: () -> Unit = {},
    val requestRemove: (Set<Int>) -> Unit = {},
    val confirmRemove: () -> Unit = {},
    val dismissRemove: () -> Unit = {},
    val requestDelete: () -> Unit = {},
    val confirmDelete: () -> Unit = {},
    val dismissDelete: () -> Unit = {},
)

@Composable
fun PlaylistScreen(
    viewModel: PlaylistViewModel,
    back: () -> Unit,
    onAddTracks: () -> Unit,
    onDeleted: () -> Unit,
) {
    val state by viewModel.state.collectAsStateWithLifecycle()
    val lifecycleOwner = LocalLifecycleOwner.current
    DisposableEffect(lifecycleOwner) {
        val observer = LifecycleEventObserver { _, event ->
            if (event == Lifecycle.Event.ON_RESUME) viewModel.reload()
        }
        lifecycleOwner.lifecycle.addObserver(observer)
        onDispose { lifecycleOwner.lifecycle.removeObserver(observer) }
    }
    PlaylistContent(
        state = state,
        actions = PlaylistActions(
            back = back,
            play = viewModel::play,
            move = viewModel::move,
            addTracks = onAddTracks,
            toggleSelectMode = viewModel::toggleSelectMode,
            toggleSelected = viewModel::toggleSelected,
            selectAll = viewModel::selectAll,
            deselectAll = viewModel::deselectAll,
            requestRemove = viewModel::requestRemove,
            confirmRemove = viewModel::confirmRemove,
            dismissRemove = viewModel::dismissRemove,
            requestDelete = viewModel::requestDelete,
            confirmDelete = { viewModel.confirmDelete(onDeleted) },
            dismissDelete = viewModel::dismissDelete,
        ),
    )
}

@Composable
fun PlaylistContent(state: PlaylistUiState, actions: PlaylistActions) {
    Scaffold(
        topBar = {
            when (state) {
                PlaylistUiState.Loading -> RetroTopBar("", navigationIcon = { BackButton(actions.back) })
                is PlaylistUiState.Ready -> PlaylistTopBar(state, actions)
            }
        },
        floatingActionButton = {
            if (state is PlaylistUiState.Ready && state.editable && !state.selectMode) {
                RetroFab(stringResource(R.string.add_tracks), Icons.AutoMirrored.Outlined.PlaylistAdd, actions.addTracks)
            }
        },
    ) { padding ->
        Box(Modifier.padding(padding).fillMaxSize()) {
            when (state) {
                PlaylistUiState.Loading -> LinearProgressIndicator(Modifier.fillMaxWidth())
                is PlaylistUiState.Ready -> {
                    Column(Modifier.fillMaxSize()) {
                        Text(
                            state.title,
                            style = MaterialTheme.typography.headlineSmall.copy(fontSize = 17.sp, lineHeight = 22.sp),
                            maxLines = 2,
                            overflow = TextOverflow.Ellipsis,
                            modifier = Modifier.padding(start = 16.dp, end = 16.dp, top = 12.dp, bottom = 8.dp),
                        )
                        HorizontalDivider()
                        Box(Modifier.weight(1f)) {
                            if (state.entries.isEmpty()) {
                                PlaylistMessage(stringResource(R.string.playlist_empty))
                            } else {
                                PlaylistList(state, actions)
                            }
                        }
                    }
                    state.confirmRemove?.let { indices ->
                        RemoveTracksDialog(indices, actions)
                    }
                    if (state.confirmDelete) {
                        DeletePlaylistDialog(state.title, actions)
                    }
                }
            }
        }
    }
}

@Composable
private fun PlaylistTopBar(state: PlaylistUiState.Ready, actions: PlaylistActions) {
    if (state.selectMode) {
        val selectedLabel = when (val count = state.selectedIndices.size) {
            0 -> stringResource(R.string.playlist_selected_count_eq0)
            1 -> stringResource(R.string.playlist_selected_count_eq1)
            else -> stringResource(R.string.playlist_selected_count_other, count)
        }
        RetroTopBar(
            selectedLabel,
            navigationIcon = { BackButton(actions.toggleSelectMode) },
            actions = { PlayerToggleAction() },
            textActions = {
                TextButton(onClick = actions.selectAll) { Text(stringResource(R.string.playlist_select_all)) }
                TextButton(onClick = actions.deselectAll) { Text(stringResource(R.string.playlist_deselect_all)) }
                TextButton(
                    onClick = { actions.requestRemove(state.selectedIndices) },
                    enabled = state.selectedIndices.isNotEmpty(),
                ) { Text(stringResource(R.string.remove)) }
            },
        )
    } else {
        RetroTopBar(
            stringResource(R.string.playlist),
            navigationIcon = { BackButton(actions.back) },
            actions = { PlayerToggleAction() },
            textActions = {
                if (!state.editable) {
                    Text(
                        stringResource(R.string.playlist_read_only),
                        style = MaterialTheme.typography.labelLarge,
                        modifier = Modifier.padding(horizontal = 12.dp, vertical = 8.dp),
                    )
                } else {
                    TextButton(onClick = actions.toggleSelectMode) { Text(stringResource(R.string.playlist_select)) }
                    TextButton(onClick = actions.requestDelete) {
                        Text(stringResource(R.string.delete_playlist_title))
                    }
                }
            },
        )
    }
}

@Composable
private fun PlaylistList(state: PlaylistUiState.Ready, actions: PlaylistActions) {
    val haptic = LocalHapticFeedback.current
    val order = remember { PlaylistDragOrder() }.apply { stored = state.entries }
    val listState = rememberLazyListState()
    val reorder = rememberReorderableLazyListState(listState) { from, to -> order.move(from.key, to.key) }
    val removeLabel = stringResource(R.string.remove)
    LazyColumn(state = listState, contentPadding = PaddingValues(bottom = 96.dp)) {
        val shown = order.shown
        itemsIndexed(shown, key = { _, entry -> entry.path.value }) { index, entry ->
            val key = entry.path.value
            val playlistIndex = state.entries.indexOfFirst { it.path == entry.path }
            val selected = playlistIndex in state.selectedIndices
            ReorderableItem(reorder, key = key) { dragging ->
                val row = @Composable {
                    PlaylistRow(
                        entry = entry,
                        playing = entry.track?.id == state.playingTrackId,
                        selected = selected,
                        onClick = {
                            if (state.selectMode) actions.toggleSelected(playlistIndex)
                            else order.click(key) { actions.play(entry) }
                        },
                        modifier = if (state.editable && !state.selectMode) {
                            Modifier.longPressDraggableHandle(
                                onDragStarted = {
                                    haptic.performHapticFeedback(HapticFeedbackType.LongPress)
                                    order.start(key, playlistIndex)
                                },
                                onDragStopped = { order.stop(key, actions.move) },
                            )
                        } else {
                            Modifier
                        },
                    )
                }
                if (state.editable && !state.selectMode) {
                    val swipeRemove = Swipe(Icons.Outlined.Delete, removeLabel, SwipeStyle.Remove) {
                        actions.requestRemove(setOf(playlistIndex))
                    }
                    SwipeActions(
                        modifier = Modifier.playlistLifted(dragging),
                        fromStart = swipeRemove,
                        fromEnd = swipeRemove,
                        moreActions = playlistMoveActions(playlistIndex, shown.size, actions.move),
                    ) { row() }
                } else {
                    Box(Modifier.playlistLifted(dragging)) { row() }
                }
            }
        }
    }
}

@Composable
private fun PlaylistMessage(text: String) {
    Text(
        text,
        style = MaterialTheme.typography.bodyLarge,
        textAlign = TextAlign.Center,
        color = MaterialTheme.colorScheme.onSurfaceVariant,
        modifier = Modifier.fillMaxSize().padding(32.dp).testTag(PLAYLIST_EMPTY_TAG),
    )
}

@Composable
private fun PlaylistRow(
    entry: PlaylistEntryUi,
    playing: Boolean,
    selected: Boolean,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val track = entry.track
    val title = track?.displayTitle ?: stringResource(R.string.missing_track)
    val subtitle = track?.let {
        listOfNotNull(it.displayArtist, it.durationMs?.let(::formatDuration)).joinToString(" · ")
    }.orEmpty()
    RetroListRow(
        title = { Text(title, maxLines = 2, overflow = TextOverflow.Ellipsis) },
        subtitle = subtitle.takeIf { it.isNotEmpty() }?.let { { Text(it, maxLines = 1, overflow = TextOverflow.Ellipsis) } },
        leading = { IconChip(Icons.Outlined.MusicNote, highlight = playing || selected) },
        playing = playing,
        onClick = onClick,
        modifier = modifier,
    )
}

@Composable
private fun RemoveTracksDialog(indices: Set<Int>, actions: PlaylistActions) {
    val count = indices.size
    val title = when (count) {
        1 -> stringResource(R.string.remove_playlist_track_title_eq1)
        else -> stringResource(R.string.remove_playlist_track_title_other, count)
    }
    val body = when (count) {
        1 -> stringResource(R.string.remove_playlist_track_body_eq1)
        else -> stringResource(R.string.remove_playlist_track_body_other, count)
    }
    AlertDialog(
        onDismissRequest = actions.dismissRemove,
        title = { Text(title) },
        text = { DialogText(body) },
        confirmButton = { TextButton(onClick = actions.confirmRemove) { Text(stringResource(R.string.remove)) } },
        dismissButton = { TextButton(onClick = actions.dismissRemove) { Text(stringResource(R.string.cancel)) } },
    )
}

@Composable
private fun DeletePlaylistDialog(title: String, actions: PlaylistActions) {
    AlertDialog(
        onDismissRequest = actions.dismissDelete,
        title = { Text(stringResource(R.string.delete_playlist_title)) },
        text = { DialogText(stringResource(R.string.delete_playlist_body, title)) },
        confirmButton = { TextButton(onClick = actions.confirmDelete) { Text(stringResource(R.string.remove)) } },
        dismissButton = { TextButton(onClick = actions.dismissDelete) { Text(stringResource(R.string.cancel)) } },
    )
}

private fun Modifier.playlistLifted(dragging: Boolean) = if (dragging) shadow(8.dp) else this

private class PlaylistDragOrder {
    var stored: List<PlaylistEntryUi> = emptyList()
    private var local by mutableStateOf<List<PlaylistEntryUi>?>(null)
    private var startIndex = -1
    private var held: String? = null

    val shown: List<PlaylistEntryUi> get() = local?.takeIf { it.toSet() == stored.toSet() } ?: stored

    fun start(key: String, index: Int) {
        local = shown
        startIndex = index
        held = key
    }

    fun click(key: String, open: () -> Unit) {
        if (held == key) held = null else open()
    }

    fun move(from: Any?, to: Any?) {
        val list = local ?: return
        val f = list.indexOfFirst { it.path.value == from }
        val t = list.indexOfFirst { it.path.value == to }
        if (f >= 0 && t >= 0) local = list.toMutableList().apply { add(t, removeAt(f)) }
    }

    fun stop(key: String, save: (Int, Int) -> Unit) {
        val end = (local ?: stored).indexOfFirst { it.path.value == key }
        if (startIndex >= 0 && end >= 0 && end != startIndex) save(startIndex, end)
        startIndex = -1
        held = null
    }
}

@Composable
private fun playlistMoveActions(index: Int, count: Int, move: (Int, Int) -> Unit): List<CustomAccessibilityAction> {
    val up = stringResource(R.string.move_up)
    val down = stringResource(R.string.move_down)
    return listOfNotNull(
        CustomAccessibilityAction(up) { move(index, index - 1); true }.takeIf { index > 0 },
        CustomAccessibilityAction(down) { move(index, index + 1); true }.takeIf { index < count - 1 },
    )
}
