import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/ui/features/player/view_models/player_panel_view_model.dart';
import 'package:retroplayer/ui/features/player/view_models/sheet_animator.dart';

void main() {
  test('expand and collapse without a sheet just flip the flag', () async {
    final vm = PlayerPanelViewModel(animator: const JumpSheetAnimator());
    expect(vm.isExpanded, isFalse);
    await vm.expand();
    expect(vm.isExpanded, isTrue);
    await vm.collapse();
    expect(vm.isExpanded, isFalse);
  });

  test('syncFromExtent follows the sheet past the midpoint', () {
    final vm = PlayerPanelViewModel(animator: const JumpSheetAnimator());
    vm.bindSheet(null, minChildSize: 0.2);
    vm.syncFromExtent(0.2);
    expect(vm.isExpanded, isFalse);
    vm.syncFromExtent(0.7);
    expect(vm.isExpanded, isTrue);
    vm.syncFromExtent(0.2);
    expect(vm.isExpanded, isFalse);
  });

  test('scrubSheet is a no-op without an attached sheet', () {
    final vm = PlayerPanelViewModel(animator: const JumpSheetAnimator());
    vm.bindSheet(null, minChildSize: 0.2);
    vm.scrubSheet(0.5);
    expect(vm.isExpanded, isFalse);
  });

  test('persist callback runs when isExpanded changes via syncFromExtent', () {
    var persisted = <bool>[];
    final vm = PlayerPanelViewModel(
      animator: const JumpSheetAnimator(),
      onPersistExpanded: (v) async => persisted.add(v),
    );
    vm.bindSheet(null, minChildSize: 0.2);
    vm.syncFromExtent(0.7);
    expect(persisted, [true]);
    vm.syncFromExtent(0.2);
    expect(persisted, [true, false]);
  });

  test('persist callback skipped while extent sync suppressed', () async {
    var persisted = <bool>[];
    final vm = PlayerPanelViewModel(
      animator: const JumpSheetAnimator(),
      onPersistExpanded: (v) async => persisted.add(v),
      canPersistExpanded: () => false,
    );
    vm.bindSheet(null, minChildSize: 0.2);
    await vm.expand();
    vm.scrubSheet(0.9);
    vm.syncFromExtent(0.2);
    expect(persisted, isEmpty);
    await vm.collapse();
    expect(persisted, [false]);
  });

  test('persist true skipped when hasSession is false', () {
    var persisted = <bool>[];
    final vm = PlayerPanelViewModel(
      animator: const JumpSheetAnimator(),
      onPersistExpanded: (v) async => persisted.add(v),
      canPersistExpanded: () => false,
    );
    vm.bindSheet(null, minChildSize: 0.2);
    vm.syncFromExtent(0.7);
    expect(persisted, isEmpty);
    vm.syncFromExtent(0.2);
    expect(persisted, [false]);
  });

  test('scrubSheet ignores extent ticks until collapse', () async {
    final vm = PlayerPanelViewModel(animator: const JumpSheetAnimator());
    vm.bindSheet(null, minChildSize: 0.2);
    await vm.expand();
    expect(vm.isExpanded, isTrue);

    vm.scrubSheet(0.9);
    vm.syncFromExtent(0.2);
    expect(vm.isExpanded, isTrue);

    await vm.collapse();
    expect(vm.isExpanded, isFalse);
    vm.syncFromExtent(0.7);
    expect(vm.isExpanded, isTrue);
  });

  test('snapCollapsedForNavigation sets collapsed flag and extent', () {
    final vm = PlayerPanelViewModel(animator: const JumpSheetAnimator());
    vm.bindSheet(null, minChildSize: 0.2);
    vm.syncFromExtent(1.0);
    expect(vm.isExpanded, isTrue);

    vm.snapCollapsedForNavigation();
    expect(vm.isExpanded, isFalse);
    expect(vm.appBarChromeT, lessThan(0.5));
  });

  test('unbindSheet ignores a controller that is not the bound one', () {
    final vm = PlayerPanelViewModel(animator: const JumpSheetAnimator());
    final kept = _FakeSheet();
    final other = _FakeSheet();
    vm.bindSheet(kept);
    vm.unbindSheet(other);
    expect(vm.isExpanded, isFalse);
    // The bound controller is still there: expand with an unattached sheet
    // falls through to the flag.
    vm.expand();
    expect(vm.isExpanded, isTrue);
  });
}

class _FakeSheet extends DraggableScrollableController {}
