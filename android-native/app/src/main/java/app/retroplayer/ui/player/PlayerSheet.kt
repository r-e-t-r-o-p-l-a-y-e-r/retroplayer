package app.retroplayer.ui.player

import app.retroplayer.ui.settings.SettingsNavAction
import androidx.compose.foundation.combinedClickable
import androidx.compose.foundation.layout.WindowInsetsSides
import androidx.compose.foundation.layout.only
import androidx.compose.foundation.layout.statusBars
import androidx.compose.material.icons.filled.KeyboardArrowDown
import androidx.compose.runtime.derivedStateOf
import androidx.compose.runtime.State
import androidx.compose.runtime.mutableStateOf
import androidx.compose.ui.layout.Layout
import androidx.compose.ui.unit.Constraints
import kotlin.math.roundToInt
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
import androidx.compose.runtime.remember
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
import app.retroplayer.ui.formatDuration
import app.retroplayer.domain.model.Chapter
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowLeft
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material.icons.automirrored.filled.List
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.draw.clip
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
const val SHEET_HANDLE_TAG = "playerSheetHandle"
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
    val previousChapter: () -> Unit = {},
    val nextChapter: () -> Unit = {},
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
 * The app's content with the player sheet over it (UC-12): collapsed it is the mini player at
 * the bottom; dragged up by its handle it grows into the expanded player below the current
 * page's header. Must wrap the NavHost: its back handler is composed after the content so it
 * wins while the player is expanded (UC-14).
 *
 * [currentPage] is the back stack entry on top; pages report their header through
 * [rememberPlayerSheetAnchor] and [ShareHeaderWithPlayer].
 */
@Composable
fun PlayerHost(
    state: PlayerUiState,
    expanded: Boolean,
    onExpandedChange: (Boolean) -> Unit,
    actions: PlayerActions,
    showPlayer: Boolean = true,
    currentPage: Any? = null,
    content: @Composable () -> Unit,
) {
    val visible = state.visible && showPlayer
    val showExpanded = expanded && visible
    val anchors = remember { PlayerSheetAnchors() }
    val sheet = rememberSheetPosition(showExpanded, onExpandedChange)
    val collapse = { onExpandedChange(false) }
    val expand = if (visible && !showExpanded) ({ onExpandedChange(true) }) else null
    val statusBarTop = WindowInsets.statusBars.getTop(LocalDensity.current)
    val miniHeight = remember { IntArray(1) }
    val miniActive by remember { derivedStateOf { sheet.fraction <= MINI_FADED } }
    val bodyShown by remember { derivedStateOf { sheet.fraction > BODY_APPEARS || sheet.dragging } }
    val bodyActive by remember { derivedStateOf { sheet.fraction >= BODY_ACTIVE } }
    val headerShared by remember(currentPage) { derivedStateOf { anchors.sharesHeader(currentPage) } }
    val headerShown by remember { derivedStateOf { sheet.fraction >= 0.5f } }
    CompositionLocalProvider(
        LocalPlayerExpanded provides showExpanded,
        LocalExpandPlayer provides expand,
        LocalPlayerSheetAnchors provides anchors,
    ) {
        Layout(
            contents = listOf(
                {
                    Box(
                        Modifier
                            .then(if (visible) Modifier.consumeWindowInsets(WindowInsets.navigationBars) else Modifier)
                            .then(if (showExpanded) Modifier.clearAndSetSemantics {} else Modifier),
                    ) { content() }
                },
                { if (visible) SheetBackground() },
                {
                    if (visible) {
                        MiniBody(
                            state,
                            actions,
                            onExpand = { onExpandedChange(true) },
                            drag = sheet.drag,
                            modifier = Modifier
                                .graphicsLayer { alpha = (1f - sheet.fraction / MINI_FADED).coerceIn(0f, 1f) }
                                .then(if (miniActive) Modifier else Modifier.clearAndSetSemantics {}),
                        )
                    }
                },
                {
                    if (visible && bodyShown) {
                        ExpandedBody(
                            state,
                            actions,
                            drag = sheet.drag,
                            modifier = Modifier
                                .graphicsLayer { alpha = ((sheet.fraction - MINI_FADED) / (1f - MINI_FADED)).coerceIn(0f, 1f) }
                                .then(if (bodyActive) Modifier else Modifier.clearAndSetSemantics {}),
                        )
                    }
                },
                { if (visible) SheetHandle(showExpanded, sheet.drag, onToggle = { onExpandedChange(!showExpanded) }) },
                {
                    if (visible && headerShared) {
                        CompositionLocalProvider(LocalPlayerSheetAnchors provides null) {
                            NowPlayingHeader(
                                state,
                                actions,
                                collapse,
                                if (headerShown) Modifier else Modifier.clearAndSetSemantics {},
                            )
                        }
                    }
                },
            ),
        ) { parts, constraints ->
            val (contentPart, backgroundPart, miniPart, bodyPart, handlePart) = parts
            val headerPart = parts[5]
            val width = constraints.maxWidth
            val height = constraints.maxHeight
            val handle = handlePart.firstOrNull()?.measure(Constraints.fixedWidth(width))
            val mini = miniPart.firstOrNull()?.measure(Constraints(minWidth = width, maxWidth = width))
            if (mini != null) miniHeight[0] = mini.height
            val collapsedHeight = if (visible) (handle?.height ?: 0) + miniHeight[0] else 0
            val pageTop = maxOf(anchors.headerBottom(currentPage), statusBarTop).coerceIn(0, height)
            // The Now Playing header can wrap taller than the page header it replaces.
            val header = headerPart.firstOrNull()?.measure(Constraints(width, width, pageTop, height))
            val top = maxOf(pageTop, header?.height ?: 0)
            val travel = (height - top - collapsedHeight).coerceAtLeast(1)
            sheet.travel = travel.toFloat()
            val sheetHeight = collapsedHeight + (sheet.fraction * travel).roundToInt()
            val sheetTop = height - sheetHeight
            val handleHeight = handle?.height ?: 0
            val page = contentPart.first().measure(Constraints.fixed(width, (height - collapsedHeight).coerceAtLeast(0)))
            val background = backgroundPart.firstOrNull()?.measure(Constraints.fixed(width, sheetHeight))
            val body = bodyPart.firstOrNull()?.measure(Constraints.fixed(width, (height - top - handleHeight).coerceAtLeast(0)))
            layout(width, height) {
                page.place(0, 0)
                background?.place(0, sheetTop)
                mini?.place(0, sheetTop + handleHeight)
                body?.place(0, sheetTop + handleHeight)
                handle?.place(0, sheetTop)
                // Measured even while hidden so the sheet top stays put when it appears.
                if (sheet.fraction >= 0.5f) header?.place(0, 0)
            }
        }
        if (visible) SheetBackHandler(sheet, showExpanded, onExpandedChange)
    }
}

/** How far the sheet is pulled up (0 = mini, 1 = expanded) and the drag that moves it. */
private class SheetPosition(
    val drag: Modifier,
    val position: Animatable<Float, *>,
    private val travelPx: FloatArray,
    private val draggingState: State<Boolean>,
) {
    val fraction: Float get() = position.value

    /** True while a finger moves the sheet; the part being dragged must stay composed. */
    val dragging: Boolean get() = draggingState.value

    /** Pixels between the collapsed and the expanded sheet top; set by the layout. */
    var travel: Float
        get() = travelPx[0]
        set(value) {
            travelPx[0] = value
        }
}

/**
 * The sheet follows the finger; on release it snaps to the end a fling points at,
 * else to the nearer one, and reports it through [onExpandedChange].
 */
@Composable
private fun rememberSheetPosition(expanded: Boolean, onExpandedChange: (Boolean) -> Unit): SheetPosition {
    val position = remember { Animatable(if (expanded) 1f else 0f) }
    val travel = remember { floatArrayOf(1f) }
    val dragging = remember { mutableStateOf(false) }
    val scope = rememberCoroutineScope()
    val flingPx = with(LocalDensity.current) { FLING_VELOCITY.toPx() }
    val currentExpanded by rememberUpdatedState(expanded)
    val report by rememberUpdatedState(onExpandedChange)
    LaunchedEffect(expanded) { position.animateTo(if (expanded) 1f else 0f, SHEET_SPRING) }
    val dragState = rememberDraggableState { delta ->
        scope.launch { position.snapTo((position.value - delta / travel[0]).coerceIn(0f, 1f)) }
    }
    val drag = Modifier.draggable(
        state = dragState,
        orientation = Orientation.Vertical,
        onDragStarted = { dragging.value = true },
        onDragStopped = { velocity ->
            dragging.value = false
            val target = when {
                velocity < -flingPx -> true
                velocity > flingPx -> false
                else -> position.value > 0.5f
            }
            if (target != currentExpanded) report(target) else scope.launch { position.animateTo(if (target) 1f else 0f, SHEET_SPRING) }
        },
    )
    return remember(drag) { SheetPosition(drag, position, travel, dragging) }
}

/** Back pulls the expanded sheet down with the finger; letting go finishes the collapse, cancelling springs it back. */
@Composable
private fun SheetBackHandler(sheet: SheetPosition, expanded: Boolean, onExpandedChange: (Boolean) -> Unit) {
    val scope = rememberCoroutineScope()
    PredictiveBackHandler(enabled = expanded) { events ->
        try {
            events.collect { sheet.position.snapTo(1f - it.progress) }
            onExpandedChange(false)
        } catch (cancelled: CancellationException) {
            scope.launch { sheet.position.animateTo(1f, SHEET_SPRING) }
            throw cancelled
        }
    }
}

@Composable
private fun SheetBackground() {
    val palette = LocalRetroPalette.current
    Surface(color = palette.screenElevated, shadowElevation = 8.dp, modifier = Modifier.fillMaxSize()) {
        Box(Modifier.fillMaxSize()) { HorizontalDivider(color = palette.divider) }
    }
}

/** The grip on top of the sheet: drag it to pull the player up or down, tap it to toggle. */
@Composable
private fun SheetHandle(expanded: Boolean, drag: Modifier, onToggle: () -> Unit) {
    Box(
        Modifier
            .fillMaxWidth()
            .height(HANDLE_HEIGHT)
            .testTag(SHEET_HANDLE_TAG)
            .clickable(onClickLabel = stringResource(if (expanded) R.string.show_library else R.string.expand_player), onClick = onToggle)
            .then(drag),
        contentAlignment = Alignment.Center,
    ) {
        DragHandle()
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
private fun MiniBody(state: PlayerUiState, actions: PlayerActions, onExpand: () -> Unit, drag: Modifier, modifier: Modifier = Modifier) {
    val now = state.nowPlaying
    val locateLabel = stringResource(R.string.show_library)
    val expandLabel = stringResource(R.string.expand_player)
    Column(
        Modifier
            .testTag(MINI_PLAYER_TAG)
            .then(modifier)
            .fillMaxWidth()
            .then(drag)
            .clickable(interactionSource = null, indication = null, onClickLabel = expandLabel, onClick = onExpand)
            .windowInsetsPadding(WindowInsets.navigationBars)
            .padding(horizontal = 16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
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

/** The library header while the player is open: Now Playing with the playing item's breadcrumbs. */
@Composable
private fun NowPlayingHeader(state: PlayerUiState, actions: PlayerActions, onCollapse: () -> Unit, modifier: Modifier) {
    Surface(color = LocalRetroPalette.current.screen, modifier = modifier.fillMaxWidth()) {
        Column(Modifier.windowInsetsPadding(WindowInsets.safeDrawing.only(WindowInsetsSides.Top + WindowInsetsSides.Horizontal))) {
            RetroTopBar(
                stringResource(R.string.now_playing),
                navigationIcon = { BackButton(onCollapse, contentDescription = stringResource(R.string.library)) },
                actions = {
                    IconButton(onClick = onCollapse) {
                        Icon(Icons.Filled.KeyboardArrowDown, contentDescription = stringResource(R.string.show_library))
                    }
                    SettingsNavAction(actions.openSettings)
                },
            )
            if (state.crumbs.isNotEmpty()) BreadcrumbStrip(state.crumbs, actions.playbackCrumb)
        }
    }
}

@Composable
private fun ExpandedBody(state: PlayerUiState, actions: PlayerActions, drag: Modifier, modifier: Modifier = Modifier) {
    BoxWithConstraints(
        Modifier
            .testTag(EXPANDED_PLAYER_TAG)
            .then(modifier)
            .fillMaxSize()
            .then(drag)
            .windowInsetsPadding(WindowInsets.safeDrawing.only(WindowInsetsSides.Bottom + WindowInsetsSides.Horizontal)),
    ) {
        if (maxWidth > maxHeight) {
            Row(Modifier.fillMaxSize().padding(horizontal = 24.dp, vertical = 8.dp), verticalAlignment = Alignment.CenterVertically) {
                ArtWithJumps(state, actions, Modifier.weight(1f).fillMaxHeight())
                Spacer(Modifier.width(24.dp))
                Column(
                    Modifier.weight(1f).verticalScroll(rememberScrollState()),
                    horizontalAlignment = Alignment.CenterHorizontally,
                ) {
                    Controls(state, actions)
                }
            }
        } else {
            Column(Modifier.fillMaxSize().padding(horizontal = 24.dp), horizontalAlignment = Alignment.CenterHorizontally) {
                Spacer(Modifier.weight(1f))
                ArtWithJumps(state, actions, Modifier.weight(4f, fill = false).fillMaxWidth())
                Spacer(Modifier.height(16.dp))
                Controls(state, actions)
                Spacer(Modifier.weight(1.4f))
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
private fun Controls(state: PlayerUiState, actions: PlayerActions) {
    val now = state.nowPlaying
    Titles(
        now,
        titleStyle = MaterialTheme.typography.headlineSmall.copy(fontSize = 20.sp, lineHeight = 24.sp),
        subtitleStyle = MaterialTheme.typography.bodyLarge.copy(fontSize = 15.sp),
        align = TextAlign.Center,
        titleModifier = Modifier
            .testTag(EXPANDED_LOCATE_TITLE_TAG)
            .clickable(onClick = actions.locate),
    )
    if (state.chapters.isNotEmpty()) ChapterRow(state, actions) else Spacer(Modifier.height(16.dp))
    PlaybackProgress(now.positionMs, now.durationMs, actions.seekTo, marksMs = state.chapters.map { it.startMs })
    Spacer(Modifier.height(8.dp))
    Transport(now, actions, skipSize = 40.dp, playSize = 64.dp)
    Spacer(Modifier.height(16.dp))
    SpeedRow(now.speed, actions.setSpeed)
}

/** The current chapter between chapter steps; tapping it lists all chapters. */
@Composable
private fun ChapterRow(state: PlayerUiState, actions: PlayerActions) {
    val palette = LocalRetroPalette.current
    var listOpen by rememberSaveable { mutableStateOf(false) }
    val current = state.currentChapter ?: state.chapters.first()
    Row(Modifier.fillMaxWidth().padding(vertical = 4.dp), verticalAlignment = Alignment.CenterVertically) {
        IconButton(onClick = actions.previousChapter) {
            Icon(Icons.AutoMirrored.Filled.KeyboardArrowLeft, stringResource(R.string.previous_chapter), tint = palette.textSecondary)
        }
        Row(
            Modifier
                .weight(1f)
                .clip(RoundedCornerShape(8.dp))
                .clickable(onClickLabel = stringResource(R.string.chapters)) { listOpen = true }
                .padding(horizontal = 8.dp, vertical = 8.dp),
            horizontalArrangement = Arrangement.Center,
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Icon(Icons.AutoMirrored.Filled.List, contentDescription = null, tint = palette.textMuted, modifier = Modifier.size(18.dp))
            Text(
                chapterLabel(state.chapters, current),
                style = TextStyle(fontSize = 14.sp, fontWeight = FontWeight.Medium, color = palette.textSecondary),
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
                modifier = Modifier.padding(start = 6.dp),
            )
        }
        IconButton(onClick = actions.nextChapter) {
            Icon(Icons.AutoMirrored.Filled.KeyboardArrowRight, stringResource(R.string.next_chapter), tint = palette.textSecondary)
        }
    }
    if (listOpen) ChapterList(state, onSeek = actions.seekTo, onDismiss = { listOpen = false })
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun ChapterList(state: PlayerUiState, onSeek: (Long) -> Unit, onDismiss: () -> Unit) {
    val palette = LocalRetroPalette.current
    val sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true)
    val scope = rememberCoroutineScope()
    val current = state.currentChapter
    val list = rememberLazyListState(initialFirstVisibleItemIndex = state.chapters.indexOf(current).coerceAtLeast(0))
    ModalBottomSheet(onDismissRequest = onDismiss, sheetState = sheetState, containerColor = palette.screenElevated) {
        Text(
            stringResource(R.string.chapters),
            style = MaterialTheme.typography.titleMedium,
            color = palette.textPrimary,
            modifier = Modifier.padding(horizontal = 24.dp, vertical = 8.dp),
        )
        LazyColumn(state = list) {
            items(state.chapters) { chapter ->
                val selected = chapter == current
                Row(
                    Modifier
                        .fillMaxWidth()
                        .clickable {
                            onSeek(chapter.startMs)
                            scope.launch { sheetState.hide() }.invokeOnCompletion { onDismiss() }
                        }
                        .padding(horizontal = 24.dp, vertical = 14.dp),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    Text(
                        chapterLabel(state.chapters, chapter),
                        style = TextStyle(
                            fontSize = 15.sp,
                            fontWeight = if (selected) FontWeight.SemiBold else FontWeight.Normal,
                            color = if (selected) palette.accent else palette.textPrimary,
                        ),
                        modifier = Modifier.weight(1f),
                    )
                    Text(
                        formatDuration(chapter.startMs),
                        style = TextStyle(fontSize = 13.sp, fontFeatureSettings = "tnum", color = palette.textMuted),
                        modifier = Modifier.padding(start = 12.dp),
                    )
                }
            }
        }
    }
}

/** Untitled chapters show their number. */
private fun chapterLabel(chapters: List<Chapter>, chapter: Chapter): String =
    chapter.title.ifBlank { (chapters.indexOf(chapter) + 1).toString() }

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

private val HANDLE_HEIGHT = 20.dp

/** Sheet fractions where the mini player has faded out and the expanded player appears and takes touches. */
private const val MINI_FADED = 0.25f
private const val BODY_APPEARS = 0.2f
private const val BODY_ACTIVE = 0.75f
