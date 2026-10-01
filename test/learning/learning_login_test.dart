import 'package:bookstar/modules/auth/view/screens/login_screen.dart';
import 'package:bookstar/modules/auth/view_model/auth_state.dart';
import 'package:bookstar/modules/auth/view_model/auth_view_model.dart';
import 'package:bookstar/modules/learning/view/bs_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const _previewLabel = '로그인 없이 한 문제 풀어보기';

void main() {
  testWidgets('login shows the 0.1 copy and every sign-in method',
      (tester) async {
    await _pumpLogin(tester, size: const Size(375, 812));
    expect(find.text('읽은 책이\n오래 기억되도록'), findsOneWidget);
    expect(find.text('AI 퀴즈로 책을 더 깊이 읽고,\n끝까지 완독해보세요.'), findsOneWidget);
    expect(find.text('또는'), findsOneWidget);
    for (final label in [
      _previewLabel,
      '카카오로 시작하기',
      'Google로 시작하기',
      'Apple로 시작하기',
    ]) {
      expect(find.text(label).hitTestable(), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  for (final scale in [1.0, 2.0]) {
    testWidgets('short landscape login actions remain reachable at ${scale}x',
        (tester) async {
      await _pumpLogin(tester, scale: scale, size: const Size(480, 320));
      for (final label in [
        _previewLabel,
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
        of: find.text(_previewLabel), matching: find.byType(BsPrimaryButton));
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
          of: find.text(_previewLabel), matching: find.byType(BsPrimaryButton));
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
    final preview = find.text(_previewLabel);
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

  for (final (label, route) in [
    ('서비스 이용약관', '/policies/service'),
    ('개인정보 수집 및 이용', '/policies/privacy'),
  ]) {
    testWidgets(
        'policy link "$label" stays reachable below the sign-in options',
        (tester) async {
      await _pumpLogin(tester);
      await tester.scrollUntilVisible(find.text(label), 150,
          scrollable: find.byType(Scrollable).first, maxScrolls: 30);
      await tester.pumpAndSettle();
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      expect(find.text('약관 $route'), findsOneWidget);
    });
  }

  testWidgets('failed session restore offers a retry instead of the character',
      (tester) async {
    final auth = _RestoreFailedAuth();
    await _pumpLogin(tester, auth: () => auth);
    expect(
        find.text('저장된 로그인을 확인하지 못했어요.\n연결이 돌아오면 다시 시도해 주세요.'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('저장된 로그인 다시 확인하기'), 150,
        scrollable: find.byType(Scrollable).first, maxScrolls: 30);
    await tester.tap(find.text('저장된 로그인 다시 확인하기'));
    await tester.pumpAndSettle();
    expect(auth.retries, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a failed sign-in is reported without leaving the screen',
      (tester) async {
    final auth = _FailingAuth();
    await _pumpLogin(tester, auth: () => auth);
    await tester.tap(find.text('카카오로 시작하기'));
    await tester.pumpAndSettle();
    expect(find.text('로그인을 완료하지 못했어요. 다시 시도해 주세요.'), findsOneWidget);
    expect(find.text(_previewLabel), findsOneWidget);
  });
}

class _IdleAuth extends AuthViewModel {
  @override
  Future<AuthState> build() async => AuthIdle();
}

class _RestoreFailedAuth extends AuthViewModel {
  int retries = 0;

  @override
  Future<AuthState> build() async => AuthRestoreFailed();

  @override
  Future<void> retryStoredSession() async => retries++;
}

class _FailingAuth extends AuthViewModel {
  @override
  Future<AuthState> build() async => AuthIdle();

  @override
  Future<void> login(_) async =>
      state = AsyncData(AuthFailed(errorMsg: '', errorCode: -1));
}

Future<void> _pumpLogin(WidgetTester tester,
    {double scale = 1,
    Size size = const Size(320, 568),
    AuthViewModel Function()? auth}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final router = GoRouter(initialLocation: '/login', routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(
        path: '/preview',
        builder: (_, __) => const Scaffold(body: Text('로그인 없는 체험 목적지'))),
    for (final kind in ['service', 'privacy'])
      GoRoute(
          path: '/policies/$kind',
          builder: (_, __) => Scaffold(body: Text('약관 /policies/$kind'))),
  ]);
  addTearDown(router.dispose);
  await tester.pumpWidget(ProviderScope(
    overrides: [authViewModelProvider.overrideWith(auth ?? _IdleAuth.new)],
    child: MaterialApp.router(
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
