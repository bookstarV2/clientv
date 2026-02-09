import 'package:bookstar/common/components/base_screen.dart';
import 'package:bookstar/common/components/custom_grid_view.dart';
import 'package:bookstar/common/utils/overlay_utils.dart';
import 'package:bookstar/modules/book_pick/model/search_book_response.dart';
import 'package:bookstar/modules/book_pick/view/widgets/book_search_result_card.dart';
import 'package:bookstar/modules/book_pick/view_model/book_pick_search_view_model.dart';
import 'package:bookstar/modules/book_pick/view_model/search_book_view_model.dart';
import 'package:bookstar/modules/reading_challenge/view/widgets/reading_challenge_has_quiz_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/components/text_field/search_text_field.dart';
import '../../../../common/theme/app_style.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/colors.gen.dart';

class ReadingChallengeSearchNewMyLikesScreen extends BaseScreen {
  const ReadingChallengeSearchNewMyLikesScreen({
    super.key,
  });

  @override
  BaseScreenState<ReadingChallengeSearchNewMyLikesScreen> createState() =>
      _ReadingChallengeSearchNewMyLikesScreenState();
}

class _ReadingChallengeSearchNewMyLikesScreenState
    extends BaseScreenState<ReadingChallengeSearchNewMyLikesScreen> {
  @override
  bool enableRefreshIndicator() => true;

  @override
  int getListTotalItemCount() =>
      ref
          .watch(bookPickSearchViewModelProvider)
          .value
          ?.likeBook
          .likeBooks
          .length ??
      0;

  final TextEditingController _textController = TextEditingController();

  @override
  void onBottomReached() async {
    await ref
        .read(bookPickSearchViewModelProvider.notifier)
        .initLikeBooks(title: _textController.text);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(AppSizes.APP_BAR_HEIGHT),
      child: AppBar(
        title: Text(
          '리딩 챌린지',
          style: AppTexts.b5,
        ),
        leading: IconButton(
          icon: const BackButton(),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    final state = ref.watch(bookPickSearchViewModelProvider);
    final notifier = ref.read(searchBookViewModelProvider.notifier);

    return state.when(
      data: (data) => Padding(
        padding: AppPaddings.SCREEN_BODY_PADDING,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBook(
              textController: _textController,
              onTapSuffixIcon: onRefresh,
            ),
            Expanded(
                child: CustomGridView(
              emptyIcon: Assets.icons.icBookpickSearchCharacter.svg(),
              emptyText: '검색 결과가 없습니다.',
              isEmpty: data.likeBook.likeBooks.isEmpty,
              itemCount: data.likeBook.likeBooks.length,
              itemBuilder: (context, index) {
                final likeBook = data.likeBook.likeBooks[index];
                final book = SearchBookResponse(
                  bookId: likeBook.bookId,
                  title: likeBook.title,
                  bookCover: likeBook.bookCover,
                  pubDate: likeBook.pubDate,
                  author: likeBook.author,
                  publisher: likeBook.publisher,
                  hasChallenge: likeBook.hasChallenge,
                  hasChapter: likeBook.hasChapter,
                  hasQuiz: likeBook.hasQuiz,
                );
                return BookSearchResultCard(
                    book: book,
                    onTap: () async {
                      if (book.hasChallenge) {
                        OverlayUtils.showCustomToast(
                            context, '이미 진행중인 챌린지입니다.');
                      } else if (!book.hasChapter) {
                        OverlayUtils.showCustomToast(context, '이 책은 목차가 없습니다.');
                      } else {
                        if (!book.hasQuiz) {
                          final result = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReadingChallengeHasQuizDialog(),
                              fullscreenDialog: true,
                            ),
                          );
                          if (result != null && result) {
                            // 챌린지가 존재하지 않으면 다음 화면으로 이동
                            final challengeId =
                                await notifier.createChallenges(book.bookId);
                            if (!context.mounted) return;
                            context.go("/reading-challenge",
                                extra: {"challengeId": challengeId});
                          }
                        } else {
                          // 챌린지가 존재하지 않으면 다음 화면으로 이동
                          final challengeId =
                              await notifier.createChallenges(book.bookId);
                          if (!context.mounted) return;
                          context.go("/reading-challenge",
                              extra: {"challengeId": challengeId});
                        }
                      }
                    });
              },
              hasNext: data.likeBook.hasNext,
              scrollController: scrollController,
            )),
          ],
        ),
      ),
      loading: loading,
      error: error("책픽 정보를 불러올 수 없습니다."),
    );
  }

  Widget _buildSearchBook({
    required TextEditingController textController,
    FocusNode? focusNode,
    required Function() onTapSuffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '내가 PICK한 책을 확인해 보세요',
          style: AppTexts.b1.copyWith(color: ColorName.w1),
        ),
        SizedBox(
          height: 15,
        ),
        SearchTextField(
          controller: textController,
          focusNode: focusNode,
          hintText: '읽고 싶은 책을 검색해 보세요',
          hintStyle: AppTexts.b6.copyWith(color: ColorName.g3),
          suffixIcon: textController.text.isNotEmpty
              ? Assets.images.icSearchColored3x.image(scale: 3)
              : Assets.images.icSearchUncolored3x.image(scale: 3),
          onTapSuffixIcon: onTapSuffixIcon,
        ),
      ],
    );
  }
}
