package app.retroplayer.domain

import com.google.common.truth.Truth.assertThat
import org.junit.Test
import java.util.Locale

class NaturalOrderTest {
    private val order = NaturalOrder(Locale.ENGLISH)

    private fun sorted(vararg names: String) = names.sortedWith(order)

    @Test
    fun `numbers compare by value not by characters`() {
        assertThat(sorted("Track 10", "Track 2", "Track 1"))
            .containsExactly("Track 1", "Track 2", "Track 10").inOrder()
        assertThat(sorted("CD10", "CD9", "CD1"))
            .containsExactly("CD1", "CD9", "CD10").inOrder()
    }

    @Test
    fun `case is ignored`() {
        assertThat(sorted("beta", "Alpha", "alpha2"))
            .containsExactly("Alpha", "alpha2", "beta").inOrder()
    }

    @Test
    fun `accents sort next to their base letter`() {
        assertThat(sorted("Zebra", "Élan", "Echo"))
            .containsExactly("Echo", "Élan", "Zebra").inOrder()
    }

    @Test
    fun `leading zeros do not change value order`() {
        assertThat(sorted("010 c", "2 b", "001 a"))
            .containsExactly("001 a", "2 b", "010 c").inOrder()
    }

    @Test
    fun `order is total and deterministic for equal looking names`() {
        assertThat(order.compare("a", "A")).isNotEqualTo(0)
        assertThat(order.compare("01", "1")).isNotEqualTo(0)
        assertThat(order.compare("same", "same")).isEqualTo(0)
    }

    @Test
    fun `very long digit runs do not overflow`() {
        assertThat(sorted("x 99999999999999999999999", "x 100000000000000000000000"))
            .containsExactly("x 99999999999999999999999", "x 100000000000000000000000").inOrder()
    }
}
