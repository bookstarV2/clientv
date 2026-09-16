import 'package:bookstar/modules/learning/data/learning_repository.dart';
import 'package:bookstar/modules/learning/data/reading_graph.dart';
import 'package:bookstar/modules/learning/view/learning_chapters_screen.dart';
import 'package:bookstar/modules/learning/view/learning_design.dart';
import 'package:bookstar/modules/learning/view/learning_home_screen.dart';
import 'package:bookstar/modules/learning/view/learning_library_screen.dart';
import 'package:bookstar/modules/reading_challenge/model/challenge_detail_book_overview.dart';
import 'package:bookstar/modules/reading_challenge/model/challenge_detail_chapter.dart';
import 'package:bookstar/modules/reading_challenge/model/challenge_detail_response.dart';
import 'package:bookstar/modules/reading_challenge/model/challenge_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _title = '아주 긴 책 제목을 가진 독서와 기억의 관계에 관한 여러 가지 생각과 실제 생활에서 활용할 수 있는 방법';
const _book = ChallengeResponse(
    challengeId: 7, bookTitle: _title, bookAuthor: '여러 명의 작가와 긴 이름을 가진 공동 저자들');

void main() {
  testWidgets('empty home exposes book search above bottom navigation on SE',
      (tester) async {
    tester.view.physicalSize = const Size(375, 667);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(ProviderScope(
        overrides: [
          readingGraphProvider
              .overrideWith((ref) async => const ReadingGraph([])),
        ],
        child: MaterialApp(
            theme: LearningColors.theme,
            home: Scaffold(
                appBar: AppBar(title: const Text('북스타')),
                body: const SafeArea(child: LearningHomeScreen()),
                bottomNavigationBar: const SizedBox(height: 90)))));
    await tester.pumpAndSettle();
    final button = tester.getRect(find.text('퀴즈 풀 책 찾기'));
    expect(button.bottom, lessThan(577));
    expect(find.text('퀴즈 풀 책 찾기').hitTestable(), findsOneWidget);
    expect(find.text('내 책으로 퀴즈 풀기').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  for (final populated in [false, true]) {
    testWidgets('home ${populated ? 'long book' : 'empty'} fits 320px 2x',
        (tester) async {
      await _pump(tester, const LearningHomeScreen(), overrides: [
        readingGraphProvider
            .overrideWith((ref) async => ReadingGraph.fromReviews(populated
                ? [
                    ReviewItem(
                        bookId: 5,
                        quizId: 1,
                        chapterId: 2,
                        chapterTitle: '긴 목차',
                        bookTitle: _title,
                        bookCover: '',
                        question: '긴 질문',
                        reviewCount: 0,
                        due: false,
                        nextReviewAt: DateTime.utc(2030))
                  ]
                : [])),
      ]);
      await _scan(tester);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
      'map failure never blocks quiz home and retry restores secondary map',
      (tester) async {
    var calls = 0;
    await _pump(tester, const LearningHomeScreen(), overrides: [
      readingGraphProvider.overrideWith((ref) async {
        if (++calls == 1) throw StateError('map unavailable');
        return const ReadingGraph([]);
      }),
    ]);
    await _reveal(tester, find.text('내 책으로 퀴즈 풀기'));
    expect(find.text('내 책으로 퀴즈 풀기').hitTestable(), findsOneWidget);
    await _reveal(tester, find.text('퀴즈 풀 책 찾기'));
    expect(find.text('퀴즈 풀 책 찾기').hitTestable(), findsOneWidget);
    await _reveal(tester, find.text('지도 다시 불러오기'));
    await tester.tap(find.text('지도 다시 불러오기'));
    await tester.pumpAndSettle();
    expect(calls, 2);
    await _reveal(tester, find.text('한 문제를 풀면 책과 목차, 질문의 첫 점들이 연결돼요.'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('library empty and finished empty remain readable at 320px 2x',
      (tester) async {
    await _pump(tester, const LearningLibraryScreen(), overrides: [
      learningBooksProvider.overrideWith((ref) async => []),
      finishedLearningBooksProvider.overrideWith((ref) async => []),
    ]);
    await _reveal(tester, find.text('책을 담아 볼까요?'));
    await _reveal(tester, find.text('퀴즈를 마친 책'));
    await tester.tap(find.text('퀴즈를 마친 책'));
    await tester.pumpAndSettle();
    await _reveal(tester, find.text('아직 퀴즈를 마친 책이 없어요'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('library long title and author fit 320px 2x', (tester) async {
    await _pump(tester, const LearningLibraryScreen(), overrides: [
      learningBooksProvider.overrideWith((ref) async => [_book]),
    ]);
    await _scan(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('library failed request can retry at 320px 2x', (tester) async {
    var calls = 0;
    await _pump(tester, const LearningLibraryScreen(), overrides: [
      learningBooksProvider.overrideWith((ref) async {
        if (++calls == 1) throw StateError('library unavailable');
        return [];
      }),
    ]);
    await _reveal(tester, find.text('다시 불러오기'));
    await tester.tap(find.text('다시 불러오기'));
    await tester.pumpAndSettle();
    await _reveal(tester, find.text('책을 담아 볼까요?'));
    expect(calls, 2);
    expect(tester.takeException(), isNull);
  });

  for (final populated in [false, true]) {
    testWidgets('chapters ${populated ? 'long titles' : 'empty'} fit 320px 2x',
        (tester) async {
      await _pump(tester, const LearningChaptersScreen(challengeId: 7),
          page: true,
          overrides: [
            learningChaptersProvider(7).overrideWith((ref) async =>
                ChallengeDetailResponse(
                    bookOverview: const ChallengeDetailBookOverview(
                        title: _title, author: '저자와 공동 저자의 긴 이름'),
                    chapters: populated
                        ? [
                            ChallengeDetailChapter(
                                chapterId: 10,
                                title: List.filled(5, _title).join(' ')),
                            const ChallengeDetailChapter(
                                chapterId: 11,
                                title: '두 번째 목차',
                                status: ChapterStatus.COMPLETED),
                          ]
                        : [])),
          ]);
      await _scan(tester);
      expect(tester.takeException(), isNull);
      if (!populated) {
        await _reveal(tester, find.text('지금 풀 수 있는 퀴즈가 없어요'));
      }
    });
  }

  testWidgets('chapters API failure retry fits 320px 2x', (tester) async {
    var calls = 0;
    await _pump(tester, const LearningChaptersScreen(challengeId: 7),
        page: true,
        overrides: [
          learningChaptersProvider(7).overrideWith((ref) async {
            if (++calls == 1) throw StateError('chapters unavailable');
            return const ChallengeDetailResponse();
          }),
        ]);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('다시 불러오기'));
    await tester.pumpAndSettle();
    expect(calls, 2);
    await _reveal(tester, find.text('지금 풀 수 있는 퀴즈가 없어요'));
  });
}

Future<void> _pump(WidgetTester tester, Widget screen,
    {required List<Override> overrides, bool page = false}) async {
  tester.view.physicalSize = const Size(320, 568);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(ProviderScope(
      overrides: overrides,
      child: MaterialApp(
          theme: LearningColors.theme,
          builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(2)),
              child: child!),
          home: page ? screen : Scaffold(body: screen))));
  await tester.pumpAndSettle();
}

Future<void> _scan(WidgetTester tester) async {
  final position =
      tester.state<ScrollableState>(find.byType(Scrollable).first).position;
  for (var step = 0; step < 100; step++) {
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    if (position.pixels >= position.maxScrollExtent) break;
    position.jumpTo((position.pixels + 220).clamp(0, position.maxScrollExtent));
  }
}

Future<void> _reveal(WidgetTester tester, Finder target) async {
  final scrollable = find.byType(Scrollable).first;
  tester.state<ScrollableState>(scrollable).position.jumpTo(0);
  await tester.pump();
  await tester.scrollUntilVisible(target, 140,
      scrollable: scrollable, maxScrolls: 100);
  await tester.pumpAndSettle();
}
