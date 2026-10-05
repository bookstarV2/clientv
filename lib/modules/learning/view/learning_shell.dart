import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/learning_access.dart';
import '../data/learning_footprint.dart';
import '../data/learning_repository.dart';
import '../data/reading_graph.dart';
import '../data/reading_map_remote.dart';
import 'bs_ui.dart';
import 'learning_design.dart';

/// Height of [BsNavBar] above the bottom safe area. Tab screens that use an
/// explicit scroll padding must add `MediaQuery.paddingOf(context).bottom`
/// (the Scaffold already includes this bar in it because of `extendBody`).
const kBsNavBarHeight = 86.0;

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
    ref.invalidate(reviewedQuizzesProvider);
    ref.invalidate(readingGraphProvider);
    ref.invalidate(readingMapStateProvider);
    ref.invalidate(learningFootprintProvider);
  }

  @override
  Widget build(BuildContext context) => Theme(
        data: LearningColors.theme,
        child: Scaffold(
          backgroundColor: Bs.bg,
          extendBody: true,
          body: Stack(
            children: [
              Positioned.fill(child: widget.navigationShell),
              Positioned(
                left: 0,
                right: 0,
                bottom: kBsNavBarHeight + MediaQuery.paddingOf(context).bottom,
                height: 44,
                child: const IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x00FFFFFF), Color(0x99FFFFFF)],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: BsNavBar(
            currentIndex: widget.navigationShell.currentIndex,
            onTap: (index) => widget.navigationShell.goBranch(
              index,
              initialLocation: index == widget.navigationShell.currentIndex,
            ),
          ),
        ),
      );
}

/// Bottom tab bar of Figma UI_v2: white, 24pt top corners, soft shadow,
/// AI 퀴즈 / 내 서재 / 복습 / 독서 지도.
class BsNavBar extends StatelessWidget {
  const BsNavBar({super.key, required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    ('nav_quiz', 'AI 퀴즈'),
    ('nav_library', '내 서재'),
    ('nav_review', '복습'),
    ('nav_map', '독서 지도'),
  ];

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: const BoxDecoration(
          color: Bs.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
                color: Color(0x1A303070),
                blurRadius: 24,
                offset: Offset(0, -2)),
          ],
        ),
        child: SafeArea(
          top: false,
          child: MediaQuery.withClampedTextScaling(
            maxScaleFactor: 1.3,
            child: SizedBox(
              height: kBsNavBarHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final (index, (icon, label)) in _items.indexed)
                    Expanded(
                      child: _NavItem(
                        icon: icon,
                        label: label,
                        selected: index == currentIndex,
                        onTap: () => onTap(index),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
}

class _NavItem extends StatelessWidget {
  const _NavItem(
      {required this.icon,
      required this.label,
      required this.selected,
      required this.onTap});

  final String icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        selected: selected,
        label: '$label 탭',
        excludeSemantics: true,
        child: InkResponse(
          onTap: onTap,
          radius: 40,
          highlightShape: BoxShape.rectangle,
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                selected
                    ? BsIcon('${icon}_active', size: 24, color: Bs.primary)
                    : BsIcon(icon, size: 24, color: Bs.black),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(label,
                      maxLines: 1,
                      style: Bs.text(14,
                          weight: FontWeight.w400,
                          color: selected ? Bs.primary : Bs.black,
                          height: 1.43)),
                ),
              ],
            ),
          ),
        ),
      );
}
