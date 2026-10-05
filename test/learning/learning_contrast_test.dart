import 'package:bookstar/modules/learning/view/learning_design.dart';
import 'package:bookstar/modules/learning/view/bs_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Do not round before comparing. These opaque-color checks also cover text
  // whose complete card semantics label cannot be matched to a single Text by
  // Flutter's screenshot-based guideline.
  final pairs = <String, (Color, Color)>{
    'body on paper': (LearningColors.ink, LearningColors.paper),
    'body on white card': (LearningColors.ink, Colors.white),
    'secondary on paper': (LearningColors.muted, LearningColors.paper),
    'secondary on white card': (LearningColors.muted, Colors.white),
    'secondary on lavender': (LearningColors.muted, LearningColors.lavender),
    'correct on green soft': (LearningColors.green, LearningColors.greenSoft),
    'correct on white card': (LearningColors.green, Colors.white),
    'wrong on amber soft': (LearningColors.amber, LearningColors.amberSoft),
    'wrong on white card': (LearningColors.amber, Colors.white),
    'error on paper': (LearningColors.amber, LearningColors.paper),
    'body on green soft': (LearningColors.ink, LearningColors.greenSoft),
    'body on amber soft': (LearningColors.ink, LearningColors.amberSoft),
  };
  for (final pair in pairs.entries) {
    test('palette ${pair.key} meets normal-text 4.5 contrast', () {
      expect(
          _contrast(pair.value.$1, pair.value.$2), greaterThanOrEqualTo(4.5));
    });
  }

  // UI v2 P1 (#775DFF) is used for CTA fills, 16pt semibold labels and accents.
  // It reaches 4.38:1 against white, so it is held to the large-text and
  // UI-component minimum (3:1); the gap to 4.5 is tracked with the designers.
  final accentPairs = <String, (Color, Color)>{
    'purple on paper': (LearningColors.primary, LearningColors.paper),
    'purple on white card': (LearningColors.primary, Colors.white),
    'purple on lavender': (LearningColors.primary, LearningColors.lavender),
    'white on purple CTA': (Colors.white, LearningColors.primary),
  };
  for (final pair in accentPairs.entries) {
    test('palette ${pair.key} meets large-text 3.0 contrast', () {
      expect(
          _contrast(pair.value.$1, pair.value.$2), greaterThanOrEqualTo(3.0));
    });
  }

  testWidgets('small secondary text on lavender passes rendered text contrast',
      (tester) async {
    final handle = tester.ensureSemantics();
    try {
      await tester.pumpWidget(const MaterialApp(
          home: Scaffold(
              body: Center(
        child: ColoredBox(
            color: LearningColors.lavender,
            child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('복습 가능한 퀴즈',
                    style:
                        TextStyle(fontSize: 12, color: LearningColors.muted)))),
      ))));
      await _check(tester);
    } finally {
      handle.dispose();
    }
  });

  // UI v2 (Figma 0.1 / 0.2.x) text pairs that must stay readable. White on
  // P1 (4.38:1) and G2 hint text (≈1.8:1) are below 4.5 by design and are
  // tracked with the design team instead of being asserted here.
  final v2Pairs = <String, (Color, Color)>{
    'B1 title on W2': (Bs.black, Bs.bg),
    'G3 subtitle on W2': (Bs.g3, Bs.bg),
    'G7 passage on W3': (Bs.g7, Bs.surface),
    'G6 option on W1': (Bs.g6, Bs.white),
    'G5 explanation on W1': (Bs.g5, Bs.white),
    'G7 guide step on W1': (Bs.g7, Bs.white),
    'selected option on P soft': (
      BsOptionTile.selectedTextColor,
      Bs.primarySoft
    ),
    'social label on Kakao': (const Color(0xD9000000), Bs.kakao),
  };
  for (final pair in v2Pairs.entries) {
    test('v2 ${pair.key} meets normal-text 4.5 contrast', () {
      final background = pair.value.$2;
      final foreground =
          Color.alphaBlend(pair.value.$1, background.withValues(alpha: 1));
      expect(_contrast(foreground, background), greaterThanOrEqualTo(4.5));
    });
  }
}

double _contrast(Color a, Color b) {
  final x = a.computeLuminance();
  final y = b.computeLuminance();
  return x > y ? (x + .05) / (y + .05) : (y + .05) / (x + .05);
}

Future<void> _check(WidgetTester tester) async {
  await expectLater(tester, meetsGuideline(textContrastGuideline));
  expect(tester.takeException(), isNull);
}
