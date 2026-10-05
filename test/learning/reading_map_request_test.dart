import 'package:bookstar/modules/learning/data/learning_access.dart';
import 'package:bookstar/modules/learning/data/learning_repository.dart';
import 'package:bookstar/modules/learning/data/reading_graph.dart';
import 'package:bookstar/modules/learning/data/reading_map_remote.dart';
import 'package:bookstar/modules/learning/view/reading_map_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class FakeMapRemote extends ReadingMapRemote {
  FakeMapRemote() : super(Dio());

  int requests = 0;
  String? requestedMode;
  ReadingMapState state = const ReadingMapState(
    balance: 20,
    createCost: 20,
    refreshCost: 10,
    answeredQuizCount: 2,
    analyzedQuizCount: 0,
    hasNewQuizzes: true,
    status: null,
    jobId: null,
    version: 0,
    links: [],
  );

  @override
  Future<ReadingMapState> get() async => state;

  @override
  Future<ReadingMapJobResult> request(String requestId, String mode) async {
    requests++;
    requestedMode = mode;
    state = const ReadingMapState(
      balance: 0,
      createCost: 20,
      refreshCost: 10,
      answeredQuizCount: 2,
      analyzedQuizCount: 2,
      hasNewQuizzes: false,
      status: 'SUCCEEDED',
      jobId: 9,
      version: 1,
      links: [
        ReadingMapLink(
          quizAId: 1,
          quizBId: 2,
          type: 'COMPLEMENTS',
          reason: '두 생각이 서로 보완해요.',
          supportA: '첫 근거',
          supportB: '둘째 근거',
        ),
      ],
    );
    return const ReadingMapJobResult(9, 'QUEUED', 0);
  }
}

ReviewItem item(int id) => ReviewItem(
      bookId: 1,
      quizId: id,
      chapterId: id,
      chapterTitle: '목차 $id',
      bookTitle: '생각 책',
      bookCover: '',
      question: '질문 $id',
      reviewCount: 0,
      due: false,
      nextReviewAt: DateTime.utc(2030),
    );

void main() {
  testWidgets('user spends points to create a map and sees the relation card',
      (tester) async {
    final remote = FakeMapRemote();
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => const ReadingMapAllScreen()),
    ]);
    addTearDown(router.dispose);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        learningAccountProvider.overrideWithValue(1),
        readingGraphProvider.overrideWith(
            (ref) async => ReadingGraph.fromReviews([item(1), item(2)])),
        readingMapRemoteProvider.overrideWithValue(remote),
      ],
      child: MaterialApp.router(routerConfig: router),
    ));
    await tester.pumpAndSettle();

    expect(find.text('내 포인트 20P'), findsOneWidget);
    await tester.tap(find.text('지도 만들기 · 20P'));
    await tester.pumpAndSettle();
    expect(remote.requests, 0);
    await tester.tap(find.text('지도 만들기').last);
    await tester.pumpAndSettle();

    expect(remote.requests, 1);
    expect(remote.requestedMode, 'CREATE');
    expect(find.text('내 포인트 0P'), findsOneWidget);
    await tester.ensureVisible(find.text('두 생각이 서로 보완해요.'));
    expect(find.text('두 생각이 서로 보완해요.'), findsOneWidget);
    expect(find.text('① 첫 근거'), findsOneWidget);
    expect(find.text('② 둘째 근거'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
