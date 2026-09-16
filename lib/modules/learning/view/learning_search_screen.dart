import 'dart:async';

import 'package:bookstar/modules/book_pick/repository/search_book_repository.dart';
import 'package:bookstar/modules/reading_challenge/repository/reading_challenge_repository.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/learning_repository.dart';
import 'learning_design.dart';

class LearningSearchScreen extends ConsumerStatefulWidget {
  const LearningSearchScreen({super.key});

  @override
  ConsumerState<LearningSearchScreen> createState() =>
      _LearningSearchScreenState();
}

class _LearningSearchScreenState extends ConsumerState<LearningSearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  List<LearningBook> _books = [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasNext = false;
  int? _cursor;
  int? _openingId;
  int _requestVersion = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _search();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search({bool more = false}) async {
    _debounce?.cancel();
    if (more && (_loadingMore || !_hasNext)) return;
    final version = more ? _requestVersion : ++_requestVersion;
    final query = _controller.text.trim();
    setState(() {
      _error = null;
      if (more) {
        _loadingMore = true;
      } else {
        _loading = true;
        _loadingMore = false;
        _books = [];
        _cursor = null;
        _hasNext = false;
      }
    });
    try {
      final result = await ref
          .read(learningRepositoryProvider)
          .searchBooks(query, cursor: more ? _cursor : null);
      if (!mounted || version != _requestVersion) return;
      setState(() {
        _books = more ? [..._books, ...result.items] : result.items;
        _hasNext = result.hasNext;
        _cursor = result.nextCursor;
      });
    } catch (error) {
      if (mounted && version == _requestVersion) {
        setState(() => _error = learningErrorMessage(error));
      }
    } finally {
      if (mounted && version == _requestVersion) {
        setState(() {
          _loading = false;
          _loadingMore = false;
        });
      }
    }
  }

  Future<void> _openBook(LearningBook book) async {
    if (_openingId != null) return;
    FocusScope.of(context).unfocus();
    setState(() => _openingId = book.bookId);
    try {
      final ongoing = await ref
          .read(readingChallengeRepositoryProvider)
          .getOngoingChallenges();
      var id = ongoing.data.challenges
          .firstWhereOrNull((item) => item.bookId == book.bookId)
          ?.challengeId;
      if (id == null) {
        final completed = await ref
            .read(readingChallengeRepositoryProvider)
            .getCompletedChallenges();
        id = completed.data.challenges
            .firstWhereOrNull((item) => item.bookId == book.bookId)
            ?.challengeId;
      }
      if (id == null) {
        final created = await ref
            .read(searchBookRepositoryProvider)
            .createChallenges(book.bookId);
        id = created.data.challengeId;
        if (id <= 0) {
          final refreshed = await ref
              .read(readingChallengeRepositoryProvider)
              .getOngoingChallenges();
          id = refreshed.data.challenges
              .firstWhereOrNull((item) => item.bookId == book.bookId)
              ?.challengeId;
        }
      }
      if (id == null || id <= 0) throw StateError('Book could not be added');
      ref.invalidate(learningBooksProvider);
      if (mounted) context.pushReplacement('/library/$id/chapters');
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(learningErrorMessage(error))));
      }
    } finally {
      if (mounted) setState(() => _openingId = null);
    }
  }

  @override
  Widget build(BuildContext context) => LearningPage(
        title: '기억하고 싶은 책 찾기',
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              TextField(
                controller: _controller,
                textInputAction: TextInputAction.search,
                maxLength: 100,
                decoration: InputDecoration(
                  hintText: '책 제목이나 저자를 검색해 주세요',
                  counterText: '',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _controller.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: '검색어 지우기',
                          onPressed: () {
                            _controller.clear();
                            _search();
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                  filled: true,
                  fillColor: LearningColors.surface,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: LearningColors.line)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: LearningColors.line)),
                ),
                onChanged: (_) {
                  setState(() {
                    _requestVersion++;
                    _books = [];
                    _hasNext = false;
                    _loading = true;
                    _error = null;
                  });
                  _debounce?.cancel();
                  _debounce = Timer(const Duration(milliseconds: 350), _search);
                },
                onSubmitted: (_) => _search(),
              ),
              if (MediaQuery.viewInsetsOf(context).bottom == 0) ...[
                const SizedBox(height: 12),
                Wrap(
                    spacing: 8,
                    children: ['습관', '철학', '심리']
                        .map((word) => ActionChip(
                              label: Text(word),
                              onPressed: () {
                                _controller.text = word;
                                _search();
                              },
                            ))
                        .toList()),
                const SizedBox(height: 10),
                const Text('바로 풀 수 있는 퀴즈가 준비된 책을 보여드려요.',
                    style: TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: LearningColors.muted)),
              ],
            ]),
          ),
          Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null && _books.isEmpty
                      ? SingleChildScrollView(
                          child:
                              LearningError(message: _error!, onRetry: _search))
                      : ListView.separated(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          itemCount: _books.length + 1,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            if (index == _books.length) {
                              if (_books.isEmpty) {
                                return const LearningEmpty(
                                  title: '아직 준비되지 않은 책이에요',
                                  message:
                                      '다른 제목이나 저자로 검색해 보세요.\n현재는 퀴즈가 준비된 책부터 이용할 수 있어요.',
                                  icon: Icons.search_off_rounded,
                                );
                              }
                              if (_error != null) {
                                return LearningError(
                                    message: _error!,
                                    onRetry: () => _search(more: true));
                              }
                              return _hasNext
                                  ? OutlinedButton(
                                      onPressed: _loadingMore
                                          ? null
                                          : () => _search(more: true),
                                      child: Text(
                                          _loadingMore ? '불러오는 중…' : '책 더 보기'),
                                    )
                                  : const SizedBox.shrink();
                            }
                            final book = _books[index];
                            return LearningCard(
                              flat: true,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 16),
                              onTap: _openingId == null
                                  ? () => _openBook(book)
                                  : null,
                              label: '${book.title}, '
                                  '${book.author.isEmpty ? '' : '${book.author}, '}'
                                  '목차 퀴즈 ${book.chapterCount}개 준비됨, '
                                  '${_openingId == book.bookId ? '목차 여는 중' : '목차 열기'}',
                              excludeChildSemantics: true,
                              child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    BookCover(
                                        url: book.bookCover, title: book.title),
                                    const SizedBox(width: 16),
                                    Expanded(
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                          Text(book.title,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  height: 1.4,
                                                  fontWeight: FontWeight.w700)),
                                          const SizedBox(height: 7),
                                          Text(book.author,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  height: 1.4,
                                                  color: LearningColors.muted)),
                                          const SizedBox(height: 12),
                                          LearningLabel(_openingId ==
                                                  book.bookId
                                              ? '서재에 담는 중…'
                                              : '목차 퀴즈 ${book.chapterCount}개 준비됨'),
                                        ])),
                                  ]),
                            );
                          },
                        )),
        ]),
      );
}
