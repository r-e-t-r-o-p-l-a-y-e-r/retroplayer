package app.retroplayer.ui.album

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilterChip
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.ListItem
import androidx.compose.material3.ListItemDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import app.retroplayer.R
import app.retroplayer.domain.Crumb
import app.retroplayer.domain.model.AlbumSortMode
import app.retroplayer.domain.model.AudioTrack
import app.retroplayer.ui.art.EmbeddedArt
import app.retroplayer.ui.components.AlbumArt
import app.retroplayer.ui.components.BreadcrumbBar
import app.retroplayer.ui.formatDuration
import app.retroplayer.ui.theme.LocalRetroPalette

data class AlbumActions(
    val back: () -> Unit = {},
    val openCrumb: (Crumb) -> Unit = {},
    val play: (AudioTrack) -> Unit = {},
    val playAll: () -> Unit = {},
    val selectSort: (AlbumSortMode) -> Unit = {},
    val confirmTagOrder: () -> Unit = {},
    val dismissTagOrder: () -> Unit = {},
)

@Composable
fun AlbumScreen(
    viewModel: AlbumViewModel,
    playingTrackId: String?,
    back: () -> Unit,
    openCrumb: (Crumb) -> Unit,
) {
    val state by viewModel.state.collectAsStateWithLifecycle()
    val confirm by viewModel.confirmTagOrder.collectAsStateWithLifecycle()
    LaunchedEffect(Unit) { viewModel.onShown() }
    AlbumContent(
        state = state,
        confirmMissing = confirm,
        artModel = (state as? AlbumUiState.Ready)?.let { ready -> ready.artUri ?: ready.tracks.firstOrNull()?.let { EmbeddedArt(it.uri) } },
        playingTrackId = playingTrackId,
        actions = AlbumActions(
            back = back,
            openCrumb = openCrumb,
            play = viewModel::play,
            playAll = viewModel::playAll,
            selectSort = viewModel::selectSort,
            confirmTagOrder = viewModel::confirmTagOrder,
            dismissTagOrder = viewModel::dismissTagOrder,
        ),
    )
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AlbumContent(
    state: AlbumUiState,
    confirmMissing: Int?,
    artModel: Any?,
    playingTrackId: String?,
    actions: AlbumActions,
) {
    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    if (state is AlbumUiState.Ready) BreadcrumbBar(state.crumbs, actions.openCrumb) else Text(stringResource(R.string.album))
                },
                navigationIcon = {
                    IconButton(onClick = actions.back) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = stringResource(R.string.library))
                    }
                },
            )
        },
    ) { padding ->
        Box(Modifier.padding(padding).fillMaxSize()) {
            when (state) {
                AlbumUiState.Loading -> LinearProgressIndicator(Modifier.fillMaxWidth())
                AlbumUiState.NotFound -> Text(
                    stringResource(R.string.album_not_found),
                    textAlign = TextAlign.Center,
                    modifier = Modifier.fillMaxSize().padding(32.dp),
                )
                is AlbumUiState.Ready -> AlbumBody(state, artModel, playingTrackId, actions)
            }
        }
    }
    if (confirmMissing != null) {
        AlertDialog(
            onDismissRequest = actions.dismissTagOrder,
            title = { Text(stringResource(R.string.sort_by_tag_title)) },
            text = { Text(stringResource(R.string.sort_by_tag_body, confirmMissing)) },
            confirmButton = { TextButton(onClick = actions.confirmTagOrder) { Text(stringResource(R.string.sort_by_tag_confirm)) } },
            dismissButton = { TextButton(onClick = actions.dismissTagOrder) { Text(stringResource(R.string.sort_keep_file_name)) } },
            modifier = Modifier.testTag("confirmTagOrder"),
        )
    }
}

@Composable
private fun AlbumBody(state: AlbumUiState.Ready, artModel: Any?, playingTrackId: String?, actions: AlbumActions) {
    LazyColumn(contentPadding = PaddingValues(bottom = 96.dp)) {
        item(key = "header") { AlbumHeader(state, artModel, actions) }
        items(state.tracks, key = { it.id }) { track ->
            val playing = track.id == playingTrackId
            ListItem(
                headlineContent = { Text(track.displayTitle, maxLines = 2, overflow = TextOverflow.Ellipsis) },
                supportingContent = track.displayArtist
                    ?.takeIf { it != state.album.artist }
                    ?.let { { Text(it, maxLines = 1, overflow = TextOverflow.Ellipsis) } },
                leadingContent = {
                    Text(
                        track.displayTrackNumber?.toString() ?: "–",
                        style = MaterialTheme.typography.labelLarge,
                        textAlign = TextAlign.End,
                        modifier = Modifier.widthIn(min = 28.dp),
                    )
                },
                trailingContent = track.durationMs?.let { { Text(formatDuration(it), style = MaterialTheme.typography.labelMedium) } },
                colors = if (playing) ListItemDefaults.colors(containerColor = LocalRetroPalette.current.playingHighlight) else ListItemDefaults.colors(),
                modifier = Modifier.clickable { actions.play(track) }.testTag("track:" + track.fileName),
            )
        }
    }
}

@Composable
private fun AlbumHeader(state: AlbumUiState.Ready, artModel: Any?, actions: AlbumActions) {
    Column(Modifier.fillMaxWidth().padding(16.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
        Row(horizontalArrangement = Arrangement.spacedBy(16.dp), verticalAlignment = Alignment.CenterVertically) {
            AlbumArt(artModel, size = 112.dp)
            Column(Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(4.dp)) {
                Text(state.album.title, style = MaterialTheme.typography.titleLarge, maxLines = 3, overflow = TextOverflow.Ellipsis)
                Text(
                    stringResource(R.string.tracks_count_artist, state.tracks.size, state.album.artist ?: stringResource(R.string.unknown_artist)),
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
                if (state.album.totalDurationMs > 0) {
                    Text(formatDuration(state.album.totalDurationMs), style = MaterialTheme.typography.labelMedium)
                }
            }
        }
        Button(onClick = actions.playAll) {
            Icon(Icons.Filled.PlayArrow, contentDescription = null)
            Text(stringResource(R.string.play_album), modifier = Modifier.padding(start = 8.dp))
        }
        Text(stringResource(R.string.sort_order), style = MaterialTheme.typography.labelLarge)
        FlowRow(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            SortMode.entries.forEach { option ->
                val selected = state.mode == option.mode
                FilterChip(
                    selected = selected,
                    onClick = { if (!selected) actions.selectSort(option.mode) },
                    label = { Text(stringResource(option.label)) },
                    leadingIcon = if (selected) {
                        { Icon(Icons.Filled.Check, contentDescription = null) }
                    } else {
                        null
                    },
                    modifier = Modifier.testTag("sort:" + option.mode.name),
                )
            }
        }
    }
}

private enum class SortMode(val mode: AlbumSortMode, val label: Int) {
    TAG(AlbumSortMode.TAG, R.string.sort_tag),
    FILE_NAME(AlbumSortMode.FILE_NAME, R.string.sort_file_name),
    TITLE(AlbumSortMode.TITLE, R.string.sort_title),
}
