import 'dart:async';

import 'package:bookstar/infra/network/dio_client.dart';
import 'package:bookstar/modules/learning/data/learning_repository.dart';
import 'package:bookstar/modules/learning/data/learning_access.dart';
import 'package:bookstar/modules/learning/view/learning_design.dart';
import 'package:bookstar/modules/learning/view/learning_quiz_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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
  int failSubmissions = 0;
  int failLoads = 0;
  Completer<void>? gate;

  String choiceText(int index) => longText
      ? '$index번 선택 내용입니다. ${List.filled(9, '읽은 개념을 자신의 말로 설명해 봅니다.').join(' ')}'
      : '선택 내용 $index';

  Future<void> _respond(
      RequestOptions options, RequestInterceptorHandler handler) async {
    paths.add(options.path);
    dynamic data;
    if (options.path == '/api/v3/learning/chapters/10/quiz') {
      if (failLoads-- > 0) {
        handler.reject(DioException(
            requestOptions: options, type: DioExceptionType.connectionError));
        return;
      }
      data = {
        'chapters': [
          {
            'chapterId': 10,
            'quizId': 20,
            'chapterTitle': '읽은 목차',
            'question': longText
                ? List.filled(4, '이 목차에서 설명한 개념은 무엇인가요?').join(' ')
                : '기억에서 떠올려 볼까요?',
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
      data = {'answered': review};
    } else if (options.method == 'POST') {
      final body = Map<String, dynamic>.from(options.data as Map);
      submissions.add(body);
      if (failSubmissions-- > 0) {
        handler.reject(DioException(
            requestOptions: options, type: DioExceptionType.receiveTimeout));
        return;
      }
      await gate?.future;
      data = {
        'isCorrect': body['choiceId'] == 2,
        'reviewCount': review ? 1 : 0,
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
    {double scale = 1}) async {
  await tester.pumpWidget(ProviderScope(
      overrides: [
        dioClientProvider.overrideWithValue(api.dio),
        learningAccountProvider.overrideWithValue(11),
        learningBooksProvider.overrideWith((ref) async => []),
        finishedLearningBooksProvider.overrideWith((ref) async => []),
        reviewOverviewProvider.overrideWith((ref) async => _empty),
      ],
      child: MaterialApp(
          theme: LearningColors.theme,
          builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(scale)),
              child: child!),
          home: const LearningQuizScreen(chapterId: 10, challengeId: 30))));
  await tester.pumpAndSettle();
}

Future<void> _choose(WidgetTester tester, _QuizApi api, int index) async {
  final finder = find.text(api.choiceText(index));
  await tester.scrollUntilVisible(finder, 180,
      scrollable: find.byType(Scrollable).first, maxScrolls: 80);
  final visibleChoice = tester
      .getRect(finder)
      .intersect(tester.getRect(find.byType(Scrollable).first));
  expect(visibleChoice.isEmpty, isFalse,
      reason: 'A real visible portion of the choice must be tappable.');
  await tester.tapAt(visibleChoice.center);
  await tester.pump();
}

void main() {
  testWidgets(
      'choices expose an accessibility tap and submission starts disabled',
      (tester) async {
    final semantics = tester.ensureSemantics();
    final api = _QuizApi();
    await _pumpQuiz(tester, api);
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull);
    final node = tester.getSemantics(find.bySemanticsLabel('1번 선택 내용 1'));
    expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
    await _choose(tester, api, 2);
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNotNull);
    expect(api.submissions, isEmpty);
    semantics.dispose();
  });

  testWidgets('pending submission prevents duplicate taps and choice changes',
      (tester) async {
    final api = _QuizApi()..gate = Completer<void>();
    await _pumpQuiz(tester, api);
    await _choose(tester, api, 2);
    await tester.tap(find.text('답 확인하기'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(api.submissions, hasLength(1));
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull);
    await _choose(tester, api, 1);
    api.gate!.complete();
    await tester.pumpAndSettle();
    expect(api.submissions, hasLength(1));
    expect(api.submissions.single['choiceId'], 2);
    expect(find.text('잘 떠올렸어요'), findsOneWidget);
    expect(find.text('해설 내용 2'), findsOneWidget);
  });

  testWidgets(
      'network retry keeps the selected answer and same review request id',
      (tester) async {
    final api = _QuizApi()..failSubmissions = 1;
    await _pumpQuiz(tester, api);
    await _choose(tester, api, 1);
    await tester.tap(find.text('답 확인하기'));
    await tester.pumpAndSettle();
    expect(find.textContaining('선택한 답은 그대로'), findsOneWidget);
    await tester.tap(find.text('답 확인하기'));
    await tester.pumpAndSettle();
    expect(api.submissions, hasLength(2));
    expect(api.submissions.first, api.submissions.last);
    expect(find.text('함께 다시 짚어봐요'), findsOneWidget);
    expect(find.text('내가 고른 답 살펴보기'), findsOneWidget);
  });

  testWidgets('changing a failed answer starts a different idempotency request',
      (tester) async {
    final api = _QuizApi()..failSubmissions = 1;
    await _pumpQuiz(tester, api);
    await _choose(tester, api, 1);
    await tester.tap(find.text('답 확인하기'));
    await tester.pumpAndSettle();
    await _choose(tester, api, 2);
    await tester.tap(find.text('답 확인하기'));
    await tester.pumpAndSettle();
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
    await tester.tap(find.text('답 확인하기'));
    await tester.pumpAndSettle();
    expect(api.paths, contains('/api/v3/learning/quizzes/20/submit'));
    expect(
        api.paths.any((path) =>
            path.contains('/progress') ||
            path.contains('timer') ||
            path.contains('challenge-submit')),
        isFalse);
    expect(api.submissions.single, {'choiceId': 2, 'challengeId': 30});
    expect(find.text('9월 10일에 다시 만나요'), findsOneWidget);
  });

  testWidgets(
      'load failure offers retry and does not expose technical exceptions',
      (tester) async {
    final api = _QuizApi()..failLoads = 1;
    await _pumpQuiz(tester, api);
    expect(find.textContaining('DioException'), findsNothing);
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
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNotNull);
    await tester.tap(find.text('답 확인하기'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(api.submissions, hasLength(1));
    expect(api.submissions.single['choiceId'], 2);
    expect(
        tester
            .state<ScrollableState>(find.byType(Scrollable).first)
            .position
            .pixels,
        0);
    expect(find.text('잘 떠올렸어요'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('9월 10일에 다시 만나요'), 180,
        scrollable: find.byType(Scrollable).first, maxScrolls: 80);
    await tester.pumpAndSettle();
    expect(find.text('9월 10일에 다시 만나요'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('AI information sheet scrolls at 320px with double-size text',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await _pumpQuiz(tester, _QuizApi(), scale: 2);
    await tester.tap(find.byTooltip('퀴즈 내용 안내'));
    await tester.pumpAndSettle();
    expect(find.text('AI 퀴즈와 함께 읽는 법'), findsOneWidget);
    expect(tester.takeException(), isNull);
    final sheetScrollable = find.descendant(
        of: find.byType(BottomSheet), matching: find.byType(Scrollable));
    await tester.scrollUntilVisible(find.text('문제 오류 알려주기'), 120,
        scrollable: sheetScrollable, maxScrolls: 40);
    await tester.pumpAndSettle();
    expect(find.text('문제 오류 알려주기').hitTestable(), findsOneWidget);
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
