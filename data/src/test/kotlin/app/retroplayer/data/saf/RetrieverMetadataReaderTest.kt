package app.retroplayer.data.saf

import com.google.common.truth.Truth.assertThat
import org.junit.Test

class RetrieverMetadataReaderTest {
    @Test
    fun `track and disc numbers accept n and n of m forms`() {
        assertThat(RetrieverMetadataReader.leadingNumber("3")).isEqualTo(3)
        assertThat(RetrieverMetadataReader.leadingNumber("03/12")).isEqualTo(3)
        assertThat(RetrieverMetadataReader.leadingNumber(" 1 / 2 ")).isEqualTo(1)
        assertThat(RetrieverMetadataReader.leadingNumber("0")).isNull()
        assertThat(RetrieverMetadataReader.leadingNumber("abc")).isNull()
        assertThat(RetrieverMetadataReader.leadingNumber(null)).isNull()
    }

    @Test
    fun `year comes from a year or a date`() {
        assertThat(RetrieverMetadataReader.year("1999", null)).isEqualTo(1999)
        assertThat(RetrieverMetadataReader.year(null, "20240131T000000.000Z")).isEqualTo(2024)
        assertThat(RetrieverMetadataReader.year("0", null)).isNull()
    }
}
