import 'package:bookstar/modules/learning/data/learning_access.dart';
import 'package:bookstar/modules/learning/data/learning_repository.dart';
import 'package:bookstar/modules/learning/view/bs_ui.dart';
import 'package:bookstar/modules/learning/view/learning_design.dart';
import 'package:bookstar/modules/learning/view/learning_quiz_screen.dart';
import 'package:bookstar/modules/learning/view/learning_review_screen.dart';
import 'package:bookstar/modules/learning/view/learning_shell.dart';
import 'package:bookstar/modules/reading_challenge/model/challenge_detail_chapter.dart';
import 'package:bookstar/modules/reading_challenge/model/challenge_detail_chapter_detail.dart';
import 'package:bookstar/modules/reading_challenge/model/challenge_detail_response.dart';
import 'package:bookstar/modules/reading_challenge/model/challenge_response.dart';
import 'package:bookstar/modules/reading_challenge/model/choice_result.dart';
import 'package:bookstar/modules/reading_challenge/model/quiz_choice.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'ui_v2_capture.dart';

const _question = '민지가 다음 날 책을 펼치기 전에 한 행동은 무엇인가요?';
const _choices = ['읽은 쪽수를 세었어요', '기억할 내용을 자기 말로 떠올렸어요', '새로운 책을 골랐어요'];
const _explanation =
    '민지는 책을 펼치기 전에 기억할 내용을 자기 말로 떠올렸어요. 기억이 흐릿한 부분은 책으로 돌아가 확인했죠.';
const _rowQuestion = '2장에서 화자인 정대의 혼이 자신이 속한 ‘몸’들의 무더기를 바라보며 느끼는 감정은 무엇인가요?';

class _Fake extends LearningRepository {
  _Fake() : super(Dio());
  final answered = <int>{};
  final reports = <int>[];

  @override
  Future<ChallengeDetailChapterDetail> getQuiz(int chapterId) async =>
      ChallengeDetailChapterDetail(
        chapterId: chapterId,
        quizId: chapterId + 100,
        chapterTitle: '목차 타이틀을 보여주세요 목차...',
        question: _question,
        choices: [
          for (final (index, text) in _choices.indexed)
            QuizChoice(
                choiceId: index + 1, choiceOrder: index + 1, choiceText: text),
        ],
      );

  @override
  Future<bool> hasAnswered(int quizId) async =>
      quizId > 200 || answered.contains(quizId);

  LearningQuizResult _result(int quizId, int choiceId) {
    answered.add(quizId);
    return LearningQuizResult(isCorrect: choiceId == 1, choiceResults: [
      for (final (index, text) in _choices.indexed)
        ChoiceResult(
            choiceId: index + 1,
            choiceText: text,
            isCorrect: index == 0,
            isSelected: choiceId == index + 1,
            explanation: index == 0 ? _explanation : ''),
    ]);
  }

  @override
  Future<LearningQuizResult> submitFirstAnswer(
          int quizId, int choiceId, int challengeId) async =>
      _result(quizId, choiceId);

  @override
  Future<LearningQuizResult> submitReview(
          int quizId, int choiceId, String requestId) async =>
      _result(quizId, choiceId);

  @override
  Future<void> reportQuiz(int quizId,
      {required String errorType,
      String content = '',
      required String requestId}) async {
    reports.add(quizId);
  }

  @override
  Future<ChallengeDetailResponse> getChapters(int challengeId) async =>
      const ChallengeDetailResponse(chapters: [
        ChallengeDetailChapter(chapterId: 10, title: '1장', chapterNumber: 0),
        ChallengeDetailChapter(chapterId: 11, title: '2장', chapterNumber: 1),
      ]);

  @override
  Future<ReviewPage> getReviews(
      {int? cursor, bool dueOnly = false, bool reviewedOnly = false}) async {
    final items = reviewedOnly
        ? [
            for (var i = 0; i < 8; i++)
              _item(i + 1, _rowQuestion, '수족관', 2,
                  reviewedAt: DateTime(2026, 9, 9, 10)),
          ]
        : [
            _item(
                1,
                '1장에서 동호가 상무관에서 시신들을 관리하며 촛불을 켜두는 행위가 상징하는 근본적인 의미는 무엇일까요?',
                '소년이 온다',
                1,
                chapterTitle: '1장 어린 새'),
            for (var i = 2; i <= 5; i++) _item(i, _rowQuestion, '수족관', 2),
          ].where((item) => !answered.contains(item.quizId)).toList();
    return ReviewPage(
        items: items,
        totalCount: items.length,
        dueCount: items.length,
        reviewedTodayCount: 0,
        hasNext: false);
  }
}

ReviewItem _item(int index, String question, String book, int bookId,
        {String chapterTitle = '2장', DateTime? reviewedAt}) =>
    ReviewItem(
      bookId: bookId,
      quizId: 200 + index,
      chapterId: 100 + index,
      chapterTitle: chapterTitle,
      bookTitle: book,
      bookCover: '',
      question: question,
      reviewCount: 1,
      due: true,
      nextReviewAt: DateTime(2026, 9, 10),
      lastReviewedAt: reviewedAt,
    );

Widget _app(_Fake fake, String initialLocation) {
  final router = GoRouter(initialLocation: initialLocation, routes: [
    GoRoute(
        path: '/review',
        builder: (_, __) => Scaffold(
              backgroundColor: Bs.bg,
              extendBody: true,
              body: const LearningReviewScreen(),
              bottomNavigationBar: BsNavBar(currentIndex: 2, onTap: (_) {}),
            ),
        routes: [
          GoRoute(
              path: 'history',
              builder: (_, __) => const LearningReviewHistoryPage()),
          GoRoute(
              path: 'quiz/:chapterId',
              builder: (_, state) => LearningQuizScreen(
                  chapterId: int.parse(state.pathParameters['chapterId']!))),
        ]),
    GoRoute(
        path: '/library/:challengeId/quiz/:chapterId',
        builder: (_, state) => LearningQuizScreen(
            chapterId: int.parse(state.pathParameters['chapterId']!),
            challengeId: int.parse(state.pathParameters['challengeId']!))),
  ]);
  return ProviderScope(
    overrides: [
      learningAccountProvider.overrideWithValue(1),
      learningRepositoryProvider.overrideWithValue(fake),
      learningBooksProvider.overrideWith((ref) async => const [
            ChallengeResponse(
                challengeId: 30,
                bookId: 2,
                bookTitle: '수족관',
                bookAuthor: '유래혁'),
          ]),
      finishedLearningBooksProvider.overrideWith((ref) async => const [
            ChallengeResponse(
                challengeId: 31,
                bookId: 1,
                bookTitle: '소년이 온다',
                bookAuthor: '한강'),
          ]),
    ],
    child: MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: LearningColors.theme,
      routerConfig: router,
    ),
  );
}

Future<void> _tapText(WidgetTester tester, String text) async {
  await tester.tap(find.text(text).last);
  await tester.pumpAndSettle();
}

Future<void> _answer(WidgetTester tester) async {
  await _tapText(tester, _choices.first);
  await _tapText(tester, '정답 확인하기');
}

void main() {
  setUpAll(setUpBsCapture);

  const library = '/library/30/quiz/10';
  final libraryFrames = <String, Future<void> Function(WidgetTester)>{
    '2.3 퀴즈풀기_Default': (_) async {},
    '2.3 퀴즈풀기_Sellected': (tester) => _tapText(tester, _choices.first),
    '2.3 정답확인(정답)_Default': _answer,
    '2.3.1 오류신고_Default': (tester) async {
      await tester.tap(find.byTooltip('퀴즈 오류 신고'));
      await tester.pumpAndSettle();
    },
    '2.3.1 오류신고_Completed': (tester) async {
      await tester.tap(find.byTooltip('퀴즈 오류 신고'));
      await tester.pumpAndSettle();
      await _tapText(tester, '퀴즈 신고하기');
    },
  };
  for (final frame in libraryFrames.entries) {
    testWidgets(frame.key, (tester) async {
      await captureBsScreen(tester, _app(_Fake(), library), frame.key,
          beforeCapture: () => frame.value(tester));
    });
  }

  // 3.2: the review session goes quiz by quiz ("다른 퀴즈 복습하기"), and a
  // solved quiz can be solved again ("이 퀴즈 다시 풀기"). The Figma variants
  // share one placeholder content, so each is a step of that session.
  Future<void> retry(WidgetTester tester) async {
    await _answer(tester);
    await _tapText(tester, '이 퀴즈 다시 풀기');
  }

  Future<void> nextQuiz(WidgetTester tester, int count) async {
    for (var i = 0; i < count; i++) {
      await _answer(tester);
      await _tapText(tester, '다른 퀴즈 복습하기');
    }
  }

  final reviewFrames = <String, Future<void> Function(WidgetTester)>{
    '3.2 퀴즈풀기_Default': (_) async {},
    '3.2 퀴즈풀기_Sellected': (tester) => _tapText(tester, _choices.first),
    '3.2 정답확인(정답)_Default': _answer,
    '3.2 퀴즈풀기_Default-1': retry,
    '3.2 퀴즈풀기_Sellected-1': (tester) async {
      await retry(tester);
      await _tapText(tester, _choices.first);
    },
    '3.2 정답확인(정답)_Default-1': (tester) async {
      await retry(tester);
      await _answer(tester);
    },
    '3.2 퀴즈풀기_Default-2': (tester) => nextQuiz(tester, 1),
    '3.2 퀴즈풀기_Sellected-2': (tester) async {
      await nextQuiz(tester, 1);
      await _tapText(tester, _choices.first);
    },
    '3.2 정답확인(정답)_Default-2': (tester) async {
      await nextQuiz(tester, 1);
      await _answer(tester);
    },
    '3.2 퀴즈풀기_Default-3': (tester) async {
      await nextQuiz(tester, 2);
      await _tapText(tester, _choices.first);
    },
    '3.2 정답확인(정답)_Default-3': (tester) async {
      await nextQuiz(tester, 2);
      await _answer(tester);
    },
    '3.2 퀴즈풀기_Default-4': (tester) => nextQuiz(tester, 3),
  };
  for (final frame in reviewFrames.entries) {
    testWidgets(frame.key, (tester) async {
      await captureBsScreen(
          tester, _app(_Fake(), '/review/quiz/101'), frame.key,
          beforeCapture: () => frame.value(tester));
    });
  }

  testWidgets('3.1 메인_Default', (tester) async {
    await captureBsScreen(tester, _app(_Fake(), '/review'), '3.1 메인_Default');
  });

  testWidgets('3.1 메인_Default-1', (tester) async {
    // Same screen after coming back from the history page.
    await captureBsScreen(tester, _app(_Fake(), '/review'), '3.1 메인_Default-1',
        beforeCapture: () async {
      await tester.tap(find.text('복습한 퀴즈'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('뒤로'));
      await tester.pumpAndSettle();
    });
  });

  testWidgets('3.3 복습한퀴즈_Default', (tester) async {
    await captureBsScreen(
        tester, _app(_Fake(), '/review/history'), '3.3 복습한퀴즈_Default');
  });
}
