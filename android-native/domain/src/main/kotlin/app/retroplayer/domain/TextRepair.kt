package app.retroplayer.domain

import java.nio.ByteBuffer
import java.nio.charset.CharacterCodingException
import java.nio.charset.Charset
import java.nio.charset.CodingErrorAction

/**
 * Repairs tag text that was decoded as Latin-1 but really was UTF-8 or
 * Windows-1250 (common for Slavic tags in ID3v2 frames labelled ISO-8859-1).
 */
object TextRepair {
    private val cp1250: Charset = Charset.forName("windows-1250")
    private const val CENTRAL_EUROPEAN =
        "ćčšžđĆČŠŽĐąęłńóśźżĄĘŁŃÓŚŹŻáéíóúýÁÉÍÓÚÝäöüÄÖÜřťďňľŘŤĎŇĽ"

    fun repair(value: String?): String? {
        if (value.isNullOrEmpty() || value.all { it.code < 0x80 }) return value
        if (value.any { it.code > 0xFF }) return value
        val bytes = value.toByteArray(Charsets.ISO_8859_1)

        if (bytes.any { (it.toInt() and 0xFF) in 0xC2..0xF4 }) {
            strictDecode(bytes, Charsets.UTF_8)?.let { if (it != value) return it }
        }
        val as1250 = strictDecode(bytes, cp1250)
        if (as1250 != null && as1250 != value && as1250.any { it in CENTRAL_EUROPEAN } && !looksLikeLatin1(value)) {
            return as1250
        }
        return value
    }

    /** Text that already reads as correct Western European (e.g. `Müller`) stays untouched. */
    private fun looksLikeLatin1(value: String): Boolean =
        value.all { it.code < 0x80 || it in "äöüÄÖÜßéèêáàâíìîóòôúùûçñÉÈÁÀÍÓÚÇÑ" }

    private fun strictDecode(bytes: ByteArray, charset: Charset): String? = try {
        charset.newDecoder()
            .onMalformedInput(CodingErrorAction.REPORT)
            .onUnmappableCharacter(CodingErrorAction.REPORT)
            .decode(ByteBuffer.wrap(bytes))
            .toString()
    } catch (_: CharacterCodingException) {
        null
    }
}
