import 'package:bookstar/common/components/base_screen.dart';
import 'package:bookstar/common/components/custom_grid_view.dart';
import 'package:bookstar/common/theme/style/app_texts.dart';
import 'package:bookstar/gen/assets.gen.dart';
import 'package:bookstar/gen/colors.gen.dart';
import 'package:bookstar/modules/reading_diary/model/diary_thumbnail_response.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../reading_diary/view_model/scrapped_diary_view_model.dart';

class ScrappedDiariesScreen extends BaseScreen {
  const ScrappedDiariesScreen({super.key});

  @override
  BaseScreenState<ScrappedDiariesScreen> createState() =>
      _ScrappedDiariesScreenState();
}

class _ScrappedDiariesScreenState
    extends BaseScreenState<ScrappedDiariesScreen> {
  @override
  bool enableRefreshIndicator() => true;

  @override
  int getListTotalItemCount() =>
      ref.watch(scrappedDiaryViewModelProvider).value?.thumbnails.length ?? 0;

  @override
  Future<void> onRefresh() async {
    await ref.read(scrappedDiaryViewModelProvider.notifier).initState();
  }

  @override
  Future<void> onBottomReached() async {
    await ref.read(scrappedDiaryViewModelProvider.notifier).refreshState();
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

    return scrappedDiaryAsync.when(
      data: (scrappedDiary) {
        final thumbnails = scrappedDiary.thumbnails
            .map(
              (e) => DiaryThumbnail(
                diaryId: e.diaryId,
                firstImage: Thumbnail(
                  imageUrl: e.firstImage?.imageUrl ?? "",
                ),
              ),
            )
            .toList();

        return CustomGridView(
          emptyIcon: Assets.icons.icSearchEmptyCharacter.svg(),
          emptyText: '스크랩한 책로그가 없어요',
          emptyTextStyle: AppTexts.b3.copyWith(color: ColorName.w1),
          emptyDescription: '다시 보고 싶은 책로그를 스크랩해 보세요',
          emptyDescriptionStyle: AppTexts.b8.copyWith(color: ColorName.g2),
          isEmpty: thumbnails.isEmpty,
          itemCount: thumbnails.length,
          itemBuilder: (context, index) {
            final item = thumbnails[index];
            return GestureDetector(
              onTap: () {
                context.push('/my-feed/my-page/scrapped-diaries/feed',
                    extra: {'index': index});
              },
              child: CachedNetworkImage(
                imageUrl: item.firstImage.imageUrl,
                fit: BoxFit.fitHeight,
              ),
            );
          },
          hasNext: scrappedDiary.hasNext,
          scrollController: scrollController,
          separatorBuilder: (context, index) {
            return SizedBox.shrink();
          },
        );
      },
      error: error("스크랩한 다이어리 정보를 불러올 수 없습니다."),
      loading: loading,
    );
  }
}
