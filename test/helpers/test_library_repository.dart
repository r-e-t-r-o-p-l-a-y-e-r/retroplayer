import 'package:retroplayer/application/ports/library_scanner.dart';
import 'package:retroplayer/data/repositories/library_repository.dart';
import 'package:retroplayer/data/services/file_scan_service.dart';
import 'package:retroplayer/data/services/library_storage_service.dart';
import 'package:retroplayer/domain/use_cases/sort_library.dart';

LibraryRepository testLibraryRepository(LibraryStorageService storage) =>
    createLibraryRepository(storage);

LibraryRepository testLibraryRepositoryWithScanner(
  LibraryStorageService storage,
  LibraryScanner scanLibrary,
) {
  final fileScan = FileScanService();
  return LibraryRepository(
    storageService: storage,
    scanLibrary: scanLibrary,
    sortLibrary: SortLibrary(),
    fileScanService: fileScan,
  );
}
