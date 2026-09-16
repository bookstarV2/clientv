import 'package:bookstar/modules/learning/data/learning_access.dart';
import 'package:bookstar/modules/learning/data/learning_repository.dart';
import 'package:bookstar/modules/learning/view/learning_design.dart';
import 'package:bookstar/modules/learning/view/learning_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

final _account = StateProvider<int?>((ref) => 7);

void main() {
  testWidgets('all shell tabs remain reachable in short landscape with 2x text',
      (tester) async {
    tester.view.physicalSize = const Size(480, 320);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await _Fixture.pump(tester, scale: 2);
    for (final index in [1, 2, 0]) {
      final destination = find.byType(NavigationDestination).at(index);
      expect(destination.hitTestable(), findsOneWidget);
      await tester.tap(destination);
      await tester.pumpAndSettle();
      expect(
          tester
              .widget<NavigationBar>(find.byType(NavigationBar))
              .selectedIndex,
          index);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('all three shell tabs remain reachable at 320px with triple text',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await _Fixture.pump(tester, scale: 3);

    for (final index in [1, 2, 0]) {
      final destination = find.byType(NavigationDestination).at(index);
      expect(destination.hitTestable(), findsOneWidget);
      await tester.tap(destination);
      await tester.pumpAndSettle();
      expect(
          tester
              .widget<NavigationBar>(find.byType(NavigationBar))
              .selectedIndex,
          index);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets(
      'background resume refreshes all cached tabs once and preserves selection and local state',
      (tester) async {
    final fixture = await _Fixture.pump(tester);
    await fixture.visitEveryTab(tester);
    await tester.tap(find.text('keep local state'));
    await tester.pump();
    expect(find.text('review local 1'), findsOneWidget);
    expect(fixture.loads, [1, 1, 1]);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(fixture.loads, [1, 1, 1]);
    await _backgroundAndResume(tester);

    expect(fixture.loads, [2, 2, 2]);
    expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        2);
    expect(find.text('review local 1'), findsOneWidget);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(fixture.loads, [2, 2, 2]);

    await _backgroundAndResume(tester);
    expect(fixture.loads, [3, 3, 3]);
    expect(find.text('review local 1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('hidden without paused also refreshes once on resume',
      (tester) async {
    final fixture = await _Fixture.pump(tester);
    await fixture.visitEveryTab(tester);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(fixture.loads, [2, 2, 2]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('inactive-only interruptions never reload the cached providers',
      (tester) async {
    final fixture = await _Fixture.pump(tester);
    await fixture.visitEveryTab(tester);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(fixture.loads, [1, 1, 1]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('guest background resume does not reload learning data',
      (tester) async {
    final fixture = await _Fixture.pump(tester, memberId: null);
    await fixture.visitEveryTab(tester);

    await _backgroundAndResume(tester);

    expect(fixture.loads, [1, 1, 1]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('logout while backgrounded prevents resumed data requests',
      (tester) async {
    final fixture = await _Fixture.pump(tester);
    await fixture.visitEveryTab(tester);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    fixture.container.read(_account.notifier).state = null;

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(fixture.loads, [1, 1, 1]);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'disposed shell unregisters its observer and ignores later resume',
      (tester) async {
    final fixture = await _Fixture.pump(tester);
    await fixture.visitEveryTab(tester);
    fixture.router.go('/outside');
    await tester.pumpAndSettle();
    expect(find.byType(LearningShell), findsNothing);

    await _backgroundAndResume(tester);

    expect(fixture.loads, [1, 1, 1]);
    expect(find.text('outside shell'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _backgroundAndResume(WidgetTester tester) async {
  for (final state in [
    AppLifecycleState.inactive,
    AppLifecycleState.hidden,
    AppLifecycleState.paused,
    AppLifecycleState.hidden,
    AppLifecycleState.inactive,
    AppLifecycleState.resumed,
  ]) {
    tester.binding.handleAppLifecycleStateChanged(state);
  }
  await tester.pumpAndSettle();
}

class _Fixture {
  final loads = [0, 0, 0];
  late final ProviderContainer container;
  late final GoRouter router;

  static Future<_Fixture> pump(WidgetTester tester,
      {int? memberId = 7, double scale = 1}) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    final fixture = _Fixture();
    fixture.container = ProviderContainer(overrides: [
      _account.overrideWith((ref) => memberId),
      learningAccountProvider.overrideWith((ref) => ref.watch(_account)),
      learningBooksProvider.overrideWith((ref) async {
        fixture.loads[0]++;
        return [];
      }),
      finishedLearningBooksProvider.overrideWith((ref) async {
        fixture.loads[1]++;
        return [];
      }),
      reviewOverviewProvider.overrideWith((ref) async {
        fixture.loads[2]++;
        return const ReviewPage(
            items: [],
            totalCount: 0,
            dueCount: 0,
            reviewedTodayCount: 0,
            hasNext: false);
      }),
    ]);
    fixture.router = GoRouter(initialLocation: '/quiz', routes: [
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => LearningShell(navigationShell: shell),
        branches: [
          for (final (index, path) in ['quiz', 'library', 'review'].indexed)
            StatefulShellBranch(routes: [
              GoRoute(
                  path: '/$path',
                  builder: (_, __) => _BranchProbe(index, path)),
            ]),
        ],
      ),
      GoRoute(
          path: '/outside',
          builder: (_, __) => const Scaffold(body: Text('outside shell'))),
    ]);
    addTearDown(() {
      fixture.router.dispose();
      fixture.container.dispose();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    });
    await tester.pumpWidget(UncontrolledProviderScope(
      container: fixture.container,
      child: MaterialApp.router(
          theme: LearningColors.theme,
          routerConfig: fixture.router,
          builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(scale)),
              child: child!)),
    ));
    await tester.pumpAndSettle();
    return fixture;
  }

  Future<void> visitEveryTab(WidgetTester tester) async {
    for (final index in [1, 2]) {
      await tester.tap(find.byType(NavigationDestination).at(index));
      await tester.pumpAndSettle();
    }
  }
}

class _BranchProbe extends ConsumerStatefulWidget {
  const _BranchProbe(this.index, this.label);
  final int index;
  final String label;

  @override
  ConsumerState<_BranchProbe> createState() => _BranchProbeState();
}

class _BranchProbeState extends ConsumerState<_BranchProbe> {
  int localCount = 0;

  @override
  Widget build(BuildContext context) {
    switch (widget.index) {
      case 0:
        ref.watch(learningBooksProvider);
      case 1:
        ref.watch(finishedLearningBooksProvider);
      case 2:
        ref.watch(reviewOverviewProvider);
    }
    return Column(children: [
      Text('${widget.label} local $localCount'),
      TextButton(
          onPressed: () => setState(() => localCount++),
          child: const Text('keep local state')),
    ]);
  }
}
