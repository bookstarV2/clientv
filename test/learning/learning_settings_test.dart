import 'package:bookstar/modules/auth/model/auth_response.dart';
import 'package:bookstar/modules/auth/view_model/auth_state.dart';
import 'package:bookstar/modules/auth/view_model/auth_view_model.dart';
import 'package:bookstar/modules/learning/view/bs_ui.dart';
import 'package:bookstar/modules/learning/view/learning_design.dart';
import 'package:bookstar/modules/learning/view/learning_settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _Auth extends AuthViewModel {
  _Auth(this.provider);
  final String provider;
  int signOuts = 0;

  @override
  Future<AuthState> build() async => AuthSuccess(
      memberId: 1,
      nickName: '북스타',
      profileImage: '',
      providerType: provider,
      email: 'bookstar1234@gmail.com',
      memberRole: MemberRole.USER);

  @override
  Future<void> signOut() async => signOuts++;
}

const _destinations = [
  '/settings/archive',
  '/preview',
  '/settings/notifications',
  '/policies/service',
  '/policies/privacy',
  '/settings/delete-account',
];

void main() {
  Future<_Auth> pump(WidgetTester tester,
      {String provider = 'KAKAO',
      TargetPlatform platform = TargetPlatform.android,
      double scale = 1,
      Size size = const Size(375, 812)}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final auth = _Auth(provider);
    final router = GoRouter(initialLocation: '/settings', routes: [
      GoRoute(
          path: '/settings',
          builder: (_, __) => const LearningSettingsScreen()),
      for (final path in _destinations)
        GoRoute(
            path: path,
            builder: (_, __) => Scaffold(body: Text('destination $path'))),
    ]);
    addTearDown(router.dispose);
    await tester.pumpWidget(ProviderScope(
        overrides: [authViewModelProvider.overrideWith(() => auth)],
        child: MaterialApp.router(
            theme: LearningColors.theme.copyWith(platform: platform),
            routerConfig: router,
            builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(scale)),
                child: child!))));
    await tester.pumpAndSettle();
    return auth;
  }

  Future<void> tapRow(WidgetTester tester, String label) async {
    await tester.scrollUntilVisible(find.text(label), 120,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  Finder chevrons() => find.byWidgetPredicate(
      (widget) => widget is BsIcon && widget.name == 'ic_chevron_right');

  for (final (provider, label) in [
    ('KAKAO', '카카오 계정'),
    ('APPLE', 'Apple 계정'),
    ('GOOGLE', 'Google 계정'),
  ]) {
    testWidgets('login card shows $label and the account email',
        (tester) async {
      await pump(tester, provider: provider);
      expect(find.text('로그인 정보'), findsOneWidget);
      expect(find.text(label), findsOneWidget);
      expect(find.text('bookstar1234@gmail.com'), findsOneWidget);
    });
  }

  testWidgets('Android follows 1.3: no chevrons, a divider under every row',
      (tester) async {
    await pump(tester);
    expect(chevrons(), findsNothing);
    expect(find.byType(Divider), findsNWidgets(7));
  });

  testWidgets('iOS follows 1.2: chevrons, separators only inside groups',
      (tester) async {
    await pump(tester, platform: TargetPlatform.iOS);
    expect(chevrons(), findsNWidgets(7));
    expect(find.byType(Divider), findsNWidgets(4));
  });

  for (final (label, path) in [
    ('나의 지난 독서 기록', '/settings/archive'),
    ('퀴즈 체험 다시 보기', '/preview'),
    ('알림 설정', '/settings/notifications'),
    ('서비스 이용 약관', '/policies/service'),
    ('개인정보 수집 및 이용', '/policies/privacy'),
    ('회원탈퇴', '/settings/delete-account'),
  ]) {
    testWidgets('$label opens $path', (tester) async {
      await pump(tester);
      await tapRow(tester, label);
      expect(find.text('destination $path'), findsOneWidget);
    });
  }

  testWidgets('AI 퀴즈 이용 안내 opens the guide sheet', (tester) async {
    await pump(tester);
    await tapRow(tester, 'AI 퀴즈 이용 안내');
    expect(find.text('내 책으로도 이어서 해볼 수 있어요'), findsOneWidget);
    await tester.tap(find.text('확인'));
    await tester.pumpAndSettle();
    expect(find.text('내 책으로도 이어서 해볼 수 있어요'), findsNothing);
    expect(find.text('설정'), findsOneWidget);
  });

  testWidgets('문의하기 copies the support email', (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        copied = (call.arguments as Map)['text'] as String?;
      }
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));
    await pump(tester);
    await tapRow(tester, '문의하기');
    expect(copied, 'bookstar816@gmail.com');
    expect(find.text('문의 이메일을 복사했어요: bookstar816@gmail.com'), findsOneWidget);
  });

  testWidgets('logout asks first and signs out only when confirmed',
      (tester) async {
    final auth = await pump(tester);
    await tapRow(tester, '로그아웃');
    expect(find.text('로그아웃할까요?'), findsOneWidget);
    await tester.tap(find.text('취소'));
    await tester.pumpAndSettle();
    expect(auth.signOuts, 0);
    await tapRow(tester, '로그아웃');
    await tester.tap(find.widgetWithText(BsPrimaryButton, '로그아웃'));
    await tester.pumpAndSettle();
    expect(auth.signOuts, 1);
  });

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    testWidgets('settings fit 320px with 2x text on $platform', (tester) async {
      await pump(tester,
          platform: platform, scale: 2, size: const Size(320, 568));
      expect(tester.takeException(), isNull);
      await tester.scrollUntilVisible(find.text('회원탈퇴'), 200,
          scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();
      expect(find.text('회원탈퇴').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
