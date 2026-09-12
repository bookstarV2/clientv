import 'package:bookstar/modules/auth/view/screens/login_screen.dart';
import 'package:bookstar/modules/auth/view_model/auth_state.dart';
import 'package:bookstar/modules/auth/view_model/auth_view_model.dart';
import 'package:bookstar/modules/learning/view/learning_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  for (final scale in [1.0, 2.0]) {
    testWidgets('short landscape login actions remain reachable at ${scale}x',
        (tester) async {
      await _pumpLogin(tester, scale: scale, size: const Size(480, 320));
      for (final label in [
        '로그인 없이 한 문제 체험',
        '카카오로 시작하기',
        'Google로 시작하기',
        'Apple로 시작하기',
      ]) {
        await tester.scrollUntilVisible(find.text(label), 100,
            scrollable: find.byType(Scrollable).first, maxScrolls: 40);
        await tester.pumpAndSettle();
        expect(find.text(label).hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });
  }

  testWidgets(
      'normal-size login exposes the full preview action without scrolling',
      (tester) async {
    await _pumpLogin(tester);
    final action = find.ancestor(
        of: find.text('로그인 없이 한 문제 체험'),
        matching: find.byWidgetPredicate((widget) => widget is FilledButton));
    expect(action, findsOneWidget);
    final rect = tester.getRect(action);
    expect(rect.top, greaterThanOrEqualTo(0));
    expect(rect.bottom, lessThanOrEqualTo(568),
        reason:
            'The first action should not follow another repeated explainer');
    expect(action.hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final scale in [2.0, 3.0]) {
    testWidgets(
        'preview stays within ${scale - 1} viewport scroll at ${scale}x',
        (tester) async {
      await _pumpLogin(tester, scale: scale);
      final action = find.ancestor(
          of: find.text('로그인 없이 한 문제 체험'),
          matching: find.byWidgetPredicate((widget) => widget is FilledButton));
      final scrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(action, 140,
          scrollable: scrollable, maxScrolls: 40);
      await tester.pumpAndSettle();
      final position = tester.state<ScrollableState>(scrollable).position;
      final initialActionBottom =
          tester.getRect(action).bottom + position.pixels;
      final minimumScrollToExposeAction =
          (initialActionBottom - 568).clamp(0, double.infinity);
      expect(minimumScrollToExposeAction, lessThanOrEqualTo(568 * (scale - 1)),
          reason:
              'Measure the scroll needed for the entire CTA, not finder alignment');
      expect(action.hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(action);
      await tester.pumpAndSettle();
      expect(find.text('로그인 없는 체험 목적지'), findsOneWidget);
    });
  }

  testWidgets('login offers preview without authenticating', (tester) async {
    await _pumpLogin(tester);
    final preview = find.text('로그인 없이 한 문제 체험');
    await tester.scrollUntilVisible(preview, 150,
        scrollable: find.byType(Scrollable).first, maxScrolls: 30);
    await tester.tap(preview);
    await tester.pumpAndSettle();
    expect(find.text('로그인 없는 체험 목적지'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final scale in [2.0, 3.0]) {
    testWidgets(
        'all login methods remain readable at 320px with ${scale}x text',
        (tester) async {
      await _pumpLogin(tester, scale: scale);
      expect(tester.takeException(), isNull);
      for (final label in ['카카오로 시작하기', 'Google로 시작하기', 'Apple로 시작하기']) {
        await tester.scrollUntilVisible(find.text(label), 150,
            scrollable: find.byType(Scrollable).first, maxScrolls: 40);
        await tester.pumpAndSettle();
        expect(find.text(label).hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });
  }
}

class _IdleAuth extends AuthViewModel {
  @override
  Future<AuthState> build() async => AuthIdle();
}

Future<void> _pumpLogin(WidgetTester tester,
    {double scale = 1, Size size = const Size(320, 568)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final router = GoRouter(initialLocation: '/login', routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(
        path: '/preview',
        builder: (_, __) => const Scaffold(body: Text('로그인 없는 체험 목적지'))),
  ]);
  addTearDown(router.dispose);
  await tester.pumpWidget(ProviderScope(
    overrides: [authViewModelProvider.overrideWith(_IdleAuth.new)],
    child: MaterialApp.router(
      theme: LearningColors.theme,
      routerConfig: router,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
    ),
  ));
  await tester.pumpAndSettle();
}
