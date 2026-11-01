import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retroplayer/data/services/directory_picker_service.dart';
import 'package:retroplayer/data/services/permission_service.dart';
import 'package:retroplayer/l10n/app_localizations.dart';
import 'package:retroplayer/ui/features/library/view_models/library_view_model.dart';

/// Storage permission and the native folder dialog used to add a library
/// root. Provide a subclass to replace both in tests.
class LibraryFolderPicker {
  const LibraryFolderPicker();

  Future<bool> requestAccess() => PermissionService().requestLibraryAccess();

  Future<String?> pickFolder() =>
      const DirectoryPickerService().pickDirectory();
}

/// Asks for storage access, lets the user pick a folder and adds it as a
/// library root.
Future<void> addLibraryFolder(BuildContext context) async {
  final picker = _providedPicker(context) ?? const LibraryFolderPicker();
  final library = context.read<LibraryViewModel>();
  final messenger = ScaffoldMessenger.maybeOf(context);
  final l10n = AppLocalizations.of(context);

  if (!await picker.requestAccess()) {
    messenger?.showSnackBar(
      SnackBar(content: Text(l10n.audioPermissionRequired)),
    );
    return;
  }
  final path = await picker.pickFolder();
  if (path != null) await library.addLibraryRoot(path);
}

LibraryFolderPicker? _providedPicker(BuildContext context) {
  try {
    return context.read<LibraryFolderPicker>();
  } on ProviderNotFoundException {
    return null;
  }
}
