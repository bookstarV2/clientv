import 'package:bookstar/common/components/base_screen.dart';
import 'package:bookstar/common/components/custom_list_view.dart';
import 'package:bookstar/common/components/text_field/search_text_field.dart';
import 'package:bookstar/common/theme/style/app_texts.dart';
import 'package:bookstar/gen/assets.gen.dart';
import 'package:bookstar/modules/auth/model/policy.dart';
import 'package:bookstar/modules/auth/view/screens/policy_screen.dart';
import 'package:bookstar/modules/auth/view_model/auth_view_model.dart';
import 'package:bookstar/modules/book_pick/model/like_book_response.dart';
import 'package:bookstar/modules/book_pick/model/search_book_response.dart';
import 'package:bookstar/modules/book_pick/model/youtube_recommend_response.dart';
import 'package:bookstar/modules/book_pick/view/widgets/book_search_result_card.dart';
import 'package:bookstar/modules/book_pick/view/widgets/youtube_item.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../gen/colors.gen.dart';
import '../../view_model/book_pick_view_model.dart';

class BookPickScreen extends BaseScreen {
  const BookPickScreen({super.key});

  @override
  BaseScreenState<BookPickScreen> createState() => _BookPickScreenState();
}

class _BookPickScreenState extends BaseScreenState<BookPickScreen> {
  @override
  bool enableRefreshIndicator() => true;
  int _currentIndex = 0;

  @override
  int getListTotalItemCount() =>
      ref.watch(bookPickViewModelProvider).value?.likeBook.likeBooks.length ??
      0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkPolicyAgreed();
    });
  }

  Future<void> checkPolicyAgreed() async {
    final policy = await ref.read(authViewModelProvider.notifier).getPolicy();
    final isValidPolicyAgree = policy.serviceUsingAgree == PolicyAgree.Y &&
        policy.personalInformationAgree == PolicyAgree.Y;

    if (!isValidPolicyAgree && mounted) {
      final result = await showModalBottomSheet(
          isDismissible: false,
          isScrollControlled: true,
          context: context,
          barrierColor: Colors.transparent,
          builder: (_) => PolicyScreen(initPolicy: policy));

      if (result != null) {
        final serviceUsingAgree = result["serviceUsingAgree"] as PolicyAgree;
        final personalInformationAgree =
            result["personalInformationAgree"] as PolicyAgree;
        final marketingAgree = result["marketingAgree"] as PolicyAgree;

        await ref.read(authViewModelProvider.notifier).setPolicy(Policy(
            serviceUsingAgree: serviceUsingAgree,
            personalInformationAgree: personalInformationAgree,
            marketingAgree: marketingAgree));
      }
    }
  }

  void _updateIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void onRightReached() {
    final notifier = ref.read(bookPickViewModelProvider.notifier);
    notifier.refreshLikeBooks();
  }

  @override
  Future<void> onRefresh() async {
    final notifier = ref.read(bookPickViewModelProvider.notifier);
    notifier.initState();
  }

  Future<void> _otherRecommend() async {
    await ref.read(bookPickViewModelProvider.notifier).getOtherRecommend();
  }

  void _launchYouTube(String videoId) async {
    final url = 'https://www.youtube.com/watch?v=$videoId';

    if (await canLaunchUrl(Uri.parse(url))) {
      await ref
          .read(bookPickViewModelProvider.notifier)
          .watchYoutubeVideo(videoId);
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget buildBody(BuildContext context) {
    final bookPickStateAsync = ref.watch(bookPickViewModelProvider);

    return bookPickStateAsync.when(
      data: (bookPickState) => CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchBook(
                  onTap: () => context.push('/book-pick/search'),
                ),
                SizedBox(
                  height: 60,
                ),
                _buildYoutubeBook(
                  ctx: context,
                  list: bookPickState.youtubeRecommends,
                  currentIndex: _currentIndex,
                  updateIndex: _updateIndex,
                  onItemTap: (index) {
                    final videoId =
                        bookPickState.youtubeRecommends[index].videoId;
                    _launchYouTube(videoId);
                  },
                  onDirectShow: () {
                    final videoId =
                        bookPickState.youtubeRecommends[_currentIndex].videoId;
                    _launchYouTube(videoId);
                  },
                  onOtherRecommend: _otherRecommend,
                ),
                SizedBox(
                  height: 60,
                ),
                _buildBookPick(
                  controller: scrollController,
                  list: bookPickState.likeBook.likeBooks,
                  onAllView: () {
                    context.push('/book-pick/my-likes');
                  },
                  onItemTap: (index) {
                    final item = bookPickState.likeBook.likeBooks[index];
                    context.push('/book-pick/overview/${item.bookId}');
                  },
                ),
              ],
            ),
          )
        ],
      ),
      error: _error("책픽 정보를 불러올 수 없습니다."),
      loading: _loading,
    );
  }

  Widget _buildSearchBook({required VoidCallback onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '책 찾기',
          style: AppTexts.b1.copyWith(color: ColorName.w1),
        ),
        SizedBox(
          height: 15,
        ),
        SearchTextField(
          hintText: '읽고 싶은 책을 검색해 보세요',
          hintStyle: AppTexts.b6.copyWith(color: ColorName.g3),
          suffixIcon: Assets.images.icSearchUncolored3x.image(scale: 3),
          onTap: onTap,
          readOnly: true,
        ),
      ],
    );
  }

  Widget _buildYoutubeBook(
          {required BuildContext ctx,
          required List<YoutubeRecommendResponse> list,
          required int currentIndex,
          required Function(int) updateIndex,
          required Function(int) onItemTap,
          required Function() onDirectShow,
          required Function() onOtherRecommend}) =>
      Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: List.generate(
              list.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: currentIndex == index ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: currentIndex == index
                      ? ColorName.p1 // 활성화된 인디케이터 색상
                      : ColorName.g7, // 비활성화된 인디케이터 색상
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 30,
          ),
          CarouselSlider.builder(
              itemCount: list.length,
              options: CarouselOptions(
                height: 240,
                enlargeCenterPage: true,
                aspectRatio: 2.0,
                onPageChanged: (index, reason) {
                  updateIndex(index);
                },
              ),
              itemBuilder:
                  (BuildContext context, int index, int pageViewIndex) {
                final item = list[index];
                return YoutubeItem(
                    item: item, onItemTap: () => onItemTap(index));
              }),
          SizedBox(
            height: 45,
          ),
          _buildActionButton(
            ctx,
            '바로 보기',
            ColorName.p1,
            AppTexts.b7.copyWith(color: ColorName.w1),
            onDirectShow,
          ),
          SizedBox(
            height: 8,
          ),
          _buildActionButton(
            ctx,
            '다른 추천 받기',
            ColorName.g7,
            AppTexts.b7.copyWith(color: ColorName.w1),
            onOtherRecommend,
          ),
        ],
      );

  Widget _buildBookPick(
          {required ScrollController controller,
          required List<LikeBookResponse> list,
          required Function() onAllView,
          required Function(int) onItemTap}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('책 PICK', style: AppTexts.h4.copyWith(color: ColorName.w1)),
          SizedBox(
            height: 3,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('내가 픽한 책을 확인하고 빠르게 읽어보세요!',
                  style: AppTexts.b10.copyWith(color: ColorName.g2)),
              if (list.isNotEmpty)
                InkWell(
                  onTap: onAllView,
                  child: Row(
                    children: [
                      Text(
                        "전체 보기",
                        style: AppTexts.b10.copyWith(color: ColorName.g3),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: ColorName.g3,
                      )
                    ],
                  ),
                )
            ],
          ),
          SizedBox(
            height: 30,
          ),
          SizedBox(
            height: list.isNotEmpty ? 135 : 135 + 38,
            child: CustomListView(
              scrollDirection: Axis.horizontal,
              emptyIcon: Assets.icons.icBookpickSearchCharacter.svg(),
              emptyText: '내가 픽한 책이 없습니다.',
              isEmpty: list.isEmpty,
              itemCount: list.length,
              scrollController: controller,
              itemBuilder: (context, index) {
                final item = list[index];
                return BookSearchResultCard(
                  book: SearchBookResponse(
                    bookId: item.bookId,
                    title: item.title,
                    bookCover: item.bookCover,
                    pubDate: item.pubDate,
                    author: item.author,
                    publisher: item.publisher,
                  ),
                  onTap: () => onItemTap(index),
                );
              },
              separatorBuilder: (context, index) => SizedBox(width: 12),
            ),
          ),
          SizedBox(
            height: 70,
          )
        ],
      );

  Widget _buildActionButton(
    BuildContext context,
    String text,
    Color backgroundColor,
    TextStyle textStyle,
    VoidCallback onPressed,
  ) {
    return GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          width: double.infinity,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              text,
              style: textStyle,
            ),
          ),
        ));
  }

  Widget _loading() => const Center(child: CircularProgressIndicator());
  Widget Function(Object, StackTrace) _error(String msg) => (e, st) =>
      Center(child: Text(msg, style: TextStyle(color: ColorName.g3)));
}
