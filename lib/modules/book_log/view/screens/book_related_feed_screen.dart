import 'package:bookstar/common/components/base_screen.dart';
import 'package:bookstar/common/models/image_request.dart';
import 'package:bookstar/modules/auth/view_model/auth_view_model.dart';
import 'package:bookstar/modules/book_log/view/widgets/book_log_feed_list.dart';
import 'package:bookstar/modules/book_log/view/widgets/diary_feed_comment_dialog.dart';
import 'package:bookstar/modules/book_log/view/widgets/diary_feed_delete_dialog.dart';
import 'package:bookstar/modules/book_log/view/widgets/report_dialog.dart';
import 'package:bookstar/modules/book_log/view/widgets/report_success_dialog.dart';
import 'package:bookstar/modules/follow/view_model/follow_info_view_model.dart';
import 'package:bookstar/modules/reading_diary/model/diary_update_request.dart';
import 'package:bookstar/modules/reading_diary/view_model/related_diaries_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../gen/colors.gen.dart';
import '../../view_model/book_log_view_model.dart';

class BookRelatedFeedScreen extends BaseScreen {
  const BookRelatedFeedScreen(
      {super.key, required this.bookId, required this.initialIndex});
  final int bookId;
  final int initialIndex;

  @override
  BaseScreenState<BookRelatedFeedScreen> createState() =>
      _BookRelatedFeedScreenState();
}

class _BookRelatedFeedScreenState
    extends BaseScreenState<BookRelatedFeedScreen> {
  @override
  bool enableRefreshIndicator() => true;

  @override
  int getListTotalItemCount() =>
      ref
          .watch(relatedDiariesViewModelProvider(widget.bookId))
          .value
          ?.feeds
          .length ??
      0;

  @override
  Future<void> onRefresh() async {
    final bookLogAsync =
        ref.watch(relatedDiariesViewModelProvider(widget.bookId));
    final sort = bookLogAsync.value?.sort;
    if (sort == null) return;
    final bookLogNotifier =
        ref.read(relatedDiariesViewModelProvider(widget.bookId).notifier);
    await bookLogNotifier.initState(widget.bookId, sort);
  }

  @override
  Future<void> onBottomReached() async {
    final bookLogNotifier =
        ref.read(relatedDiariesViewModelProvider(widget.bookId).notifier);
    await bookLogNotifier.refreshState();
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('책로그'),
      leading: IconButton(
        icon: const BackButton(),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    final bookLogAsync =
        ref.watch(relatedDiariesViewModelProvider(widget.bookId));
    final bookLogNotifier =
        ref.read(relatedDiariesViewModelProvider(widget.bookId).notifier);
    final followInfoAsync = ref.watch(followInfoViewModelProvider);
    final userAsync = ref.watch(authViewModelProvider);

    return userAsync.when(
      data: (user) {
        return bookLogAsync.when(
          data: (bookLog) => followInfoAsync.when(
            data: (followInfo) => BookLogFeedList(
              feeds: bookLog.feeds,
              initialIndex: widget.initialIndex,
              itemScrollController: itemScrollController,
              itemPositionsListener: itemPositionsListener,
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
            error: _error("팔로우 정보를 불러올 수 없습니다."),
            loading: _loading,
          ),
          error: _error("북로그 정보를 불러올 수 없습니다."),
          loading: _loading,
        );
      },
      error: _error("유저 정보를 불러올 수 없습니다."),
      loading: _loading,
    );
  }

  Widget _loading() => const Center(child: CircularProgressIndicator());
  Widget Function(Object, StackTrace) _error(String msg) => (e, st) =>
      Center(child: Text(msg, style: TextStyle(color: ColorName.g3)));
}
