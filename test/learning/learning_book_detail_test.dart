import 'package:bookstar/modules/learning/data/learning_repository.dart';
import 'package:bookstar/modules/learning/view/learning_book_detail_screen.dart';
import 'package:bookstar/modules/learning/view/learning_design.dart';
import 'package:bookstar/modules/learning/view/learning_library_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const _synopsis = '첫 문장입니다. 두 번째 문장도 길게 이어집니다. 세 번째 문장은 줄거리를 더 설명합니다. '
    '네 번째 문장은 접힌 상태에서 보이지 않아야 합니다. 다섯 번째 문장은 펼쳤을 때만 보입니다. '
    '여섯 번째 문장으로 충분히 길게 만듭니다. 일곱 번째 문장까지 이어집니다.';

LearningBookDetail _detail({int? challengeId}) => LearningBookDetail(
      bookId: 1,
      title: '기억할 책',
      author: '테스트 작가',
      bookCover: '',
      publisher: '출판사',
      description: _synopsis,
      chapterCount: 2,
      chapters: const [
        LearningBookChapter(
            chapterId: 10, chapterNumber: 0, title: '1장 어린 새', hasQuiz: true),
        LearningBookChapter(
            chapterId: 11, chapterNumber: 1, title: '2장 검은 숨', hasQuiz: true),
      ],
      challengeId: challengeId,
    );

class _Fixture {
  final saved = <int>[];
  late final ProviderContainer container;
  bool fail = false;
  bool loadFails = false;
  int? challengeId;

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    container = ProviderContainer(overrides: [
      learningBookDetailProvider(1).overrideWith((ref) async {
        if (loadFails) throw StateError('isolated detail failure');
        return _detail(challengeId: challengeId);
      }),
      learningBookRegistrarProvider.overrideWithValue((bookId) async {
        saved.add(bookId);
        if (fail) throw StateError('isolated save failure');
        return 42;
      }),
    ]);
    final router = GoRouter(initialLocation: '/library/book/1', routes: [
      GoRoute(
          path: '/library',
          builder: (_, __) => const Scaffold(body: Text('library'))),
      GoRoute(
          path: '/library/book/:bookId',
          builder: (_, state) => LearningBookDetailScreen(
              bookId: int.parse(state.pathParameters['bookId']!))),
      GoRoute(
          path: '/library/:id/chapters',
          builder: (_, state) =>
              Scaffold(body: Text('chapters ${state.pathParameters['id']}'))),
    ]);
    addTearDown(() {
      router.dispose();
      container.dispose();
    });
    await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
            theme: LearningColors.theme, routerConfig: router)));
    await tester.pumpAndSettle();
  }
}

void main() {
  testWidgets('shows the book, a collapsible synopsis and its chapters',
      (tester) async {
    await _Fixture().pump(tester);

    expect(find.text('기억할 책'), findsWidgets);
    expect(find.text('테스트 작가 저자'), findsOneWidget);
    expect(find.text('줄거리'), findsOneWidget);
    expect(find.text('목차'), findsOneWidget);
    expect(find.text('1장 어린 새'), findsOneWidget);
    expect(tester.widget<Text>(find.text(_synopsis)).maxLines, 3);

    await tester.tap(find.text('더보기'));
    await tester.pumpAndSettle();
    expect(tester.widget<Text>(find.text(_synopsis)).maxLines, isNull);
    expect(find.text('접기'), findsOneWidget);
  });

  testWidgets('퀴즈 풀기 saves the book once and returns to the library',
      (tester) async {
    final fixture = _Fixture();
    await fixture.pump(tester);

    await tester.tap(find.text('퀴즈 풀기'));
    await tester.pumpAndSettle();

    expect(fixture.saved, [1]);
    expect(find.text('library'), findsOneWidget);
    expect(fixture.container.read(libraryAddedBookProvider), 42);
  });

  testWidgets('a book already in 내 서재 opens its chapters without saving',
      (tester) async {
    final fixture = _Fixture()..challengeId = 9;
    await fixture.pump(tester);

    await tester.tap(find.text('퀴즈 풀기'));
    await tester.pumpAndSettle();

    expect(fixture.saved, isEmpty);
    expect(find.text('chapters 9'), findsOneWidget);
  });

  testWidgets('a failed save keeps the detail open with a message',
      (tester) async {
    final fixture = _Fixture()..fail = true;
    await fixture.pump(tester);

    await tester.tap(find.text('퀴즈 풀기'));
    await tester.pumpAndSettle();

    expect(find.text('요청을 완료하지 못했어요. 잠시 후 다시 시도해 주세요.'), findsOneWidget);
    expect(find.text('퀴즈 풀기'), findsOneWidget);
    expect(fixture.container.read(libraryAddedBookProvider), isNull);
  });

  testWidgets('a detail load error can be retried', (tester) async {
    final fixture = _Fixture()..loadFails = true;
    await fixture.pump(tester);
    expect(find.text('다시 불러오기'), findsOneWidget);

    fixture.loadFails = false;
    await tester.tap(find.text('다시 불러오기'));
    await tester.pumpAndSettle();
    expect(find.text('줄거리'), findsOneWidget);
  });
}
