import 'package:bookstar/gen/colors.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

abstract class BaseScreen extends ConsumerStatefulWidget {
  const BaseScreen({super.key});

  @override
  BaseScreenState<BaseScreen> createState();
}

abstract class BaseScreenState<T extends BaseScreen> extends ConsumerState<T>
    with WidgetsBindingObserver {
  late ScrollController scrollController;
  late FocusNode focusNode;
  late ItemScrollController itemScrollController;
  late ItemPositionsListener itemPositionsListener;
  late PageController pageController;

  bool _isKeyboardVisible = false;

  // 아이템 위치 추적용 변수들
  int _currentFirstVisibleIndex = 0;
  int _previousFirstVisibleIndex = 0;

  // 기존 변수들
  double _currentScrollOffset = 0.0;
  double _previousScrollOffset = 0.0;

// 디바운싱용 새 변수들
  DateTime? _lastScrollTopReachedTime;
  DateTime? _lastScrollBottomReachedTime;

// ItemPositionsListener용 변수들 (기존)
  DateTime? _lastTopReachedTime;
  DateTime? _lastBottomReachedTime;

// 가로 스크롤용 변수들
  DateTime? _lastLeftReachedTime;
  DateTime? _lastRightReachedTime;
  double _currentHorizontalScrollOffset = 0.0;
  double _previousHorizontalScrollOffset = 0.0;

  // 디바운싱 시간 (밀리초)
  final double _scrollDebounceDuration = 1000;

  int currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    focusNode = FocusNode();
    itemScrollController = ItemScrollController();
    itemPositionsListener = ItemPositionsListener.create();
    pageController = PageController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.addListener(_scrollListener);
      itemPositionsListener.itemPositions.addListener(_itemPositionsListener);
      pageController.addListener(_pageListener);
      focusNode.addListener(_focusListener);
      WidgetsBinding.instance.addObserver(this);
    });
    onInitState();
  }

  @override
  void dispose() {
    scrollController.removeListener(_scrollListener);
    pageController.removeListener(_pageListener);
    focusNode.removeListener(_focusListener);
    scrollController.dispose();
    pageController.dispose();
    focusNode.dispose();
    itemPositionsListener.itemPositions.removeListener(_itemPositionsListener);

    WidgetsBinding.instance.removeObserver(this);

    onDispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final wasKeyboardVisible = _isKeyboardVisible;
    _isKeyboardVisible = bottomInset > 0;

    if (!wasKeyboardVisible && _isKeyboardVisible) {
      onKeyboardShown();
    } else if (wasKeyboardVisible && !_isKeyboardVisible) {
      onKeyboardHidden();
    }
  }

  void _scrollListener() {
    final offset = scrollController.offset;
    final maxScrollExtent = scrollController.position.maxScrollExtent;

    // 이전 offset 저장 후 현재 offset 업데이트
    _previousScrollOffset = _currentScrollOffset;
    _currentScrollOffset = offset;

    onScroll(offset, maxScrollExtent);

    // 방향 감지 - 이전 offset과 비교
    if (scrollController.position.axis == Axis.vertical) {
      if (offset > _previousScrollOffset) {
        onScrollDown(offset);
      } else if (offset < _previousScrollOffset) {
        onScrollUp(offset);
      }
    } else if (scrollController.position.axis == Axis.horizontal) {
      _previousHorizontalScrollOffset = _currentHorizontalScrollOffset;
      _currentHorizontalScrollOffset = offset;

      if (offset > _previousHorizontalScrollOffset) {
        onScrollRight(offset);
      } else if (offset < _previousHorizontalScrollOffset) {
        onScrollLeft(offset);
      }

      // 좌측 끝 도달 감지
      if (offset <= 0) {
        final now = DateTime.now();
        if (_lastLeftReachedTime == null ||
            now.difference(_lastLeftReachedTime!).inMilliseconds >= 300) {
          _lastLeftReachedTime = now;
          onLeftReached();
        }
      }

      // 우측 끝 도달 감지 (80% 지점)
      if (maxScrollExtent > 0 && offset >= maxScrollExtent * 0.8) {
        final now = DateTime.now();
        if (_lastRightReachedTime == null ||
            now.difference(_lastRightReachedTime!).inMilliseconds >= 300) {
          _lastRightReachedTime = now;
          onRightReached();
        }
      }
    }

    // 상단 도달 감지 - DateTime 디바운싱 적용
    if (offset <= 0) {
      final now = DateTime.now();
      if (_lastScrollTopReachedTime == null ||
          now.difference(_lastScrollTopReachedTime!).inMilliseconds >= 300) {
        _lastScrollTopReachedTime = now;
        onTopReached();
      }
    }

    // 하단 도달 감지 - 리스트 개수 기반으로 계산
    final totalItems = getListTotalItemCount();
    if (totalItems > 0 && maxScrollExtent > 0) {
      // 전체 아이템의 80% 지점의 스크롤 위치 계산
      final threshold = (totalItems * 0.8).round();
      final itemHeight = maxScrollExtent / totalItems; // 평균 아이템 높이
      final thresholdScrollPosition = threshold * itemHeight;

      if (offset >= thresholdScrollPosition) {
        final now = DateTime.now();
        if (_lastScrollBottomReachedTime == null ||
            now.difference(_lastScrollBottomReachedTime!).inMilliseconds >=
                300) {
          _lastScrollBottomReachedTime = now;
          onBottomReached();
        }
      }
    }
  }

  void _itemPositionsListener() {
    final positions = itemPositionsListener.itemPositions.value;

    if (positions.isNotEmpty) {
      // 화면에 보이는 아이템들 필터링 (trailing edge가 1.0 미만인 것들)
      final visibleItems = positions
          .where((position) => position.itemTrailingEdge < 1.0)
          .map((position) => position.index);

      if (visibleItems.isEmpty) {
        return;
      }

      /// 현재 보이는 아이템들 중 가장 첫번째 아이템의 인덱스
      final firstVisibleIndex = visibleItems.reduce((a, b) => a < b ? a : b);

      /// 현재 보이는 아이템들 중 가장 마지막 아이템의 인덱스
      final lastVisibleIndex = visibleItems.reduce((a, b) => a > b ? a : b);

      // 이전 상태 저장 후 현재 상태 업데이트 (방향 감지용)
      setState(() {
        _previousFirstVisibleIndex = _currentFirstVisibleIndex;
        _currentFirstVisibleIndex = firstVisibleIndex;
      });

      // 스크롤 콜백 호출
      onScroll(firstVisibleIndex.toDouble(), lastVisibleIndex.toDouble());

      // 방향 감지 - 첫 번째 보이는 아이템의 인덱스 변화로 판단
      if (_currentFirstVisibleIndex > _previousFirstVisibleIndex) {
        // 아래로 스크롤 (더 뒤쪽 아이템들이 보임)
        onScrollDown(firstVisibleIndex.toDouble());
      } else if (_currentFirstVisibleIndex < _previousFirstVisibleIndex) {
        // 위로 스크롤 (더 앞쪽 아이템들이 보임)
        onScrollUp(firstVisibleIndex.toDouble());
      }

      // 상단 도달 감지 - 0.3초 디바운싱 적용
      if (firstVisibleIndex == 0) {
        final now = DateTime.now();
        if (_lastTopReachedTime == null ||
            now.difference(_lastTopReachedTime!).inMilliseconds >=
                _scrollDebounceDuration) {
          setState(() {
            _lastTopReachedTime = now;
          });
          onTopReached();
        }
      }

      // 하단 도달 감지 - positions에서 최대 인덱스를 구해서 판단, 0.3초 디바운싱 적용
      final allIndices = positions.map((pos) => pos.index).toList();
      if (allIndices.isNotEmpty) {
        final totalItems = getListTotalItemCount(); // 인덱스는 0부터 시작하므로 +1
        final threshold = (totalItems * 0.8).round();

        if (lastVisibleIndex >= threshold) {
          final now = DateTime.now();
          if (_lastBottomReachedTime == null ||
              now.difference(_lastBottomReachedTime!).inMilliseconds >=
                  _scrollDebounceDuration) {
            setState(() {
              _lastBottomReachedTime = now;
            });
            onBottomReached();
          }
        }
      }
    }
  }

  void _focusListener() {
    if (focusNode.hasFocus) {
      onFocusGained();
    } else {
      onFocusLost();
    }
  }

  void _pageListener() {
    if (pageController.hasClients) {
      final page = pageController.page;
      if (page != null) {
        final newPageIndex = page.round();
        if (newPageIndex != currentPageIndex) {
          setState(() {
            currentPageIndex = newPageIndex;
          });
          onPageChanged(newPageIndex);
        }
      }
    }
  }

  void jumpToTop() {
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    itemScrollController.scrollTo(
      index: 0,
      duration: const Duration(milliseconds: 500), // 애니메이션 시간
      curve: Curves.easeInOut,
    );
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);
    onDidUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          onPopInvoked();
        }
      },
      child: GestureDetector(
        onTap: onScreenTap,
        child: Scaffold(
          backgroundColor: getBackgroundColor(context),
          extendBodyBehindAppBar: extendBodyBehindAppBar(),
          appBar: buildAppBar(context),
          body: _buildBodyWithRefresh(context),
          // bottomNavigationBar: _buildBottomNavigationBar(context),
          floatingActionButton: buildFloatingActionButton(context),
          floatingActionButtonAnimator: FloatingActionButtonAnimator.noAnimation,
          drawer: buildDrawer(context),
        ),
      ),
    );
  }

  Widget _buildBodyWithRefresh(BuildContext context) {
    final body = buildBody(context);

    if (enableRefreshIndicator()) {
      return RefreshIndicator(
        onRefresh: () => onRefresh(),
        color: getRefreshIndicatorColor(context) ?? ColorName.p1,
        backgroundColor:
            getRefreshIndicatorBackgroundColor(context) ?? Colors.transparent,
        child: body,
      );
    }

    return body;
  }

  // 유틸리티 메서드들
  void scrollToTop() {
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void scrollToBottom() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void hideKeyboard() {
    FocusScope.of(context).unfocus();
  }

  void requestFocus() {
    focusNode.requestFocus();
  }

  // Getter들
  bool get isKeyboardVisible => _isKeyboardVisible;
  double get currentScrollOffset => _currentScrollOffset;
  String get currentRoute =>
      GoRouter.of(context).routerDelegate.currentConfiguration.uri.path;
  Widget loading() => const Center(child: CircularProgressIndicator());
  Widget Function(Object, StackTrace) error(String msg) => (e, st) =>
      Center(child: Text(msg, style: TextStyle(color: ColorName.g3)));

  // 추상 메서드 - 필수 구현
  Widget buildBody(BuildContext context);

  // Hook 메서드들 - 선택적 구현
  PreferredSizeWidget? buildAppBar(BuildContext context) => null;
  Widget? buildFloatingActionButton(BuildContext context) => null;
  Widget? buildDrawer(BuildContext context) => null;
  Widget? buildBottomNavigationBar(BuildContext context) => null;

  // BottomNavigation 설정
  // List<BottomNavItem>? getBottomNavigationItems() => null;
  bool onBottomNavTap(int index, String targetRoute) => false;
  Color? getBottomNavSelectedColor(BuildContext context) => null;
  Color? getBottomNavUnselectedColor(BuildContext context) => null;
  bool getShowSelectedLabels() => true;
  bool getShowUnselectedLabels() => true;

  // 색상 설정
  Color getBackgroundColor(BuildContext context) => ColorName.b1;

  // RefreshIndicator 설정
  bool enableRefreshIndicator() => false;
  Future<void> onRefresh() async {}
  Color? getRefreshIndicatorColor(BuildContext context) => null;
  Color? getRefreshIndicatorBackgroundColor(BuildContext context) => null;
  int getListTotalItemCount() => 0;

  // 이벤트 Hook 메서드들
  void onInitState() {}
  void onDispose() {}
  void onScroll(double offset, double maxScrollExtent) {}
  void onScrollDown(double offset) {}
  void onScrollUp(double offset) {}
  void onScrollLeft(double offset) {}
  void onScrollRight(double offset) {}
  void onBottomReached() async {}
  void onTopReached() {}
  void onLeftReached() {}
  void onRightReached() {}
  void onKeyboardShown() {}
  void onKeyboardHidden() {}
  void onFocusGained() {}
  void onFocusLost() {}
  void onScreenTap() {}
  void onPageChanged(int pageIndex) {}
  void onDidUpdateWidget(covariant T oldWidget) {}

  // Pop 제어 메서드들
  bool canPop() => true;
  void onPopInvoked() {}

  // Scaffold 설정
  bool extendBodyBehindAppBar() => false;
}
