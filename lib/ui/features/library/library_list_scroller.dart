import 'package:flutter/widgets.dart';
import 'package:retroplayer/ui/features/library/library_index_labels.dart';

/// [ScrollController] that can open a new list at a remembered offset.
///
/// Used when the library [CustomScrollView] is keyed by browse path so the
/// first paint of the parent folder is already at the saved offset instead of
/// scrolling there from the top.
class RestoringScrollController extends ScrollController {
  RestoringScrollController() : super(keepScrollOffset: false);

  double? pendingInitialOffset;

  @override
  ScrollPosition createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition? _,
  ) {
    final pending = pendingInitialOffset;
    pendingInitialOffset = null;
    return ScrollPositionWithSingleContext(
      physics: physics,
      context: context,
      // Drop the previous path's pixels so browse-up does not inherit 0
      // from the child list and then jump.
      oldPosition: null,
      initialPixels: pending ?? 0.0,
      keepScrollOffset: false,
    );
  }
}

/// Scrolls the folder-mode library [CustomScrollView] to a selectable row.
class LibraryListScroller {
  ScrollController? controller;

  int folderCount = 0;
  int playlistCount = 0;
  int audioCount = 0;

  int get totalRows => folderCount + playlistCount + audioCount;

  /// Current pixels scrolled, or null when the controller has no clients.
  double? get currentOffset {
    final scrollController = controller;
    if (scrollController == null || !scrollController.hasClients) return null;
    return scrollController.offset;
  }

  void updateCounts({
    required int folders,
    required int playlists,
    required int audio,
  }) {
    folderCount = folders;
    playlistCount = playlists;
    audioCount = audio;
  }

  /// Remember [offset] for the next scroll-position attach (browse-up).
  void prepareRestore(double offset) {
    final scrollController = controller;
    if (scrollController is RestoringScrollController) {
      scrollController.pendingInitialOffset = offset;
    }
  }

  /// Restore a previously captured scroll offset (parent browse-up).
  ///
  /// Does not snap to a row alignment — keeps the list where it was when the
  /// user entered a child folder.
  void jumpToOffset(double offset) {
    prepareRestore(offset);
    final scrollController = controller;
    if (scrollController == null || !scrollController.hasClients) return;
    final max = scrollController.position.maxScrollExtent;
    scrollController.jumpTo(offset.clamp(0.0, max));
  }

  /// Jump so [rowIndex] is near [alignment] in the viewport.
  ///
  /// Prefers a fraction of [ScrollPosition.maxScrollExtent] (accurate when rows
  /// are similar height) and falls back to a structural estimate.
  void jumpToRow(int rowIndex, {double alignment = 0.15}) {
    final scrollController = controller;
    if (scrollController == null || !scrollController.hasClients) return;
    if (rowIndex < 0) return;

    final position = scrollController.position;
    final max = position.maxScrollExtent;
    final viewport = position.viewportDimension;
    if (max <= 0) return;

    final rows = totalRows;
    late final double estimated;
    if (rows > 0) {
      // Map row index onto the real scroll range — far more reliable than a
      // fixed pixel guess once section headers / dense tiles vary.
      final fraction = (rowIndex / rows).clamp(0.0, 1.0);
      estimated = fraction * max;
    } else {
      estimated = estimateLibraryRowScrollOffset(
        rowIndex: rowIndex,
        folderCount: folderCount,
        playlistCount: playlistCount,
        audioCount: audioCount,
      );
    }

    final target = (estimated - viewport * alignment).clamp(0.0, max);
    scrollController.jumpTo(target);
  }
}
