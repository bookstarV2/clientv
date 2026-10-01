import 'package:bookstar/modules/learning/data/learning_repository.dart';
import 'package:bookstar/modules/learning/view/learning_design.dart';
import 'package:bookstar/modules/learning/view/learning_search_screen.dart';
import 'package:bookstar/modules/learning/view/library_widgets.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const _bestseller = LearningBookPage([
  LearningBook(1, '베스트 책', '가 작가', '', 4),
  LearningBook(2, '인기 책', '나 작가', '', 3),
], false, null);

const _popular = LearningBookPage([
  LearningBook(2, '인기 책', '나 작가', '', 3),
  LearningBook(1, '베스트 책', '가 작가', '', 4),
], false, null);

void main() {
  testWidgets('추천하는 책 toggles between 베스트셀러순 and 유저 인기순', (tester) async {
    await _pumpSearch(tester);

    expect(find.text('추천하는 책'), findsOneWidget);
    expect(find.text('베스트셀러순'), findsOneWidget);
    expect(_order(tester), ['베스트 책', '인기 책']);

    await tester.tap(find.text('베스트셀러순'));
    await tester.pumpAndSettle();
    expect(find.text('유저 인기순'), findsOneWidget);
    expect(_order(tester), ['인기 책', '베스트 책']);
  });

  testWidgets('focusing the empty field shows the search prompt',
      (tester) async {
    await _pumpSearch(tester);
    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    expect(find.text('읽고 싶은 책을\n찾아 보세요'), findsOneWidget);
    expect(find.text('추천하는 책'), findsNothing);
  });

  testWidgets(
      'typing shows suggestions and submitting shows ranked results with the sort toggle',
      (tester) async {
    final repository = _Repository();
    await _pumpSearch(tester, repository: repository);

    await tester.enterText(find.byType(TextField), '책');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.byType(LibraryCompactBookRow), findsNWidgets(2));
    expect(find.text('베스트셀러순'), findsNothing);

    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(find.byType(LibraryBookRow), findsNWidgets(2));
    expect(find.text('베스트셀러순'), findsOneWidget);
    expect(repository.queries, ['책']);
    expect(_order(tester), ['베스트 책', '인기 책']);

    await tester.tap(find.text('베스트셀러순'));
    await tester.pumpAndSettle();
    expect(_order(tester), ['인기 책', '베스트 책']);
  });

  testWidgets('tapping a book opens its detail without saving it',
      (tester) async {
    final semantics = tester.ensureSemantics();
    await _pumpSearch(tester);
    final node =
        tester.getSemantics(find.byKey(const ValueKey('search-book-1')));
    expect(node.label, '베스트 책, 가 작가 저자, 책 상세 보기');
    expect(node.label, isNot(contains('추가')));

    await tester.tap(find.byKey(const ValueKey('search-book-1')));
    await tester.pumpAndSettle();
    expect(find.text('book 1 detail'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('empty book search states the supported-book limitation',
      (tester) async {
    await _pumpSearch(tester, repository: _Repository(empty: true));
    await tester.enterText(find.byType(TextField), '없는 책');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(
        find.text('아직 준비되지 않은 책이에요\n현재는 퀴즈가 준비된 책부터 찾을 수 있어요'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a failed search can be retried', (tester) async {
    final repository = _Repository(fail: true);
    await _pumpSearch(tester, repository: repository);
    await tester.enterText(find.byType(TextField), '책');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(find.text('다시 불러오기'), findsOneWidget);

    repository.fail = false;
    await tester.tap(find.text('다시 불러오기'));
    await tester.pumpAndSettle();
    expect(find.byType(LibraryBookRow), findsNWidgets(2));
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
    expect(find.byTooltip('검색').hitTestable(), findsOneWidget);
  });
}

List<String> _order(WidgetTester tester) => tester
    .widgetList<LibraryBookRow>(find.byType(LibraryBookRow))
    .map((row) => row.title)
    .toList();

class _Repository extends LearningRepository {
  _Repository({this.empty = false, this.fail = false}) : super(Dio());
  final bool empty;
  bool fail;
  final queries = <String>[];

  @override
  Future<LearningBookPage> searchBooks(String query, {int? cursor}) async {
    queries.add(query);
    if (fail) throw StateError('isolated search failure');
    return empty
        ? const LearningBookPage([], false, null)
        : const LearningBookPage([
            LearningBook(2, '인기 책', '나 작가', '', 3),
            LearningBook(1, '베스트 책', '가 작가', '', 4),
          ], false, null);
  }
}

Future<void> _pumpSearch(WidgetTester tester,
    {_Repository? repository,
    double scale = 1,
    double keyboardInset = 0}) async {
  tester.view.physicalSize = const Size(320, 568);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final router = GoRouter(initialLocation: '/library/search', routes: [
    GoRoute(
        path: '/library/search',
        builder: (_, __) => const LearningSearchScreen()),
    GoRoute(
        path: '/library/book/:bookId',
        builder: (_, state) => Scaffold(
            body: Text('book ${state.pathParameters['bookId']} detail'))),
  ]);
  addTearDown(router.dispose);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      learningRepositoryProvider.overrideWithValue(repository ?? _Repository()),
      recommendedBooksProvider(BookRecommendationSort.bestseller)
          .overrideWith((ref) async => _bestseller),
      recommendedBooksProvider(BookRecommendationSort.popular)
          .overrideWith((ref) async => _popular),
    ],
    child: MaterialApp.router(
      theme: LearningColors.theme,
      routerConfig: router,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(scale),
          viewInsets: EdgeInsets.only(bottom: keyboardInset),
        ),
        child: child!,
      ),
    ),
  ));
  await tester.pumpAndSettle();
}
