import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads the bundled Pretendard weights so captures render real Korean text.
Future<void> loadBsFonts() async {
  final loader = FontLoader('Pretendard');
  for (final weight in const [
    'Light',
    'Regular',
    'Medium',
    'SemiBold',
    'Bold',
    'ExtraBold'
  ]) {
    loader.addFont(rootBundle.load('assets/fonts/Pretendard-$weight.otf'));
  }
  await loader.load();
}

final _captureKey = GlobalKey();

/// Renders [app] like an iPhone 11 Pro (375×812pt @2x, 44pt status bar,
/// 34pt home indicator) and writes `build/ui_v2_shots/<name>.png` so it can be
/// compared with the Figma export in docs/디자인 (same 750×1624 size).
///
/// Call [setUpBsCapture] once in `setUpAll`.
Future<File> captureBsScreen(WidgetTester tester, Widget app, String name,
    {Future<void> Function()? beforeCapture}) async {
  tester.view.physicalSize = const Size(750, 1624);
  tester.view.devicePixelRatio = 2;
  tester.view.padding = const FakeViewPadding(top: 88, bottom: 68);
  tester.view.viewPadding = const FakeViewPadding(top: 88, bottom: 68);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(RepaintBoundary(key: _captureKey, child: app));
  await settleBsImages(tester);
  if (beforeCapture != null) {
    await beforeCapture();
    await settleBsImages(tester);
  }
  final boundary =
      tester.renderObject<RenderRepaintBoundary>(find.byKey(_captureKey));
  final bytes = await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 2);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  });
  final file = File('build/ui_v2_shots/$name.png')
    ..createSync(recursive: true)
    ..writeAsBytesSync(bytes!);
  return file;
}

/// Pumps frames and lets asset/SVG images decode outside the fake clock.
Future<void> settleBsImages(WidgetTester tester) async {
  for (var i = 0; i < 3; i++) {
    await tester.runAsync(() async {
      for (final element in find.byType(Image).evaluate()) {
        final widget = element.widget as Image;
        await precacheImage(widget.image, element, onError: (_, __) {});
      }
      await Future<void>.delayed(const Duration(milliseconds: 60));
    });
    await tester.pump(const Duration(milliseconds: 400));
  }
}

Future<void> setUpBsCapture() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await loadBsFonts();
}
