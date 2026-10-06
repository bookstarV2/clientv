import 'dart:async';

import 'package:bookstar/infra/network/dio_client.dart';
import 'package:bookstar/modules/learning/data/learning_repository.dart';
import 'package:bookstar/modules/learning/data/learning_access.dart';
import 'package:bookstar/modules/learning/view/bs_ui.dart';
import 'package:bookstar/modules/learning/view/learning_design.dart';
import 'package:bookstar/modules/learning/view/learning_quiz_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const _empty = ReviewPage(
    items: [],
    totalCount: 0,
    dueCount: 0,
    reviewedTodayCount: 0,
    hasNext: false);

class _QuizApi {
  _QuizApi({this.review = true, this.longText = false}) {
    dio.interceptors.add(InterceptorsWrapper(onRequest: _respond));
  }

  final bool review;
  final bool longText;
  final Dio dio = Dio(BaseOptions(baseUrl: 'http://example.invalid'));
  final List<String> paths = [];
  final List<Map<String, dynamic>> submissions = [];
  final List<Map<String, dynamic>> reports = [];
  final Set<int> answered = {};
  int failSubmissions = 0;
  int failLoads = 0;
  Completer<void>? gate;

  /// Chapters 10..12 of challenge 30; chapter N has quiz N + 10.
  Set<int> completedChapters = {12};

  String choiceText(int index) => longText
      ? '$index번 선택 내용입니다. ${List.filled(9, '읽은 개념을 자신의 말로 설명해 봅니다.').join(' ')}'
      : '선택 내용 $index';

  String question(int chapterId) => longText
      ? List.filled(4, '이 목차에서 설명한 개념은 무엇인가요?').join(' ')
      : chapterId == 10
          ? '기억에서 떠올려 볼까요?'
          : '$chapterId번 목차 질문';

  Future<void> _respond(
      RequestOptions options, RequestInterceptorHandler handler) async {
    paths.add('${options.method} ${options.path}');
    final quizPath = RegExp(r'^/api/v3/learning/chapters/(\d+)/quiz$')
        .firstMatch(options.path);
    dynamic data;
    if (quizPath != null) {
      if (failLoads-- > 0) {
        handler.reject(DioException(
            requestOptions: options, type: DioExceptionType.connectionError));
        return;
      }
      final chapterId = int.parse(quizPath.group(1)!);
      data = {
        'chapters': [
          {
            'chapterId': chapterId,
            'quizId': chapterId + 10,
            'chapterTitle': '읽은 목차 $chapterId',
            'question': question(chapterId),
            'choices': List.generate(
                4,
                (index) => {
                      'choiceId': index + 1,
                      'choiceOrder': index + 1,
                      'choiceText': choiceText(index + 1),
                    }),
          }
        ]
      };
    } else if (options.path.endsWith('/status')) {
      final quizId = int.parse(options.path.split('/')[4]);
      data = {'answered': review || answered.contains(quizId)};
    } else if (options.path.endsWith('/error-report')) {
      reports.add(Map<String, dynamic>.from(options.data as Map));
      data = null;
    } else if (options.path == '/api/v3/learning/challenges/30/chapters') {
      data = {
        'chapters': [
          for (final id in [10, 11, 12])
            {
              'chapterId': id,
              'title': '$id장',
              'chapterNumber': id - 10,
              'status': completedChapters.contains(id) ? 'COMPLETED' : 'LOCKED',
            }
        ]
      };
    } else if (options.method == 'GET' &&
        options.path == '/api/v3/quiz-reviews') {
      final items = [
        for (final chapterId in [10, 11])
          if (!answered.contains(chapterId + 10))
            {
              'quizId': chapterId + 10,
              'chapterId': chapterId,
              'chapterTitle': '읽은 목차 $chapterId',
              'bookTitle': '책',
              'question': question(chapterId),
              'reviewCount': 1,
              'due': true,
              'nextReviewAt': '2026-09-10T12:00:00',
            }
      ];
      data = {
        'items': items,
        'totalCount': items.length,
        'dueCount': items.length,
        'reviewedTodayCount': 0,
        'hasNext': false,
      };
    } else if (options.method == 'POST') {
      final body = Map<String, dynamic>.from(options.data as Map);
      submissions.add(body);
      if (failSubmissions-- > 0) {
        handler.reject(DioException(
            requestOptions: options, type: DioExceptionType.receiveTimeout));
        return;
      }
      await gate?.future;
      final quizId = int.parse(options.path
          .split('/')
          .firstWhere((part) => int.tryParse(part) != null));
      answered.add(quizId);
      completedChapters.add(quizId - 10);
      data = {
        'isCorrect': body['choiceId'] == 2,
        'reviewCount': review ? 1 : 0,
        'earnedPoints': options.path.endsWith('/submit') ? 10 : 0,
        'nextReviewAt': '2026-09-10T12:00:00.123456',
        'choiceResults': List.generate(
            4,
            (index) => {
                  'choiceId': index + 1,
                  'choiceText': choiceText(index + 1),
                  'isCorrect': index == 1,
                  'isSelected': body['choiceId'] == index + 1,
                  'explanation': longText
                      ? List.filled(15, '이 개념을 책에서 다시 확인해요.').join(' ')
                      : '해설 내용 ${index + 1}',
                }),
      };
    } else {
      throw StateError('Unexpected test request: ${options.path}');
    }
    handler.resolve(Response(requestOptions: options, statusCode: 200, data: {
      'statusResponse': {'resultCode': 'OK', 'resultMessage': 'OK'},
      'data': data
    }));
  }
}

Future<void> _pumpQuiz(WidgetTester tester, _QuizApi api,
    {double scale = 1, bool library = true}) async {
  final router = GoRouter(
      initialLocation: library ? '/library/30/quiz/10' : '/review/quiz/10',
      routes: [
        GoRoute(
            path: '/library/30/chapters',
            builder: (_, __) => const Scaffold(body: Text('목차 목록'))),
        GoRoute(
            path: '/library/:challengeId/quiz/:chapterId',
            builder: (_, state) => LearningQuizScreen(
                chapterId: int.parse(state.pathParameters['chapterId']!),
                challengeId: int.parse(state.pathParameters['challengeId']!))),
        GoRoute(
            path: '/review',
            builder: (_, __) => const Scaffold(body: Text('복습 목록'))),
        GoRoute(
            path: '/review/quiz/:chapterId',
            builder: (_, state) => LearningQuizScreen(
                chapterId: int.parse(state.pathParameters['chapterId']!))),
      ]);
  addTearDown(router.dispose);
  await tester.pumpWidget(ProviderScope(
      overrides: [
        dioClientProvider.overrideWithValue(api.dio),
        learningAccountProvider.overrideWithValue(11),
        learningBooksProvider.overrideWith((ref) async => []),
        finishedLearningBooksProvider.overrideWith((ref) async => []),
        reviewOverviewProvider.overrideWith((ref) async => _empty),
      ],
      child: MaterialApp.router(
          theme: LearningColors.theme,
          routerConfig: router,
          builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(scale)),
              child: child!))));
  await tester.pumpAndSettle();
}

VoidCallback? _primary(WidgetTester tester) => tester
    .widget<TextButton>(find.descendant(
        of: find.byType(BsPrimaryButton).first,
        matching: find.byType(TextButton)))
    .onPressed;

BsOptionState _state(WidgetTester tester, String text) => tester
    .widget<BsOptionTile>(
        find.ancestor(of: find.text(text), matching: find.byType(BsOptionTile)))
    .state;

Future<void> _choose(WidgetTester tester, _QuizApi api, int index) async {
  final finder = find.text(api.choiceText(index));
  await tester.scrollUntilVisible(finder, 180,
      scrollable: find.byType(Scrollable).first, maxScrolls: 80);
  await tester.pump();
  final visibleChoice = tester
      .getRect(finder)
      .intersect(tester.getRect(find.byType(Scrollable).first));
  expect(visibleChoice.isEmpty, isFalse,
      reason: 'A real visible portion of the choice must be tappable.');
  await tester.tapAt(visibleChoice.center);
  await tester.pump();
}

Future<void> _check(WidgetTester tester) async {
  await tester.tap(find.text('정답 확인하기'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
      'choices expose an accessibility tap and submission starts disabled',
      (tester) async {
    final semantics = tester.ensureSemantics();
    final api = _QuizApi();
    await _pumpQuiz(tester, api);
    expect(find.text('AI 퀴즈'), findsOneWidget);
    expect(_primary(tester), isNull);
    final node = tester.getSemantics(find.bySemanticsLabel('1번 선택 내용 1'));
    expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
    await _choose(tester, api, 2);
    expect(_state(tester, api.choiceText(2)), BsOptionState.selected);
    expect(_primary(tester), isNotNull);
    expect(api.submissions, isEmpty);
    semantics.dispose();
  });

  testWidgets('pending submission prevents duplicate taps and choice changes',
      (tester) async {
    final api = _QuizApi()..gate = Completer<void>();
    await _pumpQuiz(tester, api);
    await _choose(tester, api, 2);
    await tester.tap(find.text('정답 확인하기'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(api.submissions, hasLength(1));
    expect(_primary(tester), isNull);
    await _choose(tester, api, 1);
    api.gate!.complete();
    await tester.pumpAndSettle();
    expect(api.submissions, hasLength(1));
    expect(api.submissions.single['choiceId'], 2);
    await tester.scrollUntilVisible(find.text('왜 정답인가요?'), 180,
        scrollable: find.byType(Scrollable).first, maxScrolls: 20);
    expect(find.text('왜 정답인가요?'), findsOneWidget);
    expect(find.text('해설 내용 2'), findsOneWidget);
    expect(_state(tester, api.choiceText(2)), BsOptionState.answer);
    expect(_state(tester, api.choiceText(1)), BsOptionState.dimmed);
  });

  testWidgets(
      'network retry keeps the selected answer and same review request id',
      (tester) async {
    final api = _QuizApi()..failSubmissions = 1;
    await _pumpQuiz(tester, api);
    await _choose(tester, api, 1);
    await _check(tester);
    expect(find.textContaining('선택한 답은 그대로'), findsOneWidget);
    expect(_state(tester, api.choiceText(1)), BsOptionState.selected);
    await _check(tester);
    expect(api.submissions, hasLength(2));
    expect(api.submissions.first, api.submissions.last);
    await tester.scrollUntilVisible(find.text('해설 내용 2'), 180,
        scrollable: find.byType(Scrollable).first, maxScrolls: 20);
    expect(find.text('해설 내용 2'), findsOneWidget);
    expect(_state(tester, api.choiceText(2)), BsOptionState.answer,
        reason: 'The correct answer carries the ring');
    expect(_state(tester, api.choiceText(1)), BsOptionState.idle,
        reason: 'A wrong pick stays readable, unlike other choices');
    expect(_state(tester, api.choiceText(3)), BsOptionState.dimmed);
  });

  testWidgets('changing a failed answer starts a different idempotency request',
      (tester) async {
    final api = _QuizApi()..failSubmissions = 1;
    await _pumpQuiz(tester, api);
    await _choose(tester, api, 1);
    await _check(tester);
    await _choose(tester, api, 2);
    await _check(tester);
    expect(api.submissions.first['requestId'],
        isNot(api.submissions.last['requestId']));
    expect(api.submissions.last['choiceId'], 2);
  });

  testWidgets(
      'first answer uses the atomic endpoint without progress or timer calls',
      (tester) async {
    final api = _QuizApi(review: false);
    await _pumpQuiz(tester, api);
    await _choose(tester, api, 2);
    await _check(tester);
    expect(api.paths, contains('POST /api/v3/learning/quizzes/20/submit'));
    expect(
        api.paths.any((path) =>
            path.contains('/progress') ||
            path.contains('timer') ||
            path.contains('challenge-submit')),
        isFalse);
    expect(api.submissions.single, {'choiceId': 2, 'challengeId': 30});
    expect(find.text('퀴즈 포인트 적립 완료'), findsOneWidget);
    expect(find.text('+10P'), findsOneWidget);
    expect(tester.getTopLeft(find.text('+10P')).dy,
        lessThan(tester.getTopLeft(find.text('기억에서 떠올려 볼까요?')).dy),
        reason: 'The reward must appear above the scrollable answer content.');
    expect(find.text('다른 퀴즈 풀기'), findsOneWidget);
    expect(find.text('이 퀴즈 다시 풀기'), findsOneWidget);
  });

  testWidgets('solving the same quiz again resets it and records a review',
      (tester) async {
    final api = _QuizApi(review: false);
    await _pumpQuiz(tester, api);
    await _choose(tester, api, 1);
    await _check(tester);
    await tester.tap(find.text('이 퀴즈 다시 풀기'));
    await tester.pumpAndSettle();
    expect(find.text('왜 정답인가요?'), findsNothing);
    expect(_primary(tester), isNull);
    expect(_state(tester, api.choiceText(1)), BsOptionState.idle);
    await _choose(tester, api, 2);
    await _check(tester);
    expect(api.paths.last, 'POST /api/v3/quiz-reviews/20');
    expect(find.text('복습 완료'), findsOneWidget);
    expect(find.text('+10P'), findsNothing);
    expect(find.text('포인트는 퀴즈 첫 풀이에 한 번 적립돼요.'), findsOneWidget);
    expect(api.submissions.last['choiceId'], 2);
    expect(api.submissions.last['requestId'], isA<String>());
    expect(_state(tester, api.choiceText(2)), BsOptionState.answer);
  });

  testWidgets('another quiz opens the next unanswered chapter, then the list',
      (tester) async {
    final api = _QuizApi(review: false);
    await _pumpQuiz(tester, api);
    await _choose(tester, api, 2);
    await _check(tester);
    await tester.tap(find.text('다른 퀴즈 풀기'));
    await tester.pumpAndSettle();
    expect(find.text('11번 목차 질문'), findsOneWidget,
        reason: 'Chapter 12 is already completed');
    await _choose(tester, api, 2);
    await _check(tester);
    expect(api.submissions.last, {'choiceId': 2, 'challengeId': 30});
    await tester.tap(find.text('다른 퀴즈 풀기'));
    await tester.pumpAndSettle();
    expect(find.text('목차 목록'), findsOneWidget);
  });

  testWidgets('review moves through due quizzes and returns to the review tab',
      (tester) async {
    final api = _QuizApi();
    await _pumpQuiz(tester, api, library: false);
    expect(find.text('복습'), findsOneWidget);
    await _choose(tester, api, 2);
    await _check(tester);
    await tester.tap(find.text('다른 퀴즈 복습하기'));
    await tester.pumpAndSettle();
    expect(find.text('11번 목차 질문'), findsOneWidget);
    await _choose(tester, api, 1);
    await _check(tester);
    expect(api.paths.last, 'POST /api/v3/quiz-reviews/21');
    await tester.tap(find.text('다른 퀴즈 복습하기'));
    await tester.pumpAndSettle();
    expect(find.text('복습 목록'), findsOneWidget);
  });

  testWidgets(
      'load failure offers retry and does not expose technical exceptions',
      (tester) async {
    final api = _QuizApi()..failLoads = 1;
    await _pumpQuiz(tester, api);
    expect(find.textContaining('DioException'), findsNothing);
    expect(find.text('정답 확인하기'), findsNothing);
    await tester.tap(find.text('다시 불러오기'));
    await tester.pumpAndSettle();
    expect(find.text('기억에서 떠올려 볼까요?'), findsOneWidget);
  });

  testWidgets('long question choices and explanation fit 320px with 2x text',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final api = _QuizApi(longText: true);
    await _pumpQuiz(tester, api, scale: 2);
    expect(tester.takeException(), isNull);
    await _choose(tester, api, 2);
    expect(_primary(tester), isNotNull);
    await _check(tester);
    expect(tester.takeException(), isNull);
    expect(api.submissions, hasLength(1));
    expect(api.submissions.single['choiceId'], 2);
    expect(
        tester
            .state<ScrollableState>(find.byType(Scrollable).first)
            .position
            .pixels,
        0);
    final explanation = List.filled(15, '이 개념을 책에서 다시 확인해요.').join(' ');
    await tester.scrollUntilVisible(find.text(explanation), 180,
        scrollable: find.byType(Scrollable).first, maxScrolls: 80);
    await tester.pumpAndSettle();
    expect(find.text(explanation), findsOneWidget);
    expect(find.text('이 퀴즈 다시 풀기').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('one report entry opens the report sheet at 320px with 2x text',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final api = _QuizApi();
    await _pumpQuiz(tester, api, scale: 2);
    expect(find.byTooltip('퀴즈 오류 신고'), findsOneWidget);
    await tester.tap(find.byTooltip('퀴즈 오류 신고'));
    await tester.pumpAndSettle();
    expect(find.text('퀴즈 내용에 오류가 있나요?'), findsOneWidget);
    expect(tester.takeException(), isNull);
    final sheetScrollable = find.descendant(
        of: find.byType(BottomSheet), matching: find.byType(Scrollable));
    await tester.scrollUntilVisible(find.text('퀴즈 신고하기'), 120,
        scrollable: sheetScrollable, maxScrolls: 40);
    await tester.pumpAndSettle();
    await tester.tap(find.text('퀴즈 신고하기'));
    await tester.pumpAndSettle();
    expect(api.reports.single['errorType'], 'OTHER');
    expect(find.text('신고가 접수되었어요.'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('확인'), 120,
        scrollable: sheetScrollable, maxScrolls: 40);
    await tester.tap(find.text('확인'));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.text('기억에서 떠올려 볼까요?'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('load failure can be retried at 320px with double-size text',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final api = _QuizApi()..failLoads = 1;
    await _pumpQuiz(tester, api, scale: 2);
    expect(tester.takeException(), isNull);
    final retry = find.text('다시 불러오기');
    if (retry.hitTestable().evaluate().isEmpty) {
      await tester.scrollUntilVisible(retry, 140,
          scrollable: find.byType(Scrollable).first, maxScrolls: 30);
    }
    await tester.tap(retry);
    await tester.pumpAndSettle();
    expect(find.text('기억에서 떠올려 볼까요?'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
