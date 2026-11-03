package app.retroplayer.ui.settings

import android.content.Context
import app.retroplayer.R
import java.util.Locale
import org.xmlpull.v1.XmlPullParser

/** Locale tags from [R.xml.locales_config], excluding the default `en` duplicate handling. */
fun localeTagsFromConfig(context: Context): List<String> {
    val tags = mutableListOf<String>()
    val parser = context.resources.getXml(R.xml.locales_config)
    var event = parser.eventType
    while (event != XmlPullParser.END_DOCUMENT) {
        if (event == XmlPullParser.START_TAG && parser.name == "locale") {
            parser.getAttributeValue(null, "name")?.takeIf { it.isNotEmpty() }?.let(tags::add)
        }
        event = parser.next()
    }
    return tags.distinct()
}

fun displayNameForLocaleTag(tag: String): String {
    val locale = Locale.forLanguageTag(tag)
    return locale.getDisplayName(locale).replaceFirstChar { if (it.isLowerCase()) it.titlecase(locale) else it.toString() }
}
