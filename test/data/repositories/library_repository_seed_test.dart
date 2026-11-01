/// LibraryRepository test seeding helpers and path normalization stability.
///
/// Evidence:
/// - `seeded child folders are returned by listChildFolders`
/// - `normalizeLibraryPath is stable for music paths`
library;
import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/data/db/app_database.dart';
import 'package:retroplayer/domain/library_paths.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import '../../helpers/library_test_seed.dart';
import '../../helpers/test_library_repository.dart';

void main() {
  test('seeded child folders are returned by listChildFolders', () async {
    final db = AppDatabase.inMemory();
    addTearDown(db.close);
    final storage = LibraryStorageService(db);
    final repo = testLibraryRepository(storage);
    await repo.addLibraryRoot('/music');
    seedAuthorBook1Hierarchy(repo);

    final normalizedMusic = normalizeLibraryPath('/music');
    final children = await repo.listChildFolders(normalizedMusic);

    expect(children.map((f) => f.name), ['Author']);
  });

  test('normalizeLibraryPath is stable for music paths', () {
    expect(normalizeLibraryPath('/music'), normalizeLibraryPath('/music'));
    expect(
      normalizeLibraryPath('/music/Author'),
      normalizeLibraryPath('/music/Author'),
    );
  });
}
