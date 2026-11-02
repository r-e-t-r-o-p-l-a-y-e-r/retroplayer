package app.retroplayer.ui.player

import androidx.activity.compose.PredictiveBackHandler
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutVertically
import androidx.compose.foundation.clickable
import androidx.compose.foundation.gestures.Orientation
import androidx.compose.foundation.gestures.draggable
import androidx.compose.foundation.gestures.rememberDraggableState
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.consumeWindowInsets
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBars
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.safeDrawing
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.KeyboardArrowDown
import androidx.compose.material.icons.filled.Pause
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material.icons.filled.SkipNext
import androidx.compose.material.icons.filled.SkipPrevious
import androidx.compose.material3.FilledIconButton
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.compositionLocalOf
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import app.retroplayer.R
import app.retroplayer.ui.components.AlbumArt
import kotlin.coroutines.cancellation.CancellationException

const val MINI_PLAYER_TAG = "miniPlayer"
const val EXPANDED_PLAYER_TAG = "expandedPlayer"

/** True while the expanded player covers the screen; back handlers below it step aside. */
val LocalPlayerExpanded = compositionLocalOf { false }

data class PlayerActions(
    val toggle: () -> Unit,
    val previous: () -> Unit,
    val next: () -> Unit,
)

/**
 * The app's content with the mini player docked below it and the expanded
 * player on top (UC-12). Must wrap the NavHost: its back handler is composed
 * after the content so it wins while the player is expanded (UC-14).
 */
@Composable
fun PlayerHost(
    state: PlayerUiState,
    expanded: Boolean,
    onExpandedChange: (Boolean) -> Unit,
    actions: PlayerActions,
    content: @Composable () -> Unit,
) {
    val showExpanded = expanded && state.visible
    var backProgress by remember { mutableFloatStateOf(0f) }
    LaunchedEffect(showExpanded) { if (showExpanded) backProgress = 0f }

    CompositionLocalProvider(LocalPlayerExpanded provides showExpanded) {
        Box(Modifier.fillMaxSize()) {
            Column(Modifier.fillMaxSize()) {
                val contentInsets = if (state.visible) Modifier.consumeWindowInsets(WindowInsets.navigationBars) else Modifier
                Box(Modifier.weight(1f).then(contentInsets)) { content() }
                if (state.visible) MiniPlayer(state, actions, onExpand = { onExpandedChange(true) })
            }
            PredictiveBackHandler(enabled = showExpanded) { events ->
                try {
                    events.collect { backProgress = it.progress }
                    onExpandedChange(false)
                } catch (cancelled: CancellationException) {
                    backProgress = 0f
                    throw cancelled
                }
            }
            AnimatedVisibility(
                visible = showExpanded,
                enter = slideInVertically { it },
                exit = slideOutVertically { it },
            ) {
                ExpandedPlayer(
                    state = state,
                    actions = actions,
                    onCollapse = { onExpandedChange(false) },
                    modifier = Modifier.graphicsLayer {
                        val scale = 1f - backProgress * 0.1f
                        scaleX = scale
                        scaleY = scale
                        translationY = backProgress * 48.dp.toPx()
                    },
                )
            }
        }
    }
}

@Composable
private fun MiniPlayer(state: PlayerUiState, actions: PlayerActions, onExpand: () -> Unit) {
    val now = state.nowPlaying
    var dragged by remember { mutableFloatStateOf(0f) }
    val expandLabel = stringResource(R.string.expand_player)
    Surface(
        color = MaterialTheme.colorScheme.surfaceContainer,
        modifier = Modifier
            .fillMaxWidth()
            .testTag(MINI_PLAYER_TAG)
            .clickable(onClickLabel = expandLabel, onClick = onExpand)
            .draggable(
                state = rememberDraggableState { dragged += it },
                orientation = Orientation.Vertical,
                onDragStarted = { dragged = 0f },
                onDragStopped = { if (dragged < -DRAG_THRESHOLD_PX) onExpand() },
            ),
    ) {
        Column(Modifier.windowInsetsPadding(WindowInsets.navigationBars)) {
            LinearProgressIndicator(
                progress = { if (now.durationMs > 0) now.positionMs.toFloat() / now.durationMs else 0f },
                modifier = Modifier.fillMaxWidth().height(2.dp),
                drawStopIndicator = {},
            )
            Row(Modifier.padding(horizontal = 12.dp, vertical = 8.dp), verticalAlignment = Alignment.CenterVertically) {
                AlbumArt(state.artModel, size = 48.dp)
                Column(Modifier.weight(1f).padding(horizontal = 12.dp)) {
                    Text(
                        now.title ?: stringResource(R.string.track_fallback),
                        style = MaterialTheme.typography.bodyLarge,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                    )
                    now.subtitle?.let {
                        Text(
                            it,
                            style = MaterialTheme.typography.bodyMedium,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis,
                        )
                    }
                }
                IconButton(onClick = actions.toggle) { PlayPauseIcon(now.isPlaying) }
            }
        }
    }
}

@Composable
private fun ExpandedPlayer(state: PlayerUiState, actions: PlayerActions, onCollapse: () -> Unit, modifier: Modifier = Modifier) {
    val now = state.nowPlaying
    var dragged by remember { mutableFloatStateOf(0f) }
    Surface(color = MaterialTheme.colorScheme.background, modifier = modifier.fillMaxSize().testTag(EXPANDED_PLAYER_TAG)) {
        Column(
            Modifier
                .windowInsetsPadding(WindowInsets.safeDrawing)
                .draggable(
                    state = rememberDraggableState { dragged += it },
                    orientation = Orientation.Vertical,
                    onDragStarted = { dragged = 0f },
                    onDragStopped = { if (dragged > DRAG_THRESHOLD_PX) onCollapse() },
                )
                .padding(horizontal = 24.dp, vertical = 8.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            Row(Modifier.fillMaxWidth()) {
                IconButton(onClick = onCollapse) {
                    Icon(Icons.Filled.KeyboardArrowDown, contentDescription = stringResource(R.string.show_library))
                }
            }
            Spacer(Modifier.weight(1f))
            BoxWithConstraints(contentAlignment = Alignment.Center) {
                AlbumArt(state.artModel, size = minOf(maxWidth, 360.dp))
            }
            Spacer(Modifier.height(24.dp))
            Text(
                now.title ?: stringResource(R.string.track_fallback),
                style = MaterialTheme.typography.headlineSmall,
                textAlign = TextAlign.Center,
                maxLines = 2,
                overflow = TextOverflow.Ellipsis,
            )
            now.subtitle?.let {
                Text(
                    it,
                    style = MaterialTheme.typography.bodyLarge,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    textAlign = TextAlign.Center,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                )
            }
            Spacer(Modifier.height(24.dp))
            Row(horizontalArrangement = Arrangement.spacedBy(24.dp), verticalAlignment = Alignment.CenterVertically) {
                IconButton(onClick = actions.previous, modifier = Modifier.size(56.dp)) {
                    Icon(Icons.Filled.SkipPrevious, contentDescription = stringResource(R.string.previous), modifier = Modifier.size(36.dp))
                }
                FilledIconButton(onClick = actions.toggle, modifier = Modifier.size(72.dp)) {
                    PlayPauseIcon(now.isPlaying, Modifier.size(40.dp))
                }
                IconButton(onClick = actions.next, enabled = now.hasNext, modifier = Modifier.size(56.dp)) {
                    Icon(Icons.Filled.SkipNext, contentDescription = stringResource(R.string.next), modifier = Modifier.size(36.dp))
                }
            }
            Spacer(Modifier.weight(1f))
        }
    }
}

@Composable
private fun PlayPauseIcon(isPlaying: Boolean, modifier: Modifier = Modifier) {
    if (isPlaying) {
        Icon(Icons.Filled.Pause, contentDescription = stringResource(R.string.pause), modifier = modifier)
    } else {
        Icon(Icons.Filled.PlayArrow, contentDescription = stringResource(R.string.play), modifier = modifier)
    }
}

private const val DRAG_THRESHOLD_PX = 120f
