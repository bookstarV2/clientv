import 'package:bookstar/modules/learning/data/learning_footprint.dart';
import 'package:bookstar/modules/learning/data/learning_repository.dart';
import 'package:bookstar/modules/learning/data/library_layout.dart';
import 'package:bookstar/modules/learning/view/bs_ui.dart';
import 'package:bookstar/modules/learning/view/learning_design.dart';
import 'package:bookstar/modules/learning/view/learning_library_screen.dart';
import 'package:bookstar/modules/learning/view/library_widgets.dart';
import 'package:bookstar/modules/reading_challenge/model/challenge_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _longTitle = '책을 덮은 뒤에도 다시 생각하고 싶은 아주 긴 제목의 독서와 기억에 관한 이야기';
const _longAuthor = '이름이 긴 작가와 여러 공동 작가';
const _book = ChallengeResponse(
    challengeId: 7,
    bookId: 17,
    bookTitle: _longTitle,
    bookAuthor: _longAuthor,
    progressRate: 40);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('a freshly mounted library restores its saved 2열 layout',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      LibraryLayoutStore.preferenceKey: LibraryLayout.twoColumns.name,
    });
    await _Fixture.pump(tester);

    expect(find.text('2열'), findsOneWidget);
    expect(find.byType(LibraryBookCell), findsOneWidget);
    expect(find.byType(LibraryBookRow), findsNothing);
  });

  testWidgets('the 목록/2열 toggle switches the layout and persists it',
      (tester) async {
    final fixture = await _Fixture.pump(tester);
    expect(find.text('목록'), findsOneWidget);
    expect(find.byType(LibraryBookRow), findsOneWidget);

    await tester.tap(find.text('목록'));
    await tester.pumpAndSettle();
    expect(find.text('2열'), findsOneWidget);
    expect(find.byType(LibraryBookCell), findsOneWidget);
    expect(fixture.container.read(libraryLayoutProvider),
        LibraryLayout.twoColumns);
    expect(await LibraryLayoutStore().load(), LibraryLayout.twoColumns);

    await tester.tap(find.text('2열'));
    await tester.pumpAndSettle();
    expect(find.byType(LibraryBookRow), findsOneWidget);
    expect(await LibraryLayoutStore().load(), LibraryLayout.list);
  });

  testWidgets(
      'summary shows books, chapters and quizzes from the stored records',
      (tester) async {
    await _Fixture.pump(tester);
    expect(find.bySemanticsLabel('3권 4목차 5개 퀴즈'), findsOneWidget);
    expect(find.text('읽고 떠올린 것이\n하나의 세계로'), findsOneWidget);
  });

  for (final grid in [false, true]) {
    testWidgets(
        '${grid ? 'grid' : 'list'} book is one button with title, author, status and progress',
        (tester) async {
      final semantics = tester.ensureSemantics();
      SharedPreferences.setMockInitialValues({
        LibraryLayoutStore.preferenceKey:
            (grid ? LibraryLayout.twoColumns : LibraryLayout.list).name,
      });
      await _Fixture.pump(tester);

      final node =
          tester.getSemantics(find.byKey(const ValueKey('library-book-7')));
      expect(node.label, '$_longTitle, $_longAuthor 저자, 읽는중 책, 40% 진행, 목차 열기');
      expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
      expect(find.text('40% 진행'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('library-book-7')));
      await tester.pumpAndSettle();
      expect(find.text('chapters 7'), findsOneWidget);
      semantics.dispose();
    });
  }

  testWidgets('완독한 책 shows finished books and keeps the chosen layout',
      (tester) async {
    final fixture = await _Fixture.pump(tester);
    await tester.tap(find.text('목록'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('완독한 책'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('library-book-77')), findsOneWidget);
    expect(find.byKey(const ValueKey('library-book-7')), findsNothing);
    expect(find.text('100% 진행'), findsOneWidget);
    expect(fixture.container.read(libraryLayoutProvider),
        LibraryLayout.twoColumns);
  });

  testWidgets('newest books come first and a long library stays lazy',
      (tester) async {
    final books = List.generate(
        200,
        (index) => ChallengeResponse(
            challengeId: index + 100,
            bookId: index + 100,
            bookTitle: '책 $index'));
    await _Fixture.pump(tester, books: books);

    expect(find.byType(LibraryBookRow).evaluate().length, lessThan(20));
    expect(find.byKey(const ValueKey('library-book-299')), findsOneWidget);
    expect(find.byKey(const ValueKey('library-book-100')), findsNothing);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -1500));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('library-book-299')), findsNothing);
    expect(find.byType(LibraryBookRow).evaluate().length, lessThan(20));
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty library guides to the search and hides the layout toggle',
      (tester) async {
    final fixture = await _Fixture.pump(tester, books: []);
    expect(find.text('우측 상단의 검색 탭에서\n읽고 싶은 책을 찾아보세요'), findsOneWidget);
    expect(find.text('목록'), findsNothing);

    fixture.books = [const ChallengeResponse(challengeId: 8, bookTitle: '  ')];
    fixture.container.invalidate(learningBooksProvider);
    await tester.pumpAndSettle();
    expect(find.text('제목 없는 책'), findsWidgets);
  });

  testWidgets('a load error offers retry instead of an empty library',
      (tester) async {
    final fixture = await _Fixture.pump(tester, fail: true);
    expect(find.text('우측 상단의 검색 탭에서\n읽고 싶은 책을 찾아보세요'), findsNothing);
    fixture.fail = false;
    await tester.tap(find.text('다시 불러오기'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('library-book-7')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('add-book action opens the book search', (tester) async {
    await _Fixture.pump(tester);
    await tester.tap(find.byTooltip('책 찾아서 추가하기'));
    await tester.pumpAndSettle();
    expect(find.text('book search'), findsOneWidget);
  });

  testWidgets('a book saved from the detail returns to 읽는중 책 at the top',
      (tester) async {
    final fixture = await _Fixture.pump(tester);
    await tester.tap(find.text('완독한 책'));
    await tester.pumpAndSettle();

    fixture.container.read(libraryAddedBookProvider.notifier).state = 7;
    await tester.pumpAndSettle();

    expect(tester.widget<BsChip>(find.widgetWithText(BsChip, '읽는중 책')).selected,
        isTrue);
    expect(find.byKey(const ValueKey('library-book-7')), findsOneWidget);
    expect(fixture.container.read(libraryAddedBookProvider), isNull);
  });

  for (final scale in [2.0, 3.0]) {
    testWidgets('list and grid stay usable at ${scale}x text', (tester) async {
      final fixture = await _Fixture.pump(tester, scale: scale);
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.byType(LibraryToggle));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(LibraryToggle));
      await tester.pumpAndSettle();
      expect(fixture.container.read(libraryLayoutProvider),
          LibraryLayout.twoColumns);
      expect(tester.takeException(), isNull);
    });
  }
}

class _Fixture {
  late final ProviderContainer container;
  late final GoRouter router;
  List<ChallengeResponse> books = [_book];
  bool fail = false;

  static Future<_Fixture> pump(WidgetTester tester,
      {List<ChallengeResponse>? books,
      bool fail = false,
      double scale = 1}) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final fixture = _Fixture()..fail = fail;
    if (books != null) fixture.books = books;
    fixture.container = ProviderContainer(overrides: [
      learningBooksProvider.overrideWith((ref) async {
        if (fixture.fail) throw StateError('isolated API failure');
        return fixture.books;
      }),
      finishedLearningBooksProvider.overrideWith((ref) async => [
            const ChallengeResponse(
                challengeId: 77,
                bookId: 177,
                bookTitle: '다시 펼칠 책',
                progressRate: 100),
          ]),
      learningFootprintProvider.overrideWith((ref) async => LearningFootprint(
          answeredQuizCount: 5,
          reviewedQuizCount: 1,
          bookCount: 3,
          chapterCount: 4,
          generatedAt: DateTime(2026, 10, 2))),
    ]);
    fixture.router = GoRouter(initialLocation: '/library', routes: [
      GoRoute(
          path: '/library',
          builder: (_, __) => const Scaffold(body: LearningLibraryScreen())),
      GoRoute(
          path: '/library/search',
          builder: (_, __) => const Scaffold(body: Text('book search'))),
      GoRoute(
          path: '/library/:id/chapters',
          builder: (_, state) =>
              Scaffold(body: Text('chapters ${state.pathParameters['id']}'))),
    ]);
    addTearDown(() {
      fixture.router.dispose();
      fixture.container.dispose();
    });
    await tester.pumpWidget(UncontrolledProviderScope(
        container: fixture.container,
        child: MaterialApp.router(
            theme: LearningColors.theme,
            routerConfig: fixture.router,
            builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(scale)),
                child: child!))));
    await tester.pumpAndSettle();
    return fixture;
  }
}
