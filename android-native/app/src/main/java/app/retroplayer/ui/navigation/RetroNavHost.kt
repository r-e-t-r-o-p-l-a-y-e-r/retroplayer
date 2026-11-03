package app.retroplayer.ui.navigation

import androidx.compose.animation.AnimatedContentTransitionScope.SlideDirection
import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeOut
import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.IntOffset
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost

private const val SLIDE_MS = 250
private const val PARALLAX_DIVISOR = 4

private val slide = tween<IntOffset>(SLIDE_MS, easing = FastOutSlowInEasing)

@Composable
fun RetroNavHost(nav: NavHostController) {
    NavHost(
        nav,
        nav.graph,
        enterTransition = { slideIntoContainer(SlideDirection.Start, slide) },
        exitTransition = {
            slideOutOfContainer(SlideDirection.Start, slide) { it / PARALLAX_DIVISOR } + fadeOut(tween(SLIDE_MS))
        },
        popEnterTransition = { slideIntoContainer(SlideDirection.End, slide) { it / PARALLAX_DIVISOR } },
        popExitTransition = { slideOutOfContainer(SlideDirection.End, slide) },
    )
}
