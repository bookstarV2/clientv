import 'dart:math' as math;

import 'package:bookstar/modules/learning/view/learning_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('white surfaces are pure white and utility grays are neutral', () {
    expect(LearningColors.paper, Colors.white);
    expect(LearningColors.theme.scaffoldBackgroundColor, Colors.white);
    expect(LearningColors.theme.appBarTheme.backgroundColor, Colors.white);
    expect(LearningColors.theme.bottomSheetTheme.backgroundColor, Colors.white);
    for (final color in [LearningColors.line, LearningColors.surface]) {
      expect(color.r, color.g);
      expect(color.g, color.b);
    }
  });

  double contrast(Color a, Color b) {
    final x = a.computeLuminance();
    final y = b.computeLuminance();
    return (math.max(x, y) + .05) / (math.min(x, y) + .05);
  }

  test('editorial palette keeps normal text at least 4.5:1', () {
    for (final background in [
      LearningColors.paper,
      Colors.white,
      LearningColors.surface,
      LearningColors.lavender
    ]) {
      expect(
          contrast(LearningColors.ink, background), greaterThanOrEqualTo(4.5));
      expect(contrast(LearningColors.muted, background),
          greaterThanOrEqualTo(4.5));
      expect(contrast(LearningColors.primary, background),
          greaterThanOrEqualTo(4.5));
    }
    expect(contrast(Colors.white, LearningColors.primary),
        greaterThanOrEqualTo(4.5));
  });

  test('shared controls retain touch size and a consistent corner family', () {
    final theme = LearningColors.theme;
    for (final style in [
      theme.filledButtonTheme.style!,
      theme.outlinedButtonTheme.style!,
      theme.textButtonTheme.style!
    ]) {
      expect(style.minimumSize!.resolve({})!.height, greaterThanOrEqualTo(48));
      final shape = style.shape!.resolve({})! as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(12));
    }
  });

  testWidgets('flat book rows retain full-label semantics and full-row action',
      (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      var opened = false;
      await tester.pumpWidget(MaterialApp(
          theme: LearningColors.theme,
          home: Scaffold(
              body: LearningCard(
                  flat: true,
                  label: '긴 책 제목, 목차 열기',
                  excludeChildSemantics: true,
                  onTap: () => opened = true,
                  child: const SizedBox(
                      width: 280, height: 90, child: Text('긴 책 제목'))))));
      expect(find.bySemanticsLabel('긴 책 제목, 목차 열기'), findsOneWidget);
      await tester.tap(find.byType(LearningCard));
      expect(opened, isTrue);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('missing cover remains named and bounded at maximum text scale',
      (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(MaterialApp(
          theme: LearningColors.theme,
          home: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(3)),
              child: const Scaffold(
                  body: Center(
                      child: BookCover(
                          url: '',
                          title: '아주 긴 책 제목으로 확인하는 표지 없는 책의 접근성',
                          width: 62))))));
      expect(find.bySemanticsLabel('아주 긴 책 제목으로 확인하는 표지 없는 책의 접근성 표지'),
          findsOneWidget);
      expect(tester.getSize(find.byType(BookCover)).width, 62);
      expect(
          tester.getSize(find.byType(BookCover)).height, closeTo(89.9, .001));
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  });
}
