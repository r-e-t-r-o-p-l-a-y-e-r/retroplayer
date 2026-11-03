package app.retroplayer.ui.album

import app.retroplayer.ui.settings.SettingsNavAction
import app.retroplayer.ui.components.DialogText
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.PlaylistAdd
import androidx.compose.material.icons.automirrored.filled.Sort
import androidx.compose.material.icons.automirrored.filled.VolumeUp
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.HorizontalDivider
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
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalResources
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.selected
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import app.retroplayer.R
import app.retroplayer.domain.model.AlbumSortMode
import app.retroplayer.domain.model.AudioTrack
import app.retroplayer.ui.art.EmbeddedArt
import app.retroplayer.ui.components.AlbumArt
import app.retroplayer.ui.components.BackButton
import app.retroplayer.ui.components.RetroListRow
import app.retroplayer.ui.components.RetroTopBar
import app.retroplayer.ui.player.ShareHeaderWithPlayer
import app.retroplayer.ui.components.Swipe
import app.retroplayer.ui.components.SwipeActions
import app.retroplayer.ui.components.TransportButton
import app.retroplayer.ui.components.addedToQueue
import app.retroplayer.ui.formatDuration
import app.retroplayer.ui.player.PlayerToggleAction
import app.retroplayer.ui.theme.LocalRetroPalette
import kotlinx.coroutines.launch

data class AlbumActions(
    val back: () -> Unit = {},
    val play: (AudioTrack) -> Unit = {},
    val playAll: () -> Unit = {},
    val selectSort: (AlbumSortMode) -> Unit = {},
    val confirmTagOrder: () -> Unit = {},
    val dismissTagOrder: () -> Unit = {},
    /** Queues one track; the callback gets how many tracks were new. */
    val addToQueue: (AudioTrack, onAdded: (Int) -> Unit) -> Unit = { _, _ -> },
    val openSettings: () -> Unit = {},
)

@Composable
fun AlbumScreen(
    viewModel: AlbumViewModel,
    playingTrackId: String?,
    scrollToTrackId: String?,
    back: () -> Unit,
    openSettings: () -> Unit,
) {
    val state by viewModel.state.collectAsStateWithLifecycle()
    val confirm by viewModel.confirmTagOrder.collectAsStateWithLifecycle()
    LaunchedEffect(Unit) { viewModel.onShown() }
    AlbumContent(
        state = state,
        confirmMissing = confirm,
        artModel = (state as? AlbumUiState.Ready)?.let { ready -> ready.artUri ?: ready.tracks.firstOrNull()?.let { EmbeddedArt(it.uri) } },
        playingTrackId = playingTrackId,
        scrollToTrackId = scrollToTrackId,
        actions = AlbumActions(
            back = back,
            play = viewModel::play,
            playAll = viewModel::playAll,
            selectSort = viewModel::selectSort,
            confirmTagOrder = viewModel::confirmTagOrder,
            dismissTagOrder = viewModel::dismissTagOrder,
            addToQueue = viewModel::addToQueue,
            openSettings = openSettings,
        ),
    )
}

@Composable
fun AlbumContent(
    state: AlbumUiState,
    confirmMissing: Int?,
    artModel: Any?,
    playingTrackId: String?,
    scrollToTrackId: String?,
    actions: AlbumActions,
) {
    val snackbar = remember { SnackbarHostState() }
    val resources = LocalResources.current
    val scope = rememberCoroutineScope()
    val rowActions = actions.copy(
        addToQueue = { track, onAdded ->
            actions.addToQueue(track) { count ->
                onAdded(count)
                scope.launch { snackbar.showSnackbar(resources.addedToQueue(count)) }
            }
        },
    )
    Scaffold(
        topBar = {
            ShareHeaderWithPlayer()
            RetroTopBar(
                stringResource(R.string.album),
                navigationIcon = { BackButton(actions.back) },
                actions = {
                    if (state is AlbumUiState.Ready) SortMenu(state.mode, actions.selectSort)
                    PlayerToggleAction()
                    SettingsNavAction(actions.openSettings)
                },
            )
        },
        snackbarHost = { SnackbarHost(snackbar) },
    ) { padding ->
        Box(Modifier.padding(padding).fillMaxSize()) {
            when (state) {
                AlbumUiState.Loading -> LinearProgressIndicator(Modifier.fillMaxWidth())
                AlbumUiState.NotFound -> Text(
                    stringResource(R.string.album_not_found),
                    textAlign = TextAlign.Center,
                    modifier = Modifier.fillMaxSize().padding(32.dp),
                )
                is AlbumUiState.Ready -> AlbumBody(state, artModel, playingTrackId, scrollToTrackId, rowActions)
            }
        }
    }
    if (confirmMissing != null) {
        AlertDialog(
            onDismissRequest = actions.dismissTagOrder,
            title = { Text(stringResource(R.string.sort_by_tag_title)) },
            text = { DialogText(stringResource(R.string.sort_by_tag_body, confirmMissing)) },
            confirmButton = { TextButton(onClick = actions.confirmTagOrder) { Text(stringResource(R.string.sort_by_tag_confirm)) } },
            dismissButton = { TextButton(onClick = actions.dismissTagOrder) { Text(stringResource(R.string.sort_keep_file_name)) } },
            modifier = Modifier.testTag("confirmTagOrder"),
        )
    }
}

@Composable
private fun SortMenu(mode: AlbumSortMode, select: (AlbumSortMode) -> Unit) {
    var open by remember { mutableStateOf(false) }
    Box {
        IconButton(onClick = { open = true }) {
            Icon(Icons.AutoMirrored.Filled.Sort, contentDescription = stringResource(R.string.sort_order))
        }
        DropdownMenu(expanded = open, onDismissRequest = { open = false }) {
            SortMode.entries.forEach { option ->
                val selected = mode == option.mode
                DropdownMenuItem(
                    text = { Text(stringResource(option.label)) },
                    onClick = {
                        open = false
                        if (!selected) select(option.mode)
                    },
                    leadingIcon = { if (selected) Icon(Icons.Filled.Check, contentDescription = null) },
                    modifier = Modifier.testTag("sort:" + option.mode.name).semantics { this.selected = selected },
                )
            }
        }
    }
}

@Composable
private fun AlbumBody(
    state: AlbumUiState.Ready,
    artModel: Any?,
    playingTrackId: String?,
    scrollToTrackId: String?,
    actions: AlbumActions,
) {
    val listState = rememberLazyListState()
    LaunchedEffect(scrollToTrackId, state.tracks) {
        val id = scrollToTrackId ?: return@LaunchedEffect
        val index = state.tracks.indexOfFirst { it.id == id }
        if (index >= 0) listState.animateScrollToItem(index)
    }
    Column(Modifier.fillMaxSize()) {
        AlbumHeader(state, artModel, actions)
        HorizontalDivider()
        LazyColumn(state = listState, contentPadding = PaddingValues(bottom = 96.dp)) {
            itemsIndexed(state.tracks, key = { _, track -> track.id }) { index, track ->
                val queueLabel = stringResource(R.string.add_to_queue)
                SwipeActions(fromEnd = Swipe(Icons.AutoMirrored.Filled.PlaylistAdd, queueLabel) { actions.addToQueue(track) {} }) {
                    TrackRow(index, track, track.id == playingTrackId, onClick = { actions.play(track) })
                }
            }
        }
    }
}

@Composable
private fun TrackRow(index: Int, track: AudioTrack, playing: Boolean, onClick: () -> Unit) {
    val palette = LocalRetroPalette.current
    val subtitle = listOfNotNull(track.metadata.artist, track.durationMs?.let(::formatDuration)).joinToString(" · ")
    RetroListRow(
        title = { Text(track.displayTitle, maxLines = 2, overflow = TextOverflow.Ellipsis) },
        subtitle = subtitle.takeIf { it.isNotEmpty() }?.let { { Text(it, maxLines = 1, overflow = TextOverflow.Ellipsis) } },
        leading = {
            Box(Modifier.width(32.dp), contentAlignment = Alignment.Center) {
                if (playing) {
                    Icon(Icons.AutoMirrored.Filled.VolumeUp, contentDescription = stringResource(R.string.now_playing), tint = palette.accent)
                } else {
                    Text(
                        "${index + 1}",
                        style = TextStyle(fontFeatureSettings = "tnum", fontSize = 12.sp, fontWeight = FontWeight.Medium, color = palette.textMuted),
                    )
                }
            }
        },
        playing = playing,
        onClick = onClick,
        modifier = Modifier.testTag("track:" + track.fileName),
    )
}

@Composable
private fun AlbumHeader(state: AlbumUiState.Ready, artModel: Any?, actions: AlbumActions) {
    val palette = LocalRetroPalette.current
    Row(
        Modifier.fillMaxWidth().padding(start = 16.dp, top = 12.dp, end = 16.dp, bottom = 8.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        AlbumArt(artModel, size = 56.dp)
        Column(Modifier.weight(1f).padding(horizontal = 12.dp)) {
            Text(
                state.album.title,
                style = MaterialTheme.typography.headlineSmall.copy(fontSize = 17.sp),
                maxLines = 2,
                overflow = TextOverflow.Ellipsis,
            )
            state.album.artist?.let {
                Text(it, fontSize = 13.sp, color = palette.textSecondary, maxLines = 1, overflow = TextOverflow.Ellipsis)
            }
        }
        TransportButton(Icons.Filled.PlayArrow, stringResource(R.string.play_album), actions.playAll, size = 40.dp, primary = true)
    }
}

private enum class SortMode(val mode: AlbumSortMode, val label: Int) {
    TAG(AlbumSortMode.TAG, R.string.sort_tag),
    FILE_NAME(AlbumSortMode.FILE_NAME, R.string.sort_file_name),
    TITLE(AlbumSortMode.TITLE, R.string.sort_title),
}
