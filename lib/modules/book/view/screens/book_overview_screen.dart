import 'package:bookstar/common/components/base_screen.dart';
import 'package:bookstar/common/components/grid/async_Image_grid_view.dart';
import 'package:bookstar/common/theme/app_style.dart';
import 'package:bookstar/gen/assets.gen.dart';
import 'package:bookstar/gen/colors.gen.dart';
import 'package:bookstar/modules/book/model/book_overview_response.dart';
import 'package:bookstar/modules/reading_diary/model/related_diary_sort.dart';
import 'package:bookstar/modules/reading_diary/model/related_diary_thumbnail.dart';
import 'package:bookstar/modules/reading_diary/view_model/related_diaries_view_model.dart';
import 'package:bookstar/modules/reading_diary/view_model/related_diary_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../view_model/book_view_model.dart';

class BookOverviewScreen extends BaseScreen {
  const BookOverviewScreen({
    super.key,
    required this.bookId,
  });

  final int bookId;

  @override
  BaseScreenState<BookOverviewScreen> createState() =>
      _BookOverviewScreenState();
}

class _BookOverviewScreenState extends BaseScreenState<BookOverviewScreen> {
  @override
  bool enableRefreshIndicator() => false;

  @override
  void onBottomReached() async {
    await ref
        .read(relatedDiariesViewModelProvider(widget.bookId).notifier)
        .refreshState();
  }

  Future<void> _updateStar(double rating) async {
    await ref
        .read(bookViewModelProvider(widget.bookId).notifier)
        .handleOverviewStar(rating);
  }

  void _onLike() {
    ref
        .read(bookViewModelProvider(widget.bookId).notifier)
        .handleOverviewLike();
  }

  Future<void> _onAladin(String aladinUrl) async {
    if (await canLaunchUrl(Uri.parse(aladinUrl))) {
      await launchUrl(Uri.parse(aladinUrl),
          mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $aladinUrl';
    }
  }

  @override
  Widget buildBody(BuildContext context) {
    final bookAsync = ref.watch(bookViewModelProvider(widget.bookId));
    final currentStar = bookAsync.valueOrNull?.overview.star ?? 0;
    final relatedDiariesAsync =
        ref.watch(relatedDiariesViewModelProvider(widget.bookId));

    return bookAsync.when(
      data: (bookOverview) => relatedDiariesAsync.when(
        data: (relatedDiaries) {
          return CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 516,
                automaticallyImplyLeading: false,
                flexibleSpace: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        ..._buildBackgroundImage(bookOverview.overview.cover),
                        Positioned(
                          top: AppSizes.APP_BAR_HEIGHT,
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ..._buildAppBarTopSection(
                                      context, bookOverview.overview,
                                      onAladin: _onAladin, onLike: _onLike)
                                ],
                              ),
                              _buildAppBarBottomSection(
                                  initialStar: currentStar,
                                  updateStar: _updateStar)
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              SliverToBoxAdapter(
                  child: SizedBox(
                height: 60,
              )),
              SliverToBoxAdapter(
                child: _buildRelationDiary(
                  list: relatedDiaries.thumbnails,
                  hasNext: relatedDiaries.hasNext,
                  currentSort: relatedDiaries.sort,
                  onToggle: () {
                    ref
                        .read(relatedDiariesViewModelProvider(widget.bookId)
                            .notifier)
                        .toggleSort();
                  },
                  onItemTap: (index) {
                    context.push('/book-log/related-feed/${widget.bookId}',
                        extra: {'index': index});
                  },
                ),
              )
            ],
          );
        },
        loading: loading,
        error: error("관련 게시물 정보를 불러올 수 없습니다."),
      ),
      loading: loading,
      error: error("북 상세 정보를 불러올 수 없습니다."),
    );
  }

  List<Widget> _buildBackgroundImage(String imageUrl) {
    return [
      // Background image
      CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
      ),
      Container(
        decoration: BoxDecoration(
          color: ColorName.b1.withOpacity(0.7),
        ),
      )
    ];
  }

  List<Widget> _buildAppBarTopSection(
      BuildContext context, BookOverviewResponse book,
      {required Function() onLike, required Function(String) onAladin}) {
    return [
      BackButton(
        color: ColorName.w1,
        onPressed: () {
          context.pop();
        },
      ),
      SizedBox(height: 8),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.5),
                    child: Text(
                      book.title,
                      style: AppTexts.h3.copyWith(color: ColorName.w1),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Assets.icons.icStar.svg(width: 14, height: 14),
                  const SizedBox(width: 3),
                  Text(
                    book.star.toStringAsFixed(1),
                    style: AppTexts.b8.copyWith(
                      color: ColorName.p2,
                      height: 1,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: 4,
                children: [
                  GestureDetector(
                      onTap: () => onAladin(book.aladinUrl),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Assets.icons.aladin.svg(width: 24, height: 24),
                      )),
                  GestureDetector(
                      onTap: () => onLike(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: book.liked
                            ? Assets.icons.icHeartFilled
                                .svg(width: 24, height: 24)
                            : Assets.icons.icHeart.svg(width: 24, height: 24),
                      )),
                ],
              )
            ],
          ),
          SizedBox(
            height: 12,
          ),
          Row(
            children: [
              Text(
                "작가",
                style: AppTexts.b11.copyWith(color: ColorName.g2),
              ),
              SizedBox(
                width: 6,
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.8),
                child: Text(
                  book.author,
                  style: AppTexts.b11.copyWith(color: ColorName.w3),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                "출판사",
                style: AppTexts.b11.copyWith(color: ColorName.g2),
              ),
              SizedBox(
                width: 6,
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.8),
                child: Text(
                  book.publisher,
                  style: AppTexts.b11.copyWith(color: ColorName.w3),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                "출판연도",
                style: AppTexts.b11.copyWith(color: ColorName.g2),
              ),
              SizedBox(
                width: 6,
              ),
              Text(
                book.publishedDate,
                style: AppTexts.b11.copyWith(color: ColorName.w3),
              ),
            ],
          ),
        ]),
      ),
    ];
  }

  Widget _buildAppBarBottomSection({
    required double initialStar,
    required Function(double) updateStar,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: Container(
        decoration: BoxDecoration(
          color: ColorName.dim1,
          borderRadius: BorderRadius.circular(78),
          border: Border.all(color: ColorName.p2),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "내 별점 후기",
                    style: AppTexts.b7.copyWith(color: ColorName.w1),
                  ),
                  Text(
                    "이 책이 얼마나 재미있었나요?",
                    style: AppTexts.b10.copyWith(color: ColorName.g2),
                  ),
                ],
              ),
              RatingBar.builder(
                glowColor: Colors.transparent,
                initialRating: initialStar,
                minRating: 0,
                itemCount: 5,
                itemSize: 25,
                itemPadding: EdgeInsets.symmetric(horizontal: 2),
                itemBuilder: (context, index) {
                  if (index >= initialStar.floor()) {
                    return Assets.icons.icRatingStar.svg(color: ColorName.g3);
                  }
                  return Assets.icons.icRatingStarFilled.svg();
                },
                onRatingUpdate: updateStar,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRelationDiary(
          {required List<RelatedDiaryThumbnail> list,
          required bool hasNext,
          required RelatedDiarySort currentSort,
          required Function() onToggle,
          required Function(int) onItemTap}) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("관련 게시물", style: AppTexts.b3.copyWith(color: ColorName.w1)),
            SizedBox(height: 3),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "북스타 유저들이 공유한 관련 게시물을 확인해 보세요",
                  style: AppTexts.b10.copyWith(color: ColorName.g2),
                ),
                GestureDetector(
                  onTap: onToggle,
                  child: Row(
                    children: [
                      Text(
                        currentSort == RelatedDiarySort.LATEST ? '최신순' : '인기순',
                        style: AppTexts.b10.copyWith(color: ColorName.g3),
                      ),
                      Assets.icons.icArrowUpDown.svg(),
                    ],
                  ),
                )
              ],
            ),
            AsyncImageGridView<RelatedDiaryState, RelatedDiaryThumbnail>(
              asyncValue: AsyncValue.data(RelatedDiaryState(thumbnails: list)),
              getItems: (state) => state.thumbnails,
              getImageUrl: (diary) => diary.firstImage.imageUrl,
              hasNext: hasNext,
              onTap: onItemTap,
              emptyText: '관련 독서일기가 없습니다.',
              errorText: '게시물을 불러올 수 없습니다.',
            ),
          ],
        ),
      );
}
