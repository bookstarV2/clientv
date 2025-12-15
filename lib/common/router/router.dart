import 'package:bookstar/modules/book_log/view/screens/book_log_create_screen.dart';
import 'package:bookstar/modules/book_log/view/screens/book_log_thumbnail_screen.dart';
import 'package:bookstar/modules/book_log/view/screens/book_log_update_screen.dart';
import 'package:bookstar/modules/book_log/view/screens/book_related_feed_screen.dart';
import 'package:bookstar/modules/book_pick/view/screens/book_pick_my_likes_screen.dart';
import 'package:bookstar/modules/my_feed/view/screens/my_feed_feed_screen.dart';
import 'package:bookstar/modules/my_feed/view/screens/my_feed_screen.dart';
import 'package:bookstar/modules/reading_challenge/view/screens/reading_challenge_quiz_check_screen.dart';
import 'package:bookstar/modules/reading_challenge/view/screens/reading_challenge_quiz_deep_time_screen.dart';
import 'package:bookstar/modules/reading_challenge/view/screens/reading_challenge_quiz_screen.dart';
import 'package:bookstar/modules/reading_challenge/view/screens/reading_challenge_search_new_my_likes_screen.dart';
import 'package:bookstar/modules/reading_challenge/view/screens/reading_challenge_search_new_screen.dart';
import 'package:bookstar/modules/reading_challenge/view/screens/reading_challenge_start_screen.dart';
import 'package:bookstar/modules/reading_diary/model/diary_update_request.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../modules/auth/view/screens/login_screen.dart';
import '../../modules/auth/view_model/auth_state.dart';
import '../../modules/auth/view_model/auth_view_model.dart';
import '../../modules/book/view/screens/book_overview_screen.dart';
import '../../modules/book_log/view/screens/book_log_feed_screen.dart';
import '../../modules/book_log/view/screens/book_log_screen.dart';
import '../../modules/book_pick/model/search_book_response.dart';
import '../../modules/book_pick/view/screens/book_pick_screen.dart';
import '../../modules/book_pick/view/screens/book_pick_search_screen.dart';
import '../../modules/home/view/screens/home_screen.dart';
import '../../modules/my_page/view/screens/challenge_quit_books_screen.dart';
import '../../modules/my_page/view/screens/customer_support_screen.dart';
import '../../modules/my_page/view/screens/delete_account_screen.dart';
import '../../modules/my_page/view/screens/follower_management_screen.dart';
import '../../modules/my_page/view/screens/liked_diaries_screen.dart';
import '../../modules/reading_diary/view/screens/liked_diary_feed_screen.dart';
import '../../modules/reading_diary/view/screens/scrapped_diary_feed_screen.dart';
import '../../modules/my_page/view/screens/login_info_screen.dart';
import '../../modules/my_page/view/screens/my_page_screen.dart';
import '../../modules/my_page/view/screens/scrapped_diaries_screen.dart';
import '../../modules/profile/view/screens/profile_screen.dart';
import '../../modules/reading_challenge/view/screens/reading_challenge_detail_screen.dart';
import '../../modules/reading_challenge/view/screens/reading_challenge_diary_encourage_screen.dart';
import '../../modules/reading_challenge/view/screens/reading_challenge_rating_screen.dart';
import '../../modules/reading_challenge/view/screens/reading_challenge_screen.dart';
import '../../modules/reading_challenge/view/screens/reading_challenge_start_and_end_page_screen.dart';
import '../../modules/reading_challenge/view/screens/reading_challenge_total_page_screen.dart';
import '../../modules/reading_challenge/view/screens/my_diary_feeds_screen.dart';

part 'router.g.dart';

@riverpod
GoRouter router(Ref ref) {
  final rootNavigatorKey = GlobalKey<NavigatorState>();
  final authState = ValueNotifier<AsyncValue<AuthState>>(const AsyncLoading());
  final analytics = FirebaseAnalytics.instance;

  ref
    ..onDispose(authState.dispose)
    ..listen(
        authViewModelProvider.select(
            (value) => value.whenData((value) => value)), (_, next) async {
      authState.value = next;
    });

  return GoRouter(
    initialLocation: '/login',
    navigatorKey: rootNavigatorKey,
    refreshListenable: authState,
    observers: [
      FirebaseAnalyticsObserver(analytics: analytics),
    ],
    redirect: (context, state) {
      final isKakaoRedirect = state.uri.scheme.startsWith("kakao");
      if (isKakaoRedirect) {
        return "/login";
      }

      if (authState.value.isLoading || !authState.value.hasValue) return null;

      if (authState.value.unwrapPrevious().hasError) return '/login';

      final isAuthenticated = authState.value.requireValue is AuthSuccess;
      final isWithdrawCompleted =
          authState.value.requireValue is AuthWithdrawCompleted;
      final isLoginRoute = state.uri.path == '/login';
      // final isSplashRoute = state.uri.path == '/';

      // if (isSplashRoute) {
      //   return isAuthenticated ? '/book-pick' : '/login';
      // }

      if (isWithdrawCompleted) {
        return null;
      }

      if (isLoginRoute && isAuthenticated) {
        return '/book-pick';
      }

      if (!isLoginRoute && !isAuthenticated) {
        return '/login';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return HomeScreen(navigationShell: navigationShell);
        },
        branches: [
          /// 책픽
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/book-pick',
                builder: (context, state) => const BookPickScreen(),
                routes: [
                  GoRoute(
                      path: 'search',
                      parentNavigatorKey: rootNavigatorKey,
                      builder: (context, state) {
                        return BookPickSearchScreen();
                      },
                      routes: []),
                  GoRoute(
                    path: 'overview/:bookId',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) {
                      final bookId = int.parse(state.pathParameters['bookId']!);
                      return BookOverviewScreen(bookId: bookId);
                    },
                  ),
                  GoRoute(
                    path: 'my-likes',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) {
                      return BookPickMyLikesScreen();
                    },
                  ),
                ],
              ),
            ],
          ),

          /// 리딩챌린지
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/reading-challenge',
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  final challengeId = extra?['challengeId'] as int? ?? -1;

                  return ReadingChallengeScreen(challengeId: challengeId);
                },
                routes: [
                  GoRoute(
                    path: 'start/:challengeId',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) {
                      final challengeId =
                          int.parse(state.pathParameters['challengeId']!);
                      final extra = state.extra as Map<String, dynamic>?;
                      final requiredRefresh =
                          extra?['requiredRefresh'] as bool? ?? false;
                      return ReadingChallengeStartScreen(
                          challengeId: challengeId,
                          requiredRefresh: requiredRefresh);
                    },
                  ),
                  GoRoute(
                    path: ':challengeId/quiz/:chapterId/check',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) {
                      final challengeId =
                          int.parse(state.pathParameters['challengeId']!);
                      final chapterId =
                          int.parse(state.pathParameters['chapterId']!);

                      return ReadingChallengeQuizCheckScreen(
                          chapterId: chapterId, challengeId: challengeId);
                    },
                  ),
                  GoRoute(
                    path: ':challengeId/quiz/:chapterId/deep-time',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) {
                      final challengeId =
                          int.parse(state.pathParameters['challengeId']!);
                      final chapterId =
                          int.parse(state.pathParameters['chapterId']!);

                      return ReadingChallengeQuizDeepTimeScreen(
                          chapterId: chapterId, challengeId: challengeId);
                    },
                  ),
                  GoRoute(
                    path: ':challengeId/quiz/:chapterId',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) {
                      final challengeId =
                          int.parse(state.pathParameters['challengeId']!);
                      final chapterId =
                          int.parse(state.pathParameters['chapterId']!);

                      return ReadingChallengeQuizScreen(
                          chapterId: chapterId, challengeId: challengeId);
                    },
                  ),
                  GoRoute(
                    path: 'detail/:bookId',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) {
                      final bookId = int.parse(state.pathParameters['bookId']!);
                      final challengeId = int.parse(
                          state.uri.queryParameters['challengeId'] ?? '0');
                      final totalPages = int.parse(
                          state.uri.queryParameters['totalPages'] ?? '0');
                      final visibleDeleteChallenge = (state.uri
                                  .queryParameters['visibleDeleteChallenge'] ??
                              'false') ==
                          'true';
                      return ReadingChallengeDetailScreen(
                        bookId: bookId,
                        challengeId: challengeId,
                        totalPages: totalPages,
                        visibleDeleteChallenge: visibleDeleteChallenge,
                      );
                    },
                  ),
                  GoRoute(
                    path: 'search-new',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) {
                      return ReadingChallengeSearchNewScreen();
                    },
                    routes: [
                      GoRoute(
                        path: 'my-likes',
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (context, state) {
                          return ReadingChallengeSearchNewMyLikesScreen();
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'total-page',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) {
                      final book = state.extra as SearchBookResponse;
                      return ReadingChallengeTotalPageScreen(book: book);
                    },
                  ),
                  GoRoute(
                    path: 'start-and-end',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) {
                      final extra = state.extra as Map<String, dynamic>;
                      final book = extra['book'] as SearchBookResponse;
                      final totalPages = extra['totalPages'] as int;
                      final challengeId =
                          extra['challengeId'] as int?; // challengeId를 안전하게 추출
                      return ReadingChallengeStartAndEndPageScreen(
                        book: book,
                        totalPages: totalPages,
                        challengeId: challengeId, // challengeId 전달
                      );
                    },
                  ),
                  GoRoute(
                    path: 'rating',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) {
                      final book = state.extra as SearchBookResponse;
                      return ReadingChallengeRatingScreen(book: book);
                    },
                  ),
                  GoRoute(
                    path: 'diary-encourage',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) {
                      final extra = state.extra as Map<String, dynamic>;
                      final isChallengeCompleted =
                          extra['isChallengeCompleted'] as bool;
                      final bookId = extra['bookId'] as int;

                      return ReadingChallengeDiaryEncourageScreen(
                        isChallengeCompleted: isChallengeCompleted,
                        bookId: bookId,
                      );
                    },
                  ),
                  GoRoute(
                    path: 'diary-feeds',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) {
                      final extra = state.extra as Map<String, dynamic>;
                      final bookId = extra['bookId'] as int;
                      final memberId = extra['memberId'] as int;
                      final index = extra['index'] as int;
                      return MyDiaryFeedsScreen(
                        bookId: bookId,
                        memberId: memberId,
                        initialIndex: index,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          /// 책로그
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/book-log',
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  final requiredRefresh =
                      extra?['requiredRefresh'] as bool? ?? false;
                  return BookLogScreen(requiredRefresh: requiredRefresh);
                },
                routes: [
                  GoRoute(
                    path: 'thumbnail/:memberId',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) {
                      final memberId =
                          int.parse(state.pathParameters['memberId']!);
                      final extra = state.extra as Map<String, dynamic>?;
                      final requiredRefresh =
                          extra?['requiredRefresh'] as bool? ?? false;
                      return BookLogThumbnailScreen(
                          memberId: memberId, requiredRefresh: requiredRefresh);
                    },
                  ),
                  GoRoute(
                    path: 'feed/:memberId',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) {
                      final memberId =
                          int.parse(state.pathParameters['memberId']!);
                      final extra = state.extra as Map<String, dynamic>?;
                      final index = extra?['index'] as int? ?? 0;
                      return BookLogFeedScreen(
                          memberId: memberId, initialIndex: index);
                    },
                  ),
                  GoRoute(
                    path: 'related-feed/:bookId',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) {
                      final bookId = int.parse(state.pathParameters['bookId']!);
                      final extra = state.extra as Map<String, dynamic>;
                      final index = extra['index'] as int;
                      return BookRelatedFeedScreen(
                          bookId: bookId, initialIndex: index);
                    },
                  ),
                  GoRoute(
                    path: '/create',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) {
                      return BookLogCreateScreen();
                    },
                  ),
                  GoRoute(
                    path: '/update/:diaryId',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) {
                      final diaryId =
                          int.parse(state.pathParameters['diaryId']!);
                      final extra = state.extra as Map<String, dynamic>;
                      final request = extra["request"] as DiaryUpdateRequest;
                      return BookLogUpdateScreen(
                          diaryId: diaryId, request: request);
                    },
                  ),
                ],
              ),
            ],
          ),

          /// 마이피드
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/my-feed',
                builder: (context, state) => MyFeedScreen(),
                routes: [
                  GoRoute(
                    path: 'feed/:memberId',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) {
                      final extra = state.extra as Map<String, dynamic>?;
                      final index = extra?['index'] as int? ?? 0;
                      return MyFeedFeedScreen(initialIndex: index);
                    },
                  ),
                  GoRoute(
                    path: 'profile',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const ProfileScreen(),
                  ),
                  GoRoute(
                    path: 'my-page',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const MyPageScreen(),
                    routes: [
                      GoRoute(
                        path: 'challenge-quit-books',
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (context, state) =>
                            const ChallengeQuitBooksScreen(),
                      ),
                      GoRoute(
                        path: 'customer-support',
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (context, state) =>
                            const CustomerSupportScreen(),
                      ),
                      GoRoute(
                        path: 'delete-account',
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (context, state) =>
                            const DeleteAccountScreen(),
                      ),
                      GoRoute(
                        path: 'scrapped-diaries',
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (context, state) =>
                            const ScrappedDiariesScreen(),
                        routes: [
                          GoRoute(
                            path: 'feed',
                            parentNavigatorKey: rootNavigatorKey,
                            builder: (context, state) {
                              final extra =
                                  state.extra as Map<String, dynamic>?;
                              final index = extra?['index'] as int? ?? 0;
                              return ScrappedDiaryFeedScreen(
                                  initialIndex: index);
                            },
                          ),
                        ],
                      ),
                      GoRoute(
                        path: 'follower-management',
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (context, state) =>
                            const FollowerManagementScreen(),
                      ),
                      GoRoute(
                        path: 'liked-diaries',
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (context, state) => const LikedDiariesScreen(),
                        routes: [
                          GoRoute(
                            path: 'feed',
                            parentNavigatorKey: rootNavigatorKey,
                            builder: (context, state) {
                              final extra =
                                  state.extra as Map<String, dynamic>?;
                              final index = extra?['index'] as int? ?? 0;
                              return LikedDiaryFeedScreen(initialIndex: index);
                            },
                          ),
                        ],
                      ),
                      GoRoute(
                        path: 'login-info',
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (context, state) => const LoginInfoScreen(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
