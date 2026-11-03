package app.retroplayer.ui.player

import app.retroplayer.ui.settings.SettingsNavAction
import androidx.compose.foundation.combinedClickable
import kotlinx.coroutines.launch
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.runtime.rememberUpdatedState
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.animation.core.spring
import androidx.compose.animation.core.Spring
import androidx.compose.animation.core.Animatable
import kotlin.math.sin
import kotlin.math.cos
import app.retroplayer.ui.components.RetroSlider
import androidx.compose.foundation.layout.heightIn
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.draw.drawBehind
import androidx.compose.foundation.verticalScroll
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.activity.compose.PredictiveBackHandler
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.gestures.Orientation
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
import androidx.compose.material.icons.filled.KeyboardArrowUp
import androidx.compose.material.icons.filled.Pause
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material.icons.filled.SkipNext
import androidx.compose.material.icons.filled.SkipPrevious
import androidx.compose.material.icons.outlined.Speed
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.HorizontalDivider
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
import app.retroplayer.ui.components.mayEllipsize
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
    val openSettings: () -> Unit = {},
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
    allowExpansion: Boolean = true,
    content: @Composable () -> Unit,
) {
    val showExpanded = expanded && state.visible && allowExpansion
    var backProgress by remember { mutableFloatStateOf(0f) }
    LaunchedEffect(showExpanded) { if (showExpanded) backProgress = 0f }

    val expand = if (state.visible && !showExpanded && allowExpansion) ({ onExpandedChange(true) }) else null
    CompositionLocalProvider(LocalPlayerExpanded provides showExpanded, LocalExpandPlayer provides expand) {
        BoxWithConstraints(Modifier.fillMaxSize()) {
            val travel = constraints.maxHeight.toFloat().coerceAtLeast(1f)
            val sheet = rememberSheetPosition(showExpanded, travel, onExpandedChange)
            Column(Modifier.fillMaxSize().then(if (showExpanded) Modifier.clearAndSetSemantics {} else Modifier)) {
                val contentInsets = if (state.visible) Modifier.consumeWindowInsets(WindowInsets.navigationBars) else Modifier
                Box(Modifier.weight(1f).then(contentInsets)) { content() }
                if (state.visible) {
                    MiniPlayer(
                        state,
                        actions,
                        onExpand = if (allowExpansion) ({ onExpandedChange(true) }) else ({}),
                        drag = if (allowExpansion) sheet.drag else Modifier,
                    )
                }
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
            if (state.visible && (showExpanded || sheet.fraction > 0f)) {
                ExpandedPlayer(
                    state = state,
                    actions = actions,
                    onCollapse = { onExpandedChange(false) },
                    drag = sheet.drag,
                    modifier = Modifier.graphicsLayer {
                        val scale = 1f - backProgress * 0.1f
                        scaleX = scale
                        scaleY = scale
                        translationY = (1f - sheet.fraction) * travel + backProgress * 48.dp.toPx()
                    },
                )
            }
        }
    }
}

/** How far the expanded player is pulled up (0 = mini, 1 = expanded) and the drag that moves it. */
private class SheetPosition(val drag: Modifier, private val position: Animatable<Float, *>) {
    val fraction: Float get() = position.value
}

/**
 * The sheet follows the finger; on release it snaps to the end a fling points at,
 * else to the nearer one, and reports it through [onExpandedChange].
 */
@Composable
private fun rememberSheetPosition(expanded: Boolean, travel: Float, onExpandedChange: (Boolean) -> Unit): SheetPosition {
    val position = remember { Animatable(if (expanded) 1f else 0f) }
    val scope = rememberCoroutineScope()
    val flingPx = with(LocalDensity.current) { FLING_VELOCITY.toPx() }
    val currentExpanded by rememberUpdatedState(expanded)
    val report by rememberUpdatedState(onExpandedChange)
    LaunchedEffect(expanded) { position.animateTo(if (expanded) 1f else 0f, SHEET_SPRING) }
    val dragState = rememberDraggableState { delta ->
        scope.launch { position.snapTo((position.value - delta / travel).coerceIn(0f, 1f)) }
    }
    val drag = Modifier.draggable(
        state = dragState,
        orientation = Orientation.Vertical,
        onDragStopped = { velocity ->
            val target = when {
                velocity < -flingPx -> true
                velocity > flingPx -> false
                else -> position.value > 0.5f
            }
            if (target != currentExpanded) report(target) else scope.launch { position.animateTo(if (target) 1f else 0f, SHEET_SPRING) }
        },
    )
    return SheetPosition(drag, position)
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
    Column(modifier.mayEllipsize(), horizontalAlignment = if (align == TextAlign.Center) Alignment.CenterHorizontally else Alignment.Start) {
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
private fun MiniPlayer(state: PlayerUiState, actions: PlayerActions, onExpand: () -> Unit, drag: Modifier) {
    val now = state.nowPlaying
    val palette = LocalRetroPalette.current
    val locateLabel = stringResource(R.string.show_library)
    val expandLabel = stringResource(R.string.expand_player)
    Surface(
        color = palette.screenElevated,
        shadowElevation = 8.dp,
        modifier = Modifier
            .fillMaxWidth()
            .testTag(MINI_PLAYER_TAG)
            .clickable(onClickLabel = expandLabel, onClick = onExpand)
            .then(drag),
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
                    modifier = Modifier
                        .weight(1f)
                        .padding(start = 12.dp)
                        .clickable(onClickLabel = locateLabel, onClick = actions.locate),
                )
            }
            PlaybackProgress(now.positionMs, now.durationMs, actions.seekTo, compact = true)
            Transport(now, actions, skipSize = 28.dp, playSize = 36.dp)
        }
    }
}

@Composable
private fun ExpandedPlayer(state: PlayerUiState, actions: PlayerActions, onCollapse: () -> Unit, drag: Modifier, modifier: Modifier = Modifier) {
    val now = state.nowPlaying
    Surface(color = LocalRetroPalette.current.screenElevated, modifier = modifier.fillMaxSize().testTag(EXPANDED_PLAYER_TAG)) {
        Column(Modifier.windowInsetsPadding(WindowInsets.safeDrawing)) {
            RetroTopBar(
                stringResource(R.string.now_playing),
                navigationIcon = { BackButton(onCollapse, contentDescription = stringResource(R.string.library)) },
                actions = { SettingsNavAction(actions.openSettings) },
            )
            if (state.crumbs.isNotEmpty()) BreadcrumbStrip(state.crumbs, actions.playbackCrumb)
            BoxWithConstraints(
                Modifier
                    .weight(1f)
                    .fillMaxWidth()
                    .then(drag),
            ) {
                if (maxWidth > maxHeight) {
                    Row(Modifier.fillMaxSize().padding(horizontal = 24.dp, vertical = 8.dp), verticalAlignment = Alignment.CenterVertically) {
                        ArtWithJumps(state, actions, Modifier.weight(1f).fillMaxHeight())
                        Spacer(Modifier.width(24.dp))
                        Column(
                            Modifier.weight(1f).verticalScroll(rememberScrollState()),
                            horizontalAlignment = Alignment.CenterHorizontally,
                        ) {
                            Controls(now, actions)
                        }
                    }
                } else {
                    Column(Modifier.fillMaxSize().padding(horizontal = 24.dp), horizontalAlignment = Alignment.CenterHorizontally) {
                        DragHandle()
                        Spacer(Modifier.weight(1f))
                        ArtWithJumps(state, actions, Modifier.weight(4f, fill = false).fillMaxWidth())
                        Spacer(Modifier.height(16.dp))
                        Controls(now, actions)
                        Spacer(Modifier.weight(1.4f))
                    }
                }
            }
        }
    }
}

/** Cover between the jump buttons; tap locates, double tap on a half jumps. */
@Composable
private fun ArtWithJumps(state: PlayerUiState, actions: PlayerActions, modifier: Modifier) {
    BoxWithConstraints(modifier, contentAlignment = Alignment.Center) {
        val jumps = 40.dp
        val gaps = 12.dp
        val artSize = minOf(maxWidth - jumps * 2 - gaps * 2, maxHeight, 248.dp)
        Row(
            Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(gaps),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            JumpButton(forward = false, onClick = actions.jumpBack)
            val locateLabel = stringResource(R.string.show_library)
            Box(Modifier.weight(1f).testTag(EXPANDED_ART_TAG), contentAlignment = Alignment.Center) {
                AlbumArt(state.artModel, size = artSize)
                // Clickables, unlike a tap detector, leave drags to the sheet.
                Row(Modifier.matchParentSize()) {
                    listOf(actions.jumpBack, actions.jumpForward).forEach { jump ->
                        Box(
                            Modifier
                                .weight(1f)
                                .fillMaxHeight()
                                .combinedClickable(
                                    interactionSource = null,
                                    indication = null,
                                    onClickLabel = locateLabel,
                                    onClick = actions.locate,
                                    onDoubleClick = jump,
                                ),
                        )
                    }
                }
            }
            JumpButton(forward = true, onClick = actions.jumpForward)
        }
    }
}

@Composable
private fun Controls(now: NowPlaying, actions: PlayerActions) {
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
}

@Composable
private fun JumpButton(forward: Boolean, onClick: () -> Unit) {
    val palette = LocalRetroPalette.current
    val description = stringResource(if (forward) R.string.jump_forward else R.string.jump_back)
    val ink = palette.textSecondary
    Surface(
        onClick = onClick,
        shape = CircleShape,
        color = palette.iconChip,
        modifier = Modifier.size(40.dp).semantics { contentDescription = description },
    ) {
        Box(Modifier.drawBehind { drawJumpArc(forward, ink) }, contentAlignment = Alignment.Center) {
            Text(
                if (forward) "+15" else "-15",
                style = TextStyle(fontSize = 10.sp, fontWeight = FontWeight.W700, color = ink, letterSpacing = (-0.2).sp),
                modifier = Modifier.clearAndSetSemantics {},
            )
        }
    }
}

/** Three-quarter circle open towards the jump, arrowhead on its upper end; the seconds sit inside. */
private fun DrawScope.drawJumpArc(forward: Boolean, color: Color) {
    val radius = size.minDimension * 0.36f
    val stroke = size.minDimension * 0.065f
    // Degrees clockwise from 3 o'clock, as drawArc measures them.
    val start = if (forward) 45f else 135f
    val sweep = if (forward) 270f else -270f
    drawArc(
        color = color,
        startAngle = start,
        sweepAngle = sweep,
        useCenter = false,
        topLeft = center - Offset(radius, radius),
        size = Size(radius * 2, radius * 2),
        style = Stroke(width = stroke, cap = StrokeCap.Butt),
    )
    val end = Math.toRadians((start + sweep).toDouble())
    val base = center + Offset(cos(end).toFloat(), sin(end).toFloat()) * radius
    val tangent = if (forward) Offset(-sin(end).toFloat(), cos(end).toFloat()) else Offset(sin(end).toFloat(), -cos(end).toFloat())
    val normal = Offset(-tangent.y, tangent.x)
    val tip = base + tangent * (size.minDimension * 0.16f)
    val half = stroke * 1.35f
    drawPath(
        Path().apply {
            moveTo(tip.x, tip.y)
            lineTo(base.x + normal.x * half, base.y + normal.y * half)
            lineTo(base.x - normal.x * half, base.y - normal.y * half)
            close()
        },
        color,
    )
}

@Composable
private fun SpeedRow(speed: Float, onSpeed: (Float) -> Unit) {
    val palette = LocalRetroPalette.current
    val locale = LocalConfiguration.current.locales[0]
    Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
        Icon(Icons.Outlined.Speed, contentDescription = null, tint = palette.textMuted, modifier = Modifier.size(20.dp))
        Text(
            stringResource(R.string.speed),
            style = TextStyle(fontSize = 13.sp, color = palette.textMuted),
            modifier = Modifier.padding(start = 8.dp),
        )
        RetroSlider(
            value = speed.coerceIn(TransportRules.MIN_SPEED, TransportRules.MAX_SPEED),
            onValueChange = { onSpeed(it) },
            valueRange = TransportRules.MIN_SPEED..TransportRules.MAX_SPEED,
            steps = 5,
            modifier = Modifier.weight(1f).heightIn(max = 32.dp).padding(horizontal = 8.dp).testTag(SPEED_SLIDER_TAG),
        )
        Text(
            formatSpeed(speed, locale),
            style = TextStyle(fontSize = 13.sp, fontWeight = FontWeight.Medium, color = palette.textMuted),
            textAlign = TextAlign.End,
            modifier = Modifier.width(52.dp),
        )
    }
}

/** Faster than this the sheet goes where the finger flung it, wherever it is let go. */
private val FLING_VELOCITY = 400.dp

private val SHEET_SPRING = spring<Float>(stiffness = Spring.StiffnessMediumLow)
