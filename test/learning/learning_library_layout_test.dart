import 'package:bookstar/modules/learning/data/learning_repository.dart';
import 'package:bookstar/modules/learning/data/library_layout.dart';
import 'package:bookstar/modules/learning/view/learning_design.dart';
import 'package:bookstar/modules/learning/view/learning_library_screen.dart';
import 'package:bookstar/modules/reading_challenge/model/challenge_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _longTitle = '책을 덮은 뒤에도 다시 생각하고 싶은 아주 긴 제목의 독서와 기억에 관한 이야기';
const _longAuthor = '이름이 긴 저자와 여러 공동 저자';
const _book = ChallengeResponse(
    challengeId: 7, bookId: 17, bookTitle: _longTitle, bookAuthor: _longAuthor);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('a freshly mounted library restores its saved layout',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      LibraryLayoutStore.preferenceKey: LibraryLayout.threeColumns.name,
    });
    await _Fixture.pump(tester);

    expect(_columns(tester), 3);
    expect(find.text('보기: 3열'), findsOneWidget);
  });

  testWidgets('layout picker remains scrollable at 320px and triple text',
      (tester) async {
    final fixture = await _Fixture.pump(tester);
    fixture.scale.value = 3;
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('보기: 목록'));
    await tester.tap(find.text('보기: 목록'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('3열'));
    await tester.tap(find.text('3열'));
    await tester.pumpAndSettle();

    expect(fixture.container.read(libraryLayoutProvider).preferred,
        LibraryLayout.threeColumns);
    expect(find.byType(SliverGrid), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'default list has compact actions and the entire title in one semantic action',
      (tester) async {
    final semantics = tester.ensureSemantics();
    await _Fixture.pump(tester);

    expect(find.text('보기: 목록'), findsOneWidget);
    expect(find.text('작은 기억 연습'), findsNothing);
    final node =
        tester.getSemantics(find.byKey(const ValueKey('library-book-7')));
    expect(node.label, '$_longTitle, $_longAuthor, 읽고 있는 책, 목차 열기');
    expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
    final title = tester.widget<Text>(find.text(_longTitle));
    expect(title.maxLines, isNull);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets('layout choice persists and completed filter remains independent',
      (tester) async {
    final fixture = await _Fixture.pump(tester);
    await _choose(tester, '3열');
    expect(_columns(tester), 3);
    expect(await LibraryLayoutStore().load(), LibraryLayout.threeColumns);

    await tester.tap(find.text('퀴즈를 마친 책'));
    await tester.pumpAndSettle();

    expect(_columns(tester), 3);
    expect(find.byKey(const ValueKey('library-book-77')), findsOneWidget);
    expect(find.byKey(const ValueKey('library-book-7')), findsNothing);
    expect(fixture.container.read(libraryLayoutProvider).preferred,
        LibraryLayout.threeColumns);
    await _choose(tester, '2열');
    expect(_columns(tester), 2);
    expect(
        tester
            .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, '퀴즈를 마친 책'))
            .selected,
        isTrue);
  });

  testWidgets(
      'large text falls back and then restores the saved three-column choice',
      (tester) async {
    final fixture = await _Fixture.pump(tester);
    await _choose(tester, '3열');
    fixture.scale.value = 1.5;
    await tester.pumpAndSettle();
    expect(_columns(tester), 2);
    expect(find.textContaining('선택한 3열 보기는 유지돼요'), findsOneWidget);

    fixture.scale.value = 3;
    await tester.pumpAndSettle();
    expect(find.byType(SliverGrid), findsNothing);
    expect(find.text('보기: 목록'), findsOneWidget);
    expect(await LibraryLayoutStore().load(), LibraryLayout.threeColumns);
    expect(tester.takeException(), isNull);

    fixture.scale.value = 1;
    await tester.pumpAndSettle();
    expect(_columns(tester), 3);
    expect(find.textContaining('선택한 3열 보기는 유지돼요'), findsNothing);
  });

  testWidgets(
      'grid retains full title author and action semantics while visual titles truncate',
      (tester) async {
    final semantics = tester.ensureSemantics();
    await _Fixture.pump(tester);
    await _choose(tester, '3열');

    final node =
        tester.getSemantics(find.byKey(const ValueKey('library-book-7')));
    expect(node.label, '$_longTitle, $_longAuthor, 읽고 있는 책, 목차 열기');
    expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
    expect(tester.widget<Text>(find.text(_longTitle)).maxLines, 2);
    await tester.tap(find.byKey(const ValueKey('library-book-7')));
    await tester.pumpAndSettle();
    expect(find.text('chapters 7'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('many books use a lazy grid and preserve source order',
      (tester) async {
    final books = List.generate(
        200,
        (index) => ChallengeResponse(
            challengeId: index + 100,
            bookId: index + 100,
            bookTitle: '책 $index'));
    await _Fixture.pump(tester, books: books);
    await _choose(tester, '3열');

    expect(find.byType(LearningCard).evaluate().length, lessThan(40));
    expect(find.byKey(const ValueKey('library-book-299')), findsNothing);
    final first =
        tester.getTopLeft(find.byKey(const ValueKey('library-book-100')));
    final second =
        tester.getTopLeft(find.byKey(const ValueKey('library-book-101')));
    expect(first.dy, second.dy);
    expect(first.dx, lessThan(second.dx));
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -1100));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('library-book-100')), findsNothing);
    expect(find.byType(LearningCard).evaluate().length, lessThan(40));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'empty books show no invented grid slots and blank title has a readable fallback',
      (tester) async {
    final fixture = await _Fixture.pump(tester, books: []);
    await _choose(tester, '3열');
    expect(find.text('책을 담아 볼까요?'), findsOneWidget);
    expect(find.byType(SliverGrid), findsNothing);
    fixture.books = [const ChallengeResponse(challengeId: 8, bookTitle: '  ')];
    fixture.container.invalidate(learningBooksProvider);
    await tester.pumpAndSettle();
    expect(find.text('제목 없는 책'), findsOneWidget);
  });

  testWidgets(
      'book error is not an empty library and retry keeps the chosen layout',
      (tester) async {
    final fixture = await _Fixture.pump(tester, fail: true);
    await _choose(tester, '2열');
    expect(find.text('첫 책을 담아 볼까요?'), findsNothing);
    fixture.fail = false;
    await tester.ensureVisible(find.text('다시 불러오기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다시 불러오기'));
    await tester.pumpAndSettle();
    expect(_columns(tester), 2);
    expect(find.text(_longTitle), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('personal footprint remains a secondary navigable action',
      (tester) async {
    await _Fixture.pump(tester);
    await tester.tap(find.text('나의 독서 흔적'));
    await tester.pumpAndSettle();
    expect(find.text('private footprint'), findsOneWidget);
  });
}

int _columns(WidgetTester tester) =>
    (tester.widget<SliverGrid>(find.byType(SliverGrid)).gridDelegate
            as SliverGridDelegateWithFixedCrossAxisCount)
        .crossAxisCount;

Future<void> _choose(WidgetTester tester, String label) async {
  await tester.tap(find.textContaining('보기: '));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

class _Fixture {
  final scale = ValueNotifier<double>(1);
  late final ProviderContainer container;
  late final GoRouter router;
  List<ChallengeResponse> books = [_book];
  bool fail = false;

  static Future<_Fixture> pump(WidgetTester tester,
      {List<ChallengeResponse>? books, bool fail = false}) async {
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
                challengeId: 77, bookId: 177, bookTitle: '다시 펼칠 책'),
          ]),
    ]);
    fixture.router = GoRouter(initialLocation: '/library', routes: [
      GoRoute(
          path: '/library',
          builder: (_, __) => const Scaffold(body: LearningLibraryScreen())),
      GoRoute(
          path: '/library/footprint',
          builder: (_, __) => const Scaffold(body: Text('private footprint'))),
      GoRoute(
          path: '/library/:id/chapters',
          builder: (_, state) =>
              Scaffold(body: Text('chapters ${state.pathParameters['id']}'))),
    ]);
    addTearDown(() {
      fixture.router.dispose();
      fixture.container.dispose();
      fixture.scale.dispose();
    });
    await tester.pumpWidget(UncontrolledProviderScope(
        container: fixture.container,
        child: ValueListenableBuilder<double>(
            valueListenable: fixture.scale,
            builder: (_, scale, __) => MaterialApp.router(
                theme: LearningColors.theme,
                routerConfig: fixture.router,
                builder: (context, child) => MediaQuery(
                    data: MediaQuery.of(context)
                        .copyWith(textScaler: TextScaler.linear(scale)),
                    child: child!)))));
    await tester.pumpAndSettle();
    return fixture;
  }
}
