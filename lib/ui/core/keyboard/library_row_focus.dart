import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:retroplayer/ui/core/keyboard/library_row_focus_registry.dart';
import 'package:retroplayer/ui/features/library/view_models/library_view_model.dart';

/// Tab order for one library row: body first, optional play control second.
class LibraryRowFocusGroup extends StatefulWidget {
  const LibraryRowFocusGroup({
    super.key,
    required this.rowIndex,
    required this.body,
    this.onPlayPressed,
    this.playTooltip,
  });

  final int rowIndex;
  final Widget body;
  final VoidCallback? onPlayPressed;
  final String? playTooltip;

  @override
  State<LibraryRowFocusGroup> createState() => _LibraryRowFocusGroupState();
}

class _LibraryRowFocusGroupState extends State<LibraryRowFocusGroup> {
  final _bodyFocusNode = FocusNode();
  final _playFocusNode = FocusNode();
  final _bodyKey = GlobalKey();
  int? _registeredIndex;
  Offset? _pointerDownPosition;

  /// Movement beyond this (logical px) counts as a scroll, not a row select.
  static const double _tapSlop = 18;

  @override
  void initState() {
    super.initState();
    _bodyFocusNode.addListener(_onBodyFocusChange);
    _playFocusNode.addListener(_onPlayFocusChange);
  }

  @override
  void didUpdateWidget(LibraryRowFocusGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rowIndex != widget.rowIndex) {
      _unregister();
      _registerIfNeeded();
    }
  }

  void _registerIfNeeded() {
    if (!mounted) return;
    final vm = context.read<LibraryViewModel>();
    if (vm.rowFocusRegistry == null) return;
    vm.rowFocusRegistry!.register(
      widget.rowIndex,
      LibraryRowFocusEntry(
        focusNode: _bodyFocusNode,
        contextGetter: () => _bodyKey.currentContext!,
      ),
    );
    _registeredIndex = widget.rowIndex;
  }

  void _unregister() {
    if (_registeredIndex == null || !mounted) return;
    try {
      context.read<LibraryViewModel>().rowFocusRegistry?.unregister(
            _registeredIndex!,
          );
    } on Object {
      // VM may be gone during teardown.
    }
    _registeredIndex = null;
  }

  void _onBodyFocusChange() {
    if (!_bodyFocusNode.hasFocus) return;
    context.read<LibraryViewModel>().selectKeyboardRowAt(widget.rowIndex);
  }

  void _onPlayFocusChange() {
    if (!_playFocusNode.hasFocus) return;
    context.read<LibraryViewModel>().selectKeyboardRowAt(widget.rowIndex);
  }

  void _onBodyPointerDown(PointerDownEvent event) {
    _pointerDownPosition = event.position;
  }

  void _onBodyPointerUp(PointerUpEvent event) {
    final down = _pointerDownPosition;
    _pointerDownPosition = null;
    if (down == null) return;
    if ((event.position - down).distance > _tapSlop) return;
    context.read<LibraryViewModel>().selectKeyboardRowFromPointer(
          widget.rowIndex,
        );
  }

  void _onBodyPointerCancel(PointerCancelEvent event) {
    _pointerDownPosition = null;
  }

  void _onPlayPointerSelect() {
    context.read<LibraryViewModel>().selectKeyboardRowAt(widget.rowIndex);
  }

  KeyEventResult _onPlayKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent || widget.onPlayPressed == null) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.space) {
      widget.onPlayPressed!();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  void dispose() {
    _bodyFocusNode.removeListener(_onBodyFocusChange);
    _playFocusNode.removeListener(_onPlayFocusChange);
    _unregister();
    _bodyFocusNode.dispose();
    _playFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _registerIfNeeded();

    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: FocusTraversalOrder(
              order: const NumericFocusOrder(1),
              child: Listener(
                // Select only on tap. Pointer-down selection steals focus and
                // ensureVisible-jumps the list when the user meant to scroll.
                onPointerDown: _onBodyPointerDown,
                onPointerUp: _onBodyPointerUp,
                onPointerCancel: _onBodyPointerCancel,
                child: Focus(
                  key: _bodyKey,
                  focusNode: _bodyFocusNode,
                  child: widget.body,
                ),
              ),
            ),
          ),
          if (widget.onPlayPressed != null)
            FocusTraversalOrder(
              order: const NumericFocusOrder(2),
              child: Listener(
                onPointerDown: (_) => _onPlayPointerSelect(),
                child: Focus(
                  key: const ValueKey('library_row_play_focus'),
                  focusNode: _playFocusNode,
                  onKeyEvent: _onPlayKey,
                  child: ExcludeFocus(
                    child: IconButton(
                      icon: const Icon(Icons.play_arrow_rounded),
                      tooltip: widget.playTooltip,
                      onPressed: widget.onPlayPressed,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Provides a shared [LibraryRowFocusRegistry] for library list rows.
class LibraryRowFocusScope extends StatefulWidget {
  const LibraryRowFocusScope({super.key, required this.child});

  final Widget child;

  @override
  State<LibraryRowFocusScope> createState() => _LibraryRowFocusScopeState();
}

class _LibraryRowFocusScopeState extends State<LibraryRowFocusScope> {
  late final LibraryRowFocusRegistry _registry;

  @override
  void initState() {
    super.initState();
    _registry = LibraryRowFocusRegistry();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<LibraryViewModel>().attachRowFocusRegistry(_registry);
    });
  }

  @override
  void dispose() {
    try {
      context.read<LibraryViewModel>().attachRowFocusRegistry(null);
    } on Object {
      // Provider may be gone.
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
