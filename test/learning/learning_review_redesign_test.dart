import 'dart:async';

import 'package:bookstar/modules/learning/data/learning_access.dart';
import 'package:bookstar/modules/learning/data/learning_repository.dart';
import 'package:bookstar/modules/learning/view/bs_ui.dart';
import 'package:bookstar/modules/learning/view/learning_design.dart';
import 'package:bookstar/modules/learning/view/learning_review_screen.dart';
import 'package:bookstar/modules/reading_challenge/model/challenge_response.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

ReviewItem item(int id, {DateTime? reviewedAt}) => ReviewItem(
    bookId: id == 1 ? 1 : 2,
    quizId: id,
    chapterId: id + 100,
    chapterTitle: '목차 $id',
    bookTitle: id == 1 ? '소년이 온다' : '수족관',
    bookCover: '',
    question: '질문 $id: 읽은 내용을 다시 설명하려면 무엇부터 해보면 좋을까요?',
    reviewCount: 1,
    due: true,
    nextReviewAt: DateTime(2026, 9, 12, 9),
    lastReviewedAt: reviewedAt);

class ReviewFake extends LearningRepository {
  ReviewFake({this.empty = false}) : super(Dio());
  final bool empty;
  bool failMore = false;
  Completer<ReviewPage>? pendingMore;
  final calls = <(int?, bool, bool)>[];

  @override
  Future<ReviewPage> getReviews(
      {int? cursor, bool dueOnly = false, bool reviewedOnly = false}) async {
    calls.add((cursor, dueOnly, reviewedOnly));
    if (cursor != null && failMore) throw StateError('page offline');
    if (cursor != null && pendingMore != null) return pendingMore!.future;
    final items = empty
        ? <ReviewItem>[]
        : cursor != null
            ? [item(4, reviewedAt: reviewedOnly ? DateTime(2026, 9, 1) : null)]
            : reviewedOnly
                ? [
                    item(2, reviewedAt: DateTime(2026, 9, 9, 10)),
                    item(3),
                  ]
                : [item(1), item(2), item(3)];
    return ReviewPage(
        items: items,
        totalCount: empty ? 0 : 4,
        dueCount: empty ? 0 : 4,
        reviewedTodayCount: 0,
        hasNext: !empty && cursor == null,
        nextCursor: 42);
  }
}

Future<ProviderContainer> open(WidgetTester tester, ReviewFake repo,
    {double scale = 1,
    String location = '/review',
    bool overviewFails = false,
    bool settle = true}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(375, 667);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final router = GoRouter(initialLocation: location, routes: [
    GoRoute(
        path: '/review',
        builder: (_, __) => const Scaffold(body: LearningReviewScreen()),
        routes: [
          GoRoute(
              path: 'history',
              builder: (_, __) => const LearningReviewHistoryPage()),
          GoRoute(
              path: 'quiz/:id',
              builder: (_, state) =>
                  Scaffold(body: Text('열린 문항 ${state.pathParameters['id']}'))),
        ]),
  ]);
  addTearDown(router.dispose);
  var fail = overviewFails;
  final container = ProviderContainer(overrides: [
    learningAccountProvider.overrideWithValue(1),
    learningRepositoryProvider.overrideWithValue(repo),
    reviewOverviewProvider.overrideWith((ref) {
      if (fail) {
        fail = false;
        throw StateError('offline');
      }
      return repo.getReviews(dueOnly: true);
    }),
    learningBooksProvider.overrideWith((ref) async => const [
          ChallengeResponse(
              challengeId: 30, bookId: 2, bookTitle: '수족관', bookAuthor: '유래혁'),
        ]),
    finishedLearningBooksProvider.overrideWith((ref) async => []),
  ]);
  addTearDown(container.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
          theme: LearningColors.theme,
          routerConfig: router,
          builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(scale)),
              child: child!))));
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }
  return container;
}

Future<void> reveal(WidgetTester tester, Finder target) async {
  await tester.scrollUntilVisible(target, 160,
      scrollable: find.byType(Scrollable).first, maxScrolls: 40);
  await tester.pumpAndSettle();
}

void main() {
  test('review text keeps WCAG contrast', () {
    for (final pair in [
      (Bs.g3, Bs.bg, 4.5),
      (Bs.g3, Bs.surface, 4.5),
      (Bs.g6, Bs.white, 4.5),
      (Bs.g7, Bs.surface, 4.5),
      // 16pt semibold button label counts as large text.
      (Bs.white, Bs.primary, 3.0),
    ]) {
      final a = pair.$1.computeLuminance();
      final b = pair.$2.computeLuminance();
      expect(((a > b ? a : b) + .05) / ((a > b ? b : a) + .05),
          greaterThanOrEqualTo(pair.$3));
    }
  });

  testWidgets('the first due quiz is highlighted with one action',
      (tester) async {
    await open(tester, ReviewFake());
    expect(find.text('오늘 복습할 퀴즈'), findsOneWidget);
    expect(find.text('소년이 온다'), findsOneWidget);
    expect(find.text('목차 1'), findsOneWidget);
    expect(find.text(item(1).question), findsOneWidget);
    expect(find.text('퀴즈 다시 풀기').hitTestable(), findsOneWidget);
    await tester.tap(find.text('퀴즈 다시 풀기'));
    await tester.pumpAndSettle();
    expect(find.text('열린 문항 101'), findsOneWidget);
  });

  testWidgets('other due quizzes show book and author and open their quiz',
      (tester) async {
    final semantics = tester.ensureSemantics();
    await open(tester, ReviewFake());
    expect(find.text('수족관 (유래혁)'), findsWidgets);
    final row = find.bySemanticsLabel('${item(2).question}, 수족관 (유래혁), 복습하기');
    expect(row, findsOneWidget);
    final node = tester.getSemantics(row);
    expect(node.getSemanticsData().hasFlag(SemanticsFlag.isButton), isTrue);
    node.owner!.performAction(node.id, SemanticsAction.tap);
    await tester.pumpAndSettle();
    expect(find.text('열린 문항 102'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('scrolling to the end appends the next page once',
      (tester) async {
    final repo = ReviewFake();
    await open(tester, repo);
    await reveal(tester, find.text(item(4).question));
    expect(repo.calls.where((call) => call.$1 == 42), hasLength(1));
    expect(repo.calls.last, (42, true, false));
    expect(find.text(item(1).question), findsOneWidget);
  });

  testWidgets('pagination failure keeps questions and offers a retry',
      (tester) async {
    final repo = ReviewFake()..failMore = true;
    await open(tester, repo);
    await reveal(tester, find.text('퀴즈 더 불러오기'));
    expect(find.text(item(3).question), findsOneWidget);
    repo.failMore = false;
    await tester.tap(find.text('퀴즈 더 불러오기'));
    await tester.pumpAndSettle();
    await reveal(tester, find.text(item(4).question));
    expect(find.text(item(4).question), findsOneWidget);
  });

  testWidgets('a late page from before a refresh is not appended',
      (tester) async {
    final repo = ReviewFake()..pendingMore = Completer<ReviewPage>();
    final container = await open(tester, repo, settle: false);
    final stale = repo.pendingMore!;
    expect(repo.calls.where((call) => call.$1 == 42), hasLength(1));
    repo.pendingMore = null;
    container.invalidate(reviewOverviewProvider);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    stale.complete(ReviewPage(
        items: [item(99)],
        totalCount: 4,
        dueCount: 3,
        reviewedTodayCount: 0,
        hasNext: false));
    await tester.pumpAndSettle();
    expect(find.text(item(99).question), findsNothing);
    await reveal(tester, find.text(item(4).question));
    expect(find.text(item(4).question), findsOneWidget);
  });

  testWidgets('history lists reviewed quizzes with their last review date',
      (tester) async {
    final repo = ReviewFake();
    await open(tester, repo);
    await tester.tap(find.text('복습한 퀴즈'));
    await tester.pumpAndSettle();
    expect(repo.calls, contains((null, false, true)));
    expect(find.text('복습한 퀴즈'), findsOneWidget);
    expect(find.text('퀴즈 다시 풀기'), findsNothing);
    expect(find.text('수족관 (유래혁) | 2026.09.09 복습'), findsOneWidget);
    expect(find.text('수족관 (유래혁)'), findsOneWidget,
        reason: 'Without lastReviewedAt the date is left out');
    await tester.tap(find.text(item(2).question));
    await tester.pumpAndSettle();
    expect(find.text('열린 문항 102'), findsOneWidget);
  });

  testWidgets('history pagination asks for reviewed quizzes and back returns',
      (tester) async {
    final repo = ReviewFake();
    await open(tester, repo);
    await tester.tap(find.text('복습한 퀴즈'));
    await tester.pumpAndSettle();
    await reveal(tester, find.text(item(4).question));
    expect(repo.calls.last, (42, false, true));
    expect(find.text('수족관 (유래혁) | 2026.09.01 복습'), findsOneWidget);
    await tester.tap(find.byTooltip('뒤로'));
    await tester.pumpAndSettle();
    expect(find.text('오늘 복습할 퀴즈'), findsOneWidget);
  });

  testWidgets('empty state puts a useful action on the first screen',
      (tester) async {
    await open(tester, ReviewFake(empty: true));
    expect(find.text('퀴즈 풀러 가기').hitTestable(), findsOneWidget);
    expect(find.text('퀴즈 다시 풀기'), findsNothing);
  });

  testWidgets('empty history explains how quizzes get there', (tester) async {
    await open(tester, ReviewFake(empty: true), location: '/review/history');
    expect(find.text('아직 복습한 퀴즈가 없어요.\n복습 탭에서 오늘의 퀴즈를 다시 풀어 보세요.'),
        findsOneWidget);
  });

  testWidgets('load failure is not a completion or a fake zero',
      (tester) async {
    await open(tester, ReviewFake(), overviewFails: true);
    expect(find.text('다시 불러오기'), findsOneWidget);
    expect(find.text('퀴즈 다시 풀기'), findsNothing);
    await tester.tap(find.text('다시 불러오기'));
    await tester.pumpAndSettle();
    expect(find.text(item(1).question), findsOneWidget);
  });

  for (final scale in [2.0, 3.0]) {
    testWidgets('hero action and history stay reachable at ${scale}x text',
        (tester) async {
      await open(tester, ReviewFake(), scale: scale);
      expect(tester.takeException(), isNull);
      await reveal(tester, find.text('퀴즈 다시 풀기'));
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('퀴즈 다시 풀기'));
      await tester.pumpAndSettle();
      expect(find.text('열린 문항 101'), findsOneWidget);
      GoRouter.of(tester.element(find.text('열린 문항 101'))).pop();
      await tester.pumpAndSettle();
      tester
          .state<ScrollableState>(find.byType(Scrollable).first)
          .position
          .jumpTo(0);
      await tester.pumpAndSettle();
      await tester.tap(find.text('복습한 퀴즈'));
      await tester.pumpAndSettle();
      expect(find.text(item(2).question), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
