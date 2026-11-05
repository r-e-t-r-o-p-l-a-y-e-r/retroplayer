package app.retroplayer.ui.library

import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.awaitEachGesture
import androidx.compose.foundation.gestures.awaitFirstDown
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.width
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberUpdatedState
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import app.retroplayer.ui.theme.LocalRetroPalette
import app.retroplayer.R

const val LIBRARY_INDEX_BAR_TAG = "libraryIndexBar"

/** Width of the index bar; lists showing it pad their content by this much. */
val INDEX_BAR_WIDTH = 56.dp

private val MIN_LABEL_HEIGHT = 14.dp

/**
 * Vertical index scrubber over the full list height. Touching or sliding
 * selects the label under the finger; when the bar is too short for every
 * label, only every n-th is drawn, but sliding still reaches all of them.
 */
@Composable
fun AlphabetIndexBar(
    labels: List<String>,
    onSelect: (String) -> Unit,
    modifier: Modifier = Modifier,
) {
    if (labels.isEmpty()) return
    val barLabel = stringResource(R.string.library_index)
    val palette = LocalRetroPalette.current
    val haptic = LocalHapticFeedback.current
    val select by rememberUpdatedState(onSelect)
    var active by remember { mutableStateOf<String?>(null) }
    BoxWithConstraints(
        modifier = modifier
            .width(INDEX_BAR_WIDTH)
            .fillMaxHeight()
            .background(palette.screenElevated.copy(alpha = 0.92f))
            .testTag(LIBRARY_INDEX_BAR_TAG)
            .semantics { contentDescription = barLabel }
            .pointerInput(labels) {
                fun pick(y: Float) {
                    val fraction = (y / size.height).coerceIn(0f, 0.999f)
                    val label = labels[(fraction * labels.size).toInt()]
                    if (label != active) {
                        active = label
                        haptic.performHapticFeedback(HapticFeedbackType.TextHandleMove)
                        select(label)
                    }
                }
                awaitEachGesture {
                    val down = awaitFirstDown()
                    down.consume()
                    pick(down.position.y)
                    while (true) {
                        val change = awaitPointerEvent().changes.firstOrNull { it.id == down.id } ?: break
                        if (!change.pressed) break
                        change.consume()
                        pick(change.position.y)
                    }
                    active = null
                }
            },
    ) {
        val fit = (maxHeight / MIN_LABEL_HEIGHT).toInt().coerceAtLeast(1)
        val step = (labels.size + fit - 1) / fit
        Column(Modifier.fillMaxSize()) {
            labels.forEachIndexed { index, label ->
                Box(Modifier.fillMaxWidth().weight(1f), contentAlignment = Alignment.Center) {
                    if (index % step == 0 || label == active) {
                        val isActive = label == active
                        Text(
                            text = label,
                            fontSize = 13.sp,
                            fontWeight = if (isActive) FontWeight.Bold else FontWeight.SemiBold,
                            color = if (isActive) palette.accent else palette.textSecondary,
                            textAlign = TextAlign.Center,
                            maxLines = 1,
                            softWrap = false,
                        )
                    }
                }
            }
        }
    }
}
