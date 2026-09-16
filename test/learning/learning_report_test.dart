import 'dart:async';

import 'package:bookstar/infra/network/dio_client.dart';
import 'package:bookstar/modules/learning/view/learning_design.dart';
import 'package:bookstar/modules/learning/view/learning_report_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('report starts without a reason and never posts implicitly',
      (tester) async {
    final api = await _pump(tester);
    expect(_submit(tester).onPressed, isNull);
    expect(api.requests, isEmpty);
  });

  testWidgets('timeout preserves selected reason, content and UUID for retry',
      (tester) async {
    final api = await _pump(tester);
    api.failures = 1;
    await _fill(tester);
    await tester.tap(find.text('의견 보내기'));
    await tester.pumpAndSettle();
    expect(api.requests.single.path, '/api/v3/quizzes/77/error-report');
    final first = Map<String, dynamic>.from(api.requests.single.data as Map);
    expect(first['errorType'], 'DIFFERENT_FROM_BOOK');
    expect(first['content'], '책 12쪽의 설명과 달라요.');
    expect(
        first['requestId'],
        matches(RegExp(
            r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$')));
    await _reveal(tester, find.byType(TextField));
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '  책 12쪽의 설명과 달라요.  ');
    await tester.tap(find.text('의견 보내기'));
    await tester.pumpAndSettle();
    expect(api.requests.last.data, first);
    expect(find.text('알려주셔서 고마워요'), findsOneWidget);
    await tester.tap(find.text('퀴즈로 돌아가기'));
    await tester.pumpAndSettle();
    expect(find.text('원래 퀴즈'), findsOneWidget);
  });

  testWidgets('reselecting the unchanged reason preserves retry UUID',
      (tester) async {
    final api = await _pump(tester);
    api.failures = 1;
    await _fill(tester);
    await tester.tap(find.text('의견 보내기'));
    await tester.pumpAndSettle();
    final firstId = (api.requests.single.data as Map)['requestId'];
    await _reveal(tester, find.text('책의 내용과 달라요'));
    await tester.tap(find.text('책의 내용과 달라요'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('의견 보내기'));
    await tester.pumpAndSettle();
    expect((api.requests.last.data as Map)['requestId'], firstId);
  });

  for (final editReason in [false, true]) {
    testWidgets(
        'editing ${editReason ? 'reason' : 'content'} creates a new report UUID',
        (tester) async {
      final api = await _pump(tester);
      api.failures = 1;
      await _fill(tester);
      await tester.tap(find.text('의견 보내기'));
      await tester.pumpAndSettle();
      final firstId = (api.requests.single.data as Map)['requestId'];
      if (editReason) {
        await _reveal(tester, find.text('책에 없는 내용이에요'));
        await tester.tap(find.text('책에 없는 내용이에요'));
      } else {
        await _reveal(tester, find.byType(TextField));
        await tester.enterText(find.byType(TextField), '새로 확인한 다른 설명');
      }
      await tester.pumpAndSettle();
      await tester.tap(find.text('의견 보내기'));
      await tester.pumpAndSettle();
      expect((api.requests.last.data as Map)['requestId'], isNot(firstId));
      expect(find.text('알려주셔서 고마워요'), findsOneWidget);
    });
  }

  testWidgets('pending report disables edits and duplicate send',
      (tester) async {
    final api = await _pump(tester);
    api.gate = Completer<void>();
    await _fill(tester);
    await tester.tap(find.text('의견 보내기'));
    await tester.pumpAndSettle();
    expect(api.requests, hasLength(1));
    expect(_submit(tester).onPressed, isNull);
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
    api.gate!.complete();
    await tester.pumpAndSettle();
    expect(api.requests, hasLength(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('320px 2x report send remains above the active keyboard',
      (tester) async {
    await _pump(tester, scale: 2);
    await _fill(tester);
    tester.view.viewInsets = const FakeViewPadding(bottom: 250);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(tester.getRect(find.byType(FilledButton)).bottom,
        lessThanOrEqualTo(318),
        reason: 'The send action must not sit behind the visible keyboard');
  });

  testWidgets('320px 2x keyboard and failed report retain a usable retry',
      (tester) async {
    final api = await _pump(tester, scale: 2);
    api.failures = 1;
    await _fill(tester);
    tester.view.viewInsets = const FakeViewPadding(bottom: 250);
    await tester.pumpAndSettle();
    await tester.tap(find.text('의견 보내기'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(api.requests, hasLength(1));
    expect(tester.getRect(find.byType(FilledButton)).bottom,
        lessThanOrEqualTo(318));
    final first = Map<String, dynamic>.from(api.requests.single.data as Map);
    expect(_submit(tester).onPressed, isNotNull);
    await tester.tap(find.text('의견 보내기'));
    await tester.pumpAndSettle();
    expect(api.requests.last.data, first);
    expect(tester.takeException(), isNull);
  });

  testWidgets('320px 2x sent confirmation fits and can return to quiz',
      (tester) async {
    await _pump(tester, scale: 2);
    await _fill(tester);
    await tester.tap(find.text('의견 보내기'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('알려주셔서 고마워요'), findsOneWidget);
    await tester.tap(find.text('퀴즈로 돌아가기'));
    await tester.pumpAndSettle();
    expect(find.text('원래 퀴즈'), findsOneWidget);
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
  addTearDown(tester.view.resetViewInsets);
  final api = _Reports();
  final router = GoRouter(initialLocation: '/quiz/report', routes: [
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
      overrides: [dioClientProvider.overrideWithValue(api.dio)],
      child: MaterialApp.router(
          theme: LearningColors.theme,
          routerConfig: router,
          builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(scale)),
              child: child!))));
  await tester.pumpAndSettle();
  return api;
}

FilledButton _submit(WidgetTester tester) =>
    tester.widget<FilledButton>(find.byType(FilledButton));
Future<void> _fill(WidgetTester tester) async {
  await _reveal(tester, find.text('책의 내용과 달라요'));
  await tester.tap(find.text('책의 내용과 달라요'));
  await _reveal(tester, find.byType(TextField));
  await tester.enterText(find.byType(TextField), '  책 12쪽의 설명과 달라요.  ');
  await tester.pumpAndSettle();
}

Future<void> _reveal(WidgetTester tester, Finder finder) async {
  final scrollable = find.byType(Scrollable).first;
  tester.state<ScrollableState>(scrollable).position.jumpTo(0);
  await tester.pump();
  await tester.scrollUntilVisible(finder, 140,
      scrollable: scrollable, maxScrolls: 80);
  await tester.pumpAndSettle();
}
