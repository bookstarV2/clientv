import 'dart:async';

import 'package:bookstar/modules/learning/data/learning_access.dart';
import 'package:bookstar/modules/learning/data/learning_repository.dart';
import 'package:bookstar/modules/learning/view/learning_design.dart';
import 'package:bookstar/modules/learning/view/learning_review_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

ReviewItem _item(int id) => ReviewItem(
    quizId: id,
    chapterId: id + 100,
    chapterTitle: '목차 $id',
    bookTitle: '책 $id',
    bookCover: '',
    question: '질문 $id',
    reviewCount: 1,
    due: true,
    nextReviewAt: DateTime(2026, 9, 12, 9));

void main() {
  testWidgets('overview refresh shows fresh due quizzes once they arrive',
      (tester) async {
    final repository = _ReviewRepository(_page(total: 3, items: [_item(1)]));
    final pending = Completer<ReviewPage>();
    var overviewLoads = 0;
    await _pumpReview(tester, repository, overview: () async {
      if (overviewLoads++ == 0) return repository.page;
      return pending.future;
    });
    expect(find.text('질문 1'), findsOneWidget);
    final container = ProviderScope.containerOf(
        tester.element(find.byType(LearningReviewScreen)));

    container.invalidate(reviewOverviewProvider);
    await tester.pump();
    await tester.pump();
    expect(container.read(reviewOverviewProvider).isLoading, isTrue);
    expect(find.text('퀴즈 다시 풀기'), findsNothing,
        reason: 'A stale quiz must not stay actionable while refreshing');

    pending.complete(_page(total: 3, items: [_item(2)]));
    await tester.pumpAndSettle();
    expect(find.text('질문 2'), findsOneWidget);
    expect(find.text('질문 1'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  test(
      'review payload keeps older responses compatible and reads unavailable count',
      () {
    final payload = <String, dynamic>{
      'items': [],
      'totalCount': 3,
      'dueCount': 0,
      'reviewedTodayCount': 0,
      'hasNext': false,
    };
    expect(ReviewPage.fromJson(payload).unavailableCount, 0);
    expect(
        ReviewPage.fromJson({...payload, 'unavailableCount': 3})
            .unavailableCount,
        3);
  });

  testWidgets(
      'unavailable history stays acknowledged instead of claiming an empty account',
      (tester) async {
    await _pumpReview(
        tester, _ReviewRepository(_page(total: 3, reviewed: 1, unavailable: 3)),
        width: 320, height: 568, textScale: 2);
    await _reveal(tester, find.text('지금 복습할 수 있는 퀴즈가 없어요.\n기존 풀이 기록은 보관돼요.'));
    expect(find.textContaining('아직 푼 퀴즈가 없어요'), findsNothing);
    expect(find.text('오늘 복습할 퀴즈를 모두 풀었어요.'), findsNothing);
    await _reveal(tester, find.text('다른 퀴즈 찾기'));
    await tester.tap(find.text('다른 퀴즈 찾기'));
    await tester.pumpAndSettle();
    expect(find.text('내 서재 목적지'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'partially unavailable quizzes are explained without hiding the rest',
      (tester) async {
    final repository = _ReviewRepository(
        _page(total: 3, unavailable: 1, items: [_item(1), _item(2)]));
    await _pumpReview(tester, repository,
        width: 320, height: 568, textScale: 2);
    await _reveal(
        tester, find.text('지금 제공할 수 없는 퀴즈 1개는 목록에서 제외했어요.\n기존 풀이 기록은 보관돼요.'));
    expect(find.text('질문 2'), findsOneWidget);
    await _reveal(tester, find.text('복습한 퀴즈'));
    await tester.tap(find.text('복습한 퀴즈'));
    await tester.pumpAndSettle();
    expect(repository.requests.last.reviewedOnly, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'no quiz history invites a first quiz instead of claiming success',
      (tester) async {
    await _pumpReview(tester, _ReviewRepository(_page(total: 0)));
    await _reveal(
        tester, find.text('아직 푼 퀴즈가 없어요.\n내 서재에서 퀴즈를 풀면 이곳에서 복습할 수 있어요.'));
    expect(find.text('오늘 복습할 퀴즈를 모두 풀었어요.'), findsNothing);
    await _reveal(tester, find.text('퀴즈 풀러 가기'));
    await tester.tap(find.text('퀴즈 풀러 가기'));
    await tester.pumpAndSettle();
    expect(find.text('내 서재 목적지'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'future reviews without activity do not claim today was completed',
      (tester) async {
    await _pumpReview(tester, _ReviewRepository(_page(total: 3)));
    await _reveal(tester, find.text('오늘 복습할 퀴즈가 없어요.'));
    expect(find.text('오늘 복습할 퀴즈를 모두 풀었어요.'), findsNothing);
    expect(find.textContaining('아직 푼 퀴즈가 없어요'), findsNothing);
    expect(find.text('복습한 퀴즈'), findsOneWidget,
        reason: 'History stays reachable from the header');
  });

  testWidgets('completion copy is shown after today has actual review activity',
      (tester) async {
    await _pumpReview(tester, _ReviewRepository(_page(total: 3, reviewed: 2)));
    await _reveal(tester, find.text('오늘 복습할 퀴즈를 모두 풀었어요.'));
    expect(find.text('오늘 복습할 퀴즈가 없어요.'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('positive due count without items offers retry, never success',
      (tester) async {
    await _pumpReview(
        tester, _ReviewRepository(_page(total: 3, due: 2, reviewed: 1)));
    expect(find.text('다시 불러오기'), findsOneWidget);
    expect(find.text('오늘 복습할 퀴즈를 모두 풀었어요.'), findsNothing);
  });

  for (final state in [
    (
      total: 0,
      reviewed: 0,
      title: '아직 푼 퀴즈가 없어요.\n내 서재에서 퀴즈를 풀면 이곳에서 복습할 수 있어요.'
    ),
    (total: 3, reviewed: 0, title: '오늘 복습할 퀴즈가 없어요.'),
    (total: 3, reviewed: 2, title: '오늘 복습할 퀴즈를 모두 풀었어요.'),
  ]) {
    testWidgets('320px double-size text supports review state: ${state.title}',
        (tester) async {
      await _pumpReview(
        tester,
        _ReviewRepository(_page(total: state.total, reviewed: state.reviewed)),
        width: 320,
        height: 568,
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
      await _reveal(tester, find.text(state.title));
      expect(find.text(state.title), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}

ReviewPage _page(
        {required int total,
        int reviewed = 0,
        int unavailable = 0,
        int? due,
        List<ReviewItem> items = const []}) =>
    ReviewPage(
      items: items,
      totalCount: total,
      dueCount: due ?? items.length,
      reviewedTodayCount: reviewed,
      unavailableCount: unavailable,
      hasNext: false,
    );

class _ReviewRepository extends LearningRepository {
  _ReviewRepository(this.page) : super(Dio());
  final ReviewPage page;
  final requests = <({int? cursor, bool dueOnly, bool reviewedOnly})>[];

  @override
  Future<ReviewPage> getReviews(
      {int? cursor, bool dueOnly = false, bool reviewedOnly = false}) async {
    requests
        .add((cursor: cursor, dueOnly: dueOnly, reviewedOnly: reviewedOnly));
    return page;
  }
}

Future<void> _pumpReview(WidgetTester tester, _ReviewRepository repository,
    {double width = 390,
    double height = 844,
    double textScale = 1,
    Future<ReviewPage> Function()? overview}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, height);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final router = GoRouter(initialLocation: '/review', routes: [
    GoRoute(
        path: '/review',
        builder: (_, __) => const Scaffold(body: LearningReviewScreen())),
    GoRoute(
        path: '/review/history',
        builder: (_, __) => const LearningReviewHistoryPage()),
    GoRoute(
        path: '/library',
        builder: (_, __) => const Scaffold(body: Text('내 서재 목적지'))),
  ]);
  addTearDown(router.dispose);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      learningAccountProvider.overrideWithValue(null),
      learningRepositoryProvider.overrideWithValue(repository),
      reviewOverviewProvider.overrideWith(
          (ref) async => overview == null ? repository.page : await overview()),
    ],
    child: MaterialApp.router(
      theme: LearningColors.theme,
      routerConfig: router,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
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
