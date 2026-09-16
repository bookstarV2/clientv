import 'package:bookstar/modules/auth/view/screens/login_screen.dart';
import 'package:bookstar/modules/auth/view/screens/policy_detail_screen.dart';
import 'package:bookstar/modules/auth/model/policy.dart';
import 'package:bookstar/modules/learning/data/learning_access.dart';
import 'package:bookstar/modules/learning/view/learning_entry_screen.dart';
import 'package:bookstar/modules/learning/view/learning_notification_settings_screen.dart';
import 'package:bookstar/modules/learning/view/learning_archive_screen.dart';
import 'package:bookstar/modules/auth/view_model/auth_state.dart';
import 'package:bookstar/modules/auth/view_model/auth_view_model.dart';
import 'package:bookstar/modules/learning/view/learning_chapters_screen.dart';
import 'package:bookstar/modules/learning/view/learning_design.dart';
import 'package:bookstar/modules/learning/view/learning_home_screen.dart';
import 'package:bookstar/modules/learning/view/learning_library_screen.dart';
import 'package:bookstar/modules/learning/view/learning_footprint_screen.dart';
import 'package:bookstar/modules/learning/view/learning_preview_screen.dart';
import 'package:bookstar/modules/learning/view/learning_quiz_screen.dart';
import 'package:bookstar/modules/learning/view/learning_report_screen.dart';
import 'package:bookstar/modules/learning/view/learning_review_screen.dart';
import 'package:bookstar/modules/learning/view/learning_search_screen.dart';
import 'package:bookstar/modules/learning/view/learning_settings_screen.dart';
import 'package:bookstar/modules/learning/view/learning_shell.dart';
import 'package:bookstar/modules/my_page/view/screens/delete_account_screen.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../theme/app_theme.dart';

part 'router.g.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

@riverpod
GoRouter router(Ref ref) {
  final authState =
      ValueNotifier<AsyncValue<AuthState>>(ref.read(authViewModelProvider));
  final routingChanges = ValueNotifier<int>(0);
  ref
    ..onDispose(authState.dispose)
    ..onDispose(routingChanges.dispose)
    ..listen(authViewModelProvider, (_, next) {
      authState.value = next;
      routingChanges.value++;
    })
    ..listen(learningPolicyProvider, (_, __) => routingChanges.value++);

  return GoRouter(
    initialLocation: '/login',
    navigatorKey: rootNavigatorKey,
    refreshListenable: routingChanges,
    observers: [
      FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance)
    ],
    redirect: (context, state) {
      final path = state.uri.path;
      if (state.uri.scheme.startsWith('kakao')) return '/login';
      if (path == '/preview' ||
          path == '/policies/service' ||
          path == '/policies/privacy' ||
          path == '/policies/marketing') {
        return null;
      }
      if (authState.value.isLoading) return null;
      final authenticated = authState.value.valueOrNull is AuthSuccess;
      if (!authenticated) {
        return path == '/login'
            ? null
            : learningEntryLocation('/login',
                path == '/start' ? state.uri.queryParameters['next'] : path);
      }
      final policy = ref.read(learningPolicyProvider).valueOrNull;
      if (!hasRequiredLearningPolicy(policy)) {
        return path == '/start'
            ? null
            : learningEntryLocation('/start',
                path == '/login' ? state.uri.queryParameters['next'] : path);
      }
      if (path == '/login' || path == '/start') {
        return learningReturnPath(state.uri.queryParameters['next']);
      }
      if (path.startsWith('/my-feed')) return '/settings';
      if (path.startsWith('/book-log')) return '/settings/archive';
      if (path.startsWith('/book-pick')) return '/quiz';
      if (path.startsWith('/reading-challenge')) return '/library';
      if (path.startsWith('/reading-data')) return '/review';
      if (state.pathParameters.values.any(
          (value) => int.tryParse(value) == null || int.parse(value) <= 0)) {
        return '/library';
      }
      return null;
    },
    errorBuilder: (context, state) => LearningPage(
      title: '북스타',
      child: SingleChildScrollView(
          child: LearningEmpty(
        title: '이 화면은 새로 정리됐어요',
        message: '퀴즈와 복습을 중심으로 다시 만나 보세요.',
        action: FilledButton(
            onPressed: () => context.go('/quiz'),
            child: const Text('오늘 퀴즈로 가기')),
      )),
    ),
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/start', builder: (_, __) => const LearningEntryScreen()),
      GoRoute(
          path: '/policies/service',
          builder: (_, __) => Theme(
              data: AppTheme.themeData,
              child: const PolicyDetailScreen(
                  policyType: PolicyType.serviceUsing))),
      GoRoute(
          path: '/policies/privacy',
          builder: (_, __) => Theme(
              data: AppTheme.themeData,
              child: const PolicyDetailScreen(
                  policyType: PolicyType.personalInformation))),
      GoRoute(
          path: '/policies/marketing',
          builder: (_, __) => Theme(
              data: AppTheme.themeData,
              child:
                  const PolicyDetailScreen(policyType: PolicyType.marketing))),
      GoRoute(
          path: '/preview', builder: (_, __) => const LearningPreviewScreen()),
      GoRoute(
          path: '/settings',
          builder: (_, __) => const LearningSettingsScreen(),
          routes: [
            GoRoute(
                path: 'notifications',
                builder: (_, __) => const LearningNotificationSettingsScreen()),
            GoRoute(
                path: 'archive',
                builder: (_, __) => const LearningArchiveScreen(),
                routes: [
                  GoRoute(
                      path: ':diaryId',
                      builder: (_, state) => LearningArchiveDetailScreen(
                          diaryId:
                              int.parse(state.pathParameters['diaryId']!))),
                ]),
            GoRoute(
              path: 'delete-account',
              builder: (_, __) => Theme(
                  data: AppTheme.themeData, child: const DeleteAccountScreen()),
            ),
          ]),
      GoRoute(
        path: '/quiz/:quizId/report',
        builder: (_, state) => LearningReportScreen(
            quizId: int.parse(state.pathParameters['quizId']!)),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => LearningShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/quiz', builder: (_, __) => const LearningHomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/library',
              builder: (_, __) => const LearningLibraryScreen(),
              routes: [
                GoRoute(
                  path: 'search',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (_, __) => const LearningSearchScreen(),
                ),
                GoRoute(
                  path: 'footprint',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (_, __) => const LearningFootprintScreen(),
                ),
                GoRoute(
                  path: ':challengeId/chapters',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (_, state) => LearningChaptersScreen(
                    challengeId:
                        int.parse(state.pathParameters['challengeId']!),
                  ),
                ),
                GoRoute(
                  path: ':challengeId/quiz/:chapterId',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (_, state) => LearningQuizScreen(
                    chapterId: int.parse(state.pathParameters['chapterId']!),
                    challengeId:
                        int.parse(state.pathParameters['challengeId']!),
                  ),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/review',
              builder: (_, __) => const LearningReviewScreen(),
              routes: [
                GoRoute(
                  path: 'history',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (_, __) => const LearningReviewHistoryPage(),
                ),
                GoRoute(
                  path: 'quiz/:chapterId',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (_, state) => LearningQuizScreen(
                      chapterId: int.parse(state.pathParameters['chapterId']!)),
                ),
              ],
            ),
          ]),
        ],
      ),
    ],
  );
}
