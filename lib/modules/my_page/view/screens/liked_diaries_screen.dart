import 'package:bookstar/common/components/base_screen.dart';
import 'package:bookstar/modules/book_log/view/widgets/book_log_thumbnail_grid.dart';
import 'package:bookstar/modules/reading_diary/model/diary_thumbnail_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../reading_diary/view_model/liked_diary_view_model.dart';

class LikedDiariesScreen extends BaseScreen {
  const LikedDiariesScreen({super.key});

  @override
  BaseScreenState<LikedDiariesScreen> createState() =>
      _LikedDiariesScreenState();
}

class _LikedDiariesScreenState extends BaseScreenState<LikedDiariesScreen> {
  @override
  bool enableRefreshIndicator() => true;

  @override
  int getListTotalItemCount() =>
      ref.watch(likedDiaryViewModelProvider).value?.thumbnails.length ?? 0;

  @override
  Future<void> onRefresh() async {
    await ref.read(likedDiaryViewModelProvider.notifier).initState();
  }

  @override
  Future<void> onBottomReached() async {
    await ref.read(likedDiaryViewModelProvider.notifier).refreshState();
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('좋아요 누른 책로그'),
      leading: IconButton(
        icon: const BackButton(),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    final likedDiaryState = ref.watch(likedDiaryViewModelProvider);

    return likedDiaryState.when(
      data: (likedDiary) {
        return BookLogThumbnailGrid(
            thumbnails: likedDiary.thumbnails
                .map(
                  (e) => DiaryThumbnail(
                    diaryId: e.diaryId,
                    firstImage: Thumbnail(
                      imageUrl: e.firstImage.imageUrl,
                    ),
                  ),
                )
                .toList(),
            scrollController: scrollController,
            onClickThumbnail: (int targetIndex) {
              context.push('/my-feed/my-page/liked-diaries/feed',
                  extra: {'index': targetIndex});
            });
      },
      error: error("좋아요 누른 다이어리 정보를 불러올 수 없습니다."),
      loading: loading,
    );
  }
}
