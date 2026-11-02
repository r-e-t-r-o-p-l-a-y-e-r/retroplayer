package app.retroplayer.ui.components

import android.content.res.Resources
import androidx.compose.animation.core.animate
import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.Orientation
import androidx.compose.foundation.gestures.draggable
import androidx.compose.foundation.gestures.rememberDraggableState
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Icon
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.platform.LocalLayoutDirection
import androidx.compose.ui.semantics.CustomAccessibilityAction
import androidx.compose.ui.semantics.customActions
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.dp
import app.retroplayer.R
import app.retroplayer.ui.theme.LocalRetroPalette
import kotlin.math.abs
import kotlin.math.roundToInt

/** What a row does when swiped one way; [label] also names it for accessibility services. */
class Swipe(val icon: ImageVector, val label: String, val action: () -> Unit)

private val SWIPE_THRESHOLD = 72.dp

/**
 * Row swipes that run an action once the row moved past a threshold, then
 * snap back. [fromStart] runs on a swipe from the start edge (rightwards in
 * LTR), [fromEnd] on a swipe from the end edge.
 */
@Composable
fun SwipeActions(
    modifier: Modifier = Modifier,
    fromStart: Swipe? = null,
    fromEnd: Swipe? = null,
    content: @Composable () -> Unit,
) {
    val palette = LocalRetroPalette.current
    val threshold = with(LocalDensity.current) { SWIPE_THRESHOLD.toPx() }
    val towardEndSign = if (LocalLayoutDirection.current == LayoutDirection.Rtl) -1f else 1f
    var offset by remember { mutableFloatStateOf(0f) }
    val dragState = rememberDraggableState { delta ->
        val next = offset + delta
        offset = when {
            next * towardEndSign > 0 && fromStart == null -> 0f
            next * towardEndSign < 0 && fromEnd == null -> 0f
            else -> next
        }
    }
    fun current() = when {
        offset * towardEndSign > 0 -> fromStart
        offset * towardEndSign < 0 -> fromEnd
        else -> null
    }
    Box(
        modifier
            .semantics {
                customActions = listOfNotNull(fromStart, fromEnd).map { action ->
                    CustomAccessibilityAction(action.label) {
                        action.action()
                        true
                    }
                }
            }
            .draggable(
                state = dragState,
                orientation = Orientation.Horizontal,
                enabled = fromStart != null || fromEnd != null,
                onDragStopped = {
                    if (abs(offset) >= threshold) current()?.action?.invoke()
                    animate(offset, 0f) { value, _ -> offset = value }
                },
            ),
    ) {
        val swipe = current()
        if (swipe != null) {
            Box(
                Modifier.matchParentSize().background(palette.chrome).padding(horizontal = 24.dp),
                contentAlignment = if (offset * towardEndSign > 0) Alignment.CenterStart else Alignment.CenterEnd,
            ) { Icon(swipe.icon, contentDescription = null, tint = palette.accent) }
        }
        Box(Modifier.offset { IntOffset(offset.roundToInt(), 0) }.background(palette.screen)) { content() }
    }
}

fun Resources.addedToQueue(count: Int): String = when (count) {
    0 -> getString(R.string.added_to_queue_eq0)
    1 -> getString(R.string.added_to_queue_eq1)
    else -> getString(R.string.added_to_queue_other, count)
}
