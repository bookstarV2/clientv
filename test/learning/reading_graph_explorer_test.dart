import 'package:bookstar/modules/learning/view/reading_graph_explorer.dart';
import 'package:bookstar/modules/learning/view/reading_graph_canvas.dart';
import 'package:bookstar/modules/learning/data/reading_graph.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'reading_graph_test.dart' as fixtures;

void main() {
  final graph = ReadingGraph.fromReviews([
    fixtures.item(1),
    fixtures.item(2),
    fixtures.item(3, bookId: 2, chapter: 22),
  ]);
  final surface = find.byKey(const ValueKey('graph-explorer-surface'));
  ReadingGraphPainter painter(WidgetTester tester) => tester
      .widget<CustomPaint>(
        find.descendant(
          of: surface,
          matching: find.byType(CustomPaint),
        ),
      )
      .painter! as ReadingGraphPainter;
  Matrix4 camera(WidgetTester tester) => tester
      .widget<Transform>(find.byKey(const ValueKey('graph-explorer-transform')))
      .transform;
  Future<void> pump(WidgetTester tester, {bool reduced = true}) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: reduced),
          child: Scaffold(
            body: ReadingGraphExplorer(
              graph: graph,
              onClose: () {},
              onOpen: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'drag moves only grabbed node in scene coordinates and edges retain actual parents',
    (tester) async {
      await pump(tester);
      final before = Map.of(painter(tester).layout.positions);
      final start = tester.getTopLeft(surface) + before['q1']!;
      final finger = await tester.startGesture(start);
      await tester.pump(const Duration(milliseconds: 100));
      await finger.moveBy(const Offset(5, 0));
      await finger.moveBy(const Offset(25, 0));
      await finger.moveBy(const Offset(40, 35));
      await tester.pump();
      final after = painter(tester);
      expect(
        (after.layout.positions['q1']! - before['q1']!).distance,
        greaterThan(35),
      );
      expect(after.layout.positions['b1'], before['b1']);
      expect(after.layout.positions['q3'], before['q3']);
      expect(after.selectedId, 'q1');
      expect(camera(tester), Matrix4.identity());
      expect(graph.nodes.firstWhere((n) => n.id == 'q1').parentId, 'c11');
      await finger.up();
      await tester.pumpAndSettle();
      expect(painter(tester).layout.positions, before,
          reason:
              'reduced motion returns immediately instead of storing a dragged position');
    },
  );

  testWidgets(
    'empty-space pan and plus minus change camera, fit preserves placement and reset restores it',
    (tester) async {
      await pump(tester);
      final original = Map.of(painter(tester).layout.positions);
      await tester.dragFrom(
        tester.getTopLeft(surface) + const Offset(25, 80),
        const Offset(100, 70),
      );
      await tester.pumpAndSettle();
      expect(camera(tester).getTranslation().length, greaterThan(30));
      expect(painter(tester).layout.positions, original);
      await tester.tap(find.byTooltip('탐색 지도 확대'));
      await tester.pumpAndSettle();
      expect(camera(tester).getMaxScaleOnAxis(), closeTo(1.4, .001));
      await tester.tap(find.byTooltip('탐색 지도 축소'));
      await tester.pumpAndSettle();
      expect(camera(tester).getMaxScaleOnAxis(), closeTo(1, .001));
      for (var i = 0; i < 12; i++) {
        await tester.tap(find.byTooltip('탐색 지도 축소'));
        await tester.pump();
      }
      expect(camera(tester).getMaxScaleOnAxis(), closeTo(.35, .001));
      for (var i = 0; i < 25; i++) {
        await tester.tap(find.byTooltip('탐색 지도 확대'));
        await tester.pump();
      }
      expect(camera(tester).getMaxScaleOnAxis(), closeTo(8, .001));
      await tester.tap(find.byTooltip('탐색 지도 화면 맞춤'));
      await tester.pumpAndSettle();
      expect(camera(tester), Matrix4.identity());
      await tester.tap(find.byTooltip('처음으로'));
      await tester.pumpAndSettle();
      expect(painter(tester).layout.positions, original);
    },
  );

  testWidgets('two fingers pinch both directions without dragging nodes', (
    tester,
  ) async {
    await pump(tester);
    final before = Map.of(painter(tester).layout.positions);
    final center = tester.getCenter(surface);
    final left = await tester.startGesture(
      center - const Offset(50, 0),
      pointer: 1,
    );
    final right = await tester.startGesture(
      center + const Offset(50, 0),
      pointer: 2,
    );
    await left.moveBy(const Offset(-20, 0));
    await right.moveBy(const Offset(20, 0));
    await tester.pump();
    await left.moveBy(const Offset(-50, 0));
    await right.moveBy(const Offset(50, 0));
    await tester.pump();
    final enlarged = camera(tester).getMaxScaleOnAxis();
    expect(enlarged, greaterThan(1.2));
    await left.moveBy(const Offset(65, 0));
    await right.moveBy(const Offset(-65, 0));
    await tester.pump();
    expect(camera(tester).getMaxScaleOnAxis(), lessThan(enlarged));
    await left.up();
    await right.up();
    await tester.pumpAndSettle();
    expect(painter(tester).layout.positions, before);
  });

  testWidgets(
    'spring neighbors respond to dragged book then settle; reduced motion stays still',
    (tester) async {
      await pump(tester, reduced: false);
      final before = Map.of(painter(tester).layout.positions);
      final start = tester.getTopLeft(surface) + before['b1']!;
      final finger = await tester.startGesture(start);
      await finger.moveBy(const Offset(25, 0));
      await tester.pump();
      await finger.moveBy(const Offset(90, 30));
      await tester.pump();
      for (var i = 0; i < 60; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(
        (painter(tester).layout.positions['c11']! - before['c11']!).distance,
        greaterThan(.5),
      );
      final held = painter(tester).layout.positions['b1']!;
      await finger.up();
      await tester.pump(const Duration(milliseconds: 16));
      expect((painter(tester).layout.positions['b1']! - held).distance,
          lessThan(10),
          reason: 'release is gradual, not a teleport');
      await tester.pumpAndSettle(const Duration(milliseconds: 16));
      final settled = Map.of(painter(tester).layout.positions);
      for (final id in before.keys) {
        expect((settled[id]! - before[id]!).distance, lessThan(1),
            reason:
                'released nodes return to equilibrium, not a saved dragged arrangement');
      }
      await tester.pump(const Duration(seconds: 2));
      expect(painter(tester).layout.positions, settled);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('home node tap only selects without scrolling or resetting zoom',
      (tester) async {
    await fixtures.pumpGraph(
        tester,
        fixtures.GraphApi([
          fixtures.page([fixtures.item(1)])
        ]));
    final canvas = find.byType(ReadingGraphCanvas);
    await tester.tap(find.byTooltip('지도 확대'));
    await tester.pumpAndSettle();
    final viewer =
        tester.widget<InteractiveViewer>(find.byType(InteractiveViewer));
    final before = viewer.transformationController!.value.clone();
    final layout = ReadingGraphLayout(
        tester.widget<ReadingGraphCanvas>(canvas).graph,
        tester.getSize(canvas));
    final scroll = tester
        .state<ScrollableState>(find.byType(Scrollable).first)
        .position
        .pixels;
    await tester.tapAt(tester.getTopLeft(canvas) +
        MatrixUtils.transformPoint(before, layout.positions['q1']!));
    await tester.pumpAndSettle();
    expect(tester.widget<ReadingGraphCanvas>(canvas).selectedId, 'q1');
    expect(viewer.transformationController!.value, before);
    expect(
        tester
            .state<ScrollableState>(find.byType(Scrollable).first)
            .position
            .pixels,
        scroll);
  });

  testWidgets('zoomed node drag follows finger in screen pixels then returns',
      (tester) async {
    await pump(tester);
    await tester.tap(find.byTooltip('탐색 지도 확대'));
    await tester.pumpAndSettle();
    final before = Map.of(painter(tester).layout.positions);
    final start = tester.getTopLeft(surface) +
        MatrixUtils.transformPoint(camera(tester), before['b1']!);
    final finger = await tester.startGesture(start);
    await finger.moveBy(const Offset(24, 0));
    await tester.pump();
    final accepted = painter(tester).layout.positions['b1']!;
    await finger.moveBy(const Offset(42, 0));
    await tester.pump();
    expect(painter(tester).layout.positions['b1']!.dx - accepted.dx,
        closeTo(30, .01));
    await finger.up();
    await tester.pumpAndSettle();
    expect(painter(tester).layout.positions, before);
  });

  for (final textScale in [2.0, 3.0]) {
    testWidgets('fullscreen controls fit 320px at text scale $textScale',
        (tester) async {
      tester.view.physicalSize = const Size(320, 667);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(MaterialApp(
          home: MediaQuery(
              data: MediaQueryData(
                  disableAnimations: true,
                  textScaler: TextScaler.linear(textScale)),
              child: Scaffold(
                  body: ReadingGraphExplorer(
                      graph: graph, onClose: () {}, onOpen: (_) {})))));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('탐색 지도 축소'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('fullscreen closes and account switch removes graph overlay', (
    tester,
  ) async {
    final container = await fixtures.pumpGraph(
      tester,
      fixtures.GraphApi([
        fixtures.page([fixtures.item(1)]),
      ]),
    );
    await tester.tap(find.byTooltip('지도 전체 화면 · 점 끌기'));
    await tester.pumpAndSettle();
    expect(find.byType(ReadingGraphExplorer), findsOneWidget);
    await tester.tap(find.byTooltip('지도 탐색 닫기'));
    await tester.pumpAndSettle();
    expect(find.byType(ReadingGraphExplorer), findsNothing);
    await tester.tap(find.byTooltip('지도 전체 화면 · 점 끌기'));
    await tester.pumpAndSettle();
    container.read(fixtures.account.notifier).state = null;
    await tester.pumpAndSettle();
    expect(find.byType(ReadingGraphExplorer), findsNothing);
  });
}
