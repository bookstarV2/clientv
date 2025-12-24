import 'package:bookstar/common/components/custom_grid_view.dart';
import 'package:bookstar/common/service/analytics_service.dart';
import 'package:bookstar/modules/book_pick/view_model/book_pick_search_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/components/text_field/search_text_field.dart';
import '../../../../common/theme/app_style.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/colors.gen.dart';
import '../../model/search_book_response.dart';
import '../widgets/book_search_result_card.dart';

class BookPickMyLikesScreen extends ConsumerStatefulWidget {
  const BookPickMyLikesScreen({
    super.key,
  });

  @override
  ConsumerState<BookPickMyLikesScreen> createState() =>
      _BookPickMyLikesScreenState();
}

class _BookPickMyLikesScreenState extends ConsumerState<BookPickMyLikesScreen> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  DateTime? _lastBottomReachedTime;

  @override
  void initState() {
    super.initState();
    _setupScrollListener();
    _textController.addListener(() {
      setState(() {});
    });
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent * 0.8 &&
          !_isLoadingMore) {
        _onBottomReached();
      }
    });
  }

  Future<void> _onBottomReached() async {
    final now = DateTime.now();
    // 디바운싱: 마지막 호출로부터 2초가 지나지 않았으면 무시
    if (_lastBottomReachedTime != null &&
        now.difference(_lastBottomReachedTime!).inSeconds < 2) {
      return;
    }
    // 이미 로딩 중이면 무시
    if (_isLoadingMore) {
      return;
    }
    _lastBottomReachedTime = now;
    _isLoadingMore = true;
    // 실제 로딩 로직 실행
    await _refreshState();
    _isLoadingMore = false;
  }

  _refreshState() async {
    await ref.read(bookPickSearchViewModelProvider.notifier).refreshLikeBooks();
  }

  Future<void> _onRefresh() async {
    AnalyticsService.logEvent('click_search_my_likes', parameters: {
      'screen_name': 'book_pick_my_likes',
      'query': _textController.text
    });
    await ref
        .read(bookPickSearchViewModelProvider.notifier)
        .initLikeBooks(title: _textController.text);
  }

  _hideKeyboard() {
    _focusNode.unfocus();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookPickSearchViewModelProvider);

    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(AppSizes.APP_BAR_HEIGHT),
          child: AppBar(
            title: Text(
              '책픽',
              style: AppTexts.b5,
            ),
            leading: IconButton(
              icon: const BackButton(),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        body: state.when(
          data: (data) => GestureDetector(
            onTap: () {
              _hideKeyboard();
            },
            child: RefreshIndicator(
                onRefresh: _onRefresh,
                child: Padding(
                  padding: AppPaddings.SCREEN_BODY_PADDING,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSearchBook(
                        textController: _textController,
                        focusNode: _focusNode,
                        onTapSuffixIcon: _onRefresh,
                      ),
                      Expanded(
                          child: CustomGridView(
                        emptyIcon: Assets.icons.icBookpickSearchCharacter.svg(),
                        emptyText: '검색 결과가 없습니다.',
                        isEmpty: data.likeBook.likeBooks.isEmpty,
                        itemCount: data.likeBook.likeBooks.length,
                        itemBuilder: (context, index) {
                          final book = data.likeBook.likeBooks[index];
                          return BookSearchResultCard(
                              book: SearchBookResponse(
                                bookId: book.bookId,
                                title: book.title,
                                bookCover: book.bookCover,
                                pubDate: book.pubDate,
                                author: book.author,
                                publisher: book.publisher,
                              ),
                              onTap: () {
                                AnalyticsService.logEvent('click_my_like_book',
                                    parameters: {
                                      'screen_name': 'book_pick_my_likes',
                                      'book_id': book.bookId
                                    });
                                context
                                    .push('/book-pick/overview/${book.bookId}');
                              });
                        },
                        hasNext: data.likeBook.hasNext,
                        scrollController: _scrollController,
                      ))
                    ],
                  ),
                )),
          ),
          loading: _loading,
          error: _error("책픽 정보를 불러올 수 없습니다."),
        ));
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
        )
      ],
    );
  }

  Widget _loading() => const Center(child: CircularProgressIndicator());
  Widget Function(Object, StackTrace) _error(String msg) => (e, st) =>
      Center(child: Text(msg, style: TextStyle(color: ColorName.g3)));
}
