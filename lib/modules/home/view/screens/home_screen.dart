import 'package:bookstar/common/service/analytics_service.dart';
import 'package:bookstar/gen/assets.gen.dart';
import 'package:bookstar/gen/colors.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/theme/app_style.dart';
import '../../model/home_bottom_nav_menu.dart';
import '../widgets/home_bottom_nav_bar.dart';
import '../widgets/home_app_bar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const HomeScreen({
    super.key,
    required this.navigationShell,
  });

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final int _lastVisitedTabIndex = HomeBottomNavMenu.bookPick.index;

  // NOTE(현호): 개선 필요
  void _onTabTapped(int index) {
    final tappedMenu = HomeBottomNavMenu.values[index];
    AnalyticsService.logEvent('click_bottom_nav',
        parameters: {'screen_name': tappedMenu.name});

    // 딥타임 같이 전체 화면을 사용하는 뷰로 이동할 때, 현재 탭(이전 탭이 될)을 저장합니다.
    // final previousIndex = widget.navigationShell.currentIndex;
    // if (index == HomeBottomNavMenu.deepTime.index) {
    //   setState(() {
    //     _lastVisitedTabIndex = previousIndex;
    //   });
    // }

    if (index == HomeBottomNavMenu.bookLog.index) {}

    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  Color? _getAppBarBackgroundColor({required String currentRoute}) {
    switch (currentRoute) {
      // case "/reading-challenge":
      //   {
      //     return Colors.transparent;
      //   }
      default:
        {
          return null;
        }
    }
  }

  List<Widget>? _getAppBarActions({required String currentRoute}) {
    switch (currentRoute) {
      case "/book-log":
        {
          return [
            GestureDetector(
              onTap: () {
                context.push('/book-log/search');
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 20),
                child:
                    Assets.icons.icPeopleSearchOne.svg(width: 24, height: 24),
              ),
            ),
          ];
        }
      default:
        {
          return null;
        }
    }
  }

  Widget? _getAppBarFlexibleSpace({required String currentRoute}) {
    switch (currentRoute) {
      // case "/reading-challenge":
      //   {
      //     return Container(
      //       decoration: BoxDecoration(
      //         color: ColorName.b1,
      //       ),
      //     );
      //   }
      default:
        {
          return null;
        }
    }
  }

  BoxDecoration? _getBodyDecoration({required String currentRoute}) {
    switch (currentRoute) {
      // case "/reading-challenge":
      //   {
      //     return BoxDecoration(
      //       gradient: LinearGradient(
      //         begin: Alignment.topCenter,
      //         end: Alignment.bottomLeft,
      //         colors: [
      //           ColorName.b1,
      //           ColorName.p1,
      //         ],
      //         stops: [0.15, 1],
      //       ),
      //     );
      //   }
      default:
        {
          return null;
        }
    }
  }

  EdgeInsetsGeometry _getBodyPadding({required String currentRoute}) {
    switch (currentRoute) {
      case "/book-log":
      case "/reading-challenge":
      case "/reading-data":
        {
          return EdgeInsets.zero;
        }
      default:
        {
          return AppPaddings.SCREEN_BODY_PADDING;
        }
    }
  }

  BoxDecoration? _getBottomNavigationBarDecoration(
      {required String currentRoute}) {
    switch (currentRoute) {
      case "/reading-challenge":
        {
          return BoxDecoration(
            color: ColorName.g7,
          );
        }
      default:
        {
          return null;
        }
    }
  }

  bool _getUseAppBar({required String currentRoute}) {
    switch (currentRoute) {
      case "/book-log":
      case "/my-feed":
        {
          return false;
        }
      default:
        {
          return true;
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final navigationShell = widget.navigationShell;
    // final isRunningDeepTime =
    //     ref.watch(deepTimeViewModelProvider).value?.status ==
    //         DeepTimeStatus.running;
    final router = GoRouter.of(context);
    final currentRoute =
        router.routerDelegate.currentConfiguration.uri.toString();

    Color? appBarBackgroundColor =
        _getAppBarBackgroundColor(currentRoute: currentRoute);
    List<Widget>? appBarActions = _getAppBarActions(currentRoute: currentRoute);
    Widget? appBarFlexibleSpace =
        _getAppBarFlexibleSpace(currentRoute: currentRoute);
    BoxDecoration? bodyDecoration =
        _getBodyDecoration(currentRoute: currentRoute);
    EdgeInsetsGeometry bodyPadding =
        _getBodyPadding(currentRoute: currentRoute);
    BoxDecoration? bottomNavigationBarDecoration =
        _getBottomNavigationBarDecoration(currentRoute: currentRoute);

    bool useAppBar = _getUseAppBar(currentRoute: currentRoute);

    return Scaffold(
      // NOTE(현호): 하나로 통합했어요. 기존 로직은 HomeAppBar 내에 남겨두었습니다.
      appBar: useAppBar
          ? HomeAppBar(
              backgroundColor: appBarBackgroundColor,
              flexibleSpace: appBarFlexibleSpace,
              currentIndex: navigationShell.currentIndex,
              onBackTap: () {
                navigationShell.goBranch(_lastVisitedTabIndex,
                    initialLocation: true);
              },
              actions: appBarActions,
            )
          : null,
      body: Container(
        decoration: bodyDecoration,
        child: Padding(
          // NOTE(현호): 패딩 조정
          padding: bodyPadding,
          child: navigationShell,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: bottomNavigationBarDecoration,
        child: AbsorbPointer(
          absorbing: false,
          // absorbing: isRunningDeepTime,
          child: HomeBottomNavBar(
            currentMenu: HomeBottomNavMenu.values[navigationShell.currentIndex],
            onTap: (tab) => _onTabTapped(HomeBottomNavMenu.values.indexOf(tab)),
          ),
        ),
      ),
    );
  }
}
