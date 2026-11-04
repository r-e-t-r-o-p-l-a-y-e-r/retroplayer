package app.retroplayer.domain

import app.retroplayer.domain.model.AlbumSortChoice
import app.retroplayer.domain.model.AlbumSortMode
import com.google.common.truth.Truth.assertThat
import org.junit.Test
import java.util.Locale

class AlbumOrderingTest {
    private val ordering = AlbumOrdering(NaturalOrder(Locale.ENGLISH))

    private val tagged = listOf(
        track("1/a/z.mp3", title = "Alpha", trackNumber = 2),
        track("1/a/y.mp3", title = "Beta", trackNumber = 1),
    )
    private val untagged = listOf(
        track("1/a/Chapter 10.mp3"),
        track("1/a/Chapter 9.mp3"),
        track("1/a/Chapter 1.mp3", trackNumber = 1),
    )

    private fun names(list: List<app.retroplayer.domain.model.AudioTrack>) = list.map { it.path.name }

    @Test
    fun `tags are usable when every track has a unique disc and track number`() {
        assertThat(ordering.tagsUsable(tagged)).isTrue()
        assertThat(ordering.tagsUsable(untagged)).isFalse()
        val duplicate = listOf(track("1/a/1.mp3", trackNumber = 1), track("1/a/2.mp3", trackNumber = 1))
        assertThat(ordering.tagsUsable(duplicate)).isFalse()
        val twoDiscs = listOf(
            track("1/a/1.mp3", trackNumber = 1, discNumber = 1),
            track("1/a/2.mp3", trackNumber = 1, discNumber = 2),
        )
        assertThat(ordering.tagsUsable(twoDiscs)).isTrue()
    }

    @Test
    fun `automatic uses tag order when tags are usable`() {
        assertThat(ordering.effectiveMode(tagged, AlbumSortChoice.AUTOMATIC)).isEqualTo(AlbumSortMode.TAG)
        assertThat(names(ordering.order(tagged, AlbumSortChoice.AUTOMATIC))).containsExactly("y.mp3", "z.mp3").inOrder()
    }

    @Test
    fun `automatic falls back to natural file name order for the whole album`() {
        assertThat(ordering.effectiveMode(untagged, AlbumSortChoice.AUTOMATIC)).isEqualTo(AlbumSortMode.FILE_NAME)
        assertThat(names(ordering.order(untagged, AlbumSortChoice.AUTOMATIC)))
            .containsExactly("Chapter 1.mp3", "Chapter 9.mp3", "Chapter 10.mp3").inOrder()
    }

    @Test
    fun `forced tag order puts untagged tracks after tagged ones by file name`() {
        assertThat(ordering.effectiveMode(untagged, AlbumSortChoice.TAG_FORCED)).isEqualTo(AlbumSortMode.TAG)
        assertThat(names(ordering.order(untagged, AlbumSortChoice.TAG_FORCED)))
            .containsExactly("Chapter 1.mp3", "Chapter 9.mp3", "Chapter 10.mp3").inOrder()
        val mixed = listOf(track("1/a/b.mp3"), track("1/a/a.mp3"), track("1/a/c.mp3", trackNumber = 1))
        assertThat(names(ordering.order(mixed, AlbumSortChoice.TAG_FORCED)))
            .containsExactly("c.mp3", "a.mp3", "b.mp3").inOrder()
    }

    @Test
    fun `file name and title modes`() {
        assertThat(names(ordering.order(tagged, AlbumSortChoice.FILE_NAME))).containsExactly("y.mp3", "z.mp3").inOrder()
        assertThat(names(ordering.order(tagged, AlbumSortChoice.TITLE))).containsExactly("z.mp3", "y.mp3").inOrder()
    }

    @Test
    fun `selecting tag order on usable tags stores the default`() {
        assertThat(ordering.select(AlbumSortMode.TAG, tagged)).isEqualTo(AlbumSortSelection.Store(AlbumSortChoice.AUTOMATIC))
    }

    @Test
    fun `selecting tag order on unusable tags asks for confirmation with the missing count`() {
        assertThat(ordering.select(AlbumSortMode.TAG, untagged)).isEqualTo(AlbumSortSelection.ConfirmTagOrder(missingTrackNumbers = 2))
        assertThat(AlbumSortSelection.ConfirmTagOrder(2).confirmed()).isEqualTo(AlbumSortSelection.Store(AlbumSortChoice.TAG_FORCED))
    }

    @Test
    fun `selecting file name stores the default when it is already the automatic order`() {
        assertThat(ordering.select(AlbumSortMode.FILE_NAME, untagged)).isEqualTo(AlbumSortSelection.Store(AlbumSortChoice.AUTOMATIC))
        assertThat(ordering.select(AlbumSortMode.FILE_NAME, tagged)).isEqualTo(AlbumSortSelection.Store(AlbumSortChoice.FILE_NAME))
        assertThat(ordering.select(AlbumSortMode.TITLE, tagged)).isEqualTo(AlbumSortSelection.Store(AlbumSortChoice.TITLE))
    }
}
