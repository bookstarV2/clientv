import 'package:bookstar/common/components/base_screen.dart';
import 'package:bookstar/common/components/custom_grid_view.dart';
import 'package:bookstar/common/components/custom_list_view.dart';
import 'package:bookstar/common/utils/overlay_utils.dart';
import 'package:bookstar/modules/book_pick/model/search_book_response.dart';
import 'package:bookstar/modules/book_pick/view/widgets/book_search_result_card.dart';
import 'package:bookstar/modules/book_pick/view_model/search_book_view_model.dart';
import 'package:bookstar/modules/reading_challenge/view/widgets/reading_challenge_has_quiz_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/components/text_field/search_text_field.dart';
import '../../../../common/theme/app_style.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/colors.gen.dart';

class ReadingChallengeSearchNewScreen extends BaseScreen {
  const ReadingChallengeSearchNewScreen({
    super.key,
  });

  @override
  BaseScreenState<ReadingChallengeSearchNewScreen> createState() =>
      _ReadingChallengeSearchNewScreenState();
}

class _ReadingChallengeSearchNewScreenState
    extends BaseScreenState<ReadingChallengeSearchNewScreen> {
  @override
  bool enableRefreshIndicator() => false;

  @override
  int getListTotalItemCount() =>
      ref.watch(searchBookViewModelProvider).value?.books.length ?? 0;

  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(searchBookViewModelProvider.notifier).initState();
    });
  }

  @override
  void onBottomReached() async {
    await ref.read(searchBookViewModelProvider.notifier).fetchNextPage();
  }

  void _onSearchSubmitted(String value) {
    if (value.isNotEmpty) {
      ref.read(searchBookViewModelProvider.notifier).searchBooks(value);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        '리딩 챌린지',
        style: AppTexts.b5,
      ),
      leading: IconButton(
        icon: const BackButton(),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    final state = ref.watch(searchBookViewModelProvider);
    final notifier = ref.read(searchBookViewModelProvider.notifier);

    return Padding(
      padding: AppPaddings.SCREEN_BODY_PADDING,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchBook(
              textController: _textController,
              focusNode: focusNode,
              onTapSuffixIcon: () => _onSearchSubmitted(_textController.text),
              onTapMyLikes: () {
                context.push('/reading-challenge/search-new/my-likes');
              }),
          Expanded(
              child: state.when(
            data: (data) {
              final visibleSearchHistory =
                  data.books.isEmpty && data.query.isEmpty;
              return visibleSearchHistory
                  ? _buildSearchHistory(
                      searchHistories: data.searchHistories,
                      onRemoveItem: (query) async {
                        await notifier.removeHistory(query);
                      },
                      onSearchItem: (query) {
                        _textController.text = query;
                        _onSearchSubmitted(query);
                      },
                    )
                  : _buildSearchResults(
                      books: data.books,
                      hasNext: data.hasNext,
                      scrollController: scrollController,
                      onTapItem: (book) async {
                        if (book.alreadyExists) {
                          OverlayUtils.showCustomToast(
                              context, '이미 진행중인 챌린지입니다.');
                        } else if (!book.hasChapter) {
                          OverlayUtils.showCustomToast(
                              context, '이 책은 목차가 없습니다.');
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
                      },
                    );
            },
            loading: loading,
            error: error("북 검색 정보를 불러올 수 없습니다."),
          )),
        ],
      ),
    );
  }

  Widget _buildSearchBook({
    required TextEditingController textController,
    FocusNode? focusNode,
    required Function() onTapSuffixIcon,
    required Function() onTapMyLikes,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SearchTextField(
          controller: textController,
          focusNode: focusNode,
          hintText: '새롭게 읽을 책을 찾아보세요',
          hintStyle: AppTexts.b6.copyWith(color: ColorName.g3),
          suffixIcon: textController.text.isNotEmpty
              ? Assets.images.icSearchColored3x.image(scale: 3)
              : Assets.images.icSearchUncolored3x.image(scale: 3),
          onTapSuffixIcon: onTapSuffixIcon,
        ),
        const SizedBox(height: 25),
        GestureDetector(
          onTap: onTapMyLikes,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "내가 PICK한 책",
                style: AppTexts.b10.copyWith(color: ColorName.g2),
              ),
              const Icon(
                Icons.chevron_right,
                color: ColorName.g2,
                size: 20,
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildSearchHistory(
      {required List<String> searchHistories,
      required Function(String) onRemoveItem,
      required Function(String) onSearchItem}) {
    return CustomListView(
        emptyIcon: Assets.icons.icBookpickSearchCharacter.svg(),
        emptyText: '어떤 도서를 찾고 계신가요?',
        isEmpty: searchHistories.isEmpty,
        itemCount: searchHistories.length,
        itemBuilder: (context, index) {
          final query = searchHistories[index];
          return GestureDetector(
            onTap: () => onSearchItem(query),
            child: ListTile(
              title: Text(query),
              trailing: GestureDetector(
                child: Icon(Icons.clear),
                onTap: () => onRemoveItem(query),
              ),
            ),
          );
        });
  }

  Widget _buildSearchResults(
      {required List<SearchBookResponse> books,
      required bool hasNext,
      required ScrollController scrollController,
      required Function(SearchBookResponse) onTapItem}) {
    return CustomGridView(
      emptyIcon: Assets.icons.icBookpickSearchCharacter.svg(),
      emptyText: '검색 결과가 없습니다.',
      isEmpty: books.isEmpty,
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return BookSearchResultCard(
          book: book,
          onTap: () => onTapItem(book),
        );
      },
      hasNext: hasNext,
      scrollController: scrollController,
    );
  }
}
