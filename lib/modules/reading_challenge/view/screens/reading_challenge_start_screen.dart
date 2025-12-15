import 'package:bookstar/common/components/base_screen.dart';
import 'package:bookstar/common/components/button/cta_button_l1.dart';
import 'package:bookstar/common/theme/style/app_texts.dart';
import 'package:bookstar/gen/assets.gen.dart';
import 'package:bookstar/gen/colors.gen.dart';
import 'package:bookstar/modules/reading_challenge/model/challenge_detail_book_overview.dart';
import 'package:bookstar/modules/reading_challenge/model/challenge_detail_chapter.dart';
import 'package:bookstar/modules/reading_challenge/view_model/challenge_start_view_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class ReadingChallengeStartScreen extends BaseScreen {
  const ReadingChallengeStartScreen(
      {super.key, required this.challengeId, this.requiredRefresh = false});

  final int challengeId;
  final bool requiredRefresh;

  @override
  BaseScreenState<ReadingChallengeStartScreen> createState() =>
      _ReadingChallengeStartScreenState();
}

class _ReadingChallengeStartScreenState
    extends BaseScreenState<ReadingChallengeStartScreen> {
  int? _selectedChapterId;

  @override
  void onInitState() {
    super.onInitState();
    if (widget.requiredRefresh) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final notifier = ref
            .read(challengeStartViewModelProvider(widget.challengeId).notifier);
        notifier.initState(widget.challengeId);
      });
    }
  }

  _onTapChapter(int chapterId) {
    setState(() {
      _selectedChapterId = chapterId;
    });
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('리딩챌린지'),
      leading: IconButton(
        icon: const BackButton(),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    final state =
        ref.watch(challengeStartViewModelProvider(widget.challengeId));
    return state.when(
      data: (data) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverToBoxAdapter(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBookSection(overview: data.detail.bookOverview),
                  SizedBox(height: 16),
                  Divider(),
                  SizedBox(height: 16),
                  _buildChaptersSection(
                      chapters: data.detail.chapters,
                      onTapItem: (chapterId) {
                        _onTapChapter(chapterId);
                      },
                      selectedChapterId: _selectedChapterId),
                  if (_selectedChapterId != null)
                    SizedBox(
                      height: 60,
                    )
                ],
              )),
            ],
          ),
        );
      },
      loading: loading,
      error: error("리딩 챌린지 상세 정보 취득 중 오류가 발생했습니다. ${widget.challengeId}"),
    );
  }

  Widget _buildBookSection({required ChallengeDetailBookOverview overview}) {
    return Row(
      // crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: overview.cover,
            fit: BoxFit.cover,
            width: 120,
            height: 175,
            errorWidget: (context, url, error) => Container(),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: SizedBox(
            height: 175,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      overview.title,
                      style: AppTexts.b3.copyWith(color: ColorName.w1),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Row(
                      children: [
                        Text(
                          "작가",
                          style: AppTexts.b11.copyWith(color: ColorName.g3),
                        ),
                        SizedBox(
                          width: 6,
                        ),
                        Expanded(
                          child: Text(
                            overview.author,
                            style: AppTexts.b11.copyWith(color: ColorName.g2),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          "출판사",
                          style: AppTexts.b11.copyWith(color: ColorName.g3),
                        ),
                        SizedBox(
                          width: 6,
                        ),
                        Expanded(
                          child: Text(
                            overview.publisher,
                            style: AppTexts.b11.copyWith(color: ColorName.g2),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          "출판연도",
                          style: AppTexts.b11.copyWith(color: ColorName.g3),
                        ),
                        SizedBox(
                          width: 6,
                        ),
                        Expanded(
                          child: Text(
                            overview.publishedDate,
                            style: AppTexts.b11.copyWith(color: ColorName.g2),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: ColorName.g7,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: Row(
                          children: [
                            Assets.icons.icStar.svg(width: 12, height: 12),
                            SizedBox(
                              width: 4,
                            ),
                            Text(
                              "${overview.star}",
                              style: AppTexts.b8.copyWith(color: ColorName.p1),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildChaptersSection(
      {required List<ChallengeDetailChapter> chapters,
      required Function(int) onTapItem,
      required int? selectedChapterId}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "목차",
          style: AppTexts.b1.copyWith(color: ColorName.w1),
        ),
        SizedBox(
          height: 16,
        ),
        Column(
          spacing: 12,
          children: chapters
              .map(
                (chapter) => GestureDetector(
                  onTap: () {
                    if (chapter.status == ChapterStatus.COMPLETED) return;
                    onTapItem(chapter.chapterId);
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: selectedChapterId == chapter.chapterId
                                ? ColorName.p1.withValues(alpha: 0.2)
                                : ColorName.g7,
                            borderRadius: BorderRadius.circular(8),
                            border: selectedChapterId == chapter.chapterId
                                ? Border.all(color: ColorName.p1)
                                : null,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14.5,
                              vertical: 12.5,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        chapter.title,
                                        style: AppTexts.b5
                                            .copyWith(color: ColorName.w3),
                                      ),
                                    ],
                                  ),
                                ),
                                _buildChapterStatus(
                                  chapter,
                                )
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
              .toList(),
        )
      ],
    );
  }

  Widget _buildChapterStatus(ChallengeDetailChapter chapter) {
    switch (chapter.status) {
      case ChapterStatus.LOCKED:
        return Container(
            width: 71,
            height: 26,
            decoration: BoxDecoration(
              color: ColorName.g6,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                "독서전",
                style: AppTexts.b7.copyWith(color: ColorName.g3),
              ),
            ));
      case ChapterStatus.PROCESSING:
        return Container(
            width: 71,
            height: 26,
            decoration: BoxDecoration(
              color: ColorName.p5,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                "독서중",
                style: AppTexts.b7.copyWith(color: ColorName.p2),
              ),
            ));
      case ChapterStatus.COMPLETED:
        return Container(
            width: 71,
            height: 26,
            decoration: BoxDecoration(
              color: ColorName.g6,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                "독서완료",
                style: AppTexts.b7.copyWith(color: ColorName.w3),
              ),
            ));
    }
  }

  @override
  Widget? buildFloatingActionButton(BuildContext context) {
    return _selectedChapterId != null
        ? CtaButtonL1(
            text: '퀴즈 확인하기',
            onPressed: () {
              goToQuizScreen();
            },
          )
        : null;
  }

  goToQuizScreen() {
    context.push(
        '/reading-challenge/${widget.challengeId}/quiz/${_selectedChapterId!}/check');
  }
}
