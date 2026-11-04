package app.retroplayer.ui.navigation

import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.lifecycle.compose.LocalLifecycleOwner
import androidx.lifecycle.viewmodel.compose.LocalViewModelStoreOwner
import androidx.navigation.NavGraphBuilder
import androidx.navigation.NavHostController
import androidx.navigation.compose.rememberNavController
import androidx.navigation.createGraph

/**
 * A nav controller whose back stack is [routes] (library root first) before
 * anything composes, so only the top page is ever shown on a cold start (UC-01)
 * and back walks up the chain. On recreation the saved back stack wins.
 */
@Composable
fun rememberRestoredNavController(routes: List<Any>, builder: NavGraphBuilder.() -> Unit): NavHostController {
    val nav = rememberNavController()
    val lifecycleOwner = LocalLifecycleOwner.current
    val viewModelStore = checkNotNull(LocalViewModelStoreOwner.current) { "needs a ViewModelStoreOwner" }.viewModelStore
    val rebuilt = rememberSaveable { BooleanArray(1) }
    return remember(nav) {
        nav.setLifecycleOwner(lifecycleOwner)
        nav.setViewModelStore(viewModelStore)
        nav.graph = nav.createGraph(startDestination = FolderRoute(), builder = builder)
        if (!rebuilt[0]) {
            rebuilt[0] = true
            routes.drop(1).forEach { nav.navigate(it) }
        }
        nav
    }
}
