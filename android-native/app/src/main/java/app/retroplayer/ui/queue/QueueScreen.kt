package app.retroplayer.ui.queue

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
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
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
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.core.net.toUri
import app.retroplayer.library.writeAccessIntent
import kotlinx.coroutines.launch
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
    val requestClear: () -> Unit = {},
    val confirmClear: () -> Unit = {},
    val dismissClear: () -> Unit = {},
    val requestSaveAsPlaylist: () -> Unit = {},
    val dismissSaveAsPlaylist: () -> Unit = {},
    val confirmSaveAsPlaylist: (String) -> Unit = {},
)

@Composable
fun QueueScreen(
    viewModel: QueueViewModel,
    back: () -> Unit,
    onAddTracks: () -> Unit,
) {
    val state by viewModel.state.collectAsStateWithLifecycle()
    val canSave by viewModel.canSaveAsPlaylist.collectAsStateWithLifecycle()
    val snackbar = remember { SnackbarHostState() }
    val scope = rememberCoroutineScope()
    var pendingSaveName by remember { mutableStateOf<String?>(null) }
    var pendingWriteRoot by remember { mutableStateOf<String?>(null) }
    val accessDenied = stringResource(R.string.folder_access_denied)
    val writeLauncher = rememberLauncherForActivityResult(ActivityResultContracts.StartActivityForResult()) { result ->
        val rootId = pendingWriteRoot ?: return@rememberLauncherForActivityResult
        val name = pendingSaveName ?: return@rememberLauncherForActivityResult
        val uri = result.data?.data?.toString()
        pendingWriteRoot = null
        if (uri == null) return@rememberLauncherForActivityResult
        scope.launch {
            if (viewModel.grantWrite(rootId, uri)) {
                viewModel.confirmSaveAsPlaylist(name) { }
            } else {
                snackbar.showSnackbar(accessDenied)
            }
            pendingSaveName = null
        }
    }
    QueueContent(
        state = state,
        canSaveAsPlaylist = canSave,
        snackbar = snackbar,
        actions = QueueActions(
            back = back,
            play = viewModel::play,
            remove = viewModel::remove,
            move = viewModel::move,
            addTracks = onAddTracks,
            requestClear = viewModel::requestClear,
            confirmClear = viewModel::confirmClear,
            dismissClear = viewModel::dismissClear,
            requestSaveAsPlaylist = viewModel::requestSaveAsPlaylist,
            dismissSaveAsPlaylist = viewModel::dismissSaveAsPlaylist,
            confirmSaveAsPlaylist = { name ->
                viewModel.confirmSaveAsPlaylist(name) { outcome ->
                    when (outcome) {
                        is SavePlaylistOutcome.NeedsWrite -> {
                            pendingSaveName = name
                            pendingWriteRoot = outcome.rootId
                            outcome.treeUri?.let { writeLauncher.launch(writeAccessIntent(it)) }
                                ?: scope.launch { snackbar.showSnackbar(accessDenied) }
                        }
                        else -> Unit
                    }
                }
            },
        ),
    )
}

@Composable
fun QueueContent(
    state: QueueUiState,
    actions: QueueActions,
    canSaveAsPlaylist: Boolean = false,
    snackbar: SnackbarHostState = remember { SnackbarHostState() },
) {
    var saveName by remember { mutableStateOf("") }
    Scaffold(
        snackbarHost = { SnackbarHost(snackbar) },
        topBar = {
            RetroTopBar(
                stringResource(R.string.queue),
                navigationIcon = { BackButton(actions.back) },
                actions = { PlayerToggleAction() },
                textActions = {
                    if (canSaveAsPlaylist) {
                        TextButton(onClick = actions.requestSaveAsPlaylist) {
                            Text(stringResource(R.string.save_as_playlist))
                        }
                    }
                    TextButton(onClick = actions.addTracks) { Text(stringResource(R.string.add_tracks)) }
                    TextButton(onClick = actions.requestClear) { Text(stringResource(R.string.clear_queue)) }
                },
            )
        },
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
                    if (state.showSaveDialog) {
                        AlertDialog(
                            onDismissRequest = actions.dismissSaveAsPlaylist,
                            title = { Text(stringResource(R.string.save_as_playlist)) },
                            text = {
                                OutlinedTextField(
                                    value = saveName,
                                    onValueChange = { saveName = it },
                                    label = { Text(stringResource(R.string.new_playlist_name)) },
                                    singleLine = true,
                                )
                            },
                            confirmButton = {
                                TextButton(
                                    onClick = {
                                        actions.confirmSaveAsPlaylist(saveName)
                                        saveName = ""
                                    },
                                    enabled = saveName.isNotBlank(),
                                ) { Text(stringResource(R.string.save)) }
                            },
                            dismissButton = {
                                TextButton(onClick = actions.dismissSaveAsPlaylist) { Text(stringResource(R.string.cancel)) }
                            },
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
                val swipeRemove = Swipe(Icons.Outlined.Delete, removeLabel) { actions.remove(queueIndex) }
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
