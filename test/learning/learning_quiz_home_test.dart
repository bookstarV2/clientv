import 'package:bookstar/modules/learning/data/learning_access.dart';
import 'package:bookstar/modules/learning/data/reading_graph.dart';
import 'package:bookstar/modules/learning/view/learning_home_screen.dart';
import 'package:bookstar/modules/learning/view/reading_graph_screen.dart';
import 'package:bookstar/modules/learning/view/reading_graph_explorer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'reading_graph_test.dart' as fixtures;

void main() {
  Future<void> pump(WidgetTester tester, {bool failed = false}) async {
    final router = GoRouter(routes: [
      GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(body: LearningHomeScreen())),
      GoRoute(
          path: '/library',
          builder: (_, __) => const Scaffold(body: Text('책과 목차 선택'))),
      GoRoute(
          path: '/library/search',
          builder: (_, __) => const Scaffold(body: Text('퀴즈 책 검색'))),
    ]);
    addTearDown(router.dispose);
    await tester.pumpWidget(ProviderScope(overrides: [
      learningAccountProvider.overrideWithValue(7),
      readingGraphProvider.overrideWith((ref) async {
        if (failed) throw StateError('offline');
        return ReadingGraph.fromReviews([fixtures.item(1)]);
      }),
    ], child: MaterialApp.router(routerConfig: router)));
    await tester.pumpAndSettle();
  }

  testWidgets('quiz start comes before optional map and goes to book selection',
      (tester) async {
    await pump(tester);
    expect(tester.getTopLeft(find.text('내 책으로 퀴즈 풀기')).dy,
        lessThan(tester.getTopLeft(find.text('퀴즈로 쌓인 독서 지도')).dy));
    expect(find.byType(ReadingGraphScreen), findsNothing);
    await tester.tap(find.text('내 책으로 퀴즈 풀기'));
    await tester.pumpAndSettle();
    expect(find.text('책과 목차 선택'), findsOneWidget);
  });

  testWidgets('graph error does not block book search or quiz start',
      (tester) async {
    await pump(tester, failed: true);
    expect(find.text('내 책으로 퀴즈 풀기'), findsOneWidget);
    await tester.tap(find.text('퀴즈 풀 책 찾기'));
    await tester.pumpAndSettle();
    expect(find.text('퀴즈 책 검색'), findsOneWidget);
  });

  testWidgets(
      'map and full-screen exploration are opt-in and back returns to quiz home',
      (tester) async {
    await pump(tester);
    await tester.scrollUntilVisible(find.text('내 독서 지도 보기'), 150);
    await tester.ensureVisible(find.text('내 독서 지도 보기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('내 독서 지도 보기'));
    await tester.pumpAndSettle();
    expect(find.byType(ReadingGraphScreen), findsOneWidget);
    await tester.tap(find.byTooltip('지도 전체 화면 · 점 끌기'));
    await tester.pumpAndSettle();
    expect(find.byType(ReadingGraphExplorer), findsOneWidget);
    await tester.tap(find.byTooltip('지도 탐색 닫기'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(ReadingGraphScreen), findsNothing);
    expect(find.byType(LearningHomeScreen), findsOneWidget);
  });
}
