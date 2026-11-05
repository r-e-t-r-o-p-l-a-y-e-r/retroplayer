package app.retroplayer.ui.components

import android.content.res.Resources
import androidx.compose.animation.core.animate
import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.Orientation
import androidx.compose.foundation.gestures.draggable
import androidx.compose.foundation.gestures.rememberDraggableState
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.platform.LocalLayoutDirection
import androidx.compose.ui.semantics.CustomAccessibilityAction
import androidx.compose.ui.semantics.customActions
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.dp
import app.retroplayer.R
import app.retroplayer.ui.theme.LocalRetroPalette
import kotlin.math.abs
import kotlin.math.roundToInt

/** Colors of the bar a swipe reveals, as in the Flutter dismiss backgrounds. */
enum class SwipeStyle { Favorite, Queue, Remove }

/** What a row does when swiped one way; [label] also names it for accessibility services. */
class Swipe(val icon: ImageVector, val label: String, val style: SwipeStyle, val action: () -> Unit)

private val SWIPE_THRESHOLD = 72.dp

/**
 * Row swipes that run an action once the row moved past a threshold, then
 * snap back. [fromStart] runs on a swipe from the start edge (rightwards in
 * LTR), [fromEnd] on a swipe from the end edge. [moreActions] are offered to
 * accessibility services next to the swipes.
 */
@Composable
fun SwipeActions(
    modifier: Modifier = Modifier,
    fromStart: Swipe? = null,
    fromEnd: Swipe? = null,
    moreActions: List<CustomAccessibilityAction> = emptyList(),
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
                customActions = listOfNotNull(fromStart, fromEnd).distinctBy { it.label }.map { action ->
                    CustomAccessibilityAction(action.label) {
                        action.action()
                        true
                    }
                } + moreActions
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
            val (background, ink) = swipe.style.colors()
            val atStart = offset * towardEndSign > 0
            Box(
                Modifier.matchParentSize().background(background).padding(horizontal = 20.dp),
                contentAlignment = if (atStart) Alignment.CenterStart else Alignment.CenterEnd,
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                ) {
                    Icon(swipe.icon, contentDescription = null, tint = ink)
                    Text(
                        swipe.label,
                        color = ink,
                        fontWeight = FontWeight.SemiBold,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                    )
                }
            }
        }
        Box(Modifier.offset { IntOffset(offset.roundToInt(), 0) }.background(palette.screen)) { content() }
    }
}

@Composable
private fun SwipeStyle.colors(): Pair<Color, Color> {
    val scheme = MaterialTheme.colorScheme
    return when (this) {
        SwipeStyle.Favorite -> scheme.primary to scheme.onPrimary
        SwipeStyle.Queue -> scheme.secondary to scheme.onSecondary
        SwipeStyle.Remove -> scheme.errorContainer to scheme.onErrorContainer
    }
}

fun Resources.addedToQueue(count: Int): String = when (count) {
    0 -> getString(R.string.added_to_queue_eq0)
    1 -> getString(R.string.added_to_queue_eq1)
    else -> getString(R.string.added_to_queue_other, count)
}
