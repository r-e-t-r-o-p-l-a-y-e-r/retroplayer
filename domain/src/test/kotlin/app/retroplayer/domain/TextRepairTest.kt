package app.retroplayer.domain

import com.google.common.truth.Truth.assertThat
import org.junit.Test
import java.nio.charset.Charset

class TextRepairTest {
    private val latin1 = Charsets.ISO_8859_1
    private val cp1250 = Charset.forName("windows-1250")

    @Test
    fun `recovers UTF-8 bytes that were decoded as Latin-1`() {
        val original = "Kuća i šuma — čaj"
        val misread = String(original.toByteArray(Charsets.UTF_8), latin1)
        assertThat(misread).isNotEqualTo(original)
        assertThat(TextRepair.repair(misread)).isEqualTo(original)
    }

    @Test
    fun `recovers Windows-1250 bytes that were decoded as Latin-1`() {
        val original = "Đorđe i Željko ćevapčići"
        val misread = String(original.toByteArray(cp1250), latin1)
        assertThat(misread).isNotEqualTo(original)
        assertThat(TextRepair.repair(misread)).isEqualTo(original)
    }

    @Test
    fun `leaves correct text unchanged`() {
        assertThat(TextRepair.repair("Pravilno: ćčšžđ")).isEqualTo("Pravilno: ćčšžđ")
        assertThat(TextRepair.repair("Hello Album")).isEqualTo("Hello Album")
        assertThat(TextRepair.repair("Müller")).isEqualTo("Müller")
        assertThat(TextRepair.repair("")).isEqualTo("")
        assertThat(TextRepair.repair(null)).isNull()
    }
}
