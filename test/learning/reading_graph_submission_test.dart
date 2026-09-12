import 'dart:async';

import 'package:bookstar/modules/learning/data/learning_access.dart';
import 'package:bookstar/modules/learning/data/learning_repository.dart';
import 'package:bookstar/modules/learning/data/reading_graph.dart';
import 'package:bookstar/modules/learning/view/learning_design.dart';
import 'package:bookstar/modules/learning/view/learning_quiz_screen.dart';
import 'package:bookstar/modules/learning/view/reading_graph_canvas.dart';
import 'package:bookstar/modules/learning/view/reading_graph_screen.dart';
import 'package:bookstar/modules/reading_challenge/model/challenge_detail_chapter_detail.dart';
import 'package:bookstar/modules/reading_challenge/model/choice_result.dart';
import 'package:bookstar/modules/reading_challenge/model/quiz_choice.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _SubmissionRepository extends LearningRepository {
  _SubmissionRepository({bool alreadyAnswered = false}) : super(Dio()) {
    if (alreadyAnswered) reviewCounts[20] = 0;
  }

  final reviewCounts = <int, int>{19: 0};
  final reviewRequests = <String>[];
  int reviewLoads = 0;
  int firstSubmissions = 0;
  Completer<void>? submitGate;

  @override
  Future<ReviewPage> getReviews({int? cursor, bool dueOnly = false}) async {
    expect(cursor, isNull);
    expect(dueOnly, isFalse);
    reviewLoads++;
    return ReviewPage(
      items: reviewCounts.entries
          .map((entry) => ReviewItem(
                bookId: 1,
                quizId: entry.key,
                chapterId: entry.key - 10,
                chapterTitle: '목차 ${entry.key - 10}',
                bookTitle: '독서 지도에 남길 책',
                bookCover: '',
                question: '기억에서 떠올릴 질문 ${entry.key}',
                reviewCount: entry.value,
                due: false,
                nextReviewAt: DateTime(2026, 9, 12),
              ))
          .toList(),
      totalCount: reviewCounts.length,
      dueCount: 0,
      reviewedTodayCount:
          reviewCounts.values.where((count) => count > 0).length,
      hasNext: false,
    );
  }

  @override
  Future<ChallengeDetailChapterDetail> getQuiz(int chapterId) async {
    expect(chapterId, 10);
    return ChallengeDetailChapterDetail(
      chapterId: 10,
      quizId: 20,
      chapterTitle: '목차 10',
      question: '기억에서 떠올릴 질문 20',
      choices: List.generate(
          4,
          (index) => QuizChoice(
              choiceId: index + 1,
              choiceOrder: index + 1,
              choiceText: '선택 내용 ${index + 1}')),
    );
  }

  @override
  Future<bool> hasAnswered(int quizId) async =>
      reviewCounts.containsKey(quizId);

  @override
  Future<LearningQuizResult> submitFirstAnswer(
      int quizId, int choiceId, int challengeId) async {
    expect((quizId, choiceId, challengeId), (20, 2, 30));
    expect(reviewCounts.containsKey(quizId), isFalse);
    firstSubmissions++;
    await submitGate?.future;
    reviewCounts[quizId] = 0;
    return _result(0);
  }

  @override
  Future<LearningQuizResult> submitReview(
      int quizId, int choiceId, String requestId) async {
    expect((quizId, choiceId), (20, 2));
    expect(reviewCounts.containsKey(quizId), isTrue);
    reviewRequests.add(requestId);
    reviewCounts[quizId] = reviewCounts[quizId]! + 1;
    return _result(reviewCounts[quizId]!);
  }

  LearningQuizResult _result(int reviews) => LearningQuizResult(
        isCorrect: true,
        reviewCount: reviews,
        nextReviewAt: DateTime(2026, 9, 12),
        choiceResults: List.generate(
            4,
            (index) => ChoiceResult(
                  choiceId: index + 1,
                  choiceText: '선택 내용 ${index + 1}',
                  isCorrect: index == 1,
                  isSelected: index == 1,
                  explanation: '해설 내용 ${index + 1}',
                )),
      );
}

Future<GoRouter> _pumpMap(
    WidgetTester tester, _SubmissionRepository repository) async {
  final router = GoRouter(routes: [
    GoRoute(
        path: '/',
        builder: (_, __) =>
            const Scaffold(body: SafeArea(child: ReadingGraphScreen()))),
    GoRoute(
        path: '/quiz',
        builder: (_, __) =>
            const LearningQuizScreen(chapterId: 10, challengeId: 30)),
  ]);
  addTearDown(router.dispose);
  await tester.pumpWidget(ProviderScope(
      overrides: [
        learningAccountProvider.overrideWithValue(11),
        learningRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp.router(
          theme: LearningColors.theme, routerConfig: router)));
  await tester.pumpAndSettle();
  return router;
}

ReadingGraph _renderedGraph(WidgetTester tester, {bool skipOffstage = true}) =>
    tester
        .widget<ReadingGraphCanvas>(
            find.byType(ReadingGraphCanvas, skipOffstage: skipOffstage))
        .graph;

Future<void> _openAndSubmit(WidgetTester tester, GoRouter router) async {
  unawaited(router.push<void>('/quiz'));
  await tester.pumpAndSettle();
  final choice = find.text('선택 내용 2');
  await tester.scrollUntilVisible(choice, 150,
      scrollable: find.byType(Scrollable).first);
  final visible = tester
      .getRect(choice)
      .intersect(tester.getRect(find.byType(Scrollable).first));
  expect(visible.isEmpty, isFalse);
  await tester.tapAt(visible.center);
  await tester.pump();
  await tester.tap(find.text('답 확인하기'));
  await tester.pump();
}

void main() {
  testWidgets(
      'first widget submission refreshes the mounted map and adds a question',
      (tester) async {
    final repository = _SubmissionRepository()..submitGate = Completer<void>();
    final router = await _pumpMap(tester, repository);
    final before = _renderedGraph(tester);
    expect(before.questionCount, 1);
    expect(repository.reviewLoads, 1);

    await _openAndSubmit(tester, router);
    expect(repository.firstSubmissions, 1);
    expect(repository.reviewLoads, 1);
    expect(_renderedGraph(tester, skipOffstage: false).questionCount, 1);

    repository.submitGate!.complete();
    await tester.pumpAndSettle();
    expect(find.text('잘 떠올렸어요'), findsOneWidget);
    expect(repository.reviewLoads, 2);
    final refreshed = _renderedGraph(tester, skipOffstage: false);
    expect(refreshed.questionCount, 2);
    expect(refreshed.books.length, 1);
    expect(refreshed.chapterCount, 2);
    expect(refreshed.nodes.map((node) => node.id), containsAll(['q19', 'q20']));
    expect(
        refreshed.nodes.firstWhere((node) => node.id == 'q20').parentId, 'c10');

    await tester.tap(find.text('목차로 돌아가기'));
    await tester.pumpAndSettle();
    expect(_renderedGraph(tester).questionCount, 2);
    expect(repository.reviewRequests, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'repeated widget reviews refresh counts while preserving all map nodes',
      (tester) async {
    final repository = _SubmissionRepository(alreadyAnswered: true);
    final router = await _pumpMap(tester, repository);
    final before = _renderedGraph(tester);
    final ids = before.nodes.map((node) => node.id).toList();
    expect(before.questionCount, 2);

    for (var reviews = 1; reviews <= 2; reviews++) {
      await _openAndSubmit(tester, router);
      await tester.pumpAndSettle();
      expect(repository.reviewLoads, reviews + 1);
      final refreshed = _renderedGraph(tester, skipOffstage: false);
      expect(refreshed.nodes.map((node) => node.id), ids);
      expect(refreshed.questionCount, 2);
      expect(refreshed.nodes.firstWhere((node) => node.id == 'q20').reviewCount,
          reviews);
      expect(refreshed.nodes.firstWhere((node) => node.id == 'q19').reviewCount,
          0);
      await tester.tap(find.text('목차로 돌아가기'));
      await tester.pumpAndSettle();
      expect(_renderedGraph(tester).nodes.map((node) => node.id), ids);
    }

    expect(repository.firstSubmissions, 0);
    expect(repository.reviewRequests.toSet(), hasLength(2));
    expect(tester.takeException(), isNull);
  });
}
