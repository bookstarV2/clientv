import 'package:bookstar/modules/auth/model/policy.dart';
import 'package:bookstar/modules/auth/view/screens/login_screen.dart';
import 'package:bookstar/modules/auth/view_model/auth_state.dart';
import 'package:bookstar/modules/auth/view_model/auth_view_model.dart';
import 'package:bookstar/modules/learning/data/learning_access.dart';
import 'package:bookstar/modules/learning/view/learning_entry_screen.dart';
import 'package:bookstar/modules/learning/view/learning_preview_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'ui_v2_capture.dart';

void main() {
  setUpAll(setUpBsCapture);

  Widget app(String location, Widget screen) {
    final router = GoRouter(initialLocation: location, routes: [
      GoRoute(path: location, builder: (_, __) => screen),
    ]);
    addTearDown(router.dispose);
    return ProviderScope(
      overrides: [
        authViewModelProvider.overrideWith(_IdleAuth.new),
        learningPolicyProvider.overrideWith((ref) async => const Policy()),
      ],
      child: MaterialApp.router(
          debugShowCheckedModeBanner: false, routerConfig: router),
    );
  }

  Future<void> tap(WidgetTester tester, String text) async {
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
  }

  testWidgets('0.1 login', (tester) async {
    await captureBsScreen(
        tester, app('/login', const LoginScreen()), '0.1 로그인_회원가입_Default');
  });

  testWidgets('0.2.1 reading', (tester) async {
    await captureBsScreen(tester,
        app('/preview', const LearningPreviewScreen()), '0.2.1 문장확인_Default');
  });

  testWidgets('0.2.2 question', (tester) async {
    await captureBsScreen(tester,
        app('/preview', const LearningPreviewScreen()), '0.2.2 퀴즈풀기_Default',
        beforeCapture: () => tap(tester, '퀴즈 풀어보기'));
  });

  testWidgets('0.2.2 question selected', (tester) async {
    await captureBsScreen(
        tester,
        app('/preview', const LearningPreviewScreen()),
        '0.2.2 퀴즈풀기_Selected', beforeCapture: () async {
      await tap(tester, '퀴즈 풀어보기');
      await tap(tester, '읽은 쪽수를 세었어요');
    });
  });

  testWidgets('0.2.3 answer', (tester) async {
    await captureBsScreen(
        tester,
        app('/preview', const LearningPreviewScreen()),
        '0.2.3 정답확인(정답)_Default', beforeCapture: () async {
      await tap(tester, '퀴즈 풀어보기');
      await tap(tester, '기억할 내용을 자기 말로 떠올렸어요');
      await tap(tester, '정답 확인하기');
    });
  });

  testWidgets('0.2.4 guide sheet', (tester) async {
    await captureBsScreen(
        tester,
        app('/preview', const LearningPreviewScreen()),
        '0.2.4 사용안내_Default', beforeCapture: () async {
      await tap(tester, '퀴즈 풀어보기');
      await tap(tester, '기억할 내용을 자기 말로 떠올렸어요');
      await tap(tester, '정답 확인하기');
      await tap(tester, '내 책으로 시작하기');
    });
  });

  testWidgets('start policy consent (no Figma frame)', (tester) async {
    await captureBsScreen(tester, app('/start', const LearningEntryScreen()),
        'onboarding_start_policy',
        beforeCapture: () => tap(tester, '서비스 이용약관 (필수)'));
  });
}

class _IdleAuth extends AuthViewModel {
  @override
  Future<AuthState> build() async => AuthIdle();
}
