import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:retroplayer/ui/core/main_shell_view.dart';

RenderRepaintBoundary _repaintBoundary(RenderObject object) {
  RenderObject? current = object;
  while (current != null) {
    if (current is RenderRepaintBoundary) return current;
    current = current.parent;
  }
  throw TestFailure('No RepaintBoundary ancestor for capture');
}

Future<Uint8List> _blurRegionInPng(
  Uint8List png,
  Rect regionPx, {
  double sigma = 8,
}) async {
  final codec = await ui.instantiateImageCodec(png);
  final frame = await codec.getNextFrame();
  final image = frame.image;
  final padded = regionPx.inflate(6);
  final clip = padded.intersect(
    Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
  );
  if (clip.isEmpty) return png;

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawImage(image, Offset.zero, Paint());
  canvas.saveLayer(clip, Paint()..imageFilter = ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma));
  canvas.clipRect(clip);
  canvas.drawImage(image, Offset.zero, Paint());
  canvas.restore();

  final picture = recorder.endRecording();
  final out = await picture.toImage(image.width, image.height);
  image.dispose();
  final data = await out.toByteData(format: ui.ImageByteFormat.png);
  out.dispose();
  if (data == null) return png;
  return data.buffer.asUint8List();
}

Rect _finderRectInBoundary(
  WidgetTester tester,
  Finder widget,
  Finder boundary,
  double pixelRatio,
) {
  final widgetRect = tester.getRect(widget);
  final boundaryRect = tester.getRect(boundary);
  final local = widgetRect.shift(-boundaryRect.topLeft);
  return Rect.fromLTWH(
    local.left * pixelRatio,
    local.top * pixelRatio,
    local.width * pixelRatio,
    local.height * pixelRatio,
  );
}

/// Writes a PNG under [projectRoot]/doc/images/tutorial/ and test goldens.
Future<void> captureTutorialFrame(
  WidgetTester tester,
  String baseName, {
  Finder? finder,
  List<Finder> blurInCapture = const [],
}) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 200));
  tester.takeException(); // ignore layout overflow in phone fixture

  final target = finder ?? find.byType(MainShellView);
  if (target.evaluate().isEmpty) {
    throw TestFailure('No widget to capture for $baseName');
  }

  final boundary = _repaintBoundary(tester.renderObject(target));

  await tester.binding.runAsync(() async {
    final ratio = tester.view.devicePixelRatio;
    final image = await boundary.toImage(pixelRatio: ratio);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) {
      throw TestFailure('Failed to encode PNG for $baseName');
    }
    var png = bytes.buffer.asUint8List();
    for (final blurFinder in blurInCapture) {
      if (blurFinder.evaluate().isEmpty) continue;
      png = await _blurRegionInPng(
        png,
        _finderRectInBoundary(tester, blurFinder, target, ratio),
      );
    }

    final root = Directory.current.path;
    final docDir = p.join(root, 'doc', 'images', 'tutorial');
    final goldenDir = p.join(root, 'test', 'ui', 'doc', 'goldens');
    await Directory(docDir).create(recursive: true);
    await Directory(goldenDir).create(recursive: true);

    final fileName = '$baseName.png';
    await File(p.join(docDir, fileName)).writeAsBytes(png);
    await File(p.join(goldenDir, fileName)).writeAsBytes(png);
  });
}

/// Theme for PNG capture: Roboto only (no Noto fallbacks that are absent in tests).
ThemeData tutorialScreenshotTheme(ThemeData base) {
  final textTheme = base.textTheme.apply(
    fontFamily: 'Roboto',
    fontFamilyFallback: const <String>[],
  );
  return base.copyWith(
    textTheme: textTheme,
    primaryTextTheme: textTheme,
  );
}
