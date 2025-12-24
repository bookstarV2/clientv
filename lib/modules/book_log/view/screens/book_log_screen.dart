import 'package:bookstar/common/components/base_screen.dart';
import 'package:bookstar/common/models/image_request.dart';
import 'package:bookstar/common/service/analytics_service.dart';
import 'package:bookstar/common/theme/style/app_texts.dart';
import 'package:bookstar/gen/assets.gen.dart';
import 'package:bookstar/modules/auth/view_model/auth_view_model.dart';
import 'package:bookstar/modules/book_log/view/screens/book_log_search_screen.dart';
import 'package:bookstar/modules/book_log/view/widgets/book_log_feed_list.dart';
import 'package:bookstar/modules/book_log/view/widgets/diary_feed_comment_dialog.dart';
import 'package:bookstar/modules/book_log/view/widgets/diary_feed_delete_dialog.dart';
import 'package:bookstar/modules/book_log/view/widgets/report_dialog.dart';
import 'package:bookstar/modules/book_log/view/widgets/report_success_dialog.dart';
import 'package:bookstar/modules/follow/view_model/follow_info_view_model.dart';
import 'package:bookstar/modules/reading_diary/model/diary_update_request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../gen/colors.gen.dart';
import '../../view_model/book_log_view_model.dart';

class BookLogScreen extends BaseScreen {
  const BookLogScreen({super.key, required this.requiredRefresh});

  final bool requiredRefresh;

  @override
  BaseScreenState<BookLogScreen> createState() => _BookLogScreenState();
}

class _BookLogScreenState extends BaseScreenState<BookLogScreen> {
  @override
  bool enableRefreshIndicator() => true;

  @override
  int getListTotalItemCount() =>
      ref.watch(bookLogViewModelProvider(null)).value?.feeds.length ?? 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookLogNotifier = ref.read(bookLogViewModelProvider(null).notifier);
      if (widget.requiredRefresh) {
        bookLogNotifier.initState(null);
      }
    });
  }

  @override
  Future<void> onRefresh() async {
    final bookLogNotifier = ref.read(bookLogViewModelProvider(null).notifier);
    await bookLogNotifier.initState(null);
  }

  @override
  Future<void> onBottomReached() async {
    final bookLogNotifier = ref.read(bookLogViewModelProvider(null).notifier);
    await bookLogNotifier.refreshContentState();
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Text("책로그", style: AppTexts.b5),
      actions: [
        GestureDetector(
          onTap: () {
            AnalyticsService.logEvent('click_search_user',
                parameters: {'screen_name': 'book_log'});
            showDialog(
              context: context,
              barrierColor: ColorName.dim3.withValues(alpha: 0.7),
              builder: (context) => BookLogSearchScreen(),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Assets.icons.icPeopleSearchOne.svg(width: 24, height: 24),
          ),
        ),
      ],
    );
  }

  @override
  Widget? buildFloatingActionButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AnalyticsService.logEvent('click_create_diary',
            parameters: {'screen_name': 'book_log'});
        context.push('/book-log/create');
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF3A3A43),
              Color(0xFF4F4F7F),
            ],
            stops: [0.3, 0.7],
          ),
        ),
        child: Center(
          child: Assets.icons.icPencil.svg(
              width: 30,
              colorFilter: ColorFilter.mode(ColorName.p2, BlendMode.srcIn)),
        ),
      ),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    final bookLogAsync = ref.watch(bookLogViewModelProvider(null));
    final followInfoAsync = ref.watch(followInfoViewModelProvider);
    final userAsync = ref.watch(authViewModelProvider);
    final bookLogNotifier = ref.read(bookLogViewModelProvider(null).notifier);

    return userAsync.when(
      data: (user) {
        return bookLogAsync.when(
          data: (bookLog) => followInfoAsync.when(
            data: (followInfo) => BookLogFeedList(
              feeds: bookLog.feeds,
              itemScrollController: itemScrollController,
              itemPositionsListener: itemPositionsListener,
              // followInfo: followInfo,
              initialIndex: null,
              onScrollChanged: (showButton) {
                // setState(() {
                //   _showScrollToTopButton = showButton;
                // });
              },
              onLike: (int targetIndex) {
                final targetFeed = bookLog.feeds[targetIndex];
                bookLogNotifier.handleFeedLike(
                    targetFeed.diaryId, targetFeed.liked, targetIndex);
              },
              onMessage: (BuildContext ctx, int targetIndex) async {
                final targetFeed = bookLog.feeds[targetIndex];
                final result = await showModalBottomSheet(
                    context: ctx,
                    isScrollControlled: true,
                    backgroundColor: ColorName.b1,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) =>
                        DiaryFeedCommentDialog(diaryId: targetFeed.diaryId));

                int? commentCount = result?['commentCount'];
                if (commentCount != null) {
                  bookLogNotifier.changeCommentCount(
                      targetFeed.diaryId, commentCount);
                }
              },
              onDelete: (BuildContext ctx, int targetIndex) async {
                final targetFeed = bookLog.feeds[targetIndex];
                final result = await showModalBottomSheet(
                    context: ctx,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => DiaryFeedDeleteDialog());
                if (result == true) {
                  await bookLogNotifier.deleteFeed(targetFeed.diaryId);
                }
              },
              onReport: (BuildContext ctx, int targetIndex) async {
                final targetFeed = bookLog.feeds[targetIndex];
                final result = await showModalBottomSheet(
                    context: ctx,
                    isScrollControlled: true,
                    backgroundColor: ColorName.b1,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) => ReportDialog());

                if (result == null) return;

                ReportType? reportType = result?['reportType'];
                String? content = result?['content'];

                if (reportType == null || content == null) return;
                await bookLogNotifier.reportFeed(
                    targetFeed.diaryId, reportType, content);
                if (!ctx.mounted) return;
                await showModalBottomSheet(
                    context: ctx,
                    isScrollControlled: true,
                    backgroundColor: ColorName.b1,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) => ReportSuccessDialog());
              },
              onProfile: (int targetIndex) {
                final targetFeed = bookLog.feeds[targetIndex];
                context.push('/book-log/thumbnail/${targetFeed.memberId}');
              },
              onBookTitle: (int targetIndex) {
                final targetFeed = bookLog.feeds[targetIndex];
                context.push('/book-pick/overview/${targetFeed.bookId}');
              },
              onScrap: (int targetIndex) {
                final targetFeed = bookLog.feeds[targetIndex];
                bookLogNotifier.handleFeedScrap(
                    targetFeed.diaryId, targetFeed.scraped, targetIndex);
              },
              onUpdate: (int targetIndex) {
                final targetFeed = bookLog.feeds[targetIndex];
                context.push('/book-log/update/${targetFeed.diaryId}', extra: {
                  "memberId": targetFeed.memberId,
                  "request": DiaryUpdateRequest(
                    bookId: targetFeed.bookId,
                    content: targetFeed.content,
                    images: targetFeed.images
                        .map((e) => ImageRequest(
                            imageUrl: e.imageUrl, sequence: e.sequence))
                        .toList(),
                    privacy: targetFeed.privacy,
                  )
                });
              },
            ),
            error: error("팔로우 정보를 불러올 수 없습니다."),
            loading: loading,
          ),
          error: error("북로그 정보를 불러올 수 없습니다."),
          loading: loading,
        );
      },
      error: error("유저 정보를 불러올 수 없습니다."),
      loading: loading,
    );
  }
}
