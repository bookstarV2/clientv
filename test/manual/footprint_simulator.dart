// Local synthetic-account harness. Never imported by lib/main.dart or release routing.
import 'package:bookstar/infra/network/dio_client.dart';
import 'package:bookstar/modules/learning/data/learning_access.dart';
import 'package:bookstar/modules/learning/view/learning_chapters_screen.dart';
import 'package:bookstar/modules/learning/view/learning_design.dart';
import 'package:bookstar/modules/learning/view/learning_footprint_screen.dart';
import 'package:bookstar/modules/learning/view/learning_home_screen.dart';
import 'package:bookstar/modules/learning/view/learning_library_screen.dart';
import 'package:bookstar/modules/learning/view/learning_preview_screen.dart';
import 'package:bookstar/modules/learning/view/learning_quiz_screen.dart';
import 'package:bookstar/modules/learning/view/learning_review_screen.dart';
import 'package:bookstar/modules/learning/view/learning_search_screen.dart';
import 'package:bookstar/modules/learning/view/learning_shell.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

void main() {
  if (!kDebugMode) throw StateError('Synthetic harness must never run in release');
  const member = int.fromEnvironment('QA_MEMBER_ID');
  const token = String.fromEnvironment('QA_TOKEN');
  if (member <= 0 || token.isEmpty) throw StateError('Synthetic fixture required');
  final dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:8081',
    connectTimeout: const Duration(seconds: 10), receiveTimeout: const Duration(seconds: 15),
    headers: {'Authorization': 'Bearer $token'}));
  final root = GlobalKey<NavigatorState>();
  final router = GoRouter(navigatorKey: root, initialLocation: '/library', routes: [
    GoRoute(path: '/preview', builder: (_, __) => const LearningPreviewScreen()),
    GoRoute(path: '/settings', builder: (_, __) => const LearningPage(title: '합성 계정 QA',
      child: Center(child: Text('이 검증용 실행기는 실제 계정 로그인·설정을 변경하지 않습니다.')))),
    StatefulShellRoute.indexedStack(builder: (_, __, shell) => LearningShell(navigationShell: shell),
      branches: [
        StatefulShellBranch(routes: [GoRoute(path: '/quiz', builder: (_, __) => const LearningHomeScreen())]),
        StatefulShellBranch(routes: [GoRoute(path: '/library', builder: (_, __) => const LearningLibraryScreen(), routes: [
          GoRoute(path: 'search', parentNavigatorKey: root, builder: (_, __) => const LearningSearchScreen()),
          GoRoute(path: 'footprint', parentNavigatorKey: root, builder: (_, __) => const LearningFootprintScreen()),
          GoRoute(path: ':challengeId/chapters', parentNavigatorKey: root, builder: (_, state) =>
            LearningChaptersScreen(challengeId: int.parse(state.pathParameters['challengeId']!))),
          GoRoute(path: ':challengeId/quiz/:chapterId', parentNavigatorKey: root, builder: (_, state) =>
            LearningQuizScreen(challengeId: int.parse(state.pathParameters['challengeId']!),
              chapterId: int.parse(state.pathParameters['chapterId']!))),
        ])]),
        StatefulShellBranch(routes: [GoRoute(path: '/review', builder: (_, __) => const LearningReviewScreen(), routes: [
          GoRoute(path: 'history', parentNavigatorKey: root, builder: (_, __) => const LearningReviewHistoryPage()),
          GoRoute(path: 'quiz/:chapterId', parentNavigatorKey: root, builder: (_, state) =>
            LearningQuizScreen(chapterId: int.parse(state.pathParameters['chapterId']!))),
        ])]),
      ]),
  ]);
  runApp(ProviderScope(overrides: [learningAccountProvider.overrideWithValue(member),
    dioClientProvider.overrideWithValue(dio)], child: MaterialApp.router(
      debugShowCheckedModeBanner: false, theme: LearningColors.theme, routerConfig: router,
      builder: (_, child) => Banner(message: '합성 QA', location: BannerLocation.topEnd, child: child!))));
}
