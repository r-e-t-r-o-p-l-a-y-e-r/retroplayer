import 'package:flutter/material.dart';
import 'package:retroplayer/l10n/app_localizations.dart';
import 'package:retroplayer/ui/features/library/widgets/folder_favorite_swipe.dart';

/// Asks the user to confirm removing a library root folder from the app.
///
/// Returns `true` only when the user taps Remove. Files on disk are not deleted.
Future<bool> confirmRemoveLibraryRoot(
  BuildContext context, {
  required String path,
  String? displayName,
}) async {
  final l10n = AppLocalizations.of(context);
  final name = displayName ?? path;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.removeLibraryFolderTitle),
      content: Text(l10n.removeLibraryFolderBody(name)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(l10n.remove),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

/// Asks the user to confirm deleting a playlist file from disk.
Future<bool> confirmDeletePlaylist(
  BuildContext context, {
  required String displayName,
}) async {
  final l10n = AppLocalizations.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.deletePlaylistTitle),
      content: Text(l10n.deletePlaylistBody(displayName)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(l10n.remove),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

/// Swipe-left-to-remove wrapper for a top-level library root source row.
class LibraryRootDismissible extends StatelessWidget {
  const LibraryRootDismissible({
    super.key,
    required this.path,
    required this.displayName,
    required this.onRemove,
    required this.child,
  });

  final String path;
  final String displayName;
  final Future<void> Function() onRemove;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Dismissible(
      key: ValueKey(path),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => confirmRemoveLibraryRoot(
        context,
        path: path,
        displayName: displayName,
      ),
      onDismissed: (_) => onRemove(),
      background: _RemoveDismissBackground(
        color: Theme.of(context).colorScheme.errorContainer,
        iconColor: Theme.of(context).colorScheme.onErrorContainer,
        label: l10n.remove,
      ),
      child: child,
    );
  }
}

/// Swipe-left-to-delete wrapper for a playlist file row.
class PlaylistDismissible extends StatelessWidget {
  const PlaylistDismissible({
    super.key,
    required this.playlistPath,
    required this.displayName,
    required this.onDelete,
    required this.child,
  });

  final String playlistPath;
  final String displayName;
  final Future<void> Function() onDelete;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Dismissible(
      key: ValueKey(playlistPath),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) =>
          confirmDeletePlaylist(context, displayName: displayName),
      onDismissed: (_) => onDelete(),
      background: _RemoveDismissBackground(
        color: Theme.of(context).colorScheme.errorContainer,
        iconColor: Theme.of(context).colorScheme.onErrorContainer,
        label: l10n.remove,
      ),
      child: child,
    );
  }
}

/// Swipe-right toggle for marking or clearing a folder favorite.
///
/// The row stays in place. [confirmDismiss] returns false after the toggle.
class FolderFavoriteDismissible extends StatelessWidget {
  const FolderFavoriteDismissible({
    super.key,
    required this.path,
    required this.isFavorite,
    required this.onToggle,
    required this.child,
  });

  final String path;
  final bool isFavorite;
  final Future<void> Function() onToggle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FolderFavoriteSwipe(
      key: ValueKey('favorite:$path'),
      isFavorite: isFavorite,
      onToggle: onToggle,
      child: child,
    );
  }
}

class _RemoveDismissBackground extends StatelessWidget {
  const _RemoveDismissBackground({
    required this.color,
    required this.iconColor,
    required this.label,
  });

  final Color color;
  final Color iconColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      color: color,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(Icons.delete_outline, color: iconColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(color: iconColor, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
