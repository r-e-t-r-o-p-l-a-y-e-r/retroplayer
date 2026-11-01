import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'pump_app.dart';

/// Sends an Android edge swipe the way the engine does: as a predictive back
/// gesture (start, progress, commit) on [SystemChannels.backGesture].
///
/// Unlike [WidgetsBinding.handlePopRoute], this lets a route with a predictive
/// transition pop itself, so it exercises the same path as a real device.
Future<void> sendSystemBackGesture(
  WidgetTester tester, {
  int settleFrames = 12,
}) async {
  Future<void> send(String method, [Object? args]) async {
    await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
      SystemChannels.backGesture.name,
      SystemChannels.backGesture.codec.encodeMethodCall(
        MethodCall(method, args),
      ),
      (_) {},
    );
  }

  const event = <String, Object?>{
    'touchOffset': <double>[0, 400],
    'progress': 0.0,
    'swipeEdge': 0,
  };
  await send('startBackGesture', event);
  await tester.pump();
  await send('updateBackGestureProgress', {...event, 'progress': 0.5});
  await tester.pump();
  await send('commitBackGesture');
  await pumpFrames(tester, count: settleFrames);
}

/// Records every value the app sends via `SystemNavigator.setFrameworkHandlesBack`.
///
/// If the last value is ever `false`, Android plays its own "leave app"
/// animation on the next edge swipe and Flutter never sees it. Also marks the
/// app resumed, since Flutter skips these updates while the lifecycle is unknown.
List<bool> recordFrameworkHandlesBack(WidgetTester tester) {
  final calls = <bool>[];
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      if (call.method == 'SystemNavigator.setFrameworkHandlesBack') {
        calls.add(call.arguments as bool);
      }
      return null;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    ),
  );
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  return calls;
}

/// Pumps until [condition] holds, failing after [timeout] of fake time.
Future<void> pumpUntil(
  WidgetTester tester,
  bool Function() condition, {
  Duration timeout = const Duration(seconds: 5),
  Duration step = const Duration(milliseconds: 50),
  String? reason,
}) async {
  var elapsed = Duration.zero;
  await tester.pump();
  while (!condition()) {
    if (elapsed >= timeout) {
      fail(reason ?? 'condition not met within $timeout');
    }
    await tester.pump(step);
    elapsed += step;
  }
}
