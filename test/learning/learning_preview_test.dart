import 'package:bookstar/modules/learning/view/learning_design.dart';
import 'package:bookstar/modules/learning/view/learning_preview_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets(
      'preview choices announce text once and expose accessible selection',
      (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      await _pumpPreview(tester);
      await tester.tap(find.text('글을 가리고 퀴즈 풀기'));
      await tester.pumpAndSettle();
      await _reveal(tester, find.text('읽은 쪽수를 세었어요'));

      SemanticsNode choice(String label) => tester.getSemantics(
          find.bySemanticsLabel(RegExp('^${RegExp.escape(label)}\$')));
      final first = choice('1번 읽은 쪽수를 세었어요');
      expect(first.getSemanticsData().label, '1번 읽은 쪽수를 세었어요');
      expect(first.getSemanticsData().hasFlag(SemanticsFlag.isButton), isTrue);
      expect(first.getSemanticsData().hasFlag(SemanticsFlag.isEnabled), isTrue);
      expect(first.getSemanticsData().hasFlag(SemanticsFlag.hasSelectedState),
          isTrue);
      expect(
          first.getSemanticsData().hasFlag(SemanticsFlag.isSelected), isFalse);
      expect(first.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
      first.owner!.performAction(first.id, SemanticsAction.tap);
      await tester.pumpAndSettle();
      expect(
          choice('1번 읽은 쪽수를 세었어요')
              .getSemanticsData()
              .hasFlag(SemanticsFlag.isSelected),
          isTrue);
      expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
          isNotNull);

      await _reveal(tester, find.text('기억할 내용을 자기 말로 떠올렸어요'));
      final second = choice('2번 기억할 내용을 자기 말로 떠올렸어요');
      expect(second.getSemanticsData().label, '2번 기억할 내용을 자기 말로 떠올렸어요');
      second.owner!.performAction(second.id, SemanticsAction.tap);
      await tester.pumpAndSettle();
      expect(
          choice('2번 기억할 내용을 자기 말로 떠올렸어요')
              .getSemanticsData()
              .hasFlag(SemanticsFlag.isSelected),
          isTrue);
      await _reveal(tester, find.text('읽은 쪽수를 세었어요'));
      expect(
          choice('1번 읽은 쪽수를 세었어요')
              .getSemanticsData()
              .hasFlag(SemanticsFlag.isSelected),
          isFalse);
      await tester.tap(find.text('답 확인하기'));
      await tester.pumpAndSettle();
      await _reveal(tester, find.text('잘 떠올렸어요'));
      expect(find.text('잘 떠올렸어요'), findsOneWidget);
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  });

  for (final scale in [2.0, 3.0]) {
    testWidgets(
        'each preview step starts at the top after deep ${scale}x reading',
        (tester) async {
      await _pumpPreview(tester, width: 320, height: 568, textScale: scale);
      ScrollPosition position() =>
          tester.state<ScrollableState>(find.byType(Scrollable).first).position;
      void expectStepTop(String heading) {
        expect(position().pixels, 0,
            reason: 'Check before any test helper changes the scroll offset');
        final viewport = tester.getRect(find.byType(Scrollable).first);
        final headingRect = tester.getRect(find.text(heading));
        expect(headingRect.top, lessThan(viewport.bottom));
        expect(headingRect.bottom, greaterThan(viewport.top));
        expect(tester.takeException(), isNull);
      }

      position().jumpTo(position().maxScrollExtent);
      await tester.pumpAndSettle();
      expect(position().pixels, greaterThan(0));
      await tester.tap(find.text('글을 가리고 퀴즈 풀기'));
      await tester.pumpAndSettle();
      expectStepTop('읽은 내용을\n꺼내 볼 시간');

      await tester.scrollUntilVisible(find.text('글 다시 읽기'), 150,
          scrollable: find.byType(Scrollable).first, maxScrolls: 60);
      expect(position().pixels, greaterThan(0));
      await tester.tap(find.text('글 다시 읽기'));
      await tester.pumpAndSettle();
      expectStepTop('짧게 읽고,\n한 번 떠올려 볼까요?');

      await tester.tap(find.text('글을 가리고 퀴즈 풀기'));
      await tester.pumpAndSettle();
      final choice = find.text('기억할 내용을 자기 말로 떠올렸어요');
      await tester.scrollUntilVisible(choice, 150,
          scrollable: find.byType(Scrollable).first, maxScrolls: 60);
      await tester.pumpAndSettle();
      final visibleChoice = tester
          .getRect(choice)
          .intersect(tester.getRect(find.byType(Scrollable).first));
      expect(visibleChoice.height, greaterThan(0));
      await tester.tapAt(visibleChoice.center);
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
          isNotNull);
      expect(position().pixels, greaterThan(0));
      await tester.tap(find.text('답 확인하기'));
      await tester.pumpAndSettle();
      expectStepTop('이렇게, 한 가지를\n내 것으로 남겨요');
    });
  }

  for (final correct in [true, false]) {
    testWidgets(
        'preview ${correct ? 'correct' : 'wrong'} answer explains the '
        'result without claiming to save reading progress', (tester) async {
      await _pumpPreview(tester);

      expect(find.text('작은 독서 습관'), findsOneWidget);
      expect(find.text('체험용 예시 · 실제 책의 문제가 아니에요'), findsOneWidget);
      await tester.tap(find.text('글을 가리고 퀴즈 풀기'));
      await tester.pumpAndSettle();

      expect(find.text('작은 독서 습관'), findsNothing);
      expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
          isNull);
      final choice = find.text(correct ? '기억할 내용을 자기 말로 떠올렸어요' : '읽은 쪽수를 세었어요');
      await _reveal(tester, choice);
      await tester.tap(choice);
      await tester.pumpAndSettle();
      await tester.tap(find.text('답 확인하기'));
      await tester.pumpAndSettle();

      await _reveal(tester, find.text(correct ? '잘 떠올렸어요' : '함께 다시 짚어봐요'));
      expect(find.text('자기 말로 떠올려 보기'), findsOneWidget);
      await _reveal(tester, find.text('체험 결과는 독서·복습 기록에 저장되지 않아요.'));
      expect(find.text('체험 결과는 독서·복습 기록에 저장되지 않아요.'), findsOneWidget);

      await tester.tap(find.text('내 책으로 시작하기'));
      await tester.pumpAndSettle();
      expect(find.text('책 검색 목적지'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('preview allows rereading before confirming an answer',
      (tester) async {
    await _pumpPreview(tester);
    await tester.tap(find.text('글을 가리고 퀴즈 풀기'));
    await tester.pumpAndSettle();
    await _reveal(tester, find.text('글 다시 읽기'));
    await tester.tap(find.text('글 다시 읽기'));
    await tester.pumpAndSettle();
    await _reveal(tester, find.text('작은 독서 습관'));
    expect(find.text('작은 독서 습관'), findsOneWidget);
    expect(find.text('글을 가리고 퀴즈 풀기'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('preview remains operable at 320px with double-size text',
      (tester) async {
    await _pumpPreview(tester, width: 320, height: 568, textScale: 2);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('글을 가리고 퀴즈 풀기'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    final choice = find.text('기억할 내용을 자기 말로 떠올렸어요');
    await _reveal(tester, choice);
    await tester.tap(choice);
    await tester.pumpAndSettle();
    await tester.tap(find.text('답 확인하기'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await _reveal(tester, find.text('체험 결과는 독서·복습 기록에 저장되지 않아요.'));
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('내 책으로 시작하기'));
    await tester.pumpAndSettle();
    expect(find.text('책 검색 목적지'), findsOneWidget);
  });
}

Future<void> _pumpPreview(WidgetTester tester,
    {double width = 390, double height = 844, double textScale = 1}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, height);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final router = GoRouter(initialLocation: '/preview', routes: [
    GoRoute(
        path: '/preview', builder: (_, __) => const LearningPreviewScreen()),
    GoRoute(
        path: '/library/search',
        builder: (_, __) => const Scaffold(body: Text('책 검색 목적지'))),
  ]);
  addTearDown(router.dispose);
  await tester.pumpWidget(MaterialApp.router(
    theme: LearningColors.theme,
    routerConfig: router,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(textScale)),
      child: child!,
    ),
  ));
  await tester.pumpAndSettle();
}

Future<void> _reveal(WidgetTester tester, Finder finder) async {
  final scrollable = find.byType(Scrollable).first;
  tester.state<ScrollableState>(scrollable).position.jumpTo(0);
  await tester.pump();
  await tester.scrollUntilVisible(finder, 180,
      scrollable: scrollable, maxScrolls: 40);
  await tester.pumpAndSettle();
}
