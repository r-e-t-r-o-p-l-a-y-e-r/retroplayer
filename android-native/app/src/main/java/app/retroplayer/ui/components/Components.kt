package app.retroplayer.ui.components

import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.combinedClickable
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.wrapContentHeight
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material.icons.rounded.MusicNote
import androidx.compose.material3.CenterAlignedTopAppBar
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ProvideTextStyle
import androidx.compose.material3.Slider
import androidx.compose.material3.SliderDefaults
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.heading
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import app.retroplayer.R
import app.retroplayer.domain.Crumb
import app.retroplayer.ui.formatDuration
import app.retroplayer.ui.theme.LocalRetroPalette
import app.retroplayer.ui.theme.RetroPalette
import coil3.compose.SubcomposeAsyncImage

const val PLAYING_STRIP_TAG = "playingStrip"
const val PROGRESS_TAG = "playbackProgress"

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun RetroTopBar(
    title: String,
    modifier: Modifier = Modifier,
    navigationIcon: @Composable () -> Unit = {},
    actions: @Composable RowScope.() -> Unit = {},
) {
    val palette = LocalRetroPalette.current
    CenterAlignedTopAppBar(
        title = { Text(title, style = MaterialTheme.typography.titleMedium, maxLines = 1, overflow = TextOverflow.Ellipsis) },
        navigationIcon = navigationIcon,
        actions = actions,
        colors = TopAppBarDefaults.topAppBarColors(
            containerColor = palette.screenElevated,
            scrolledContainerColor = palette.screenElevated,
            titleContentColor = palette.textPrimary,
            navigationIconContentColor = palette.textPrimary,
            actionIconContentColor = palette.textPrimary,
        ),
        modifier = modifier,
    )
}

/** Back arrow for sub pages; every one of them leads back towards the library. */
@Composable
fun BackButton(onClick: () -> Unit, contentDescription: String = stringResource(R.string.show_library)) {
    IconButton(onClick = onClick) {
        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = contentDescription)
    }
}

/**
 * Crumbs on the chrome band; parents open on tap (display only without
 * [onCrumb]), the current one is accent and not clickable.
 */
@Composable
fun BreadcrumbStrip(crumbs: List<Crumb>, onCrumb: ((Crumb) -> Unit)?, modifier: Modifier = Modifier) {
    val palette = LocalRetroPalette.current
    val scroll = rememberScrollState()
    LaunchedEffect(crumbs) { scroll.scrollTo(scroll.maxValue) }
    Surface(color = palette.chrome.copy(alpha = 0.55f), modifier = modifier.fillMaxWidth()) {
        Row(
            Modifier.horizontalScroll(scroll).padding(horizontal = 8.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            crumbs.forEachIndexed { index, crumb ->
                if (index > 0) {
                    Icon(
                        Icons.AutoMirrored.Filled.KeyboardArrowRight,
                        contentDescription = null,
                        tint = palette.textMuted,
                        modifier = Modifier.size(16.dp),
                    )
                }
                val current = index == crumbs.lastIndex
                val label = if (crumb.isLibraryRoot) stringResource(R.string.library) else crumb.label
                Text(
                    label,
                    style = MaterialTheme.typography.bodyMedium.copy(fontWeight = if (current) FontWeight.SemiBold else FontWeight.Medium),
                    color = if (current) palette.accent else MaterialTheme.colorScheme.onSurfaceVariant,
                    maxLines = 1,
                    modifier = Modifier
                        .clip(RoundedCornerShape(4.dp))
                        .then(if (current || onCrumb == null) Modifier else Modifier.clickable { onCrumb(crumb) })
                        .heightIn(min = 40.dp)
                        .wrapContentHeight()
                        .padding(horizontal = 6.dp),
                )
            }
        }
    }
}

@Composable
fun SectionHeader(text: String, modifier: Modifier = Modifier) {
    Text(
        text = text,
        style = MaterialTheme.typography.titleSmall,
        color = LocalRetroPalette.current.textMuted,
        modifier = modifier
            .padding(start = 16.dp, end = 16.dp, top = 16.dp, bottom = 4.dp)
            .semantics { heading() },
    )
}

/**
 * The list row of every library page. [playing] tints the row and draws the
 * accent strip on the leading edge.
 */
@OptIn(ExperimentalFoundationApi::class)
@Composable
fun RetroListRow(
    title: @Composable () -> Unit,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    subtitle: (@Composable () -> Unit)? = null,
    leading: (@Composable () -> Unit)? = null,
    trailing: (@Composable () -> Unit)? = null,
    playing: Boolean = false,
    onLongClick: (() -> Unit)? = null,
    onLongClickLabel: String? = null,
) {
    val palette = LocalRetroPalette.current
    Box(modifier.fillMaxWidth().background(if (playing) palette.playingHighlight else Color.Transparent)) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Row(
                Modifier
                    .weight(1f)
                    .combinedClickable(onClick = onClick, onLongClick = onLongClick, onLongClickLabel = onLongClickLabel)
                    .heightIn(min = 56.dp)
                    .padding(horizontal = 16.dp, vertical = 8.dp),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                if (leading != null) {
                    leading()
                    Spacer(Modifier.width(12.dp))
                }
                Column(Modifier.weight(1f)) {
                    ProvideTextStyle(
                        MaterialTheme.typography.bodyLarge.copy(
                            fontWeight = if (playing) FontWeight.SemiBold else FontWeight.Medium,
                            color = if (playing) palette.accent else palette.textPrimary,
                        ),
                        title,
                    )
                    if (subtitle != null) {
                        Spacer(Modifier.size(2.dp))
                        ProvideTextStyle(TextStyle(fontSize = 13.sp, color = palette.textMuted), subtitle)
                    }
                }
            }
            if (trailing != null) {
                Box(Modifier.padding(end = 4.dp)) { trailing() }
            }
        }
        if (playing) {
            Spacer(
                Modifier
                    .matchParentSize()
                    .testTag(PLAYING_STRIP_TAG)
                    .drawBehind {
                        val width = 3.dp.toPx()
                        val x = if (layoutDirection == LayoutDirection.Rtl) size.width - width else 0f
                        drawRect(palette.accent, topLeft = Offset(x, 0f), size = Size(width, size.height))
                    },
            )
        }
    }
}

@Composable
fun IconChip(icon: ImageVector, modifier: Modifier = Modifier, highlight: Boolean = false, contentDescription: String? = null) {
    val palette = LocalRetroPalette.current
    Box(
        modifier.size(40.dp).clip(RoundedCornerShape(8.dp)).background(palette.iconChip),
        contentAlignment = Alignment.Center,
    ) {
        Icon(
            icon,
            contentDescription = contentDescription,
            tint = if (highlight) palette.accent else palette.textSecondary,
            modifier = Modifier.size(22.dp),
        )
    }
}

/** Round transport button: [primary] is the accent play button, the others sit on icon-chip circles. */
@Composable
fun TransportButton(
    icon: ImageVector,
    contentDescription: String,
    onClick: () -> Unit,
    size: Dp,
    modifier: Modifier = Modifier,
    primary: Boolean = false,
    enabled: Boolean = true,
) {
    val palette = LocalRetroPalette.current
    val dark = palette == RetroPalette.Dark
    Surface(
        onClick = onClick,
        enabled = enabled,
        shape = CircleShape,
        color = if (primary) palette.accent else palette.iconChip.copy(alpha = if (enabled) 1f else 0.5f),
        shadowElevation = if (primary) 2.dp else 0.dp,
        modifier = modifier.size(size),
    ) {
        Box(contentAlignment = Alignment.Center) {
            Icon(
                icon,
                contentDescription = contentDescription,
                tint = when {
                    primary -> if (dark) palette.textPrimary else Color.White
                    enabled -> palette.textPrimary
                    else -> palette.textMuted
                },
                modifier = Modifier.size(size * if (primary) 0.55f else 0.5f),
            )
        }
    }
}

/**
 * Seek bar with elapsed and total time. While dragging it shows the drag
 * position and ignores the player; [onSeek] fires once on release.
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun PlaybackProgress(
    positionMs: Long,
    durationMs: Long,
    onSeek: (Long) -> Unit,
    modifier: Modifier = Modifier,
    compact: Boolean = false,
) {
    val palette = LocalRetroPalette.current
    var dragging by remember { mutableStateOf<Float?>(null) }
    val max = durationMs.coerceAtLeast(1).toFloat()
    val value = (dragging ?: positionMs.toFloat()).coerceIn(0f, max)
    val colors = SliderDefaults.colors(
        thumbColor = palette.screenElevated,
        activeTrackColor = palette.accent,
        inactiveTrackColor = palette.divider,
        disabledThumbColor = palette.screenElevated,
        disabledActiveTrackColor = palette.divider,
        disabledInactiveTrackColor = palette.divider,
    )
    val time = TextStyle(
        fontFeatureSettings = "tnum",
        fontSize = if (compact) 11.sp else 12.sp,
        fontWeight = FontWeight.Medium,
        letterSpacing = 0.2.sp,
        color = palette.textMuted,
    )
    Column(modifier) {
        Slider(
            value = value,
            onValueChange = { dragging = it },
            onValueChangeFinished = {
                dragging?.let { onSeek(it.toLong()) }
                dragging = null
            },
            valueRange = 0f..max,
            enabled = durationMs > 0,
            colors = colors,
            thumb = {
                Box(
                    Modifier
                        .size(14.dp)
                        .shadow(2.dp, CircleShape)
                        .background(palette.screenElevated, CircleShape)
                        .border(1.dp, palette.textPrimary.copy(alpha = 0.6f), CircleShape),
                )
            },
            track = { state ->
                SliderDefaults.Track(
                    sliderState = state,
                    colors = colors,
                    enabled = durationMs > 0,
                    thumbTrackGapSize = 0.dp,
                    drawStopIndicator = null,
                    modifier = Modifier.heightIn(max = 3.dp),
                )
            },
            modifier = Modifier.fillMaxWidth().heightIn(max = if (compact) 24.dp else 32.dp).testTag(PROGRESS_TAG),
        )
        Row(Modifier.fillMaxWidth()) {
            Text(formatDuration(value.toLong()), style = time)
            Spacer(Modifier.weight(1f))
            Text(formatDuration(durationMs), style = time)
        }
    }
}

/** Square cover: [model] is a folder picture uri or an [app.retroplayer.ui.art.EmbeddedArt]. */
@Composable
fun AlbumArt(model: Any?, modifier: Modifier = Modifier, size: Dp = 56.dp, placeholderIcon: ImageVector = Icons.Rounded.MusicNote) {
    val palette = LocalRetroPalette.current
    val shape = RoundedCornerShape(4.dp)
    val placeholder: @Composable () -> Unit = {
        Box(
            Modifier
                .size(size)
                .background(Brush.linearGradient(listOf(palette.albumPlaceholderStart, palette.albumPlaceholderEnd))),
            contentAlignment = Alignment.Center,
        ) {
            Icon(placeholderIcon, contentDescription = null, tint = palette.textMuted, modifier = Modifier.size(size / 2.5f))
        }
    }
    Box(
        modifier
            .size(size)
            .shadow(if (size > 96.dp) 6.dp else 2.dp, shape)
            .clip(shape)
            .border(1.5.dp, palette.divider, shape),
    ) {
        if (model == null) {
            placeholder()
        } else {
            SubcomposeAsyncImage(
                model = model,
                contentDescription = null,
                contentScale = ContentScale.Crop,
                modifier = Modifier.size(size),
                loading = { placeholder() },
                error = { placeholder() },
            )
        }
    }
}
