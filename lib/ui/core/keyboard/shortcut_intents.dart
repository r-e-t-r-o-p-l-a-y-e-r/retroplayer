import 'package:flutter/widgets.dart';

class TogglePlayPauseIntent extends Intent {
  const TogglePlayPauseIntent();
}

class SkipPreviousIntent extends Intent {
  const SkipPreviousIntent();
}

class SkipNextIntent extends Intent {
  const SkipNextIntent();
}

class SeekBackwardIntent extends Intent {
  const SeekBackwardIntent();
}

class SeekForwardIntent extends Intent {
  const SeekForwardIntent();
}

class ExpandPlayerIntent extends Intent {
  const ExpandPlayerIntent();
}

class CollapsePlayerIntent extends Intent {
  const CollapsePlayerIntent();
}

class AddFolderIntent extends Intent {
  const AddFolderIntent();
}

class CreatePlaylistIntent extends Intent {
  const CreatePlaylistIntent();
}

class OpenSettingsIntent extends Intent {
  const OpenSettingsIntent();
}

class EscapeNavigationIntent extends Intent {
  const EscapeNavigationIntent();
}

class MoveSelectionIntent extends Intent {
  const MoveSelectionIntent(this.delta);
  final int delta;
}

class SelectFirstIntent extends Intent {
  const SelectFirstIntent();
}

class SelectLastIntent extends Intent {
  const SelectLastIntent();
}

class ActivateSelectionIntent extends Intent {
  const ActivateSelectionIntent();
}

class PlaySelectionIntent extends Intent {
  const PlaySelectionIntent();
}

class DeleteSelectionIntent extends Intent {
  const DeleteSelectionIntent();
}

class NavigateParentIntent extends Intent {
  const NavigateParentIntent();
}

class SavePlaylistIntent extends Intent {
  const SavePlaylistIntent();
}

class MoveSettingsLineIntent extends Intent {
  const MoveSettingsLineIntent(this.delta);
  final int delta;
}
