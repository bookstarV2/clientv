import 'dart:async';

import 'package:bookstar/modules/learning/data/learning_repository.dart';
import 'package:bookstar/modules/learning/view/learning_design.dart';
import 'package:bookstar/modules/learning/view/learning_review_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('overview refresh reloads the page only after fresh data arrives',
      (tester) async {
    final repository = _ReviewRepository(_page(total: 3));
    final pending = Completer<ReviewPage>();
    var overviewLoads = 0;
    await _pumpReview(tester, repository, overview: () async {
      if (overviewLoads++ == 0) return repository.page;
      return pending.future;
    });
    final container = ProviderScope.containerOf(
        tester.element(find.byType(LearningReviewScreen)));
    final before = repository.requestedDueOnly.length;

    container.invalidate(reviewOverviewProvider);
    await tester.pump();
    expect(container.read(reviewOverviewProvider).isLoading, isTrue);
    expect(repository.requestedDueOnly.length, before,
        reason: 'AsyncData can retain old data while isLoading is true');

    pending.complete(repository.page);
    await tester.pumpAndSettle();
    expect(repository.requestedDueOnly.length, before + 1);
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
    await _reveal(tester, find.text('지금 다시 풀 수 있는 문제가 없어요'));
    expect(find.text('첫 퀴즈가 복습의 시작이에요'), findsNothing);
    expect(find.text('오늘 예정된 복습을 마쳤어요'), findsNothing);
    await _reveal(
        tester, find.text('기존 3개 풀이 기록은 보관돼요.\n내 서재에서 다른 퀴즈를 만나보세요.'));
    await _reveal(tester, find.text('다른 퀴즈 찾기'));
    await tester.tap(find.text('다른 퀴즈 찾기'));
    await tester.pumpAndSettle();
    expect(find.text('내 서재 목적지'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'partially unavailable history explains hidden items without deleting the rest',
      (tester) async {
    final repository = _ReviewRepository(_page(total: 3, unavailable: 1));
    await _pumpReview(tester, repository,
        width: 320, height: 568, textScale: 2);
    await _reveal(
        tester, find.text('지금 제공할 수 없는 퀴즈 1개는 목록에서 제외했어요.\n기존 풀이 기록은 보관돼요.'));
    await _reveal(tester, find.text('이전에 푼 문제 모두 보기'));
    await tester.tap(find.text('이전에 푼 문제 모두 보기'));
    await tester.pumpAndSettle();
    expect(repository.requestedDueOnly.last, isFalse);
    expect(find.text('지금 다시 풀 수 있는 문제가 없어요'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'no quiz history invites a first quiz instead of claiming success',
      (tester) async {
    final repository = _ReviewRepository(_page(total: 0));
    await _pumpReview(tester, repository);
    await _reveal(tester, find.text('첫 퀴즈가 복습의 시작이에요'));
    expect(find.text('오늘 예정된 복습을 마쳤어요'), findsNothing);
    await _reveal(tester, find.text('내 서재에서 시작하기'));
    await tester.tap(find.text('내 서재에서 시작하기'));
    await tester.pumpAndSettle();
    expect(find.text('내 서재 목적지'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'future reviews without activity do not claim today was completed',
      (tester) async {
    final repository = _ReviewRepository(_page(total: 3));
    await _pumpReview(tester, repository);
    await _reveal(tester, find.text('지금 예정된 복습은 없어요'));
    expect(find.text('오늘 예정된 복습을 마쳤어요'), findsNothing);
    expect(find.text('첫 퀴즈가 복습의 시작이에요'), findsNothing);

    await _reveal(tester, find.text('이전에 푼 문제 모두 보기'));
    await tester.tap(find.text('이전에 푼 문제 모두 보기'));
    await tester.pumpAndSettle();
    expect(repository.requestedDueOnly.last, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('completion copy is shown after today has actual review activity',
      (tester) async {
    await _pumpReview(tester, _ReviewRepository(_page(total: 3, reviewed: 2)));
    await _reveal(tester, find.text('오늘 2개를 다시 풀었어요'));
    expect(find.text('지금 예정된 복습은 없어요'), findsNothing);
    expect(find.text('첫 퀴즈가 복습의 시작이에요'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final state in [
    (total: 0, reviewed: 0, title: '첫 퀴즈가 복습의 시작이에요'),
    (total: 3, reviewed: 0, title: '지금 예정된 복습은 없어요'),
    (total: 3, reviewed: 2, title: '오늘 2개를 다시 풀었어요'),
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

ReviewPage _page({required int total, int reviewed = 0, int unavailable = 0}) =>
    ReviewPage(
      items: const [],
      totalCount: total,
      dueCount: 0,
      reviewedTodayCount: reviewed,
      unavailableCount: unavailable,
      hasNext: false,
    );

class _ReviewRepository extends LearningRepository {
  _ReviewRepository(this.page) : super(Dio());
  final ReviewPage page;
  final List<bool> requestedDueOnly = [];

  @override
  Future<ReviewPage> getReviews({int? cursor, bool dueOnly = false}) async {
    requestedDueOnly.add(dueOnly);
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
