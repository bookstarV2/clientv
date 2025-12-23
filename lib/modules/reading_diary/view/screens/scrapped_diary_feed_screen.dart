import 'package:bookstar/common/components/base_screen.dart';
import 'package:bookstar/modules/book_log/view/widgets/book_log_feed_list.dart';
import 'package:bookstar/modules/book_log/view/widgets/diary_feed_comment_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../gen/colors.gen.dart';
import '../../model/diary_response.dart';
import '../../model/diary_image_response.dart';
import '../../view_model/scrapped_diary_view_model.dart';

class ScrappedDiaryFeedScreen extends BaseScreen {
  const ScrappedDiaryFeedScreen({
    super.key,
    required this.initialIndex,
  });

  final int initialIndex;

  @override
  BaseScreenState<ScrappedDiaryFeedScreen> createState() =>
      _ScrappedDiaryFeedScreenState();
}

class _ScrappedDiaryFeedScreenState
    extends BaseScreenState<ScrappedDiaryFeedScreen> {
  @override
  bool enableRefreshIndicator() => true;

  @override
  int getListTotalItemCount() =>
      ref.watch(scrappedDiaryViewModelProvider).value?.feeds.length ?? 0;

  @override
  Future<void> onRefresh() async {
    final likedDiaryNotifier =
        ref.read(scrappedDiaryViewModelProvider.notifier);
    await likedDiaryNotifier.initState();
  }

  @override
  Future<void> onBottomReached() async {
    final likedDiaryNotifier =
        ref.read(scrappedDiaryViewModelProvider.notifier);
    await likedDiaryNotifier.refreshState();
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('스크랩한 책로그'),
      leading: IconButton(
        icon: const BackButton(),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    final scrappedDiaryAsync = ref.watch(scrappedDiaryViewModelProvider);
    final scrappedDiaryNotifier =
        ref.read(scrappedDiaryViewModelProvider.notifier);
    return scrappedDiaryAsync.when(
      data: (scrappedDiary) => BookLogFeedList(
        visibleMenu: false,
        feeds: scrappedDiary.feeds.map((e) {
          return DiaryResponse(
            diaryId: e.diaryId,
            content: e.content,
            createdDate: e.createdDate,
            memberId: e.memberId,
            nickname: e.nickname,
            profileImageUrl: e.profileImageUrl,
            bookId: e.bookId,
            bookTitle: e.bookTitle,
            bookAuthor: e.bookAuthor,
            bookRating: e.bookRating.toDouble(),
            images: e.images.map((image) {
              return DiaryImageResponse(
                imageUrl: image.imageUrl,
                sequence: e.images.indexOf(image),
              );
            }).toList(),
            likeCount: e.likeCount,
            commentCount: e.commentCount,
            viewCount: e.viewCount,
            liked: e.liked,
            scraped: e.scraped,
          );
        }).toList(),
        initialIndex: widget.initialIndex,
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener,
        onLike: (int targetIndex) {
          final targetFeed = scrappedDiary.feeds[targetIndex];
          scrappedDiaryNotifier.handleFeedLike(
              targetFeed.diaryId, targetFeed.liked, targetIndex);
        },
        onMessage: (BuildContext ctx, int targetIndex) async {
          final targetFeed = scrappedDiary.feeds[targetIndex];
          final result = await showModalBottomSheet(
              context: ctx,
              isScrollControlled: true,
              backgroundColor: ColorName.b1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) =>
                  DiaryFeedCommentDialog(diaryId: targetFeed.diaryId));

          int? commentCount = result?['commentCount'];
          if (commentCount != null) {
            scrappedDiaryNotifier.changeCommentCount(
                targetFeed.diaryId, commentCount);
          }
        },
        onDelete: (BuildContext ctx, int targetIndex) async {},
        onReport: (BuildContext ctx, int targetIndex) async {},
        onProfile: (int targetIndex) {
          final targetFeed = scrappedDiary.feeds[targetIndex];
          context.push('/my-feed/thumbnail/${targetFeed.memberId}');
        },
        onBookTitle: (int targetIndex) {
          final targetFeed = scrappedDiary.feeds[targetIndex];
          context.push('/book-pick/overview/${targetFeed.bookId}');
        },
        onScrap: (int targetIndex) {
          final targetFeed = scrappedDiary.feeds[targetIndex];
          scrappedDiaryNotifier.handleFeedScrap(
              targetFeed.diaryId, targetFeed.scraped, targetIndex);
        },
        onUpdate: (int targetIndex) {},
      ),
      error: error("스크랩한 다이어리 정보를 불러올 수 없습니다."),
      loading: loading,
    );
  }
}
