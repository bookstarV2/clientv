import 'package:bookstar/modules/learning/data/learning_access.dart';
import 'package:bookstar/modules/learning/data/learning_repository.dart';
import 'package:bookstar/modules/learning/data/reading_graph.dart';
import 'package:bookstar/modules/learning/view/bs_ui.dart';
import 'package:bookstar/modules/learning/view/learning_home_screen.dart';
import 'package:bookstar/modules/learning/view/reading_map_preview.dart';
import 'package:bookstar/modules/reading_challenge/model/challenge_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const _books = [
  ChallengeResponse(
      challengeId: 7, bookId: 1, bookTitle: '수족관', bookAuthor: '유래혁'),
  ChallengeResponse(
      challengeId: 8, bookId: 2, bookTitle: '작별인사', bookAuthor: '김영하'),
];

final _review = ReviewItem(
    bookId: 1,
    quizId: 1,
    chapterId: 11,
    chapterTitle: '목차 11',
    bookTitle: '수족관',
    bookCover: '',
    question: '풀어본 질문',
    reviewCount: 0,
    due: false,
    nextReviewAt: DateTime.utc(2030));

/// The visible book's title in the header (the placeholder cover repeats it).
final _graph = StateProvider<ReadingGraph?>((ref) => null);

Finder _header(String title) => find.byWidgetPredicate((widget) =>
    widget is Text && widget.data == title && widget.style?.fontSize == 20);

void main() {
  Future<void> pump(WidgetTester tester,
      {List<ChallengeResponse> books = _books,
      bool map = true,
      Object? booksError}) async {
    var bookCalls = 0;
    final router = GoRouter(routes: [
      GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(body: LearningHomeScreen())),
      for (final path in [
        '/library',
        '/library/search',
        '/library/7/chapters',
        '/library/8/chapters',
        '/settings',
        '/map',
      ])
        GoRoute(
            path: path,
            builder: (_, __) => Scaffold(body: Text('destination $path'))),
    ]);
    addTearDown(router.dispose);
    await tester.pumpWidget(ProviderScope(overrides: [
      learningAccountProvider.overrideWithValue(7),
      learningBooksProvider.overrideWith((ref) async {
        if (booksError != null && ++bookCalls == 1) throw booksError;
        return books;
      }),
      readingGraphProvider.overrideWith((ref) async =>
          ref.watch(_graph) ??
          (map ? ReadingGraph.fromReviews([_review]) : const ReadingGraph([]))),
    ], child: MaterialApp.router(routerConfig: router)));
    await tester.pumpAndSettle();
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('single CTA opens the chapters of the book on screen',
      (tester) async {
    await pump(tester);
    expect(_header('수족관'), findsOneWidget);
    expect(find.text('유래혁 저자'), findsOneWidget);
    expect(find.byType(BsPageDots), findsOneWidget);
    expect(find.text('내 책으로 퀴즈 풀기'), findsOneWidget);
    await tapVisible(tester, find.text('내 책으로 퀴즈 풀기'));
    expect(find.text('destination /library/7/chapters'), findsOneWidget);
  });

  testWidgets('swiping the carousel retargets the title and CTA',
      (tester) async {
    await pump(tester);
    await tester.fling(find.byType(PageView), const Offset(-400, 0), 1500);
    await tester.pumpAndSettle();
    expect(_header('작별인사'), findsOneWidget);
    expect(find.text('김영하 저자'), findsOneWidget);
    await tapVisible(tester, find.text('내 책으로 퀴즈 풀기'));
    expect(find.text('destination /library/8/chapters'), findsOneWidget);
  });

  testWidgets('전체 보기 opens the library and the gear opens settings',
      (tester) async {
    await pump(tester);
    await tapVisible(tester, find.text('전체 보기'));
    expect(find.text('destination /library'), findsOneWidget);
    await pump(tester);
    await tester.tap(find.byTooltip('설정'));
    await tester.pumpAndSettle();
    expect(find.text('destination /settings'), findsOneWidget);
  });

  testWidgets('map data shows the reading map preview that opens the map tab',
      (tester) async {
    await pump(tester);
    expect(find.byType(ReadingMapPreview), findsOneWidget);
    await tester.scrollUntilVisible(find.text('1권에서 쌓인 1개의 생각'), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    expect(find.text('1권에서 쌓인 1개의 생각'), findsOneWidget);
    final preview = find.byType(ReadingMapPreview);
    await tester.ensureVisible(preview);
    await tester.pumpAndSettle();
    final rect = tester.getRect(preview);
    await tester.tapAt(Offset(rect.center.dx, rect.top + 160));
    await tester.pumpAndSettle();
    expect(find.text('destination /map'), findsOneWidget);
  });

  testWidgets('switching to Default-1 keeps the book that was on screen',
      (tester) async {
    await pump(tester);
    await tester.fling(find.byType(PageView), const Offset(-400, 0), 1500);
    await tester.pumpAndSettle();
    ProviderScope.containerOf(tester.element(find.byType(LearningHomeScreen)))
        .read(_graph.notifier)
        .state = const ReadingGraph([]);
    await tester.pumpAndSettle();
    expect(find.byType(ReadingMapPreview), findsNothing);
    expect(_header('작별인사'), findsOneWidget);
    expect(tester.widget<PageView>(find.byType(PageView)).controller!.page, 1);
    await tapVisible(tester, find.text('내 책으로 퀴즈 풀기'));
    expect(find.text('destination /library/8/chapters'), findsOneWidget);
  });

  testWidgets('books without map data use the Default-1 layout',
      (tester) async {
    await pump(tester, map: false);
    expect(find.byType(ReadingMapPreview), findsNothing);
    expect(find.text('내 책으로 퀴즈 풀기').hitTestable(), findsOneWidget);
    final dots = tester.getRect(find.byType(BsPageDots));
    final cover = tester.getRect(find.byType(BsBookCover));
    expect(dots.bottom, lessThan(cover.top),
        reason: 'dots sit under the author');
    expect(dots.left, 16);
  });

  testWidgets('no saved book shows the empty home that starts a search',
      (tester) async {
    await pump(tester, books: const [], map: false);
    expect(find.text('읽고싶은 책이 있나요?'), findsOneWidget);
    expect(find.text('아직 읽은 책이 없어요'), findsOneWidget);
    await tapVisible(tester, find.text('내 책으로 퀴즈 풀기'));
    expect(find.text('destination /library/search'), findsOneWidget);
  });

  testWidgets('book load failure can be retried', (tester) async {
    await pump(tester, booksError: StateError('offline'));
    expect(find.text('내 책으로 퀴즈 풀기'), findsNothing);
    await tapVisible(tester, find.text('다시 불러오기'));
    expect(_header('수족관'), findsOneWidget);
  });
}
