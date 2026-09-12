import 'dart:async';

import 'package:bookstar/modules/auth/view_model/auth_state.dart';
import 'package:bookstar/modules/auth/view_model/auth_view_model.dart';
import 'package:bookstar/modules/learning/view/learning_design.dart';
import 'package:bookstar/modules/my_page/view/screens/delete_account_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('withdrawal starts unchecked and cancellation does not delete',
      (tester) async {
    final fixture = await _pump(tester);
    await _reveal(tester, find.text('탈퇴하기'));
    expect(_button(tester).onPressed, isNull);
    expect(find.textContaining('30일'), findsNothing);
    await _confirm(tester);
    await tester.tap(find.widgetWithText(TextButton, '계속 이용하기').last);
    await tester.pumpAndSettle();
    expect(fixture.auth.withdrawals, 0);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets(
      'confirmed pending deletion blocks duplicate actions then returns to login',
      (tester) async {
    final fixture = await _pump(tester);
    fixture.auth.gate = Completer<void>();
    await _confirm(tester);
    await tester.tap(find.text('계정 삭제'));
    await tester.pump();
    expect(fixture.auth.withdrawals, 1);
    expect(_button(tester).onPressed, isNull);
    expect(
        tester
            .widget<CheckboxListTile>(find.byType(CheckboxListTile))
            .onChanged,
        isNull);
    expect(
        tester.widget<PopScope>(find.byType(PopScope).first).canPop, isFalse);
    fixture.auth.gate!.complete();
    await tester.pumpAndSettle();
    expect(find.text('로그인 목적지'), findsOneWidget);
    expect(fixture.auth.withdrawals, 1);
    expect(tester.takeException(), isNull);
  });

  for (final scale in [1.0, 2.0]) {
    testWidgets(
        'failed deletion retains confirmation and hides raw errors at ${scale}x',
        (tester) async {
      final fixture = await _pump(tester, scale: scale);
      fixture.auth.failures = 1;
      await _confirm(tester);
      await tester.tap(find.text('계정 삭제'));
      await tester.pumpAndSettle();
      await _reveal(tester, find.byType(CheckboxListTile));
      expect(
          tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
          isTrue);
      await _reveal(tester, find.textContaining('탈퇴를 완료하지 못했어요'));
      expect(find.textContaining('탈퇴를 완료하지 못했어요'), findsOneWidget);
      expect(tester.takeException(), isNull);
      expect(find.textContaining('DioException'), findsNothing);
      expect(find.text('로그인 목적지'), findsNothing);
      await _reveal(tester, find.text('탈퇴하기'));
      await tester.tap(find.text('탈퇴하기'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('계정 삭제'));
      await tester.pumpAndSettle();
      expect(fixture.auth.withdrawals, 2);
      expect(find.text('로그인 목적지'), findsOneWidget);
    });
  }

  testWidgets(
      'completion after router disposal does not setState on removed page',
      (tester) async {
    final fixture = await _pump(tester);
    fixture.auth.gate = Completer<void>();
    await _confirm(tester);
    await tester.tap(find.text('계정 삭제'));
    await tester.pump();
    fixture.router.go('/login');
    await tester.pumpAndSettle();
    fixture.auth.gate!.complete();
    await tester.pumpAndSettle();
    expect(find.text('로그인 목적지'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'withdrawal explanation and second confirmation fit 320px 2x text',
      (tester) async {
    final fixture = await _pump(tester, scale: 2);
    await _confirm(tester);
    expect(tester.takeException(), isNull);
    expect(find.text('정말 탈퇴할까요?'), findsOneWidget);
    await tester.tap(find.text('계정 삭제'));
    await tester.pumpAndSettle();
    expect(find.text('로그인 목적지'), findsOneWidget);
    expect(fixture.auth.withdrawals, 1);
    expect(tester.takeException(), isNull);
  });
}

class _DeleteAuth extends AuthViewModel {
  int withdrawals = 0;
  int failures = 0;
  Completer<void>? gate;
  @override
  Future<AuthState> build() async => AuthIdle();
  @override
  Future<void> withdraw() async {
    withdrawals++;
    await gate?.future;
    if (failures-- > 0) {
      throw DioException(
          requestOptions: RequestOptions(path: '/withdraw'),
          type: DioExceptionType.receiveTimeout);
    }
  }
}

class _Fixture {
  _Fixture(this.router, this.auth);
  final GoRouter router;
  final _DeleteAuth auth;
}

Future<_Fixture> _pump(WidgetTester tester, {double scale = 1}) async {
  tester.view.physicalSize = const Size(320, 568);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final container = ProviderContainer(overrides: [
    authViewModelProvider.overrideWith(_DeleteAuth.new),
  ]);
  final router = GoRouter(initialLocation: '/delete', routes: [
    GoRoute(path: '/delete', builder: (_, __) => const DeleteAccountScreen()),
    GoRoute(
        path: '/login',
        builder: (_, __) => const Scaffold(body: Text('로그인 목적지'))),
    GoRoute(
        path: '/settings',
        builder: (_, __) => const Scaffold(body: Text('설정 목적지'))),
  ]);
  addTearDown(() {
    router.dispose();
    container.dispose();
  });
  await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
          theme: LearningColors.theme,
          routerConfig: router,
          builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(scale)),
              child: child!))));
  await tester.pumpAndSettle();
  return _Fixture(
      router, container.read(authViewModelProvider.notifier) as _DeleteAuth);
}

FilledButton _button(WidgetTester tester) =>
    tester.widget<FilledButton>(find.byType(FilledButton));

Future<void> _confirm(WidgetTester tester) async {
  await _reveal(tester, find.byType(CheckboxListTile));
  await tester.tap(find.byType(CheckboxListTile));
  await tester.pump();
  await _reveal(tester, find.text('탈퇴하기'));
  await tester.tap(find.text('탈퇴하기'));
  await tester.pumpAndSettle();
}

Future<void> _reveal(WidgetTester tester, Finder finder) async {
  final scrollable = find.byType(Scrollable).first;
  tester.state<ScrollableState>(scrollable).position.jumpTo(0);
  await tester.pump();
  await tester.scrollUntilVisible(finder, 140,
      scrollable: scrollable, maxScrolls: 40);
  await tester.pumpAndSettle();
}
