package app.retroplayer.ui.navigation

import androidx.activity.compose.BackHandler
import androidx.compose.runtime.Composable
import app.retroplayer.ui.player.LocalPlayerExpanded

/** UC-14: back at the library root stays in the app, unless the expanded player takes it first. */
@Composable
fun AbsorbBackAtRoot(isRoot: Boolean) {
    BackHandler(enabled = isRoot && !LocalPlayerExpanded.current) {}
}
