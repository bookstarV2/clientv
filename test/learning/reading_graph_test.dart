import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:bookstar/modules/learning/data/footprint_export.dart';
import 'package:bookstar/modules/learning/data/learning_access.dart';
import 'package:bookstar/modules/learning/data/learning_repository.dart';
import 'package:bookstar/modules/learning/data/reading_graph.dart';
import 'package:bookstar/modules/learning/view/learning_design.dart';
import 'package:bookstar/modules/learning/view/reading_graph_canvas.dart';
import 'package:bookstar/modules/learning/view/reading_map_preview.dart';
import 'package:bookstar/modules/learning/view/reading_map_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

ReviewItem item(int id,
        {int? bookId = 1,
        int chapter = 11,
        String title = '같은 제목',
        int reviews = 0}) =>
    ReviewItem(
        bookId: bookId,
        quizId: id,
        chapterId: chapter,
        chapterTitle: '목차 $chapter',
        bookTitle: title,
        bookCover: '',
        question: '풀어본 질문 $id',
        reviewCount: reviews,
        due: false,
        nextReviewAt: DateTime.utc(2030));

ReviewPage page(List<ReviewItem> items,
        {bool more = false, int? cursor, int unavailable = 0}) =>
    ReviewPage(
        items: items,
        totalCount: 999,
        dueCount: 0,
        reviewedTodayCount: 0,
        hasNext: more,
        nextCursor: cursor,
        unavailableCount: unavailable);

class GraphApi extends LearningRepository {
  GraphApi(this.pages) : super(Dio());
  final List<ReviewPage> pages;
  final calls = <int?>[];
  bool fail = false;
  @override
  Future<ReviewPage> getReviews(
      {int? cursor, bool dueOnly = false, bool reviewedOnly = false}) async {
    expect(dueOnly, isFalse);
    if (fail) throw StateError('offline');
    calls.add(cursor);
    return pages[(calls.length - 1).clamp(0, pages.length - 1)];
  }
}

class DeferredGraphApi extends GraphApi {
  DeferredGraphApi() : super([]);
  final pending = [Completer<ReviewPage>(), Completer<ReviewPage>()];
  @override
  Future<ReviewPage> getReviews(
      {int? cursor, bool dueOnly = false, bool reviewedOnly = false}) {
    calls.add(cursor);
    return pending[calls.length - 1].future;
  }
}

final account = StateProvider<int?>((ref) => 7);

class FakeExport extends FootprintExport {
  final shared = <Uint8List>[];
  @override
  Future<void> share(
      Uint8List bytes, Rect origin, bool Function() stillOwner) async {
    if (stillOwner()) shared.add(bytes);
  }
}

Future<ProviderContainer> pumpGraph(WidgetTester tester, GraphApi api,
    {double scale = 1,
    double width = 375,
    Widget screen = const ReadingMapAllScreen(),
    FakeExport? exporter}) async {
  tester.view.physicalSize = Size(width, 812);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final container = ProviderContainer(overrides: [
    learningAccountProvider.overrideWith((ref) => ref.watch(account)),
    learningRepositoryProvider.overrideWithValue(api),
    footprintExportProvider.overrideWithValue(exporter ?? FakeExport()),
  ]);
  addTearDown(container.dispose);
  final router = GoRouter(routes: [
    GoRoute(path: '/', builder: (_, __) => screen),
    GoRoute(path: '/map/all', builder: (_, __) => const ReadingMapAllScreen()),
    GoRoute(
        path: '/library',
        builder: (_, __) => const Scaffold(body: Text('서재 화면'))),
    GoRoute(
        path: '/review/quiz/:id',
        builder: (_, state) =>
            Scaffold(body: Text('목차 열기 ${state.pathParameters['id']}'))),
  ]);
  addTearDown(router.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
          theme: LearningColors.theme,
          routerConfig: router,
          builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(scale)),
              child: child!))));
  await tester.pumpAndSettle();
  return container;
}

Finder bookRow(String title) => find
    .ancestor(of: find.text(title).first, matching: find.byType(InkWell))
    .first;

Future<void> tapBookRow(WidgetTester tester, String title) async {
  await tester.ensureVisible(bookRow(title));
  await tester.pumpAndSettle();
  await tester.tap(bookRow(title));
  await tester.pumpAndSettle();
}

void main() {
  WidgetController.hitTestWarningShouldBeFatal = true;
  test('IDs, not titles, define books and real parent edges', () {
    final graph = ReadingGraph.fromReviews(
        [item(1), item(1), item(2), item(3, bookId: 2, chapter: 22)]);
    expect(graph.books.length, 2);
    expect(graph.chapterCount, 2);
    expect(graph.questionCount, 3);
    final ids = graph.nodes.map((n) => n.id).toSet();
    expect(ids.length, graph.nodes.length);
    for (final n in graph.nodes.where((n) => n.parentId != null)) {
      expect(ids.contains(n.parentId), isTrue);
      expect(
          graph.nodes.firstWhere((p) => p.id == n.parentId).bookId, n.bookId);
    }
  });

  test('repeated reviews do not invent additional learned points', () {
    final before = ReadingGraph.fromReviews([item(1)]);
    final after = ReadingGraph.fromReviews([item(1, reviews: 10)]);
    expect(after.nodes.length, before.nodes.length);
    expect(after.nodes.last.reviewCount, 10);
    expect(after.nodes.last.x, before.nodes.last.x);
  });

  test('new questions preserve book anchor and missing identity is an error',
      () {
    final first = ReadingGraph.fromReviews([item(1)]);
    final later =
        ReadingGraph.fromReviews([item(1), item(2), item(3, bookId: 2)]);
    expect(later.books.first.x, first.books.first.x);
    expect(later.books.first.y, first.books.first.y);
    expect(() => ReadingGraph.fromReviews([item(1, bookId: null)]),
        throwsFormatException);
  });

  test('pagination follows state cursor including empty intermediate pages',
      () async {
    final api = GraphApi([
      page([item(1)], more: true, cursor: 90),
      page([], more: true, cursor: 60),
      page([item(2)], unavailable: 3)
    ]);
    final container = ProviderContainer(overrides: [
      learningAccountProvider.overrideWithValue(7),
      learningRepositoryProvider.overrideWithValue(api)
    ]);
    addTearDown(container.dispose);
    final graph = await container.read(readingGraphProvider.future);
    expect(api.calls, [null, 90, 60]);
    expect(graph.questionCount, 2);
    expect(graph.unavailableCount, 3);
    expect(graph.truncated, isFalse);
  });

  test('bad cursor fails instead of hanging or rendering partial success',
      () async {
    final container = ProviderContainer(overrides: [
      learningAccountProvider.overrideWithValue(7),
      learningRepositoryProvider.overrideWithValue(GraphApi([
        page([item(1)], more: true, cursor: 8),
        page([], more: true, cursor: 8)
      ]))
    ]);
    addTearDown(container.dispose);
    await expectLater(
        container.read(readingGraphProvider.future), throwsFormatException);
  });

  test('large pages are explicitly marked truncated after bounded requests',
      () async {
    final api = GraphApi(List.generate(
        10, (i) => page([item(i + 1)], more: true, cursor: 100 - i)));
    final container = ProviderContainer(overrides: [
      learningAccountProvider.overrideWithValue(7),
      learningRepositoryProvider.overrideWithValue(api)
    ]);
    addTearDown(container.dispose);
    expect(
        (await container.read(readingGraphProvider.future)).truncated, isTrue);
    expect(api.calls.length, 10);
  });

  test('signed out never requests private graph', () async {
    final api = GraphApi([page([])]);
    final container = ProviderContainer(overrides: [
      learningAccountProvider.overrideWithValue(null),
      learningRepositoryProvider.overrideWithValue(api)
    ]);
    addTearDown(container.dispose);
    await expectLater(
        container.read(readingGraphProvider.future), throwsStateError);
    expect(api.calls, isEmpty);
  });

  for (final scale in [1.0, 2.0, 3.0]) {
    testWidgets('320px map, book list and selection fit text scale $scale',
        (tester) async {
      await pumpGraph(
          tester,
          GraphApi([
            page(List.generate(
                60,
                (i) => item(i + 1,
                    bookId: i ~/ 10 + 1,
                    chapter: i ~/ 5 + 1,
                    title: '긴 제목과 부제목이 여러 줄이 되는 가상의 독서 기록 ${i ~/ 10 + 1}')))
          ]),
          width: 320,
          scale: scale);
      expect(find.byType(ReadingGraphCanvas), findsOneWidget);
      await tapBookRow(tester, '긴 제목과 부제목이 여러 줄이 되는 가상의 독서 기록 1');
      expect(
          tester
              .getSemantics(bookRow('긴 제목과 부제목이 여러 줄이 되는 가상의 독서 기록 1'))
              .hasFlag(ui.SemanticsFlag.isSelected),
          isTrue);
      expect(find.text('목차 1'), findsOneWidget);
      expect(find.text('목차 2'), findsOneWidget);
      expect(find.text('목차 3'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('empty map contains no fake nodes and adds a book in 내 서재',
      (tester) async {
    await pumpGraph(tester, GraphApi([page([])]));
    expect(find.byType(ReadingGraphCanvas), findsNothing);
    expect(find.byTooltip('독서 지도 이미지로 공유'), findsNothing);
    await tester.tap(find.text('책 추가하기'));
    await tester.pumpAndSettle();
    expect(find.text('서재 화면'), findsOneWidget);
  });

  testWidgets('tap actual point selects question and opens its own chapter',
      (tester) async {
    await pumpGraph(
        tester,
        GraphApi([
          page([
            item(101, bookId: 1, chapter: 11),
            item(102, bookId: 1, chapter: 12),
            item(201, bookId: 2, chapter: 21, title: '다른 책'),
            item(202, bookId: 2, chapter: 22, title: '다른 책'),
          ])
        ]));
    final canvas = find.byType(ReadingGraphCanvas);
    final widget = tester.widget<ReadingGraphCanvas>(canvas);
    expect(widget.graph.books.map((node) => node.bookId), [1, 2]);
    final layout = ReadingGraphLayout(widget.graph, tester.getSize(canvas));
    await tester.tapAt(tester.getTopLeft(canvas) + layout.positions['q202']!);
    await tester.pumpAndSettle();
    expect(tester.widget<ReadingGraphCanvas>(canvas).selectedId, 'c22');
    expect(find.text('풀어본 질문 202'), findsOneWidget);
    expect(find.text('목차 22'), findsOneWidget);
    for (final other in [101, 102, 201]) {
      expect(find.text('풀어본 질문 $other'), findsNothing);
    }
    await tester.tap(find.text('퀴즈 다시 풀기'));
    await tester.pumpAndSettle();
    expect(find.text('목차 열기 22'), findsOneWidget);
    GoRouter.of(tester.element(find.text('목차 열기 22'))).pop();
    await tester.pumpAndSettle();

    // Tapping the selected book row steps back: chapter → book → nothing.
    await tapBookRow(tester, '다른 책');
    expect(find.text('풀어본 질문 202'), findsNothing);
    expect(find.text('목차 21'), findsOneWidget);
    expect(tester.widget<ReadingGraphCanvas>(canvas).selectedId, 'b2');
    await tapBookRow(tester, '다른 책');
    expect(find.text('목차 21'), findsNothing);
    expect(tester.widget<ReadingGraphCanvas>(canvas).selectedId, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('selecting a book reveals its chapters; a chapter its quizzes',
      (tester) async {
    await pumpGraph(
        tester,
        GraphApi([
          page([
            item(101, bookId: 1, chapter: 11, title: '소년이 온다'),
            item(102, bookId: 1, chapter: 11, title: '소년이 온다'),
            item(103, bookId: 1, chapter: 12, title: '소년이 온다'),
            item(201, bookId: 2, chapter: 21, title: '눈물꽃 소년'),
          ])
        ]));
    expect(
        find.byWidgetPredicate((widget) =>
            widget is RichText &&
            widget.text.toPlainText().startsWith('4') &&
            widget.text.toPlainText().endsWith('개 퀴즈')),
        findsOneWidget);
    expect(find.text('풀어본 퀴즈 3개'), findsOneWidget);
    expect(find.text('풀어본 퀴즈 1개'), findsOneWidget);
    await tapBookRow(tester, '소년이 온다');
    final scroll =
        tester.state<ScrollableState>(find.byType(Scrollable).first).position;
    expect(scroll.pixels, scroll.maxScrollExtent,
        reason: 'the selection panel is scrolled into view');
    expect(find.text('목차 11'), findsOneWidget);
    expect(find.text('목차 21'), findsNothing);
    await tester.tap(find.text('목차 11'));
    await tester.pumpAndSettle();
    expect(find.text('풀어본 질문 101'), findsOneWidget);
    expect(find.text('풀어본 질문 102'), findsOneWidget);
    expect(find.text('풀어본 질문 103'), findsNothing);
    expect(find.text('퀴즈 다시 풀기'), findsOneWidget);
    await tester.tap(find.text('소년이 온다').last);
    await tester.pumpAndSettle();
    expect(find.text('목차 12'), findsOneWidget,
        reason: 'the book label in the panel returns to its chapter list');
  });

  testWidgets('error is not an empty achievement and retry restores graph',
      (tester) async {
    final api = GraphApi([
      page([item(1)])
    ])
      ..fail = true;
    await pumpGraph(tester, api);
    expect(find.text('책 추가하기'), findsNothing);
    api.fail = false;
    await tester.tap(find.text('다시 불러오기'));
    await tester.pumpAndSettle();
    expect(find.byType(ReadingGraphCanvas), findsOneWidget);
  });

  testWidgets('account removal immediately removes prior private nodes',
      (tester) async {
    final container = await pumpGraph(
        tester,
        GraphApi([
          page([item(1)])
        ]));
    container.read(account.notifier).state = null;
    await tester.pumpAndSettle();
    expect(find.byType(ReadingGraphCanvas), findsNothing);
    expect(find.text('같은 제목'), findsNothing);
  });

  testWidgets('drag over the map scrolls the page', (tester) async {
    await pumpGraph(
        tester,
        GraphApi([
          page([item(1), item(2, bookId: 2, chapter: 22)])
        ]));
    final position =
        tester.state<ScrollableState>(find.byType(Scrollable).first).position;
    await tester.dragFrom(tester.getCenter(find.byType(ReadingGraphCanvas)),
        const Offset(0, -150));
    await tester.pumpAndSettle();
    expect(position.pixels, greaterThan(0));
  });

  testWidgets('pinching the full map zooms it', (tester) async {
    await pumpGraph(
        tester,
        GraphApi([
          page([item(1), item(2, bookId: 2, chapter: 22)])
        ]));
    final center = tester.getCenter(find.byType(ReadingGraphCanvas));
    final left =
        await tester.startGesture(center - const Offset(40, 0), pointer: 1);
    final right =
        await tester.startGesture(center + const Offset(40, 0), pointer: 2);
    for (var i = 0; i < 3; i++) {
      await left.moveBy(const Offset(-25, 0));
      await right.moveBy(const Offset(25, 0));
      await tester.pump();
    }
    await left.up();
    await right.up();
    await tester.pumpAndSettle();
    final viewer =
        tester.widget<InteractiveViewer>(find.byType(InteractiveViewer));
    expect(viewer.transformationController!.value.getMaxScaleOnAxis(),
        greaterThan(1.2));
    expect(viewer.panEnabled, isTrue);
  });

  testWidgets('share asks first and shares the rendered map only on approval',
      (tester) async {
    final exporter = FakeExport();
    await pumpGraph(
        tester,
        GraphApi([
          page([item(1)])
        ]),
        exporter: exporter);
    await tester.tap(find.byTooltip('독서 지도 이미지로 공유'));
    await tester.pumpAndSettle();
    expect(find.text('이 지도를 이미지로 공유할까요?'), findsOneWidget);
    await tester.tap(find.text('취소'));
    await tester.pumpAndSettle();
    expect(exporter.shared, isEmpty);
    await tester.tap(find.byTooltip('독서 지도 이미지로 공유'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('이미지 만들기'));
    for (var i = 0; i < 20 && exporter.shared.isEmpty; i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump();
    }
    expect(exporter.shared, hasLength(1));
    expect(exporter.shared.single.take(4), [0x89, 0x50, 0x4E, 0x47]);
  });

  testWidgets('4.1 tab shows the summary and opens the full map',
      (tester) async {
    await pumpGraph(
        tester,
        GraphApi([
          page([
            item(1),
            item(2),
            item(3, bookId: 2, chapter: 22, title: '두 번째 책')
          ])
        ]),
        screen: const Scaffold(body: ReadingMapScreen()));
    expect(find.text('2권에서 쌓인 3개의 생각'), findsOneWidget);
    await tester.tap(find.byType(ReadingGraphCanvas));
    await tester.pumpAndSettle();
    expect(find.byType(ReadingMapAllScreen), findsOneWidget);
    expect(find.text('지도 속 책'), findsOneWidget);
  });

  testWidgets('4.1 empty tab sends 책 추가하기 to 내 서재', (tester) async {
    await pumpGraph(tester, GraphApi([page([])]),
        screen: const Scaffold(body: ReadingMapScreen()));
    expect(find.text('아직 읽은 책이 없어요'), findsOneWidget);
    await tester.tap(find.text('책 추가하기'));
    await tester.pumpAndSettle();
    expect(find.text('서재 화면'), findsOneWidget);
  });

  testWidgets('home preview reports taps through onOpen', (tester) async {
    var opened = 0;
    await pumpGraph(
        tester,
        GraphApi([
          page([item(1)])
        ]),
        screen: Scaffold(
            body: ReadingMapPreview(mapHeight: 240, onOpen: () => opened++)));
    expect(find.text('1권에서 쌓인 1개의 생각'), findsOneWidget);
    await tester.tap(find.byType(ReadingGraphCanvas));
    expect(opened, 1);
  });

  for (final badId in [0, -1]) {
    test('rejects invalid book identity $badId', () {
      expect(() => ReadingGraph.fromReviews([item(1, bookId: badId)]),
          throwsFormatException);
    });
  }
  for (final next in <int?>[null, 91]) {
    test('rejects missing or forward cursor $next', () async {
      final container = ProviderContainer(overrides: [
        learningAccountProvider.overrideWithValue(7),
        learningRepositoryProvider.overrideWithValue(GraphApi([
          page([item(1)], more: true, cursor: 90),
          page([], more: true, cursor: next)
        ]))
      ]);
      addTearDown(container.dispose);
      await expectLater(
          container.read(readingGraphProvider.future), throwsFormatException);
    });
  }
  test('exactly ten complete pages are not marked partial', () async {
    final container = ProviderContainer(overrides: [
      learningAccountProvider.overrideWithValue(7),
      learningRepositoryProvider.overrideWithValue(GraphApi(List.generate(
          10,
          (i) => page([item(i + 1)],
              more: i < 9, cursor: i < 9 ? 100 - i : null))))
    ]);
    addTearDown(container.dispose);
    final graph = await container.read(readingGraphProvider.future);
    expect(graph.truncated, isFalse);
    expect(graph.questionCount, 10);
  });

  testWidgets('late account A response cannot replace B graph', (tester) async {
    final api = DeferredGraphApi();
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final container = ProviderContainer(overrides: [
      learningAccountProvider.overrideWith((ref) => ref.watch(account)),
      learningRepositoryProvider.overrideWithValue(api)
    ]);
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
            theme: LearningColors.theme, home: const ReadingMapAllScreen())));
    await tester.pump();
    container.read(account.notifier).state = 8;
    await tester.pump();
    expect(find.byType(ReadingGraphCanvas), findsNothing);
    api.pending[1].complete(page([item(2, bookId: 2, title: 'B의 책')]));
    await tester.pumpAndSettle();
    api.pending[0].complete(page([item(1, title: 'A의 비공개 책')]));
    await tester.pumpAndSettle();
    final graph = tester
        .widget<ReadingGraphCanvas>(find.byType(ReadingGraphCanvas))
        .graph;
    expect(graph.books.map((b) => b.label), ['B의 책']);
    expect(graph.nodes.any((n) => n.bookId == 1), isFalse);
  });

  testWidgets(
      'canonical share PNG includes header graph footer without viewport controls',
      (tester) async {
    final graph = ReadingGraph.fromReviews(List.generate(
        84,
        (i) => item(i + 1,
            bookId: i ~/ 12 + 1,
            chapter: i ~/ 3 + 1,
            title: 'Book ${i ~/ 12 + 1}')));
    await tester.runAsync(() async {
      await (FontLoader('Pretendard')
            ..addFont(rootBundle.load('assets/fonts/Pretendard-Regular.otf')))
          .load();
      final bytes = await renderReadingGraphImage(graph);
      final codec = await ui.instantiateImageCodec(bytes);
      final image = (await codec.getNextFrame()).image;
      expect(image.width, 1080);
      expect(image.height, 1350);
      final pixels =
          (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!
              .buffer
              .asUint8List();
      int darkPixels(int fromY, int toY) {
        var count = 0;
        for (var y = fromY; y < toY; y++) {
          for (var x = 0; x < 1080; x++) {
            final i = (y * 1080 + x) * 4;
            if (pixels[i] < 210 && pixels[i + 1] < 210 && pixels[i + 2] < 210) {
              count++;
            }
          }
        }
        return count;
      }

      expect(darkPixels(50, 400), greaterThan(1000),
          reason: 'graph background must not erase header');
      expect(darkPixels(430, 1150), greaterThan(1000),
          reason: 'full graph is painted');
      expect(darkPixels(1190, 1330), greaterThan(100),
          reason: 'brand and scope survive export');
      await File('build/reading-graph-share.png').writeAsBytes(bytes);
      image.dispose();
      codec.dispose();
    });
  });
}
