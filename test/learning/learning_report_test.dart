import 'dart:async';

import 'package:bookstar/infra/network/dio_client.dart';
import 'package:bookstar/modules/learning/data/learning_access.dart';
import 'package:bookstar/modules/learning/view/bs_ui.dart';
import 'package:bookstar/modules/learning/view/learning_design.dart';
import 'package:bookstar/modules/learning/view/learning_report_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

final _uuid = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$');

void main() {
  testWidgets('report page never posts implicitly', (tester) async {
    final api = await _pump(tester);
    expect(find.text('퀴즈 내용에 오류가 있나요?'), findsOneWidget);
    expect(_send(tester), isNotNull);
    expect(api.requests, isEmpty);
  });

  testWidgets('timeout keeps the UUID for retry, then completes and returns',
      (tester) async {
    final api = await _pump(tester);
    api.failures = 1;
    await tester.tap(find.text('퀴즈 신고하기'));
    await tester.pumpAndSettle();
    expect(api.requests.single.path, '/api/v3/quizzes/77/error-report');
    final first = Map<String, dynamic>.from(api.requests.single.data as Map);
    expect(first['errorType'], 'OTHER');
    expect(first['content'], '');
    expect(first['requestId'], matches(_uuid));
    expect(find.textContaining('잠시 후 다시 시도해 주세요'), findsOneWidget);
    expect(find.text('신고가 접수되었어요.'), findsNothing);
    await tester.tap(find.text('퀴즈 신고하기'));
    await tester.pumpAndSettle();
    expect(api.requests.last.data, first);
    expect(find.text('신고가 접수되었어요.'), findsOneWidget);
    expect(find.text('보내주신 의견은 더 나은 북스타 경험을 만드는 데\n도움이 돼요.'), findsOneWidget);
    await tester.tap(find.text('확인'));
    await tester.pumpAndSettle();
    expect(find.text('원래 퀴즈'), findsOneWidget);
    expect(api.requests, hasLength(2));
  });

  testWidgets('pending report disables duplicate send and back',
      (tester) async {
    final api = await _pump(tester);
    api.gate = Completer<void>();
    await tester.tap(find.text('퀴즈 신고하기'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(api.requests, hasLength(1));
    expect(_send(tester), isNull);
    await tester.tap(find.byTooltip('뒤로'));
    await tester.pump();
    expect(find.text('원래 퀴즈'), findsNothing);
    api.gate!.complete();
    await tester.pumpAndSettle();
    expect(api.requests, hasLength(1));
    expect(find.text('신고가 접수되었어요.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('320px 2x report page keeps the send action reachable',
      (tester) async {
    final api = await _pump(tester, scale: 2);
    expect(tester.takeException(), isNull);
    expect(find.text('퀴즈 신고하기').hitTestable(), findsOneWidget);
    await tester.tap(find.text('퀴즈 신고하기'));
    await tester.pumpAndSettle();
    expect(api.requests, hasLength(1));
    expect(find.text('확인').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sheet switches to the completed state and closes on 확인',
      (tester) async {
    final api = _Reports();
    addTearDown(api.dio.close);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        dioClientProvider.overrideWithValue(api.dio),
        learningAccountProvider.overrideWithValue(1),
      ],
      child: MaterialApp(
        theme: LearningColors.theme,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                  onPressed: () => showQuizReportSheet(context, 5),
                  child: const Text('신고 열기')),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('신고 열기'));
    await tester.pumpAndSettle();
    expect(find.text('퀴즈 내용에 오류가 있나요?'), findsOneWidget);
    expect(find.byTooltip('닫기'), findsOneWidget);
    await tester.tap(find.text('퀴즈 신고하기'));
    await tester.pumpAndSettle();
    expect(api.requests.single.path, '/api/v3/quizzes/5/error-report');
    expect(find.text('신고가 접수되었어요.'), findsOneWidget);
    await tester.tap(find.text('확인'));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.text('신고 열기'), findsOneWidget);
  });
}

class _Reports {
  final requests = <RequestOptions>[];
  int failures = 0;
  Completer<void>? gate;
  final dio = Dio();
  _Reports() {
    dio.interceptors
        .add(InterceptorsWrapper(onRequest: (request, handler) async {
      requests.add(request);
      await gate?.future;
      if (failures-- > 0) {
        handler.reject(DioException(
            requestOptions: request, type: DioExceptionType.receiveTimeout));
      } else {
        handler.resolve(Response(
            requestOptions: request, statusCode: 200, data: {'data': null}));
      }
    }));
  }
}

Future<_Reports> _pump(WidgetTester tester, {double scale = 1}) async {
  tester.view.physicalSize = const Size(320, 568);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final api = _Reports();
  final router = GoRouter(initialLocation: '/quiz', routes: [
    GoRoute(
        path: '/quiz',
        builder: (_, __) => const Scaffold(body: Text('원래 퀴즈')),
        routes: [
          GoRoute(
              path: 'report',
              builder: (_, __) => const LearningReportScreen(quizId: 77))
        ]),
  ]);
  addTearDown(router.dispose);
  addTearDown(api.dio.close);
  await tester.pumpWidget(ProviderScope(
      overrides: [
        dioClientProvider.overrideWithValue(api.dio),
        learningAccountProvider.overrideWithValue(1),
      ],
      child: MaterialApp.router(
          theme: LearningColors.theme,
          routerConfig: router,
          builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(scale)),
              child: child!))));
  router.push('/quiz/report');
  await tester.pumpAndSettle();
  return api;
}

VoidCallback? _send(WidgetTester tester) => tester
    .widget<TextButton>(find.descendant(
        of: find.byType(BsPrimaryButton), matching: find.byType(TextButton)))
    .onPressed;
