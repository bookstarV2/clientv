import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/learning_access.dart';
import '../data/learning_repository.dart';
import '../data/reading_graph.dart';
import 'learning_design.dart';

class LearningShell extends ConsumerStatefulWidget {
  const LearningShell({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<LearningShell> createState() => _LearningShellState();
}

class _LearningShellState extends ConsumerState<LearningShell>
    with WidgetsBindingObserver {
  bool _wasBackgrounded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused) {
      _wasBackgrounded = true;
      return;
    }
    if (state != AppLifecycleState.resumed || !_wasBackgrounded) return;
    _wasBackgrounded = false;
    if (!mounted || ref.read(learningAccountProvider) == null) return;
    ref.invalidate(learningBooksProvider);
    ref.invalidate(finishedLearningBooksProvider);
    ref.invalidate(reviewOverviewProvider);
    ref.invalidate(readingGraphProvider);
  }

  @override
  Widget build(BuildContext context) => Theme(
        data: LearningColors.theme,
        child: Scaffold(
          appBar: AppBar(
            title: Text([
              'AI 독서 퀴즈',
              '내 서재',
              '복습'
            ][widget.navigationShell.currentIndex]),
            actions: [
              IconButton(
                tooltip: '설정',
                onPressed: () => context.push('/settings'),
                icon: const Icon(Icons.tune_rounded),
              ),
              const SizedBox(width: 8)
            ],
          ),
          body: SafeArea(
              top: false, bottom: false, child: widget.navigationShell),
          bottomNavigationBar: DecoratedBox(
            decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: LearningColors.line))),
            child: NavigationBar(
              backgroundColor: LearningColors.paper,
              surfaceTintColor: Colors.transparent,
              indicatorColor: Colors.transparent,
              height: 72,
              selectedIndex: widget.navigationShell.currentIndex,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              onDestinationSelected: (index) => widget.navigationShell.goBranch(
                index,
                initialLocation: index == widget.navigationShell.currentIndex,
              ),
              destinations: const [
                NavigationDestination(
                    icon: Icon(Icons.lightbulb_outline_rounded),
                    selectedIcon: Icon(Icons.lightbulb_rounded,
                        color: LearningColors.primary),
                    label: 'AI 퀴즈'),
                NavigationDestination(
                    icon: Icon(Icons.menu_book_outlined),
                    selectedIcon: Icon(Icons.menu_book_rounded,
                        color: LearningColors.primary),
                    label: '내 서재'),
                NavigationDestination(
                    icon: Icon(Icons.history_rounded),
                    selectedIcon: Icon(Icons.history_rounded,
                        color: LearningColors.primary),
                    label: '복습'),
              ],
            ),
          ),
        ),
      );
}
