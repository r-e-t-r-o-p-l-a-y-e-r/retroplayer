/// runLinuxPlaybackStartup step order: configure, teardown, then media_kit init.
///
/// Evidence:
/// - `runs configure, teardown, then init in order`
library;
import 'package:flutter_test/flutter_test.dart';
import 'package:retroplayer/data/services/linux_playback_startup.dart';

void main() {
  group('runLinuxPlaybackStartup', () {
    test('runs configure, teardown, then init in order', () async {
      final order = <String>[];

      await runLinuxPlaybackStartup(
        configureEnvironment: () async => order.add('configure'),
        teardownStaleMpv: () async => order.add('teardown'),
        ensureMediaKit: () => order.add('init'),
      );

      expect(order, ['configure', 'teardown', 'init']);
    });
  });
}
