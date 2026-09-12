// Synthetic local UI fixture. Not imported by the application entry point.
import 'package:bookstar/modules/learning/data/learning_access.dart';
import 'package:bookstar/modules/learning/data/learning_repository.dart';
import 'package:bookstar/modules/learning/data/reading_graph.dart';
import 'package:bookstar/modules/learning/view/learning_design.dart';
import 'package:bookstar/modules/learning/view/learning_home_screen.dart';
import 'package:bookstar/modules/learning/view/learning_shell.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class GraphFixtureRepository extends LearningRepository {
  GraphFixtureRepository() : super(Dio());
  int count = 84;
  static const titles = [
    '사피엔스',
    '아주 작은 습관의 힘',
    '물고기는 존재하지 않는다',
    '우리는 여전히 삶을 사랑하는가',
    '불안',
    '데미안',
    '아주 세속적인 철학'
  ];
  @override
  Future<ReviewPage> getReviews({int? cursor, bool dueOnly = false}) async {
    final start = cursor ?? 0;
    final end = (start + 30).clamp(0, count);
    return ReviewPage(
        items: [
          for (var i = start; i < end; i++)
            ReviewItem(
                bookId: i ~/ 12 + 1,
                quizId: i + 1,
                chapterId: i ~/ 3 + 1,
                chapterTitle: '${i % 12 ~/ 3 + 1}장 · 읽고 떠올린 이야기',
                bookTitle: titles[i ~/ 12 % titles.length],
                bookCover: '',
                question: '합성 질문 ${i + 1} · 이 장에서 가장 인상 깊었던 관점은 무엇인가요?',
                reviewCount: i % 4 == 0 ? 2 : 0,
                due: false,
                nextReviewAt: DateTime.utc(2030))
        ],
        totalCount: count,
        dueCount: 0,
        reviewedTodayCount: 0,
        hasNext: end < count,
        nextCursor: end < count ? 10000 - end : null);
  }
}

void main() {
  if (!kDebugMode) throw StateError('This fixture is debug only');
  final api = GraphFixtureRepository();
  final provider = ProviderContainer(overrides: [
    learningAccountProvider.overrideWithValue(999999),
    learningRepositoryProvider.overrideWithValue(api),
    // Entire synthetic dataset avoids HTTP and cannot read any real account.
    readingGraphProvider.overrideWith((ref) async {
      final items = <ReviewItem>[];
      for (var i = 0; i < api.count; i += 30) {
        items.addAll((await api.getReviews(cursor: i)).items);
      }
      return ReadingGraph.fromReviews(items);
    }),
  ]);
  final router = GoRouter(initialLocation: '/quiz', routes: [
    GoRoute(
        path: '/settings',
        builder: (_, __) =>
            const Scaffold(body: Center(child: Text('합성 화면 검증')))),
    GoRoute(
        path: '/review/quiz/:id',
        builder: (_, state) => Scaffold(
            appBar: AppBar(title: const Text('기록 열기')),
            body: Center(
                child:
                    Text('합성 목차 ${state.pathParameters['id']} · 실제 기록 아님')))),
    StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => LearningShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/quiz', builder: (_, __) => const LearningHomeScreen())
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/library',
                builder: (_, __) =>
                    ListView(padding: const EdgeInsets.all(24), children: [
                      const Text('합성 기록 수 변경 · 실제 계정 쓰기 없음'),
                      for (final n in [0, 1, 12, 84, 300])
                        Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Builder(
                                builder: (context) => FilledButton(
                                    onPressed: () {
                                      api.count = n;
                                      provider.invalidate(readingGraphProvider);
                                      context.go('/quiz');
                                    },
                                    child: Text('합성 질문 $n개 보기')))),
                    ]),
                routes: [
                  GoRoute(
                      path: 'search',
                      builder: (_, __) => const Scaffold(
                          body: Center(child: Text('빈 기록에서 책 검색 진입 확인'))))
                ])
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/review',
                builder: (_, __) =>
                    const Center(child: Text('합성 검증 · 복습 데이터 없음')))
          ]),
        ]),
  ]);
  runApp(UncontrolledProviderScope(
      container: provider,
      child: MaterialApp.router(
          theme: LearningColors.theme,
          routerConfig: router,
          debugShowCheckedModeBanner: false,
          builder: (_, child) => Banner(
              message: '합성 예시',
              location: BannerLocation.topEnd,
              child: child!))));
}
