import 'package:bookstar/common/components/custom_grid_view.dart';
import 'package:bookstar/common/components/custom_list_view.dart';
import 'package:bookstar/common/service/analytics_service.dart';
import 'package:bookstar/modules/book_pick/view/widgets/book_search_result_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/components/text_field/search_text_field.dart';
import '../../../../common/theme/app_style.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/colors.gen.dart';
import '../../model/search_book_response.dart';
import '../../view_model/search_book_view_model.dart';

class BookPickSearchScreen extends ConsumerStatefulWidget {
  const BookPickSearchScreen({
    super.key,
  });

  @override
  ConsumerState<BookPickSearchScreen> createState() =>
      _BookPickSearchScreenState();
}

class _BookPickSearchScreenState extends ConsumerState<BookPickSearchScreen> {
  final TextEditingController _textController = TextEditingController();
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

  Future<void> _refreshState() async {
    await ref.read(searchBookViewModelProvider.notifier).fetchNextPage();
  }

  void _onSearchSubmitted(String value) {
    if (value.isNotEmpty) {
      AnalyticsService.logEvent('click_search_book_icon',
          parameters: {'screen_name': 'book_pick_search', 'query': value});
      ref.read(searchBookViewModelProvider.notifier).searchBooks(value);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchBookViewModelProvider);
    final notifier = ref.read(searchBookViewModelProvider.notifier);

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
      body: Padding(
        padding: AppPaddings.SCREEN_BODY_PADDING,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBook(
              textController: _textController,
              onTapSuffixIcon: () => _onSearchSubmitted(_textController.text),
            ),
            Expanded(
                child: state.when(
              data: (data) {
                final visibleSearchHistory =
                    data.books.isEmpty && data.query.isEmpty;
                return visibleSearchHistory
                    ? _buildSearchHistory(
                        searchHistories: data.searchHistories,
                        onRemoveItem: (query) async {
                          AnalyticsService.logEvent(
                              'click_remove_search_history',
                              parameters: {
                                'screen_name': 'book_pick_search',
                                'query': query
                              });
                          await notifier.removeHistory(query);
                        },
                        onSearchItem: (query) {
                          AnalyticsService.logEvent('click_search_history_item',
                              parameters: {
                                'screen_name': 'book_pick_search',
                                'query': query
                              });
                          _textController.text = query;
                          _onSearchSubmitted(query);
                        },
                      )
                    : _buildSearchResults(
                        books: data.books,
                        hasNext: data.hasNext,
                        scrollController: _scrollController,
                        onTapItem: (book) {
                          AnalyticsService.logEvent('click_book_from_search',
                              parameters: {
                                'screen_name': 'book_pick_search',
                                'book_id': book.bookId,
                                'book_title': book.title
                              });
                          context.push('/book-pick/overview/${book.bookId}');
                        },
                      );
              },
              loading: _loading,
              error: _error("북 검색 정보를 불러올 수 없습니다."),
            )),
          ],
        ),
      ),
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
          '책 찾기',
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

  Widget _loading() => const Center(child: CircularProgressIndicator());
  Widget Function(Object, StackTrace) _error(String msg) => (e, st) =>
      Center(child: Text(msg, style: TextStyle(color: ColorName.g3)));
}
