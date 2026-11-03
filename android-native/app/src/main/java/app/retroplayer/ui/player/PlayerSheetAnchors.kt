package app.retroplayer.ui.player

import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.Stable
import androidx.compose.runtime.mutableStateMapOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.ui.Modifier
import androidx.compose.ui.layout.onGloballyPositioned
import androidx.compose.ui.layout.positionInRoot
import androidx.lifecycle.viewmodel.compose.LocalViewModelStoreOwner
import kotlin.math.roundToInt

/**
 * Where each page's header ends, so the player sheet opens below it, and which pages hand
 * their header to the Now Playing bar while the player is open. Pages are keyed by their
 * [LocalViewModelStoreOwner], which is the back stack entry inside a NavHost.
 */
@Stable
class PlayerSheetAnchors {
    private val headerBottoms = mutableStateMapOf<Any, Pair<Any?, Int>>()
    private val sharedHeaders = mutableStateMapOf<Any, Any?>()

    internal fun reportHeader(reporter: Any, page: Any?, bottom: Int) {
        val entry = page to bottom
        if (headerBottoms[reporter] != entry) headerBottoms[reporter] = entry
    }

    internal fun shareHeader(reporter: Any, page: Any?) {
        sharedHeaders[reporter] = page
    }

    internal fun forget(reporter: Any) {
        headerBottoms.remove(reporter)
        sharedHeaders.remove(reporter)
    }

    /** Bottom of [page]'s header in px; any page counts when [page] is null. */
    fun headerBottom(page: Any?): Int =
        headerBottoms.values.filter { page == null || it.first == page }.maxOfOrNull { it.second } ?: 0

    fun sharesHeader(page: Any?): Boolean = sharedHeaders.values.any { page == null || it == page }
}

val LocalPlayerSheetAnchors = staticCompositionLocalOf<PlayerSheetAnchors?> { null }

/** Reports the bottom of a header part (top bar, breadcrumbs); the open player starts below the lowest one. */
@Composable
fun rememberPlayerSheetAnchor(): Modifier {
    val anchors = LocalPlayerSheetAnchors.current ?: return Modifier
    val page = LocalViewModelStoreOwner.current
    val reporter = remember { Any() }
    DisposableEffect(anchors, reporter) { onDispose { anchors.forget(reporter) } }
    return Modifier.onGloballyPositioned {
        anchors.reportHeader(reporter, page, (it.positionInRoot().y + it.size.height).roundToInt())
    }
}

/** Marks a page whose header becomes the Now Playing bar while the player is open (library pages). */
@Composable
fun ShareHeaderWithPlayer() {
    val anchors = LocalPlayerSheetAnchors.current ?: return
    val page = LocalViewModelStoreOwner.current
    val reporter = remember { Any() }
    DisposableEffect(anchors, reporter, page) {
        anchors.shareHeader(reporter, page)
        onDispose { anchors.forget(reporter) }
    }
}
