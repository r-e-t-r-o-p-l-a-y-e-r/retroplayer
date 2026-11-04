package app.retroplayer.domain

import java.text.Collator
import java.util.Locale

/**
 * Orders names the way people read them: case and accent insensitive, locale
 * aware, and digit runs compared by numeric value (`2 < 10`, `CD9 < CD10`).
 * Ties are broken by exact spelling so the order is total.
 */
class NaturalOrder(locale: Locale = Locale.getDefault()) : Comparator<String> {
    private val primary: Collator = Collator.getInstance(locale).apply { strength = Collator.PRIMARY }
    private val tertiary: Collator = Collator.getInstance(locale).apply { strength = Collator.TERTIARY }

    override fun compare(a: String, b: String): Int {
        val left = chunks(a)
        val right = chunks(b)
        for (i in 0 until minOf(left.size, right.size)) {
            val x = left[i]
            val y = right[i]
            val cmp = if (x.isDigits && y.isDigits) compareNumbers(x.text, y.text) else primary.compare(x.text, y.text)
            if (cmp != 0) return cmp
        }
        if (left.size != right.size) return left.size.compareTo(right.size)
        val accentsAndCase = tertiary.compare(a, b)
        return if (accentsAndCase != 0) accentsAndCase else a.compareTo(b)
    }

    private fun compareNumbers(x: String, y: String): Int {
        val a = x.trimStart('0')
        val b = y.trimStart('0')
        if (a.length != b.length) return a.length.compareTo(b.length)
        val cmp = a.compareTo(b)
        return if (cmp != 0) cmp else x.length.compareTo(y.length)
    }

    private class Chunk(val text: String, val isDigits: Boolean)

    private fun chunks(s: String): List<Chunk> {
        val out = ArrayList<Chunk>()
        var start = 0
        while (start < s.length) {
            val digits = s[start].isAsciiDigit()
            var end = start + 1
            while (end < s.length && s[end].isAsciiDigit() == digits) end++
            out += Chunk(s.substring(start, end), digits)
            start = end
        }
        return out
    }

    private fun Char.isAsciiDigit() = this in '0'..'9'
}
