package app.retroplayer.ui.player

import androidx.activity.compose.PredictiveBackHandler
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutVertically
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.gestures.Orientation
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.gestures.draggable
import androidx.compose.foundation.gestures.rememberDraggableState
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
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
import androidx.compose.material.icons.filled.KeyboardArrowUp
import androidx.compose.material.icons.filled.Pause
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material.icons.filled.SkipNext
import androidx.compose.material.icons.filled.SkipPrevious
import androidx.compose.material.icons.outlined.Speed
import androidx.compose.material.icons.rounded.Replay
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Slider
import androidx.compose.material3.SliderDefaults
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
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.semantics.clearAndSetSemantics
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import app.retroplayer.R
import app.retroplayer.domain.Crumb
import app.retroplayer.domain.TransportRules
import app.retroplayer.playback.NowPlaying
import app.retroplayer.ui.formatSpeed
import app.retroplayer.ui.components.AlbumArt
import app.retroplayer.ui.components.BackButton
import app.retroplayer.ui.components.BreadcrumbStrip
import app.retroplayer.ui.components.PlaybackProgress
import app.retroplayer.ui.components.RetroTopBar
import app.retroplayer.ui.components.TransportButton
import app.retroplayer.ui.theme.LocalRetroPalette
import kotlin.coroutines.cancellation.CancellationException

const val MINI_PLAYER_TAG = "miniPlayer"
const val EXPANDED_PLAYER_TAG = "expandedPlayer"
const val EXPANDED_ART_TAG = "expandedPlayerArt"
const val SPEED_SLIDER_TAG = "speedSlider"
const val EXPANDED_LOCATE_TITLE_TAG = "expandedPlayerLocateTitle"

/** True while the expanded player covers the screen; back handlers below it step aside. */
val LocalPlayerExpanded = compositionLocalOf { false }

data class PlayerActions(
    val toggle: () -> Unit,
    val previous: () -> Unit,
    val next: () -> Unit,
    val seekTo: (Long) -> Unit,
    val jumpBack: () -> Unit,
    val jumpForward: () -> Unit,
    val setSpeed: (Float) -> Unit,
    val locate: () -> Unit,
    val playbackCrumb: (Crumb) -> Unit,
)

/** Expands the player from a library top bar; null while there is nothing to expand. */
private val LocalExpandPlayer = compositionLocalOf<(() -> Unit)?> { null }

/** Chevron for library top bars (UC-12), shown while the mini player is. */
@Composable
fun PlayerToggleAction() {
    val expand = LocalExpandPlayer.current ?: return
    IconButton(onClick = expand) {
        Icon(Icons.Filled.KeyboardArrowUp, contentDescription = stringResource(R.string.expand_player))
    }
}

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

    val expand = if (state.visible && !showExpanded) ({ onExpandedChange(true) }) else null
    CompositionLocalProvider(LocalPlayerExpanded provides showExpanded, LocalExpandPlayer provides expand) {
        Box(Modifier.fillMaxSize()) {
            Column(Modifier.fillMaxSize().then(if (showExpanded) Modifier.clearAndSetSemantics {} else Modifier)) {
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
private fun DragHandle() {
    Box(
        Modifier
            .padding(vertical = 6.dp)
            .size(width = 32.dp, height = 4.dp)
            .background(LocalRetroPalette.current.divider, RoundedCornerShape(2.dp)),
    )
}

@Composable
private fun Titles(
    now: NowPlaying,
    titleStyle: TextStyle,
    subtitleStyle: TextStyle,
    align: TextAlign,
    modifier: Modifier = Modifier,
    titleModifier: Modifier = Modifier,
) {
    val palette = LocalRetroPalette.current
    Column(modifier, horizontalAlignment = if (align == TextAlign.Center) Alignment.CenterHorizontally else Alignment.Start) {
        Text(
            now.title ?: stringResource(R.string.track_fallback),
            style = titleStyle,
            color = palette.textPrimary,
            textAlign = align,
            maxLines = if (align == TextAlign.Center) 2 else 1,
            overflow = TextOverflow.Ellipsis,
            modifier = titleModifier,
        )
        now.subtitle?.let {
            Text(it, style = subtitleStyle, color = palette.textSecondary, textAlign = align, maxLines = 1, overflow = TextOverflow.Ellipsis)
        }
    }
}

@Composable
private fun Transport(now: NowPlaying, actions: PlayerActions, skipSize: Dp, playSize: Dp) {
    Row(horizontalArrangement = Arrangement.spacedBy(12.dp), verticalAlignment = Alignment.CenterVertically) {
        TransportButton(Icons.Filled.SkipPrevious, stringResource(R.string.previous), actions.previous, size = skipSize)
        TransportButton(
            if (now.isPlaying) Icons.Filled.Pause else Icons.Filled.PlayArrow,
            stringResource(if (now.isPlaying) R.string.pause else R.string.play),
            actions.toggle,
            size = playSize,
            primary = true,
        )
        TransportButton(Icons.Filled.SkipNext, stringResource(R.string.next), actions.next, size = skipSize, enabled = now.hasNext)
    }
}

@Composable
private fun MiniPlayer(state: PlayerUiState, actions: PlayerActions, onExpand: () -> Unit) {
    val now = state.nowPlaying
    val palette = LocalRetroPalette.current
    var dragged by remember { mutableFloatStateOf(0f) }
    val expandLabel = stringResource(R.string.expand_player)
    Surface(
        color = palette.screenElevated,
        shadowElevation = 8.dp,
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
        Column(
            Modifier.windowInsetsPadding(WindowInsets.navigationBars).padding(horizontal = 16.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            HorizontalDivider(color = palette.divider)
            DragHandle()
            Row(verticalAlignment = Alignment.CenterVertically) {
                AlbumArt(state.artModel, size = 40.dp)
                Titles(
                    now,
                    titleStyle = MaterialTheme.typography.titleMedium.copy(fontSize = 15.sp),
                    subtitleStyle = MaterialTheme.typography.bodyMedium.copy(fontSize = 13.sp),
                    align = TextAlign.Start,
                    modifier = Modifier.weight(1f).padding(start = 12.dp),
                )
            }
            PlaybackProgress(now.positionMs, now.durationMs, actions.seekTo, compact = true)
            Transport(now, actions, skipSize = 28.dp, playSize = 36.dp)
        }
    }
}

@Composable
private fun ExpandedPlayer(state: PlayerUiState, actions: PlayerActions, onCollapse: () -> Unit, modifier: Modifier = Modifier) {
    val now = state.nowPlaying
    var dragged by remember { mutableFloatStateOf(0f) }
    Surface(color = LocalRetroPalette.current.screenElevated, modifier = modifier.fillMaxSize().testTag(EXPANDED_PLAYER_TAG)) {
        Column(Modifier.windowInsetsPadding(WindowInsets.safeDrawing)) {
            RetroTopBar(
                stringResource(R.string.now_playing),
                navigationIcon = { BackButton(onCollapse, contentDescription = stringResource(R.string.library)) },
                actions = {
                    IconButton(onClick = onCollapse) {
                        Icon(Icons.Filled.KeyboardArrowDown, contentDescription = stringResource(R.string.show_library))
                    }
                },
            )
            if (state.crumbs.isNotEmpty()) BreadcrumbStrip(state.crumbs, actions.playbackCrumb)
            Column(
                Modifier
                    .weight(1f)
                    .fillMaxWidth()
                    .draggable(
                        state = rememberDraggableState { dragged += it },
                        orientation = Orientation.Vertical,
                        onDragStarted = { dragged = 0f },
                        onDragStopped = { if (dragged > DRAG_THRESHOLD_PX) onCollapse() },
                    )
                    .padding(horizontal = 24.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
            ) {
                DragHandle()
                Spacer(Modifier.weight(1f))
                BoxWithConstraints(Modifier.weight(4f, fill = false).fillMaxWidth(), contentAlignment = Alignment.Center) {
                    val jumps = 40.dp
                    val gaps = 12.dp
                    val artSize = minOf(maxWidth - jumps * 2 - gaps * 2, maxHeight, 248.dp)
                    Row(
                        Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(gaps),
                        verticalAlignment = Alignment.CenterVertically,
                    ) {
                        JumpButton(forward = false, onClick = actions.jumpBack)
                        Box(
                            Modifier
                                .weight(1f)
                                .testTag(EXPANDED_ART_TAG)
                                .pointerInput(actions.locate, actions.jumpBack, actions.jumpForward) {
                                    detectTapGestures(
                                        onTap = { actions.locate() },
                                        onDoubleTap = { offset ->
                                            if (offset.x < size.width / 2f) actions.jumpBack() else actions.jumpForward()
                                        },
                                    )
                                },
                            contentAlignment = Alignment.Center,
                        ) {
                            AlbumArt(state.artModel, size = artSize)
                        }
                        JumpButton(forward = true, onClick = actions.jumpForward)
                    }
                }
                Spacer(Modifier.height(16.dp))
                Titles(
                    now,
                    titleStyle = MaterialTheme.typography.headlineSmall.copy(fontSize = 20.sp, lineHeight = 24.sp),
                    subtitleStyle = MaterialTheme.typography.bodyLarge.copy(fontSize = 15.sp),
                    align = TextAlign.Center,
                    titleModifier = Modifier
                        .testTag(EXPANDED_LOCATE_TITLE_TAG)
                        .clickable(onClick = actions.locate),
                )
                Spacer(Modifier.height(16.dp))
                PlaybackProgress(now.positionMs, now.durationMs, actions.seekTo)
                Spacer(Modifier.height(8.dp))
                Transport(now, actions, skipSize = 40.dp, playSize = 64.dp)
                Spacer(Modifier.height(16.dp))
                SpeedRow(now.speed, actions.setSpeed)
                Spacer(Modifier.weight(1.4f))
            }
        }
    }
}

@Composable
private fun JumpButton(forward: Boolean, onClick: () -> Unit) {
    val palette = LocalRetroPalette.current
    val description = stringResource(if (forward) R.string.jump_forward else R.string.jump_back)
    Surface(onClick = onClick, shape = CircleShape, color = palette.iconChip, modifier = Modifier.size(40.dp)) {
        Box(contentAlignment = Alignment.Center) {
            Icon(
                Icons.Rounded.Replay,
                contentDescription = description,
                tint = palette.textPrimary,
                modifier = Modifier
                    .size(22.dp)
                    .then(if (forward) Modifier.scale(scaleX = -1f, scaleY = 1f) else Modifier),
            )
            Text(
                "15",
                style = TextStyle(fontSize = 11.sp, fontWeight = FontWeight.W700, color = palette.textMuted),
                modifier = Modifier.align(Alignment.BottomCenter).padding(bottom = 5.dp),
            )
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun SpeedRow(speed: Float, onSpeed: (Float) -> Unit) {
    val palette = LocalRetroPalette.current
    val locale = LocalConfiguration.current.locales[0]
    val colors = SliderDefaults.colors(
        thumbColor = palette.screenElevated,
        activeTrackColor = palette.accent,
        inactiveTrackColor = palette.divider,
    )
    Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
        Icon(Icons.Outlined.Speed, contentDescription = null, tint = palette.textMuted, modifier = Modifier.size(20.dp))
        Text(
            stringResource(R.string.speed),
            style = TextStyle(fontSize = 13.sp, color = palette.textMuted),
            modifier = Modifier.padding(start = 8.dp),
        )
        Slider(
            value = speed.coerceIn(TransportRules.MIN_SPEED, TransportRules.MAX_SPEED),
            onValueChange = { onSpeed(it) },
            valueRange = TransportRules.MIN_SPEED..TransportRules.MAX_SPEED,
            steps = 5,
            colors = colors,
            thumb = {
                Box(
                    Modifier
                        .size(14.dp)
                        .background(palette.screenElevated, CircleShape),
                )
            },
            modifier = Modifier.weight(1f).padding(horizontal = 8.dp).testTag(SPEED_SLIDER_TAG),
        )
        Text(
            formatSpeed(speed, locale),
            style = TextStyle(fontSize = 13.sp, fontWeight = FontWeight.Medium, color = palette.textMuted),
            textAlign = TextAlign.End,
            modifier = Modifier.width(52.dp),
        )
    }
}

private const val DRAG_THRESHOLD_PX = 120f
