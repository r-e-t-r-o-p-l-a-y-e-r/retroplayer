package app.retroplayer.ui

import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.ui.test.junit4.createComposeRule
import app.retroplayer.ui.TextFitTest.Screen
import app.retroplayer.ui.settings.BuildInfo
import app.retroplayer.ui.settings.LocalBuildInfo
import app.retroplayer.ui.theme.RetroTheme
import com.github.takahirom.roborazzi.ExperimentalRoborazziApi
import com.github.takahirom.roborazzi.RoborazziOptions
import com.github.takahirom.roborazzi.captureScreenRoboImage
import org.junit.Rule
import org.junit.Test
import org.junit.rules.RuleChain
import org.junit.runner.RunWith
import org.robolectric.ParameterizedRobolectricTestRunner
import org.robolectric.annotation.GraphicsMode

/**
 * Golden images of the [TextFitTest] screens: every screen light and dark on a phone, the main
 * screens also on a tablet, in German, in the right-to-left pseudo-locale and at font scale 2.
 * Record with `./gradlew recordRoborazziDebug`, check with `verifyRoborazziDebug`.
 */
@RunWith(ParameterizedRobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
class ScreenshotTest(private val screen: Screen, private val variant: Variant) {
    private val compose = createComposeRule()

    @get:Rule val rules: RuleChain = RuleChain.outerRule(DisplayRule(variant.qualifiers(screen), variant.fontScale)).around(compose)

    @OptIn(ExperimentalRoborazziApi::class)
    @Test
    fun screenshot() {
        compose.setContent {
            CompositionLocalProvider(LocalBuildInfo provides FIXED_BUILD) { RetroTheme { screen.content() } }
        }
        compose.waitForIdle()
        screen.open(compose)
        compose.waitForIdle()
        captureScreenRoboImage("src/test/screenshots/${screen}_${variant}.png", OPTIONS)
    }

    enum class Variant(
        private val locale: String = "en",
        private val night: Boolean = false,
        private val tablet: Boolean = false,
        val fontScale: Float = 1f,
        val allScreens: Boolean = false,
    ) {
        LIGHT(allScreens = true),
        DARK(night = true, allScreens = true),
        TABLET(tablet = true),
        GERMAN(locale = "de"),
        RTL(locale = "ar-rXB"),
        FONT_2(fontScale = 2f),
        ;

        fun qualifiers(screen: Screen): String {
            val size = when {
                tablet -> "w1280dp-h800dp"
                screen.size == PHONE_TEXT_FIT -> "w360dp-h800dp"
                else -> screen.size
            }
            return "$locale-$size" + if (night) "-night" else ""
        }

        override fun toString() = name.lowercase()
    }

    companion object {
        private const val PHONE_TEXT_FIT = "w320dp-h640dp"

        /** Show the build time and commit, so they would change with every build. */
        private val UNSTABLE = setOf(Screen.ABOUT)

        private val MAIN = setOf(
            Screen.LIBRARY, Screen.FOLDER, Screen.ALBUM, Screen.QUEUE, Screen.PLAYLIST,
            Screen.SETTINGS, Screen.PLAYER, Screen.MINI_PLAYER, Screen.PLAYER_CHAPTERS,
        )

        /** A getter: [RoborazziOptions] needs the Robolectric sandbox, which parameter collection runs outside of. */
        private val OPTIONS get() = RoborazziOptions(
            compareOptions = RoborazziOptions.CompareOptions(changeThreshold = 0.001f),
        )

        private val FIXED_BUILD = BuildInfo(version = "0.9.0", buildTime = "2026-01-01 12:00:00", commit = "000000000000", donationLink = true)

        @JvmStatic
        @ParameterizedRobolectricTestRunner.Parameters(name = "{0} {1}")
        fun cases(): List<Array<Any>> = Variant.entries.flatMap { variant ->
            Screen.entries
                .filter { it !in UNSTABLE && (variant.allScreens || it in MAIN) }
                .map { arrayOf(it, variant) }
        }
    }
}
