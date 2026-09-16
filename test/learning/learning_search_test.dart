import 'package:bookstar/infra/network/dio_client.dart';
import 'package:bookstar/modules/learning/data/learning_repository.dart';
import 'package:bookstar/modules/learning/view/learning_design.dart';
import 'package:bookstar/modules/learning/view/learning_search_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('empty book search states the supported-book limitation',
      (tester) async {
    await _pumpSearch(tester);
    expect(find.text('아직 준비되지 않은 책이에요'), findsOneWidget);
    expect(find.textContaining('현재는 퀴즈가 준비된 책부터'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('search remains usable with keyboard at 320px and 2x text',
      (tester) async {
    await _pumpSearch(tester, scale: 2, keyboardInset: 250);
    await tester.showKeyboard(find.byType(TextField));
    await tester.enterText(find.byType(TextField), '기억할 책');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(TextField).hitTestable(), findsOneWidget);
    expect(find.byTooltip('검색어 지우기').hitTestable(), findsOneWidget);
  });

  testWidgets(
      'completed book opens its existing chapters without creating a challenge',
      (tester) async {
    final api = _BookSelectionApi(
      ongoing: [_challenge(40, 400)],
      completed: [_challenge(41, 410), _challenge(7, 70), _challenge(42, 420)],
    );
    await _pumpSelectableSearch(tester, api);

    await tester.tap(find.text('기억할 책'));
    await tester.pumpAndSettle();

    expect(find.text('challenge 70 chapters'), findsOneWidget);
    expect(api.ongoingCalls, 1);
    expect(api.completedCalls, 1);
    expect(api.createdBookIds, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'ongoing book takes priority without querying completed challenges',
      (tester) async {
    final api = _BookSelectionApi(
      ongoing: [_challenge(40, 400), _challenge(7, 71), _challenge(42, 420)],
      completed: [_challenge(7, 70)],
    );
    await _pumpSelectableSearch(tester, api);

    await tester.tap(find.text('기억할 책'));
    await tester.pumpAndSettle();

    expect(find.text('challenge 71 chapters'), findsOneWidget);
    expect(api.ongoingCalls, 1);
    expect(api.completedCalls, 0);
    expect(api.createdBookIds, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'book absent from both lists creates one challenge and opens its chapters',
      (tester) async {
    final api = _BookSelectionApi(
      ongoing: [_challenge(40, 400)],
      completed: [_challenge(41, 410), _challenge(42, 420)],
    );
    await _pumpSelectableSearch(tester, api);

    await tester.tap(find.text('기억할 책'));
    await tester.pumpAndSettle();

    expect(find.text('challenge 99 chapters'), findsOneWidget);
    expect(api.ongoingCalls, 1);
    expect(api.completedCalls, 1);
    expect(api.createdBookIds, [7]);
    expect(tester.takeException(), isNull);
  });
}

Map<String, dynamic> _challenge(int bookId, int challengeId) => {
      'bookId': bookId,
      'challengeId': challengeId,
      'bookTitle': 'book $bookId',
    };

class _BookSelectionApi {
  _BookSelectionApi({required this.ongoing, required this.completed}) {
    dio.interceptors.add(InterceptorsWrapper(onRequest: _respond));
  }

  final List<Map<String, dynamic>> ongoing;
  final List<Map<String, dynamic>> completed;
  final dio = Dio(BaseOptions(baseUrl: 'https://example.invalid'));
  final createdBookIds = <int>[];
  int ongoingCalls = 0;
  int completedCalls = 0;

  void _respond(RequestOptions options, RequestInterceptorHandler handler) {
    Object data;
    switch (options.path) {
      case '/api/v3/learning/books':
        data = {
          'items': [
            {
              'bookId': 7,
              'title': '기억할 책',
              'author': '테스트 작가',
              'bookCover': '',
              'chapterCount': 3,
            }
          ],
          'hasNext': false,
          'nextCursor': null,
        };
      case '/api/v3/challenges/ongoing':
        ongoingCalls++;
        data = {'challenges': ongoing};
      case '/api/v3/challenges/completed':
        completedCalls++;
        data = {
          'challenges':
              completed.map((item) => {...item, 'completed': true}).toList(),
        };
      case '/api/v3/challenges':
        expect(options.method, 'POST');
        createdBookIds.add(options.queryParameters['bookId'] as int);
        data = {'challengeId': 99};
      default:
        handler.reject(DioException(
            requestOptions: options,
            error: StateError('Unexpected isolated request: ${options.path}')));
        return;
    }
    handler.resolve(Response(requestOptions: options, statusCode: 200, data: {
      'statusResponse': {'resultCode': 'OK', 'resultMessage': 'OK'},
      'data': data,
    }));
  }
}

Future<void> _pumpSelectableSearch(
    WidgetTester tester, _BookSelectionApi api) async {
  final router = GoRouter(initialLocation: '/search', routes: [
    GoRoute(path: '/search', builder: (_, __) => const LearningSearchScreen()),
    GoRoute(
        path: '/library/:challengeId/chapters',
        builder: (_, state) => Scaffold(
            body: Text(
                'challenge ${state.pathParameters['challengeId']} chapters'))),
  ]);
  addTearDown(router.dispose);
  addTearDown(() => api.dio.close(force: true));
  await tester.pumpWidget(ProviderScope(
      overrides: [
        dioClientProvider.overrideWithValue(api.dio),
        learningRepositoryProvider
            .overrideWithValue(LearningRepository(api.dio)),
      ],
      child: MaterialApp.router(
          theme: LearningColors.theme, routerConfig: router)));
  await tester.pumpAndSettle();
}

class _EmptySearchRepository extends LearningRepository {
  _EmptySearchRepository() : super(Dio());

  @override
  Future<LearningBookPage> searchBooks(String query, {int? cursor}) async =>
      const LearningBookPage([], false, null);
}

Future<void> _pumpSearch(WidgetTester tester,
    {double scale = 1, double keyboardInset = 0}) async {
  tester.view.physicalSize = const Size(320, 568);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      learningRepositoryProvider.overrideWithValue(_EmptySearchRepository()),
    ],
    child: MaterialApp(
      theme: LearningColors.theme,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(scale),
          viewInsets: EdgeInsets.only(bottom: keyboardInset),
        ),
        child: child!,
      ),
      home: const LearningSearchScreen(),
    ),
  ));
  await tester.pumpAndSettle();
}
