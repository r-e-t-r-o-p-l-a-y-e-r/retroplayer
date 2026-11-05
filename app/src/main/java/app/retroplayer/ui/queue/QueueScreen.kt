package app.retroplayer.ui.queue

import app.retroplayer.ui.components.RetroFab
import androidx.compose.material3.IconButton
import androidx.compose.material3.Icon
import androidx.compose.material.icons.automirrored.outlined.PlaylistAdd
import androidx.compose.material.icons.outlined.DeleteSweep
import app.retroplayer.ui.components.DialogText
import androidx.compose.foundation.layout.Box
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
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.ui.draw.shadow
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.core.net.toUri
import androidx.compose.ui.Modifier
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.CustomAccessibilityAction
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
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

const val QUEUE_EMPTY_TAG = "queueEmpty"
const val CLEAR_QUEUE_DIALOG_TAG = "clearQueueDialog"

data class QueueActions(
    val back: () -> Unit = {},
    val play: (QueueEntry) -> Unit = {},
    val remove: (Int) -> Unit = {},
    val move: (Int, Int) -> Unit = { _, _ -> },
    val addTracks: () -> Unit = {},
    val saveAsPlaylist: () -> Unit = {},
    val requestClear: () -> Unit = {},
    val confirmClear: () -> Unit = {},
    val dismissClear: () -> Unit = {},
)

@Composable
fun QueueScreen(
    viewModel: QueueViewModel,
    back: () -> Unit,
    onAddTracks: () -> Unit,
    onSaveAsPlaylist: () -> Unit,
) {
    val state by viewModel.state.collectAsStateWithLifecycle()
    QueueContent(
        state = state,
        actions = QueueActions(
            back = back,
            play = viewModel::play,
            remove = viewModel::remove,
            move = viewModel::move,
            addTracks = onAddTracks,
            saveAsPlaylist = onSaveAsPlaylist,
            requestClear = viewModel::requestClear,
            confirmClear = viewModel::confirmClear,
            dismissClear = viewModel::dismissClear,
        ),
    )
}

@Composable
fun QueueContent(state: QueueUiState, actions: QueueActions) {
    val hasEntries = (state as? QueueUiState.Ready)?.entries?.isNotEmpty() == true
    Scaffold(
        topBar = {
            RetroTopBar(
                stringResource(R.string.queue),
                navigationIcon = { BackButton(actions.back) },
                actions = {
                    if (hasEntries) {
                        IconButton(onClick = actions.requestClear) {
                            Icon(Icons.Outlined.DeleteSweep, contentDescription = stringResource(R.string.clear_queue))
                        }
                    }
                    PlayerToggleAction()
                },
                textActions = if (hasEntries) {
                    { TextButton(onClick = actions.saveAsPlaylist) { Text(stringResource(R.string.save_as_playlist)) } }
                } else {
                    null
                },
            )
        },
        floatingActionButton = { RetroFab(stringResource(R.string.add_tracks), Icons.AutoMirrored.Outlined.PlaylistAdd, actions.addTracks) },
    ) { padding ->
        Box(Modifier.padding(padding).fillMaxSize()) {
            when (state) {
                QueueUiState.Loading -> LinearProgressIndicator(Modifier.fillMaxWidth())
                is QueueUiState.Ready -> {
                    if (state.entries.isEmpty()) {
                        QueueMessage(stringResource(R.string.queue_empty))
                    } else {
                        QueueList(state, actions)
                    }
                    if (state.confirmClear) {
                        AlertDialog(
                            onDismissRequest = actions.dismissClear,
                            title = { Text(stringResource(R.string.clear_queue_title)) },
                            text = { DialogText(stringResource(R.string.clear_queue_body)) },
                            confirmButton = {
                                TextButton(onClick = actions.confirmClear) { Text(stringResource(R.string.clear_queue)) }
                            },
                            dismissButton = { TextButton(onClick = actions.dismissClear) { Text(stringResource(R.string.cancel)) } },
                            modifier = Modifier.testTag(CLEAR_QUEUE_DIALOG_TAG),
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun QueueList(state: QueueUiState.Ready, actions: QueueActions) {
    val haptic = LocalHapticFeedback.current
    val order = remember { QueueDragOrder() }.apply { stored = state.entries }
    val listState = rememberLazyListState()
    val reorder = rememberReorderableLazyListState(listState) { from, to -> order.move(from.key, to.key) }
    val removeLabel = stringResource(R.string.remove)
    LazyColumn(state = listState, contentPadding = PaddingValues(bottom = 96.dp)) {
        val shown = order.shown
        itemsIndexed(shown, key = { _, entry -> entry.path.value }) { index, entry ->
            val key = entry.path.value
            val queueIndex = state.entries.indexOfFirst { it.path == entry.path }
            ReorderableItem(reorder, key = key) { dragging ->
                val swipeRemove = Swipe(Icons.Outlined.Delete, removeLabel, SwipeStyle.Remove) { actions.remove(queueIndex) }
                SwipeActions(
                    modifier = Modifier.queueLifted(dragging),
                    fromStart = swipeRemove,
                    fromEnd = swipeRemove,
                    moreActions = queueMoveActions(queueIndex, shown.size, actions.move),
                ) {
                    QueueRow(
                        entry = entry,
                        playing = entry.track?.id == state.playingTrackId,
                        onClick = { order.click(key) { actions.play(entry) } },
                        modifier = Modifier.longPressDraggableHandle(
                            onDragStarted = {
                                haptic.performHapticFeedback(HapticFeedbackType.LongPress)
                                order.start(key, queueIndex)
                            },
                            onDragStopped = { order.stop(key, actions.move) },
                        ),
                    )
                }
            }
        }
    }
}

@Composable
private fun QueueMessage(text: String) {
    Text(
        text,
        style = MaterialTheme.typography.bodyLarge,
        textAlign = TextAlign.Center,
        color = MaterialTheme.colorScheme.onSurfaceVariant,
        modifier = Modifier.fillMaxSize().padding(32.dp).testTag(QUEUE_EMPTY_TAG),
    )
}

@Composable
private fun QueueRow(entry: QueueEntry, playing: Boolean, onClick: () -> Unit, modifier: Modifier = Modifier) {
    val track = entry.track
    val title = track?.displayTitle ?: stringResource(R.string.missing_track)
    val subtitle = track?.let {
        listOfNotNull(it.displayArtist, it.durationMs?.let(::formatDuration)).joinToString(" · ")
    }.orEmpty()
    RetroListRow(
        title = { Text(title, maxLines = 2, overflow = TextOverflow.Ellipsis) },
        subtitle = subtitle.takeIf { it.isNotEmpty() }?.let { { Text(it, maxLines = 1, overflow = TextOverflow.Ellipsis) } },
        leading = { IconChip(Icons.Outlined.MusicNote, highlight = playing) },
        playing = playing,
        onClick = onClick,
        modifier = modifier,
    )
}

private fun Modifier.queueLifted(dragging: Boolean) = if (dragging) shadow(8.dp) else this

/** Same reorder pattern as library roots (T05b). */
private class QueueDragOrder {
    var stored: List<QueueEntry> = emptyList()
    private var local by mutableStateOf<List<QueueEntry>?>(null)
    private var startIndex = -1
    private var held: String? = null

    val shown: List<QueueEntry> get() = local?.takeIf { it.toSet() == stored.toSet() } ?: stored

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
private fun queueMoveActions(index: Int, count: Int, move: (Int, Int) -> Unit): List<CustomAccessibilityAction> {
    val up = stringResource(R.string.move_up)
    val down = stringResource(R.string.move_down)
    return listOfNotNull(
        CustomAccessibilityAction(up) { move(index, index - 1); true }.takeIf { index > 0 },
        CustomAccessibilityAction(down) { move(index, index + 1); true }.takeIf { index < count - 1 },
    )
}
