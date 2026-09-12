import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:bookstar/modules/learning/data/learning_access.dart';
import 'package:bookstar/modules/learning/data/learning_repository.dart';
import 'package:bookstar/modules/learning/data/reading_graph.dart';
import 'package:bookstar/modules/learning/view/learning_design.dart';
import 'package:bookstar/modules/learning/view/reading_graph_canvas.dart';
import 'package:bookstar/modules/learning/view/reading_graph_screen.dart';
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
  Future<ReviewPage> getReviews({int? cursor, bool dueOnly = false}) async {
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
  Future<ReviewPage> getReviews({int? cursor, bool dueOnly = false}) {
    calls.add(cursor);
    return pending[calls.length - 1].future;
  }
}

final account = StateProvider<int?>((ref) => 7);

Future<ProviderContainer> pumpGraph(WidgetTester tester, GraphApi api,
    {double scale = 1, double width = 375}) async {
  tester.view.physicalSize = Size(width, 812);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final container = ProviderContainer(overrides: [
    learningAccountProvider.overrideWith((ref) => ref.watch(account)),
    learningRepositoryProvider.overrideWithValue(api),
  ]);
  addTearDown(container.dispose);
  final router = GoRouter(routes: [
    GoRoute(
        path: '/',
        builder: (_, __) =>
            const Scaffold(body: SafeArea(child: ReadingGraphScreen()))),
    GoRoute(
        path: '/library/search',
        builder: (_, __) => const Scaffold(body: Text('책 검색 화면'))),
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
    testWidgets('320px graph and book selection fit text scale $scale',
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
      await tester.scrollUntilVisible(find.text('지도 속 책'), 300);
      await tester.ensureVisible(find.byType(ListTile).first);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ListTile).first);
      await tester.pumpAndSettle();
      expect(
          find.byWidgetPredicate(
              (widget) => widget is ListTile && widget.selected),
          findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('empty state contains no fake nodes and opens real book search',
      (tester) async {
    await pumpGraph(tester, GraphApi([page([])]));
    expect(find.byType(ReadingGraphCanvas), findsNothing);
    expect(find.text('내 독서 지도 공유'), findsNothing);
    await tester.tap(find.text('첫 책 찾기'));
    await tester.pumpAndSettle();
    expect(find.text('책 검색 화면'), findsOneWidget);
  });

  testWidgets('tap actual point selects question and opens its own chapter',
      (tester) async {
    await pumpGraph(
        tester,
        GraphApi([
          page([
            item(101, bookId: 1, chapter: 11),
            item(102, bookId: 1, chapter: 12),
            item(201, bookId: 2, chapter: 21),
            item(202, bookId: 2, chapter: 22),
          ])
        ]));
    final canvas = find.byType(ReadingGraphCanvas);
    final widget = tester.widget<ReadingGraphCanvas>(canvas);
    expect(widget.graph.books.map((node) => node.label), ['같은 제목', '같은 제목']);
    expect(widget.graph.books.map((node) => node.bookId), [1, 2]);
    final layout = ReadingGraphLayout(widget.graph, tester.getSize(canvas));
    await tester.tapAt(tester.getTopLeft(canvas) + layout.positions['q202']!);
    await tester.pumpAndSettle();
    expect(tester.widget<ReadingGraphCanvas>(canvas).selectedId, 'q202');
    final selected = widget.graph.nodes.firstWhere((node) => node.id == 'q202');
    expect(selected.bookId, 2);
    expect(selected.parentId, 'c22');
    expect(selected.chapterId, 22);
    final card = find
        .ancestor(of: find.text('풀어본 질문 202'), matching: find.byType(Container))
        .first;
    expect(find.descendant(of: card, matching: find.text('풀어본 질문 202')),
        findsOneWidget);
    expect(find.descendant(of: card, matching: find.text('같은 제목')),
        findsOneWidget);
    for (final other in [101, 102, 201]) {
      expect(find.text('풀어본 질문 $other'), findsNothing);
    }
    await tester.scrollUntilVisible(find.text('이 목차 다시 열기'), 180);
    await tester.tap(find.text('이 목차 다시 열기'));
    await tester.pumpAndSettle();
    expect(find.text('목차 열기 22'), findsOneWidget);
    expect(find.text('목차 열기 11'), findsNothing);
    GoRouter.of(tester.element(find.text('목차 열기 22'))).pop();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('선택 해제'), 180);
    await tester.tap(find.text('선택 해제'));
    await tester.pumpAndSettle();
    expect(find.text('풀어본 질문 202'), findsNothing);
    expect(find.text('이 목차 다시 열기'), findsNothing);
    expect(find.text('선택 해제'), findsNothing);
    await tester.scrollUntilVisible(canvas, -180);
    expect(tester.widget<ReadingGraphCanvas>(canvas).selectedId, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('error is not an empty achievement and retry restores graph',
      (tester) async {
    final api = GraphApi([
      page([item(1)])
    ])
      ..fail = true;
    await pumpGraph(tester, api);
    expect(find.text('첫 책 찾기'), findsNothing);
    api.fail = false;
    await tester.tap(find.text('지도 다시 불러오기'));
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

  testWidgets('zoom and reset remain bounded', (tester) async {
    await pumpGraph(
        tester,
        GraphApi([
          page([item(1)])
        ]));
    expect(find.byType(InteractiveViewer), findsNothing);
    final center =
        tester.getSize(find.byType(ReadingGraphCanvas)).center(Offset.zero);
    final before = center;
    await tester.tap(find.byTooltip('지도 확대'));
    await tester.pumpAndSettle();
    final viewerBefore =
        tester.widget<InteractiveViewer>(find.byType(InteractiveViewer));
    expect(viewerBefore.transformationController!.value.getMaxScaleOnAxis(),
        greaterThan(1));
    expect(
        (MatrixUtils.transformPoint(
                    viewerBefore.transformationController!.value, center) -
                before)
            .distance,
        lessThan(.001));
    for (var i = 0; i < 12; i++) {
      await tester.tap(find.byTooltip('지도 확대'));
    }
    await tester.pumpAndSettle();
    final viewer =
        tester.widget<InteractiveViewer>(find.byType(InteractiveViewer));
    expect(viewer.transformationController!.value.getMaxScaleOnAxis(),
        closeTo(5, .001));
    await tester.tap(find.byTooltip('지도 전체 보기'));
    expect(viewer.transformationController!.value.getMaxScaleOnAxis(), 1);
    await tester.pumpAndSettle();
    expect(find.byType(InteractiveViewer), findsNothing);
  });

  testWidgets('drag over default map scrolls page and reset restores scrolling',
      (tester) async {
    await pumpGraph(
        tester,
        GraphApi([
          page([item(1)])
        ]));
    final canvas = find.byType(ReadingGraphCanvas);
    ScrollPosition position() =>
        tester.state<ScrollableState>(find.byType(Scrollable).first).position;
    await tester.dragFrom(tester.getCenter(canvas), const Offset(0, -150));
    await tester.pumpAndSettle();
    expect(position().pixels, greaterThan(0));
    position().jumpTo(0);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('지도 확대'));
    await tester.pumpAndSettle();
    final viewer =
        tester.widget<InteractiveViewer>(find.byType(InteractiveViewer));
    final before = viewer.transformationController!.value.clone();
    await tester.dragFrom(tester.getCenter(canvas), const Offset(0, -60));
    await tester.pumpAndSettle();
    expect(position().pixels, 0);
    expect(viewer.transformationController!.value, isNot(before));
    await tester.tap(find.byTooltip('지도 전체 보기'));
    await tester.pumpAndSettle();
    await tester.dragFrom(tester.getCenter(canvas), const Offset(0, -150));
    await tester.pumpAndSettle();
    expect(position().pixels, greaterThan(0));
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
            theme: LearningColors.theme,
            home: const Scaffold(body: ReadingGraphScreen()))));
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

  testWidgets('book row selection exits exploration and restores page drags',
      (tester) async {
    await pumpGraph(
        tester,
        GraphApi([
          page(List.generate(
              24,
              (index) => item(index + 1,
                  bookId: index + 1,
                  chapter: index + 101,
                  title: '독서 지도 책 ${index + 1}')))
        ]));
    tester.view.physicalSize = const Size(375, 1600);
    await tester.pumpAndSettle();
    final canvas = find.byType(ReadingGraphCanvas);
    final pageView = find.byType(ListView);

    for (var selection = 0; selection < 2; selection++) {
      await tester.tap(find.byTooltip('지도 확대'));
      await tester.pumpAndSettle();
      expect(tester.widget<ReadingGraphCanvas>(canvas).exploring, isTrue);
      expect(find.byType(InteractiveViewer), findsOneWidget);
      expect(tester.widget<ListView>(pageView).physics,
          isA<NeverScrollableScrollPhysics>());

      final bookRow = find.byType(ListTile).first;
      expect(tester.getRect(bookRow).bottom, lessThan(1600));
      await tester.tap(bookRow);
      await tester.pumpAndSettle();
      expect(tester.widget<ListView>(pageView).physics,
          isA<AlwaysScrollableScrollPhysics>());
      final position =
          tester.state<ScrollableState>(find.byType(Scrollable).first).position;
      final selectionOffset = position.pixels;
      await tester.dragFrom(const Offset(180, 500), const Offset(0, 650));
      await tester.pumpAndSettle();
      expect(position.pixels, lessThan(selectionOffset),
          reason: 'The selection card must not leave its page scroll locked.');
      expect(tester.widget<ReadingGraphCanvas>(canvas).selectedId, 'b1');
      expect(tester.widget<ReadingGraphCanvas>(canvas).exploring, isFalse);
      expect(find.byType(InteractiveViewer), findsNothing);

      final before = position.pixels;
      await tester.dragFrom(const Offset(180, 500), const Offset(0, -220));
      await tester.pumpAndSettle();
      final below = position.pixels;
      expect(below, greaterThan(before),
          reason: 'Book selection must restore upward drags over the map.');
      await tester.dragFrom(const Offset(180, 500), const Offset(0, 500));
      await tester.pumpAndSettle();
      expect(position.pixels, lessThan(below),
          reason: 'Downward page drags must also work after selecting a book.');
      expect(tester.widget<ReadingGraphCanvas>(canvas).selectedId, 'b1');
    }
    expect(tester.takeException(), isNull);
  });
}
