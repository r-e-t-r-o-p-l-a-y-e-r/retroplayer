package app.retroplayer.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material.icons.filled.Album
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.heading
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import app.retroplayer.R
import app.retroplayer.domain.Crumb
import app.retroplayer.ui.theme.LocalRetroPalette
import coil3.compose.SubcomposeAsyncImage

/** Square cover: [model] is a folder picture uri or an [app.retroplayer.ui.art.EmbeddedArt]. */
@Composable
fun AlbumArt(model: Any?, modifier: Modifier = Modifier, size: Dp = 56.dp) {
    val palette = LocalRetroPalette.current
    val shape = RoundedCornerShape(if (size > 96.dp) 12.dp else 6.dp)
    val placeholder: @Composable () -> Unit = {
        Box(
            Modifier
                .size(size)
                .background(Brush.linearGradient(listOf(palette.albumPlaceholderStart, palette.albumPlaceholderEnd))),
            contentAlignment = Alignment.Center,
        ) {
            Icon(Icons.Filled.Album, contentDescription = null, tint = palette.textMuted, modifier = Modifier.size(size / 2))
        }
    }
    Box(modifier.size(size).clip(shape)) {
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

@Composable
fun SectionHeader(text: String, modifier: Modifier = Modifier) {
    Text(
        text = text,
        style = MaterialTheme.typography.titleSmall,
        color = MaterialTheme.colorScheme.secondary,
        modifier = modifier
            .padding(start = 16.dp, end = 16.dp, top = 16.dp, bottom = 4.dp)
            .semantics { heading() },
    )
}

/** Horizontally scrolling crumbs, kept scrolled to the end so the current folder is visible. */
@Composable
fun BreadcrumbBar(crumbs: List<Crumb>, onCrumb: (Crumb) -> Unit, modifier: Modifier = Modifier) {
    val scroll = rememberScrollState()
    LaunchedEffect(crumbs) { scroll.scrollTo(scroll.maxValue) }
    Row(modifier.horizontalScroll(scroll), verticalAlignment = Alignment.CenterVertically) {
        crumbs.forEachIndexed { index, crumb ->
            if (index > 0) {
                Icon(
                    Icons.AutoMirrored.Filled.KeyboardArrowRight,
                    contentDescription = null,
                    tint = MaterialTheme.colorScheme.outline,
                    modifier = Modifier.size(18.dp),
                )
            }
            val label = if (crumb.isLibraryRoot) stringResource(R.string.library) else crumb.label
            val last = index == crumbs.lastIndex
            TextButton(onClick = { onCrumb(crumb) }, enabled = !last) {
                Text(
                    label,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                    style = if (last) MaterialTheme.typography.titleMedium else MaterialTheme.typography.bodyMedium,
                    color = if (last) MaterialTheme.colorScheme.onSurface else MaterialTheme.colorScheme.primary,
                )
            }
        }
    }
}
