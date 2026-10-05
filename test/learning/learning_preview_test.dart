import 'package:bookstar/modules/learning/view/bs_ui.dart';
import 'package:bookstar/modules/learning/view/learning_preview_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const _readingHeading = '가볍게 읽고\n한 문제 풀어볼까요?';
const _questionHeading = '읽은 내용을\n얼마나 기억하고 있나요?';
const _answerHeading = '이렇게 하나씩\n내 것으로 남겨요';
const _wrong = '읽은 쪽수를 세었어요';
const _correct = '기억할 내용을 자기 말로 떠올렸어요';

void main() {
  testWidgets('preview walks 0.2.1 → 0.2.2 → 0.2.3 with the design copy',
      (tester) async {
    await _pumpPreview(tester);
    expect(find.text('한 문제 풀어보기'), findsOneWidget);
    expect(find.text(_readingHeading), findsOneWidget);
    expect(find.text('아래 문장을 읽고,\nAI가 만든 퀴즈를 풀어보세요.'), findsOneWidget);
    expect(find.textContaining('민지는 책을 읽은 뒤'), findsOneWidget);

    await tester.tap(find.text('퀴즈 풀어보기'));
    await tester.pumpAndSettle();
    expect(find.text(_questionHeading), findsOneWidget);
    expect(find.text('민지가 다음 날 책을 펼치기 전에 한 행동은 무엇인가요?'), findsOneWidget);
    expect(find.textContaining('민지는 책을 읽은 뒤'), findsNothing);
    expect(_cta(tester, '정답 확인하기').onPressed, isNull);

    await tester.tap(find.text(_correct));
    await tester.pumpAndSettle();
    expect(_tile(tester, _correct).state, BsOptionState.selected);
    expect(_cta(tester, '정답 확인하기').onPressed, isNotNull);

    await tester.tap(find.text('정답 확인하기'));
    await tester.pumpAndSettle();
    expect(find.text(_answerHeading), findsOneWidget);
    expect(_tile(tester, _correct).state, BsOptionState.answer);
    expect(_tile(tester, _wrong).state, BsOptionState.dimmed);
    expect(find.text('왜 정답인가요?'), findsOneWidget);
    expect(find.textContaining('기억이 흐릿한 부분은 책으로 돌아가'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('preview choices announce a numbered label and selection',
      (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      await _pumpPreview(tester);
      await tester.tap(find.text('퀴즈 풀어보기'));
      await tester.pumpAndSettle();

      SemanticsData choice(String label) => tester
          .getSemantics(
              find.bySemanticsLabel(RegExp('^${RegExp.escape(label)}\$')))
          .getSemanticsData();
      expect(choice('1번 $_wrong').hasFlag(SemanticsFlag.isButton), isTrue);
      expect(
          choice('1번 $_wrong').hasFlag(SemanticsFlag.hasSelectedState), isTrue);
      expect(choice('1번 $_wrong').hasFlag(SemanticsFlag.isSelected), isFalse);

      await tester.tap(find.text(_wrong));
      await tester.pumpAndSettle();
      expect(choice('1번 $_wrong').hasFlag(SemanticsFlag.isSelected), isTrue);

      await tester.tap(find.text(_correct));
      await tester.pumpAndSettle();
      expect(choice('2번 $_correct').hasFlag(SemanticsFlag.isSelected), isTrue);
      expect(choice('1번 $_wrong').hasFlag(SemanticsFlag.isSelected), isFalse);

      await tester.tap(find.text('정답 확인하기'));
      await tester.pumpAndSettle();
      expect(choice('정답, $_correct').hasFlag(SemanticsFlag.isButton), isFalse);
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  });

  for (final pick in [_correct, _wrong]) {
    testWidgets(
        'answering "$pick" marks the correct answer and opens the 0.2.4 guide',
        (tester) async {
      await _pumpPreview(tester);
      await tester.tap(find.text('퀴즈 풀어보기'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(pick));
      await tester.pumpAndSettle();
      await tester.tap(find.text('정답 확인하기'));
      await tester.pumpAndSettle();

      expect(_tile(tester, _correct).state, BsOptionState.answer);
      expect(_tile(tester, _wrong).state, BsOptionState.dimmed);

      await tester.tap(find.text('내 책으로 시작하기'));
      await tester.pumpAndSettle();
      expect(find.text('내 책으로도 이어서 해볼 수 있어요'), findsOneWidget);
      for (final step in [
        '읽을 목차를 골라요',
        '퀴즈를 확인해요',
        '퀴즈를 풀고 해설을 확인해요',
        '저장한 문제로 다시 복습해요',
      ]) {
        expect(find.text(step), findsOneWidget);
      }

      await tester.tap(find.text('내 책으로 시작하기').last);
      await tester.pumpAndSettle();
      expect(find.text('책 검색 목적지'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('closing the guide keeps the answer on screen', (tester) async {
    await _pumpPreview(tester);
    await _answer(tester);
    await tester.tap(find.text('내 책으로 시작하기'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('닫기'));
    await tester.pumpAndSettle();
    expect(find.text('내 책으로도 이어서 해볼 수 있어요'), findsNothing);
    expect(find.text(_answerHeading), findsOneWidget);
  });

  testWidgets('preview allows rereading before confirming an answer',
      (tester) async {
    await _pumpPreview(tester);
    await tester.tap(find.text('퀴즈 풀어보기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('문장 다시 읽기'));
    await tester.pumpAndSettle();
    expect(find.text(_readingHeading), findsOneWidget);
    expect(find.textContaining('민지는 책을 읽은 뒤'), findsOneWidget);
    expect(find.text('퀴즈 풀어보기'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('back steps through the preview before leaving it',
      (tester) async {
    await _pumpPreview(tester, from: '/login');
    await tester.tap(find.text('퀴즈 풀어보기'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('뒤로'));
    await tester.pumpAndSettle();
    expect(find.text(_readingHeading), findsOneWidget);
    await tester.tap(find.byTooltip('뒤로'));
    await tester.pumpAndSettle();
    expect(find.text('로그인 화면'), findsOneWidget);
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
      await tester.tap(find.text('퀴즈 풀어보기'));
      await tester.pumpAndSettle();
      expectStepTop(_questionHeading);

      position().jumpTo(position().maxScrollExtent);
      await tester.pumpAndSettle();
      await tester.tap(find.text('문장 다시 읽기'));
      await tester.pumpAndSettle();
      expectStepTop(_readingHeading);

      await tester.tap(find.text('퀴즈 풀어보기'));
      await tester.pumpAndSettle();
      final choice = find.text(_correct);
      await tester.scrollUntilVisible(choice, 150,
          scrollable: find.byType(Scrollable).first, maxScrolls: 60);
      await tester.pumpAndSettle();
      final visibleChoice = tester
          .getRect(choice)
          .intersect(tester.getRect(find.byType(Scrollable).first));
      expect(visibleChoice.height, greaterThan(0));
      await tester.tapAt(visibleChoice.center);
      await tester.pumpAndSettle();
      expect(_cta(tester, '정답 확인하기').onPressed, isNotNull);
      expect(position().pixels, greaterThan(0));
      await tester.tap(find.text('정답 확인하기'));
      await tester.pumpAndSettle();
      expectStepTop(_answerHeading);
    });
  }

  testWidgets('preview remains operable at 320px with double-size text',
      (tester) async {
    await _pumpPreview(tester, width: 320, height: 568, textScale: 2);
    expect(tester.takeException(), isNull);
    await _answer(tester);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('내 책으로 시작하기'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(find.text('내 책으로 시작하기').last, 150,
        scrollable: find.byType(Scrollable).last, maxScrolls: 30);
    await tester.tap(find.text('내 책으로 시작하기').last);
    await tester.pumpAndSettle();
    expect(find.text('책 검색 목적지'), findsOneWidget);
  });
}

BsOptionTile _tile(WidgetTester tester, String text) => tester.widget(
    find.ancestor(of: find.text(text), matching: find.byType(BsOptionTile)));

BsPrimaryButton _cta(WidgetTester tester, String label) => tester.widget(find
    .ancestor(of: find.text(label), matching: find.byType(BsPrimaryButton)));

Future<void> _answer(WidgetTester tester) async {
  await tester.tap(find.text('퀴즈 풀어보기'));
  await tester.pumpAndSettle();
  final choice = find.text(_correct);
  await tester.scrollUntilVisible(choice, 150,
      scrollable: find.byType(Scrollable).first, maxScrolls: 60);
  await tester.pumpAndSettle();
  await tester.tap(choice);
  await tester.pumpAndSettle();
  await tester.tap(find.text('정답 확인하기'));
  await tester.pumpAndSettle();
}

Future<void> _pumpPreview(WidgetTester tester,
    {double width = 390,
    double height = 844,
    double textScale = 1,
    String? from}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, height);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final router = GoRouter(initialLocation: from ?? '/preview', routes: [
    GoRoute(
        path: '/login',
        builder: (context, __) => Scaffold(
            body: TextButton(
                onPressed: () => context.push('/preview'),
                child: const Text('로그인 화면')))),
    GoRoute(
        path: '/preview', builder: (_, __) => const LearningPreviewScreen()),
    GoRoute(
        path: '/library/search',
        builder: (_, __) => const Scaffold(body: Text('책 검색 목적지'))),
  ]);
  addTearDown(router.dispose);
  await tester.pumpWidget(MaterialApp.router(
    routerConfig: router,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(textScale)),
      child: child!,
    ),
  ));
  await tester.pumpAndSettle();
  if (from != null) {
    await tester.tap(find.text('로그인 화면'));
    await tester.pumpAndSettle();
  }
}
