import 'package:bookstar/modules/learning/data/learning_footprint.dart';
import 'package:bookstar/modules/learning/data/learning_repository.dart';
import 'package:bookstar/modules/learning/data/library_layout.dart';
import 'package:bookstar/modules/learning/view/bs_ui.dart';
import 'package:bookstar/modules/learning/view/learning_book_detail_screen.dart';
import 'package:bookstar/modules/learning/view/learning_chapters_screen.dart';
import 'package:bookstar/modules/learning/view/learning_design.dart';
import 'package:bookstar/modules/learning/view/learning_library_screen.dart';
import 'package:bookstar/modules/learning/view/learning_search_screen.dart';
import 'package:bookstar/modules/learning/view/learning_shell.dart';
import 'package:bookstar/modules/reading_challenge/model/challenge_detail_book_overview.dart';
import 'package:bookstar/modules/reading_challenge/model/challenge_detail_chapter.dart';
import 'package:bookstar/modules/reading_challenge/model/challenge_detail_response.dart';
import 'package:bookstar/modules/reading_challenge/model/challenge_response.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ui_v2_capture.dart';

ChallengeResponse _book(int id, String title, String author,
        {double progress = 40}) =>
    ChallengeResponse(
        challengeId: id,
        bookId: id,
        bookTitle: title,
        bookAuthor: author,
        progressRate: progress);

LearningFootprint _footprint(int books, int chapters, int quizzes) =>
    LearningFootprint(
        answeredQuizCount: quizzes,
        reviewedQuizCount: 0,
        bookCount: books,
        chapterCount: chapters,
        generatedAt: DateTime(2026, 10, 2));

const _seneca = '세네카, 오늘을 빼앗기고 있는 당신에게';
const _synopsis = '『세네카, 오늘을 빼앗기고 있는 당신에게』는 로마 제정기의 스토아 철학자 세네카의 대화편 다섯 편에서 '
    '핵심 사유를 선별해 55편의 짧은 글로 재구성한 편역서다. 세네카는 네로 황제의 스승이자 고문으로 '
    '제국의 운명을 좌우하면서, 누구보다 바쁜 삶 한가운데에서 시간의 본질을 꿰뚫었다. "삶은 짧지 않다. '
    '우리가 짧게 만들 뿐이다." 그의 진단은 2000년이 지난 지금도 한 글자도 고칠 필요가 없다. 이 책은 '
    '시간에 쫓기며 살아가는 현대인에게 시간을 되찾는 것이 곧 자기 자신을 되찾는 것임을 일깨운다. '
    '순서대로 읽어도 좋고, 마음이 가는 대로 펼쳐 읽어도 좋다.';

const _recommendBestseller = LearningBookPage([
  LearningBook(1, _seneca, '세네카', '', 55),
  LearningBook(2, '한국사 이상 현상 연구원(일반판)', '최인서', '', 12),
  LearningBook(3, '수족관', '유래혁', '', 10),
  LearningBook(4, '싯다르타', '헤르만헤세', '', 12),
], false, null);

const _recommendPopular = LearningBookPage([
  LearningBook(4, '싯다르타', '헤르만헤세', '', 12),
  LearningBook(3, '수족관', '유래혁', '', 10),
  LearningBook(1, _seneca, '세네카', '', 55),
  LearningBook(2, '한국사 이상 현상 연구원(일반판)', '최인서', '', 12),
], false, null);

class _SearchRepository extends LearningRepository {
  _SearchRepository() : super(Dio());

  @override
  Future<LearningBookPage> searchBooks(String query, {int? cursor}) async =>
      const LearningBookPage([
        LearningBook(1, _seneca, '세네카', '', 55),
        LearningBook(5, '세상을 움직이는 아이들은 무엇이 다른가', '임지은', '', 8),
      ], false, null);
}

Widget _app(Widget home, List<Override> overrides) => ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: LearningColors.theme,
        home: home,
      ),
    );

Widget _tab(Widget screen) => Scaffold(
      backgroundColor: Bs.bg,
      extendBody: true,
      body: screen,
      bottomNavigationBar: BsNavBar(currentIndex: 1, onTap: (_) {}),
    );

Future<void> _library(
  WidgetTester tester,
  String name, {
  required List<ChallengeResponse> ongoing,
  List<ChallengeResponse> finished = const [],
  LearningFootprint? footprint,
  bool grid = false,
  bool showFinished = false,
}) async {
  SharedPreferences.setMockInitialValues({
    LibraryLayoutStore.preferenceKey:
        (grid ? LibraryLayout.twoColumns : LibraryLayout.list).name,
  });
  await captureBsScreen(
    tester,
    _app(_tab(const LearningLibraryScreen()), [
      learningBooksProvider.overrideWith((ref) async => ongoing),
      finishedLearningBooksProvider.overrideWith((ref) async => finished),
      learningFootprintProvider
          .overrideWith((ref) async => footprint ?? _footprint(3, 3, 3)),
    ]),
    name,
    beforeCapture: showFinished
        ? () async {
            await tester.tap(find.text('완독한 책'));
            await tester.pump();
          }
        : null,
  );
}

ChallengeDetailResponse _chapters({required int completed}) =>
    ChallengeDetailResponse(
      bookOverview:
          const ChallengeDetailBookOverview(title: '수족관', author: '유래혁'),
      chapters: [
        for (var i = 0; i < 5; i++)
          ChallengeDetailChapter(
            chapterId: i + 1,
            chapterNumber: i,
            title: '목차 타이틀을 보여주세요',
            status: i >= 5 - completed
                ? ChapterStatus.COMPLETED
                : ChapterStatus.PROCESSING,
          ),
      ],
    );

Future<void> _search(WidgetTester tester, String name,
    {Future<void> Function()? then}) async {
  SharedPreferences.setMockInitialValues({});
  await captureBsScreen(
    tester,
    _app(const LearningSearchScreen(), [
      learningRepositoryProvider.overrideWithValue(_SearchRepository()),
      recommendedBooksProvider(BookRecommendationSort.bestseller)
          .overrideWith((ref) async => _recommendBestseller),
      recommendedBooksProvider(BookRecommendationSort.popular)
          .overrideWith((ref) async => _recommendPopular),
    ]),
    name,
    beforeCapture: then,
  );
}

Future<void> _detail(WidgetTester tester, String name,
    {bool expand = false}) async {
  await captureBsScreen(
    tester,
    _app(const LearningBookDetailScreen(bookId: 1), [
      learningBookDetailProvider(1)
          .overrideWith((ref) async => LearningBookDetail(
                bookId: 1,
                title: _seneca,
                author: '세네카',
                bookCover: '',
                publisher: '',
                description: _synopsis,
                chapterCount: 5,
                chapters: [
                  for (var i = 0; i < 5; i++)
                    LearningBookChapter(
                        chapterId: 10 + i,
                        chapterNumber: 0,
                        title: '목차 타이틀을 보여주세요',
                        hasQuiz: true),
                ],
              )),
    ]),
    name,
    beforeCapture: expand
        ? () async {
            await tester.tap(find.text('더보기'));
            await tester.pump();
          }
        : null,
  );
}

void main() {
  setUpAll(setUpBsCapture);

  final ongoing = [
    _book(3, '수족관', '유래혁'),
    _book(2, '소년이 온다', '한강'),
    _book(1, '눈물꽃 소년', '박노해'),
  ];

  for (final name in [
    '2.1 메인_Default',
    '2.1 메인_Default-1',
    '2.1 메인_Default(목록보기)',
  ]) {
    testWidgets(name, (tester) => _library(tester, name, ongoing: ongoing));
  }

  testWidgets('2.1 메인_Default(목록보기)-1', (tester) async {
    await _library(tester, '2.1 메인_Default(목록보기)-1', ongoing: [
      _book(3, '수족관', '유래혁'),
      _book(2, '소년이 온다', '한강'),
      _book(1, '소년이 온다', '한강'),
    ]);
  });

  testWidgets('2.1 메인_Empty', (tester) async {
    await _library(tester, '2.1 메인_Empty',
        ongoing: const [], footprint: _footprint(0, 0, 0));
  });

  testWidgets('2.1 메인_Default(2열보기)', (tester) async {
    await _library(tester, '2.1 메인_Default(2열보기)',
        ongoing: [...ongoing, _book(0, '싯다르타', '헤르만헤세')], grid: true);
  });

  final finished = [
    for (var i = 4; i > 0; i--) _book(i, '수족관', '유래혁', progress: 100),
  ];

  testWidgets('2.1 메인_Default(2열보기)-1', (tester) async {
    await _library(tester, '2.1 메인_Default(2열보기)-1',
        ongoing: ongoing, finished: finished, grid: true, showFinished: true);
  });

  testWidgets('2.1 메인(완독)_Default', (tester) async {
    await _library(tester, '2.1 메인(완독)_Default',
        ongoing: ongoing,
        finished: [
          _book(3, '수족관', '유래혁', progress: 100),
          _book(2, '소년이 온다', '한강', progress: 100),
          _book(1, '소년이 온다', '한강', progress: 100),
        ],
        showFinished: true);
  });

  testWidgets('2.4.3 책 등록_Completed', (tester) async {
    await _library(tester, '2.4.3 책 등록_Completed',
        ongoing: [_book(9, _seneca, '유래혁', progress: 0), ...ongoing],
        footprint: _footprint(4, 3, 3));
  });

  for (final (name, completed) in [
    ('2.2 목차선택_Default', 2),
    ('2.2 목차선택_Default-1', 2),
    ('2.2 목차선택_Default-2', 5),
  ]) {
    testWidgets(name, (tester) async {
      await captureBsScreen(
        tester,
        _app(const LearningChaptersScreen(challengeId: 7), [
          learningChaptersProvider(7)
              .overrideWith((ref) async => _chapters(completed: completed)),
        ]),
        name,
      );
    });
  }

  for (final name in [
    '2.4 책 찾기_Default',
    '2.4 책 찾기_Default(베스트셀러순)',
    '2.4 책 찾기_Default(베스트셀러순)-1',
  ]) {
    testWidgets(name, (tester) => _search(tester, name));
  }

  testWidgets('2.4 책 찾기_Default(유저인기순)', (tester) async {
    await _search(tester, '2.4 책 찾기_Default(유저인기순)', then: () async {
      await tester.tap(find.text('베스트셀러순'));
      await tester.pump();
    });
  });

  testWidgets('2.4.1 책 검색_Default', (tester) async {
    await _search(tester, '2.4.1 책 검색_Default', then: () async {
      await tester.tap(find.byType(TextField));
      await tester.pump();
    });
  });

  testWidgets('2.4.1 책 검색_Active', (tester) async {
    await _search(tester, '2.4.1 책 검색_Active', then: () async {
      await tester.enterText(find.byType(TextField), _seneca);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();
    });
  });

  testWidgets('2.4.1 책 검색_Completed', (tester) async {
    await _search(tester, '2.4.1 책 검색_Completed', then: () async {
      await tester.enterText(find.byType(TextField), _seneca);
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();
      await tester.pump();
    });
  });

  for (final (name, expand) in [
    ('2.4.2 검색한 책 상세_Default', false),
    ('2.4.2 검색한 책 상세_Default-1', true),
    ('2.4.2 검색한 책 상세_Default-2', true),
    ('2.4.2 검색한 책 상세_Default-3', true),
  ]) {
    testWidgets(name, (tester) => _detail(tester, name, expand: expand));
  }
}
