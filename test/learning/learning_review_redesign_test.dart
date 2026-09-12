import 'dart:async';
import 'package:bookstar/modules/learning/data/learning_repository.dart';
import 'package:bookstar/modules/learning/view/learning_design.dart';
import 'package:bookstar/modules/learning/view/learning_review_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

ReviewItem item(int id, {bool due = true}) => ReviewItem(
    quizId: id,
    chapterId: id + 100,
    chapterTitle: '목차 $id',
    bookTitle: '기억하고 싶은 책 $id',
    bookCover: '',
    question: '질문 $id: 읽은 내용을 다시 설명하려면 무엇부터 해보면 좋을까요?',
    reviewCount: 1,
    due: due,
    nextReviewAt: DateTime(2026, 9, 12, 9));

class ReviewFake extends LearningRepository {
  ReviewFake({this.fail = false, this.empty = false}) : super(Dio());
  bool fail;
  final bool empty;
  Completer<ReviewPage>? pendingAll;
  Completer<ReviewPage>? pendingMore;
  ReviewPage? response;
  bool failMore = false;
  final calls = <(int?, bool)>[];
  @override
  Future<ReviewPage> getReviews({int? cursor, bool dueOnly = false}) async {
    calls.add((cursor, dueOnly));
    if (fail) throw StateError('offline');
    if (cursor != null && failMore) throw StateError('page offline');
    if (cursor != null && pendingMore != null) return pendingMore!.future;
    if (!dueOnly && pendingAll != null) return pendingAll!.future;
    if (response != null) return response!;
    return ReviewPage(
        items: empty
            ? []
            : cursor == null
                ? [item(1), item(2), if (!dueOnly) item(3, due: false)]
                : [item(4)],
        totalCount: empty ? 0 : 4,
        dueCount: empty ? 0 : 3,
        reviewedTodayCount: 0,
        hasNext: !empty && cursor == null,
        nextCursor: 42);
  }
}

Future<void> open(WidgetTester tester, ReviewFake repo,
    {double scale = 1}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(375, 667);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final router = GoRouter(initialLocation: '/review', routes: [
    GoRoute(
        path: '/review',
        builder: (_, __) => Scaffold(
            appBar: AppBar(title: const Text('복습')),
            bottomNavigationBar: const SizedBox(height: 72),
            body: const LearningReviewScreen())),
    GoRoute(
        path: '/review/history',
        builder: (_, __) => const LearningReviewHistoryPage()),
    GoRoute(
        path: '/review/quiz/:id',
        builder: (_, state) =>
            Scaffold(body: Text('열린 문항 ${state.pathParameters['id']}'))),
    GoRoute(
        path: '/library',
        builder: (_, __) => const Scaffold(body: Text('서재 목적지'))),
  ]);
  addTearDown(router.dispose);
  await tester.pumpWidget(ProviderScope(
      overrides: [
        learningRepositoryProvider.overrideWithValue(repo),
        reviewOverviewProvider
            .overrideWith((ref) => repo.getReviews(dueOnly: true))
      ],
      child: MaterialApp.router(
          theme: LearningColors.theme,
          routerConfig: router,
          builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(scale)),
              child: child!))));
  await tester.pumpAndSettle();
}

Future<void> reveal(WidgetTester tester, Finder target) async {
  await tester.scrollUntilVisible(target, 160,
      scrollable: find.byType(Scrollable).first, maxScrolls: 40);
  await tester.pumpAndSettle();
}

void main() {
  test('review text and actions retain at least 4.5:1 contrast', () {
    for (final pair in [
      (Colors.white, ReviewColors.ink),
      (ReviewColors.context, ReviewColors.ink),
      (ReviewColors.action, ReviewColors.ink),
      (ReviewColors.soft, ReviewColors.ink),
      (ReviewColors.soft, LearningColors.muted),
    ]) {
      final a = pair.$1.computeLuminance();
      final b = pair.$2.computeLuminance();
      expect(((a > b ? a : b) + .05) / ((a > b ? b : a) + .05),
          greaterThanOrEqualTo(4.5));
    }
  });

  testWidgets('positive due count without items offers retry, never success',
      (tester) async {
    final repo = ReviewFake()
      ..response = const ReviewPage(
          items: [],
          totalCount: 3,
          dueCount: 2,
          reviewedTodayCount: 1,
          hasNext: false);
    await open(tester, repo);
    expect(find.text('다시 불러오기'), findsOneWidget);
    expect(find.text('오늘 1개를 다시 풀었어요'), findsNothing);
    expect(find.text('지금 예정된 복습은 없어요'), findsNothing);
  });

  testWidgets('pagination failure preserves questions and can retry',
      (tester) async {
    final repo = ReviewFake()..failMore = true;
    await open(tester, repo);
    await reveal(tester, find.text('퀴즈 더 보기'));
    await tester.tap(find.text('퀴즈 더 보기'));
    await tester.pumpAndSettle();
    expect(find.text(item(1).question), findsOneWidget);
    expect(find.text(item(2).question), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
    repo.failMore = false;
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await reveal(tester, find.text('퀴즈 더 보기'));
    await tester.tap(find.text('퀴즈 더 보기'));
    await tester.pumpAndSettle();
    await reveal(tester, find.text(item(4).question));
    expect(find.text(item(4).question), findsOneWidget);
  });

  testWidgets('late due pagination cannot append to the separate history page',
      (tester) async {
    final repo = ReviewFake()..pendingMore = Completer<ReviewPage>();
    await open(tester, repo);
    await reveal(tester, find.text('퀴즈 더 보기'));
    await tester.tap(find.text('퀴즈 더 보기'));
    await tester.pump();
    await tester.scrollUntilVisible(find.text('이전에 푼 문제 모두 보기'), -300,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('이전에 푼 문제 모두 보기'));
    await tester.pumpAndSettle();
    repo.pendingMore!.complete(ReviewPage(
        items: [item(99)],
        totalCount: 4,
        dueCount: 3,
        reviewedTodayCount: 0,
        hasNext: false));
    await tester.pumpAndSettle();
    expect(find.text(item(99).question), findsNothing);
    expect(find.text('이 문제 다시 풀기'), findsNothing);
    await reveal(tester, find.text(item(3).question));
    expect(find.text(item(3).question), findsOneWidget);
  });

  testWidgets('SE shows one real question and its action before scrolling',
      (tester) async {
    await open(tester, ReviewFake());
    expect(find.byType(ChoiceChip), findsNothing);
    expect(find.text('지금 복습'), findsNothing);
    expect(find.text('전체 퀴즈'), findsNothing);
    expect(find.text(item(1).question), findsOneWidget);
    expect(find.text('이 문제 다시 풀기').hitTestable(), findsOneWidget);
    expect(find.text('한 문제 복습하기'), findsNothing);
    await tester.tap(find.text('이 문제 다시 풀기'));
    await tester.pumpAndSettle();
    expect(find.text('열린 문항 101'), findsOneWidget);
  });

  testWidgets(
      'history opens separately without the hero and includes future quizzes',
      (tester) async {
    final repo = ReviewFake();
    await open(tester, repo);
    await tester.tap(find.text('이전에 푼 문제 모두 보기'));
    await tester.pumpAndSettle();
    expect(repo.calls.last.$2, isFalse);
    expect(find.text('이 문제 다시 풀기'), findsNothing);
    expect(find.text(item(1).question), findsOneWidget);
    await reveal(tester, find.text(item(3).question));
    expect(find.text(item(3).question), findsOneWidget);
  });

  testWidgets('history loading does not expose the previous page hero',
      (tester) async {
    final repo = ReviewFake();
    await open(tester, repo);
    repo.pendingAll = Completer<ReviewPage>();
    await tester.tap(find.text('이전에 푼 문제 모두 보기'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('이 문제 다시 풀기'), findsNothing);
    expect(find.text(item(1).question), findsNothing);
    repo.pendingAll!.complete(const ReviewPage(
        items: [],
        totalCount: 0,
        dueCount: 0,
        reviewedTodayCount: 0,
        hasNext: false));
    await tester.pumpAndSettle();
  });

  testWidgets(
      'history pagination uses all items and back restores fresh due page',
      (tester) async {
    final repo = ReviewFake();
    await open(tester, repo);
    await tester.tap(find.text('이전에 푼 문제 모두 보기'));
    await tester.pumpAndSettle();
    expect(find.text('이전에 푼 문제'), findsOneWidget);
    await reveal(tester, find.text('퀴즈 더 보기'));
    await tester.tap(find.text('퀴즈 더 보기'));
    await tester.pumpAndSettle();
    expect(repo.calls.last, (42, false));
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(repo.calls.last, (null, true));
    expect(find.text('이 문제 다시 풀기'), findsOneWidget);
    expect(find.text(item(3).question), findsNothing);
  });

  for (final scale in [2.0, 3.0]) {
    testWidgets('history action opens and returns at ${scale}x text',
        (tester) async {
      await open(tester, ReviewFake(), scale: scale);
      await reveal(tester, find.text('이전에 푼 문제 모두 보기'));
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('이전에 푼 문제 모두 보기'));
      await tester.pumpAndSettle();
      expect(find.text('이전에 푼 문제'), findsOneWidget);
      expect(find.text('이 문제 다시 풀기'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('이 문제 다시 풀기'), findsOneWidget);
    });
  }

  testWidgets(
      'pagination preserves the hero once and appends the requested cursor',
      (tester) async {
    final repo = ReviewFake();
    await open(tester, repo);
    await reveal(tester, find.text('퀴즈 더 보기'));
    await tester.tap(find.text('퀴즈 더 보기'));
    await tester.pumpAndSettle();
    expect(repo.calls.last, (42, true));
    expect(find.text(item(1).question), findsOneWidget);
    await reveal(tester, find.text(item(4).question));
    expect(find.text(item(4).question), findsOneWidget);
  });

  testWidgets(
      'empty state puts the useful action on the first screen without empty filters',
      (tester) async {
    await open(tester, ReviewFake(empty: true));
    expect(find.text('내 서재에서 시작하기').hitTestable(), findsOneWidget);
    expect(find.text('이전에 푼 문제 모두 보기'), findsNothing);
    await tester.tap(find.text('내 서재에서 시작하기'));
    await tester.pumpAndSettle();
    expect(find.text('서재 목적지'), findsOneWidget);
  });

  testWidgets('load failure is not a completion or a fake zero',
      (tester) async {
    final repo = ReviewFake(fail: true);
    await open(tester, repo);
    expect(find.text('불러오지 못했어요'), findsOneWidget);
    expect(find.text('이 문제 다시 풀기'), findsNothing);
    repo.fail = false;
    await tester.tap(find.text('다시 불러오기'));
    await tester.pumpAndSettle();
    expect(find.text(item(1).question), findsOneWidget);
  });

  for (final scale in [2.0, 3.0]) {
    testWidgets('question and action remain reachable at ${scale}x text',
        (tester) async {
      await open(tester, ReviewFake(), scale: scale);
      expect(tester.takeException(), isNull);
      await reveal(tester, find.text('이 문제 다시 풀기'));
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('이 문제 다시 풀기'));
      await tester.pumpAndSettle();
      expect(find.text('열린 문항 101'), findsOneWidget);
    });
  }
}
