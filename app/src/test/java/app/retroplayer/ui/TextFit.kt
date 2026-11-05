package app.retroplayer.ui

import androidx.compose.ui.semantics.SemanticsActions
import androidx.compose.ui.semantics.SemanticsNode
import androidx.compose.ui.semantics.SemanticsProperties
import androidx.compose.ui.semantics.getOrNull
import androidx.compose.ui.test.SemanticsMatcher
import androidx.compose.ui.test.SemanticsNodeInteractionsProvider
import androidx.compose.ui.text.TextLayoutResult
import app.retroplayer.ui.components.MayEllipsizeKey
import com.google.common.truth.Truth.assertWithMessage
import org.junit.rules.ExternalResource
import org.robolectric.RuntimeEnvironment

/** Fails with every visible text that is cut or ellipsized, unless it is marked [MayEllipsizeKey]. */
fun SemanticsNodeInteractionsProvider.assertNoClippedText() {
    val clipped = onAllNodes(SemanticsMatcher.keyIsDefined(SemanticsActions.GetTextLayoutResult), useUnmergedTree = true)
        .fetchSemanticsNodes(atLeastOneRootRequired = true)
        .filter { it.layoutInfo.isPlaced && !it.mayEllipsize() }
        .mapNotNull { node ->
            node.cut()?.let { (node.config.getOrNull(SemanticsProperties.Text)?.joinToString() ?: "node ${node.id}") + " ($it)" }
        }
    assertWithMessage("texts that do not fit").that(clipped).isEmpty()
}

private fun SemanticsNode.cut(): String? {
    val results = mutableListOf<TextLayoutResult>()
    config[SemanticsActions.GetTextLayoutResult].action?.invoke(results)
    return results.firstNotNullOfOrNull { it.cut() }
}

/** `hasVisualOverflow` is unusable here: the semantics layout keeps the paragraph at the full max width. */
private fun TextLayoutResult.cut(): String? = when {
    didOverflowHeight && multiParagraph.height > size.height + 0.5f -> "taller than its box: ${multiParagraph.height} > ${size.height}"
    multiParagraph.didExceedMaxLines -> "more than $lineCount lines"
    else -> (0 until lineCount).firstNotNullOfOrNull { line ->
        val width = getLineRight(line) - getLineLeft(line)
        when {
            isLineEllipsized(line) -> "line $line ellipsized"
            // Unbounded texts (scrolling rows) cannot be cut sideways.
            layoutInput.constraints.hasBoundedWidth && width > size.width + 0.5f -> "line $line wider than its box: $width > ${size.width}"
            else -> null
        }
    }
}

private fun SemanticsNode.mayEllipsize(): Boolean =
    generateSequence(this) { it.parent }.any { MayEllipsizeKey in it.config }

/**
 * Applies Robolectric [qualifiers] and [fontScale] before the compose rule starts its activity;
 * chain it outside that rule.
 */
class DisplayRule(private val qualifiers: String, private val fontScale: Float) : ExternalResource() {
    override fun before() {
        RuntimeEnvironment.setQualifiers(qualifiers)
        RuntimeEnvironment.setFontScale(fontScale)
    }
}
