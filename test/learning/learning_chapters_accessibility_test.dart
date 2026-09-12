import 'package:bookstar/modules/learning/view/learning_chapters_screen.dart';
import 'package:bookstar/modules/learning/view/learning_design.dart';
import 'package:bookstar/modules/reading_challenge/model/challenge_detail_book_overview.dart';
import 'package:bookstar/modules/reading_challenge/model/challenge_detail_chapter.dart';
import 'package:bookstar/modules/reading_challenge/model/challenge_detail_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  for (final completed in [true, false]) {
    testWidgets(
        'chapter ${completed ? 'completed' : 'not answered'} has one accessible title and action',
        (tester) async {
      final handle = tester.ensureSemantics();
      try {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        const title = '1. 우리는 여전히 삶을 사랑하는가';
        var loads = 0;
        final router =
            GoRouter(initialLocation: '/library/7/chapters', routes: [
          GoRoute(
              path: '/library/7/chapters',
              builder: (_, __) => const LearningChaptersScreen(challengeId: 7)),
          GoRoute(
              path: '/library/7/quiz/10',
              builder: (context, _) => Scaffold(
                      body: Column(children: [
                    const Text('선택한 목차 10의 문제'),
                    TextButton(
                        onPressed: () => context.pop(),
                        child: const Text('목차로 돌아가기')),
                  ]))),
        ]);
        addTearDown(router.dispose);
        await tester.pumpWidget(ProviderScope(
            overrides: [
              learningChaptersProvider(7).overrideWith((ref) async {
                loads++;
                return ChallengeDetailResponse(
                  bookOverview:
                      const ChallengeDetailBookOverview(title: '테스트 도서'),
                  chapters: [
                    ChallengeDetailChapter(
                        chapterId: 10,
                        title: title,
                        status: completed
                            ? ChapterStatus.COMPLETED
                            : ChapterStatus.PROCESSING)
                  ],
                );
              }),
            ],
            child: MaterialApp.router(
                theme: LearningColors.theme,
                routerConfig: router,
                builder: (context, child) => MediaQuery(
                    data: MediaQuery.of(context)
                        .copyWith(textScaler: TextScaler.linear(2)),
                    child: child!))));
        await tester.pumpAndSettle();
        final expectedLabel =
            '$title, ${completed ? '퀴즈를 풀어본 목차, 다시 떠올리기' : '아직 풀지 않은 목차, 한 문제 풀기'}';
        await tester.scrollUntilVisible(find.text(title), 140,
            scrollable: find.byType(Scrollable).first, maxScrolls: 50);
        await tester.pumpAndSettle();
        final node = tester.getSemantics(find
            .bySemanticsLabel(RegExp('^${RegExp.escape(expectedLabel)}\$')));
        final data = node.getSemanticsData();
        expect(data.label, expectedLabel);
        expect(data.label.split(title), hasLength(2),
            reason: 'The chapter title is announced exactly once');
        expect(data.hasFlag(SemanticsFlag.isButton), isTrue);
        expect(data.hasFlag(SemanticsFlag.isEnabled), isTrue);
        expect(data.hasAction(SemanticsAction.tap), isTrue);
        expect(tester.takeException(), isNull);

        node.owner!.performAction(node.id, SemanticsAction.tap);
        await tester.pumpAndSettle();
        expect(find.text('선택한 목차 10의 문제'), findsOneWidget);
        await tester.tap(find.text('목차로 돌아가기'));
        await tester.pumpAndSettle();
        expect(loads, 2,
            reason: 'Returning from a quiz still refreshes completion state');
        expect(tester.takeException(), isNull);
      } finally {
        handle.dispose();
      }
    });
  }
}
