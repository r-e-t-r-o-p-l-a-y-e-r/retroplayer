package app.retroplayer.data.db

import androidx.room.testing.MigrationTestHelper
import androidx.test.platform.app.InstrumentationRegistry
import com.google.common.truth.Truth.assertThat
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class RetroDatabaseMigrationTest {
    @get:Rule
    val helper = MigrationTestHelper(InstrumentationRegistry.getInstrumentation(), RetroDatabase::class.java)

    @Test
    fun `version 2 keeps existing roots in the order they were added`() {
        helper.createDatabase(NAME, 1).use { db ->
            db.execSQL("INSERT INTO library_roots (id, treeUri, name, canWrite, addedAt) VALUES (1, 'content://t/b', 'Books', 0, 20)")
            db.execSQL("INSERT INTO library_roots (id, treeUri, name, canWrite, addedAt) VALUES (2, 'content://t/a', 'Music', 0, 10)")
        }
        helper.runMigrationsAndValidate(NAME, 2, true).use { db ->
            db.query("SELECT id FROM library_roots ORDER BY position, addedAt, id").use { cursor ->
                val ids = buildList { while (cursor.moveToNext()) add(cursor.getLong(0)) }
                assertThat(ids).containsExactly(2L, 1L).inOrder()
            }
        }
    }

    private companion object {
        const val NAME = "migration-test.db"
    }
}
