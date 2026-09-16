import 'package:bookstar/modules/auth/view/screens/login_screen.dart';
import 'package:bookstar/modules/auth/view_model/auth_state.dart';
import 'package:bookstar/modules/auth/view_model/auth_view_model.dart';
import 'package:bookstar/modules/learning/view/learning_design.dart';
import 'package:bookstar/modules/learning/view/learning_preview_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

void main() {
  // Do not round before comparing. These opaque-color checks also cover text
  // whose complete card semantics label cannot be matched to a single Text by
  // Flutter's screenshot-based guideline.
  final pairs = <String, (Color, Color)>{
    'body on paper': (LearningColors.ink, LearningColors.paper),
    'body on white card': (LearningColors.ink, Colors.white),
    'secondary on paper': (LearningColors.muted, LearningColors.paper),
    'secondary on white card': (LearningColors.muted, Colors.white),
    'secondary on lavender': (LearningColors.muted, LearningColors.lavender),
    'purple on paper': (LearningColors.primary, LearningColors.paper),
    'purple on white card': (LearningColors.primary, Colors.white),
    'purple on lavender': (LearningColors.primary, LearningColors.lavender),
    'white on purple CTA': (Colors.white, LearningColors.primary),
    'correct on green soft': (LearningColors.green, LearningColors.greenSoft),
    'correct on white card': (LearningColors.green, Colors.white),
    'wrong on amber soft': (LearningColors.amber, LearningColors.amberSoft),
    'wrong on white card': (LearningColors.amber, Colors.white),
    'error on paper': (LearningColors.amber, LearningColors.paper),
    'body on green soft': (LearningColors.ink, LearningColors.greenSoft),
    'body on amber soft': (LearningColors.ink, LearningColors.amberSoft),
  };
  for (final pair in pairs.entries) {
    test('palette ${pair.key} meets normal-text 4.5 contrast', () {
      expect(
          _contrast(pair.value.$1, pair.value.$2), greaterThanOrEqualTo(4.5));
    });
  }

  testWidgets('small secondary text on lavender passes rendered text contrast',
      (tester) async {
    final handle = tester.ensureSemantics();
    try {
      await tester.pumpWidget(const MaterialApp(
          home: Scaffold(
              body: Center(
        child: ColoredBox(
            color: LearningColors.lavender,
            child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('복습 가능한 퀴즈',
                    style:
                        TextStyle(fontSize: 12, color: LearningColors.muted)))),
      ))));
      await _check(tester);
    } finally {
      handle.dispose();
    }
  });

  testWidgets(
      'login first action and social options pass rendered text contrast',
      (tester) async {
    final handle = tester.ensureSemantics();
    try {
      await _pump(tester, login: true);
      await _check(tester);
      await _reveal(tester, find.text('Apple로 시작하기'));
      await _check(tester);
    } finally {
      handle.dispose();
    }
  });

  testWidgets('preview reading and question pass rendered text contrast',
      (tester) async {
    final handle = tester.ensureSemantics();
    try {
      await _pump(tester);
      await _check(tester);
      await tester.tap(find.text('글을 가리고 퀴즈 풀기'));
      await tester.pumpAndSettle();
      await _check(tester);
    } finally {
      handle.dispose();
    }
  });

  for (final correct in [true, false]) {
    testWidgets(
        'preview ${correct ? 'correct' : 'wrong'} feedback passes rendered text contrast',
        (tester) async {
      final handle = tester.ensureSemantics();
      try {
        await _pump(tester);
        await tester.tap(find.text('글을 가리고 퀴즈 풀기'));
        await tester.pumpAndSettle();
        final choice =
            find.text(correct ? '기억할 내용을 자기 말로 떠올렸어요' : '읽은 쪽수를 세었어요');
        await _reveal(tester, choice);
        await tester.tap(choice);
        await tester.pumpAndSettle();
        await tester.tap(find.text('답 확인하기'));
        await tester.pumpAndSettle();
        expect(find.text(correct ? '잘 떠올렸어요' : '함께 다시 짚어봐요'), findsOneWidget);
        await _check(tester);
        await _reveal(tester, find.text('체험 결과는 독서·복습 기록에 저장되지 않아요.'));
        await _check(tester);
      } finally {
        handle.dispose();
      }
    });
  }
}

double _contrast(Color a, Color b) {
  final x = a.computeLuminance();
  final y = b.computeLuminance();
  return x > y ? (x + .05) / (y + .05) : (y + .05) / (x + .05);
}

class _IdleAuth extends AuthViewModel {
  @override
  Future<AuthState> build() async => AuthIdle();
}

Future<void> _pump(WidgetTester tester, {bool login = false}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final router =
      GoRouter(initialLocation: login ? '/login' : '/preview', routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(
        path: '/preview', builder: (_, __) => const LearningPreviewScreen()),
  ]);
  addTearDown(router.dispose);
  await tester.pumpWidget(ProviderScope(
      overrides: [
        authViewModelProvider.overrideWith(_IdleAuth.new),
      ],
      child: MaterialApp.router(
          theme: LearningColors.theme, routerConfig: router)));
  await tester.pumpAndSettle();
}

Future<void> _check(WidgetTester tester) async {
  await expectLater(tester, meetsGuideline(textContrastGuideline));
  expect(tester.takeException(), isNull);
}

Future<void> _reveal(WidgetTester tester, Finder target) async {
  final scrollable = find.byType(Scrollable).first;
  tester.state<ScrollableState>(scrollable).position.jumpTo(0);
  await tester.pump();
  await tester.scrollUntilVisible(target, 140,
      scrollable: scrollable, maxScrolls: 60);
  await tester.pumpAndSettle();
}
