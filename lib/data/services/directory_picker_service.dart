import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:retroplayer/data/services/android_storage_paths.dart';

/// Opens a native folder picker.
///
/// Linux/macOS/Windows use [file_selector] (GTK/Cocoa/Win32 dialogs).
/// Mobile uses [file_picker] (iOS has no file_selector directory API).
class DirectoryPickerService {
  const DirectoryPickerService();

  /// Picks a library root folder.
  ///
  /// On Android, starts at primary shared storage when [initialDirectory] is
  /// omitted, so the dialog does not reopen in a previous playlist-pick path.
  Future<String?> pickDirectory({String? initialDirectory}) async {
    final start = initialDirectory ?? androidPrimaryStoragePath();
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      return getDirectoryPath(initialDirectory: initialDirectory);
    }
    return FilePicker.getDirectoryPath(
      initialDirectory: start,
    );
  }
}
