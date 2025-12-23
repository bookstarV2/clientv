import 'package:bookstar/common/components/dialog/custom_dialog.dart';
import 'package:bookstar/modules/reading_challenge/view_model/get_challenges_by_member_view_model.dart';
import 'package:bookstar/modules/reading_challenge/view_model/ongoing_challenge_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/components/button/cta_button_l1.dart';
import '../../../../common/components/grid/async_Image_grid_view.dart';
import '../../../../common/components/header/section_header.dart';
import '../../../../common/theme/app_style.dart';
import '../../../../gen/colors.gen.dart';
import '../../../auth/view_model/auth_state.dart';
import '../../../auth/view_model/auth_view_model.dart';
import '../../../book/view/widgets/book_info_widget.dart';
import '../../../book/view_model/book_view_model.dart';
import '../../../book_pick/model/search_book_response.dart';
import '../../../../gen/assets.gen.dart';
import '../../view_model/reading_challenge_view_model.dart';
import '../../model/my_diary_sort.dart';
import '../../model/my_diary_thumbnail.dart';
import '../../model/my_diary_state.dart';

class ReadingChallengeDetailScreen extends ConsumerStatefulWidget {
  const ReadingChallengeDetailScreen({
    super.key,
    required this.bookId,
    required this.challengeId,
    required this.totalPages,
    required this.visibleDeleteChallenge,
  });

  final int bookId;
  final int challengeId;
  final int totalPages;
  final bool visibleDeleteChallenge;

  @override
  ConsumerState<ReadingChallengeDetailScreen> createState() =>
      _ReadingChallengeDetailScreenState();
}

class _ReadingChallengeDetailScreenState
    extends ConsumerState<ReadingChallengeDetailScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      ref
          .read(myDiariesViewModelProvider(widget.bookId).notifier)
          .fetchNextPage();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookState = ref.watch(bookViewModelProvider(widget.bookId));
    final authState = ref.watch(authViewModelProvider);
    final notifier = ref.read(ongoingChallengeViewModelProvider.notifier);

    final int? memberId = authState.when(
      data: (data) => (data is AuthSuccess) ? data.memberId : null,
      loading: () => null,
      error: (e, st) => null,
    );

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(AppSizes.APP_BAR_HEIGHT),
        child: AppBar(
          title: Text('리딩 챌린지', style: AppTexts.b5),
          leading: const BackButton(),
        ),
      ),
      body: Column(
        spacing: 15,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 15,
                children: [
                  bookState.when(
                    data: (book) => BookInfoWidget(book: book.overview),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) =>
                        Center(child: Text('오류가 발생했습니다: $error')),
                  ),
                  const SizedBox(height: 10),
                  _buildPointsSection(),
                  _buildCalendarSection(),
                  const SizedBox(height: 28),
                  _buildDiarySection(memberId),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: bookState.maybeWhen(
        data: (book) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CtaButtonL1(
                text: '챌린지 진행하기',
                onPressed: () {
                  final bookForRoute = SearchBookResponse(
                    bookId: book.overview.id,
                    title: book.overview.title,
                    author: book.overview.author,
                    bookCover: book.overview.cover,
                    pubDate: book.overview.publishedDate,
                    publisher: book.overview.publisher,
                  );
                  context.push(
                    '/reading-challenge/start-and-end',
                    extra: {
                      'book': bookForRoute,
                      'totalPages': widget.totalPages,
                      'challengeId': widget.challengeId,
                    },
                  );
                },
              ),
              SizedBox(height: 8),
              if (widget.visibleDeleteChallenge)
                CtaButtonL1(
                  text: '챌린지 중단하기',
                  backgroundColor: ColorName.g7,
                  borderColor: ColorName.g7,
                  onPressed: () {
                    _showDeleteConfirmDialog(
                      context: context,
                      onCancel: () {
                        Navigator.of(context).pop(); // Close the first dialog
                      },
                      onConfirm: () async {
                        Navigator.of(context).pop(); // Close the first dialog
                        await notifier.abandonChallenge(widget.challengeId);
                        // BookLogScreen의 챌린지 목록 Provider invalidate
                        final user = ref.read(authViewModelProvider).value;
                        final memberId =
                            (user is AuthSuccess) ? user.memberId : 0;
                        ref.invalidate(getChallengesByMemberViewModelProvider(
                            memberId: memberId));
                        await notifier.initState();
                        if (context.mounted) {
                          await _showDeleteSuccessDialog(context);
                        }
                      },
                    );
                  },
                ),
            ],
          ),
        ),
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildPointsSection() {
    return Padding(
      padding: AppPaddings.SCREEN_BODY_PADDING,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('이 책을 읽고 받은 포인트',
                  style: AppTexts.b10.copyWith(color: ColorName.g2)),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    height: 35,
                    padding: const EdgeInsets.symmetric(horizontal: 11),
                    decoration: BoxDecoration(
                      color: ColorName.dim3,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('300',
                            style: AppTexts.h2.copyWith(color: ColorName.p1)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text('포인트', style: AppTexts.b6.copyWith(color: ColorName.p1)),
                ],
              ),
            ],
          ),
          RichText(
            textAlign: TextAlign.right,
            text: TextSpan(
              style: AppTexts.b11.copyWith(color: ColorName.g2),
              children: [
                const TextSpan(text: '총 '),
                TextSpan(
                  text: '216 P',
                  style: AppTexts.b11.copyWith(color: ColorName.w1),
                ),
                const TextSpan(text: '\n읽은 페이지 '),
                TextSpan(
                  text: '150 P',
                  style: AppTexts.b11.copyWith(color: ColorName.w1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Padding(
      padding: AppPaddings.SCREEN_BODY_PADDING,
      child: Container(
        decoration: BoxDecoration(
          color: ColorName.g7,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            //TODO: 달력 컴포넌트 추가
          ],
        ),
      ),
    );
  }

  Widget _buildDiarySection(int? memberId) {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 15,
        children: [
          SectionHeader(
            heading: '내가 쓴 독서 다이어리',
            description: '해당 도서를 읽고 쓴 독서 다이어리를 확인해 보세요',
            descriptionStyle: AppTexts.b10.copyWith(color: ColorName.g2),
            trailing: GestureDetector(
              onTap: () => ref.read(myDiarySortStateProvider.notifier).toggle(),
              child: Row(
                children: [
                  Text(
                    ref.watch(myDiarySortStateProvider
                            .select((value) => value == MyDiarySort.LATEST))
                        ? '최신순'
                        : '인기순',
                    style: AppTexts.b10.copyWith(color: ColorName.g3),
                  ),
                  Assets.icons.icArrowUpDown.svg(),
                ],
              ),
            ),
          ),
          AsyncImageGridView<MyDiaryState, MyDiaryThumbnail>(
            asyncValue: ref.watch(myDiariesViewModelProvider(widget.bookId)),
            getItems: (state) => state.diaries,
            getImageUrl: (diary) => diary.firstImage.imageUrl,
            hasNext: ref
                    .watch(myDiariesViewModelProvider(widget.bookId))
                    .asData
                    ?.value
                    .hasNext ??
                false,
            emptyText: '내가 쓴 독서일기가 없습니다.',
            errorText: '게시물을 불러올 수 없습니다.',
            onTap: memberId != null
                ? (index) {
                    context.push('/reading-challenge/diary-feeds', extra: {
                      'bookId': widget.bookId,
                      'memberId': memberId,
                      'index': index,
                    });
                  }
                : null,
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog({
    required BuildContext context,
    required Function() onCancel,
    required Function() onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (_) {
        return CustomDialog(
          title: '리딩 챌린지를 중단할까요?',
          content: '중단한 리딩 챌린지는 마이페이지 > 중단한 리딩 챌린지에서\n언제든지 다시 진행할 수 있어요',
          titleStyle: AppTexts.b7.copyWith(color: ColorName.w1),
          contentStyle: AppTexts.b11.copyWith(color: ColorName.g2),
          icon: Assets.icons.icReadingChallengeChar1
              .svg(width: 100, height: 106.8803482055664),
          onCancel: onCancel,
          onConfirm: onConfirm,
          confirmButtonText: '중단',
          cancelButtonText: '취소',
        );
      },
    );
  }

  Future<void> _showDeleteSuccessDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (_) {
        return CustomDialog(
          title: '리딩 챌린지 중단',
          content: '리딩 챌린지를 중단되었어요',
          icon: Assets.icons.icReadingChallengeChar2.svg(),
          onConfirm: () => Navigator.of(context).pop(),
          onCancel: () => Navigator.of(context).pop(),
          confirmButtonText: '확인',
          cancelButtonText: '',
        );
      },
    );
    if (context.mounted) context.pop();
  }
}
