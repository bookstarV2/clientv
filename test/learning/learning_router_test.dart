import 'package:bookstar/common/router/router.dart';
import 'package:bookstar/modules/auth/model/auth_response.dart';
import 'package:bookstar/modules/auth/model/policy.dart';
import 'package:bookstar/modules/auth/view_model/auth_state.dart';
import 'package:bookstar/modules/auth/view_model/auth_view_model.dart';
import 'package:bookstar/modules/learning/data/learning_access.dart';
import 'package:bookstar/modules/learning/data/learning_repository.dart';
import 'package:bookstar/modules/learning/view/learning_design.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
// Firebase's installed test helper only mocks the platform, not app routing.
// ignore: depend_on_referenced_packages
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

final _testPolicy = StateProvider<Policy>((ref) => const Policy(
    serviceUsingAgree: PolicyAgree.Y, personalInformationAgree: PolicyAgree.Y));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockDecodedMessageHandler<Object?>(
      const BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.firebase_analytics_platform_interface.FirebaseAnalyticsHostApi.logEvent',
        StandardMessageCodec(),
      ),
      (message) async => <Object?>[null],
    );
  });

  testWidgets(
      'real router preserves search intent from guest preview through login',
      (tester) async {
    final fixture = await _pumpRouter(tester);
    fixture.router.go('/preview');
    await tester.pumpAndSettle();
    await tester.tap(find.text('글을 가리고 퀴즈 풀기'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('기억할 내용을 자기 말로 떠올렸어요'), 140,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('기억할 내용을 자기 말로 떠올렸어요'));
    await tester.pump();
    await tester.tap(find.text('답 확인하기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('내 책으로 시작하기'));
    await tester.pumpAndSettle();
    expect(fixture.uri.path, '/login');
    expect(fixture.uri.queryParameters['next'], '/library/search');
    fixture.auth.signIn();
    await tester.pumpAndSettle();
    expect(fixture.uri.path, '/library/search');
    expect(find.text('기억하고 싶은 책 찾기'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'missing required policy gates login and resumes next after approval',
      (tester) async {
    final fixture = await _pumpRouter(tester, agreed: false);
    fixture.router.go('/login?next=%2Flibrary%2Fsearch');
    fixture.auth.signIn();
    await tester.pumpAndSettle();
    expect(fixture.uri.path, '/start');
    expect(fixture.uri.queryParameters['next'], '/library/search');
    expect(find.byType(CheckboxListTile), findsWidgets);
    fixture.container.read(_testPolicy.notifier).state = const Policy(
        serviceUsingAgree: PolicyAgree.Y,
        personalInformationAgree: PolicyAgree.Y);
    await tester.pumpAndSettle();
    expect(fixture.uri.path, '/library/search');
    expect(tester.takeException(), isNull);
  });

  testWidgets('policy documents remain reachable without authentication',
      (tester) async {
    final fixture = await _pumpRouter(tester);
    for (final path in [
      '/policies/service',
      '/policies/privacy',
      '/policies/marketing'
    ]) {
      fixture.router.go(path);
      await tester.pumpAndSettle();
      expect(fixture.uri.path, path);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets(
      'malformed numeric route parameters fall back instead of crashing',
      (tester) async {
    final fixture = await _pumpRouter(tester);
    fixture.auth.signIn();
    await tester.pumpAndSettle();
    for (final path in [
      '/library/nope/chapters',
      '/library/1/quiz/-1',
      '/review/quiz/0',
      '/settings/archive/nope',
      '/quiz/nope/report'
    ]) {
      fixture.router.go(path);
      await tester.pumpAndSettle();
      expect(fixture.uri.path, '/library', reason: path);
      expect(tester.takeException(), isNull);
    }
  });
}

class _RouterAuth extends AuthViewModel {
  @override
  Future<AuthState> build() async => AuthIdle();
  void signIn() => state = AsyncData(AuthSuccess(
      memberId: 1,
      nickName: 'test',
      profileImage: '',
      providerType: 'test',
      email: 'test@example.invalid',
      memberRole: MemberRole.USER));
}

class _SearchRepository extends LearningRepository {
  _SearchRepository() : super(Dio());
  @override
  Future<LearningBookPage> searchBooks(String query, {int? cursor}) async =>
      const LearningBookPage([], false, null);
}

class _RouterFixture {
  _RouterFixture(this.container, this.router, this.auth);
  final ProviderContainer container;
  final GoRouter router;
  final _RouterAuth auth;
  Uri get uri => router.routeInformationProvider.value.uri;
}

Future<_RouterFixture> _pumpRouter(WidgetTester tester,
    {bool agreed = true}) async {
  final container = ProviderContainer(overrides: [
    authViewModelProvider.overrideWith(_RouterAuth.new),
    _testPolicy.overrideWith((ref) => agreed
        ? const Policy(
            serviceUsingAgree: PolicyAgree.Y,
            personalInformationAgree: PolicyAgree.Y)
        : const Policy()),
    learningPolicyProvider.overrideWith((ref) async {
      ref.watch(learningAccountProvider);
      return ref.watch(_testPolicy);
    }),
    learningRepositoryProvider.overrideWithValue(_SearchRepository()),
    learningBooksProvider.overrideWith((ref) async => []),
    finishedLearningBooksProvider.overrideWith((ref) async => []),
    reviewOverviewProvider.overrideWith((ref) async => const ReviewPage(
        items: [],
        totalCount: 0,
        dueCount: 0,
        reviewedTodayCount: 0,
        hasNext: false)),
  ]);
  final keepRouter = container.listen(routerProvider, (_, __) {});
  await container.read(authViewModelProvider.future);
  await container.read(learningPolicyProvider.future);
  final router = container.read(routerProvider);
  await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
          theme: LearningColors.theme, routerConfig: router)));
  await tester.pumpAndSettle();
  addTearDown(() {
    keepRouter.close();
    router.dispose();
    container.dispose();
  });
  return _RouterFixture(container, router,
      container.read(authViewModelProvider.notifier) as _RouterAuth);
}
