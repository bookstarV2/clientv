import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/learning_repository.dart';
import 'bs_ui.dart';
import 'library_widgets.dart';

enum _SearchMode { recommend, prompt, typing, results }

/// 2.4 책 찾기 (추천하는 책 with the 베스트셀러순/유저 인기순 toggle) and
/// 2.4.1 책 검색 (Default prompt, Active suggestions, Completed results).
/// Tapping a book opens 2.4.2 상세; saving happens there.
class LearningSearchScreen extends ConsumerStatefulWidget {
  const LearningSearchScreen({super.key});

  @override
  ConsumerState<LearningSearchScreen> createState() =>
      _LearningSearchScreenState();
}

class _LearningSearchScreenState extends ConsumerState<LearningSearchScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  Timer? _debounce;
  var _sort = BookRecommendationSort.bestseller;
  bool _submitted = false;
  List<LearningBook> _results = [];
  String? _resultsQuery;
  bool _loading = false;
  bool _loadingMore = false;
  bool _hasNext = false;
  int? _cursor;
  int _version = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _focus.dispose();
    _controller.dispose();
    super.dispose();
  }

  String get _text => _controller.text.trim();

  _SearchMode get _mode {
    if (_text.isEmpty) {
      return _focus.hasFocus ? _SearchMode.prompt : _SearchMode.recommend;
    }
    return _submitted ? _SearchMode.results : _SearchMode.typing;
  }

  BookRecommendationSort get _otherSort =>
      _sort == BookRecommendationSort.bestseller
          ? BookRecommendationSort.popular
          : BookRecommendationSort.bestseller;

  void _onChanged(String value) {
    _debounce?.cancel();
    setState(() {
      _submitted = false;
      _error = null;
    });
    if (value.trim().isNotEmpty) {
      _debounce = Timer(const Duration(milliseconds: 300), _search);
    }
  }

  void _submit() {
    if (_text.isEmpty) {
      _focus.requestFocus();
      return;
    }
    _focus.unfocus();
    setState(() => _submitted = true);
    if (_resultsQuery != _text ||
        _error != null ||
        _debounce?.isActive == true) {
      _search();
    }
  }

  Future<void> _search({bool more = false}) async {
    _debounce?.cancel();
    final query = more ? _resultsQuery : _text;
    if (query == null || query.isEmpty) return;
    if (more && (_loadingMore || _loading || !_hasNext)) return;
    final version = more ? _version : ++_version;
    setState(() {
      _error = null;
      if (more) {
        _loadingMore = true;
      } else {
        _loading = true;
      }
    });
    try {
      final page = await ref
          .read(learningRepositoryProvider)
          .searchBooks(query, cursor: more ? _cursor : null);
      if (!mounted || version != _version) return;
      setState(() {
        _results = more ? [..._results, ...page.items] : page.items;
        _resultsQuery = query;
        _hasNext = page.hasNext;
        _cursor = page.nextCursor;
      });
    } catch (error) {
      if (mounted && version == _version) {
        setState(() => _error = learningErrorMessage(error));
      }
    } finally {
      if (mounted && version == _version) {
        setState(() {
          _loading = false;
          _loadingMore = false;
        });
      }
    }
  }

  void _open(LearningBook book) {
    _focus.unfocus();
    context.push('/library/book/${book.bookId}');
  }

  @override
  Widget build(BuildContext context) => LibraryPage(
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 26, 16, 0),
              child: _field(),
            ),
            Expanded(
              child: switch (_mode) {
                _SearchMode.recommend => _recommendations(),
                _SearchMode.prompt => _message('읽고 싶은 책을\n찾아 보세요'),
                _SearchMode.typing => _suggestions(),
                _SearchMode.results => _resultList(),
              },
            ),
          ],
        ),
      );

  Widget _field() => Container(
        height: 48,
        padding: const EdgeInsets.only(left: 16, right: 4),
        decoration: BoxDecoration(
            color: Bs.surface, borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focus,
                maxLength: 100,
                textInputAction: TextInputAction.search,
                cursorColor: Bs.primary,
                style: Bs.text(16, weight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: '책 제목이나 저자를 검색해 보세요',
                  hintStyle: Bs.text(16, weight: FontWeight.w500, color: Bs.g3),
                  counterText: '',
                  filled: false,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                onChanged: _onChanged,
                onSubmitted: (_) => _submit(),
              ),
            ),
            IconButton(
              tooltip: '검색',
              onPressed: _submit,
              icon: const BsIcon('ic_search', size: 22, color: Bs.g3),
            ),
          ],
        ),
      );

  Widget _sortToggle() => LibraryToggle(
        label: _sort.label,
        expanded: _sort == BookRecommendationSort.popular,
        semanticsLabel: '${_sort.label}, ${_otherSort.label}으로 바꾸기',
        onTap: () => setState(() => _sort = _otherSort),
      );

  EdgeInsets _listPadding(double top) => EdgeInsets.fromLTRB(
      16, top, 16, 24 + MediaQuery.paddingOf(context).bottom);

  Widget _recommendations() {
    final page = ref.watch(recommendedBooksProvider(_sort));
    final header = Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text('추천하는 책',
            style: Bs.text(18, weight: FontWeight.w600, color: Bs.g7)),
        _sortToggle(),
      ],
    );
    return page.when(
      data: (data) => ListView.builder(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: _listPadding(19),
        itemCount: data.items.length + 1,
        itemBuilder: (context, index) => index == 0
            ? header
            : _row(data.items[index - 1], divider: index > 1),
      ),
      loading: () => Column(children: [
        Padding(padding: _listPadding(19).copyWith(bottom: 0), child: header),
        const Expanded(
            child: Center(child: CircularProgressIndicator(color: Bs.primary))),
      ]),
      error: (error, _) => _message(learningErrorMessage(error),
          onRetry: () => ref.invalidate(recommendedBooksProvider(_sort))),
    );
  }

  Widget _row(LearningBook book, {required bool divider, double top = 17}) =>
      Column(
        children: [
          if (divider)
            const Divider(height: 1, thickness: 1, color: Bs.surface),
          LibraryBookRow(
            key: ValueKey('search-book-${book.bookId}'),
            title: libraryTitle(book.title),
            author: book.author,
            cover: book.bookCover,
            titleMaxLines: 1,
            padding: EdgeInsets.only(top: top, bottom: 16),
            semanticsLabel: _label(book),
            onTap: () => _open(book),
          ),
        ],
      );

  String _label(LearningBook book) {
    final author = libraryAuthorLabel(book.author);
    return '${libraryTitle(book.title)}, '
        '${author.isEmpty ? '' : '$author, '}책 상세 보기';
  }

  Widget _suggestions() {
    if (_results.isEmpty) {
      if (_error != null) return _message(_error!, onRetry: _search);
      if (_loading || _debounce?.isActive == true || _resultsQuery != _text) {
        return const Center(
            child: CircularProgressIndicator(color: Bs.primary));
      }
      return _notFound();
    }
    return ListView.separated(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: _listPadding(12),
      itemCount: _results.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, thickness: 1, color: Bs.surface),
      itemBuilder: (context, index) {
        final book = _results[index];
        return LibraryCompactBookRow(
          key: ValueKey('search-book-${book.bookId}'),
          title: libraryTitle(book.title),
          author: book.author,
          cover: book.bookCover,
          semanticsLabel: _label(book),
          onTap: () => _open(book),
        );
      },
    );
  }

  Widget _resultList() {
    if (_resultsQuery != _text || (_loading && _results.isEmpty)) {
      if (_error != null) return _message(_error!, onRetry: _search);
      return const Center(child: CircularProgressIndicator(color: Bs.primary));
    }
    if (_results.isEmpty) return _notFound();
    final books = _ranked(
        _results, ref.watch(recommendedBooksProvider(_sort)).valueOrNull);
    return ListView.builder(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: _listPadding(16),
      itemCount: books.length + 2,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Align(alignment: Alignment.centerRight, child: _sortToggle());
        }
        if (index > books.length) {
          if (_hasNext && !_loadingMore && _error == null) {
            WidgetsBinding.instance
                .addPostFrameCallback((_) => _search(more: true));
          }
          return _error != null && _hasNext
              ? Center(
                  child: TextButton(
                      onPressed: () => _search(more: true),
                      child: const Text('다시 불러오기')))
              : const Divider(height: 1, thickness: 1, color: Bs.surface);
        }
        return _row(books[index - 1],
            divider: index > 1, top: index == 1 ? 4 : 16);
      },
    );
  }

  /// Orders search results by the chosen recommendation ranking; books that
  /// are not ranked keep the server order after the ranked ones.
  List<LearningBook> _ranked(List<LearningBook> books, LearningBookPage? page) {
    if (page == null || page.items.isEmpty) return books;
    final rank = {
      for (final (index, book) in page.items.indexed) book.bookId: index
    };
    final entries = books.indexed.toList()
      ..sort((a, b) => (rank[a.$2.bookId] ?? page.items.length + a.$1)
          .compareTo(rank[b.$2.bookId] ?? page.items.length + b.$1));
    return [for (final entry in entries) entry.$2];
  }

  Widget _notFound() => _message('아직 준비되지 않은 책이에요\n현재는 퀴즈가 준비된 책부터 찾을 수 있어요');

  Widget _message(String message, {VoidCallback? onRetry}) => LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Align(
              alignment: const Alignment(0, -0.18),
              child: Padding(
                padding: Bs.pagePadding,
                child: BsEmptyState(
                  message: message,
                  action: onRetry == null
                      ? null
                      : BsSecondaryButton(
                          label: '다시 불러오기', expand: false, onPressed: onRetry),
                ),
              ),
            ),
          ),
        ),
      );
}
