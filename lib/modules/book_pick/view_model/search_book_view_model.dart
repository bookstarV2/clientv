import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../repository/search_book_repository.dart';
import '../model/search_book_state.dart';

part 'search_book_view_model.g.dart';

@riverpod
class SearchBookViewModel extends _$SearchBookViewModel {
  late final SearchBookRepository searchBookRepository;

  @override
  FutureOr<SearchBookState> build() async {
    searchBookRepository = ref.watch(searchBookRepositoryProvider);
    return await initState();
  }

  Future<SearchBookState> initState() async {
    final response = await searchBookRepository.getSearchHistories();
    return SearchBookState(
        searchHistories: response.data.map((e) => e.queries).toList());
  }

  Future<void> searchBooks(String query) async {
    final prev = state.value ?? SearchBookState();
    state = const AsyncLoading();
    final initStart = 1;
    final response =
        await searchBookRepository.searchBooks(query, start: initStart);

    state = AsyncValue.data(prev.copyWith(
      books: response.data.data,
      hasNext: response.data.hasNext,
      query: query,
      start: initStart,
      searchHistories: {...prev.searchHistories, query}.toList(),
    ));
  }

  Future<void> fetchNextPage() async {
    final prev = state.value ?? SearchBookState();
    if (prev.hasNext) {
      final currentStart = prev.start;
      final response = await searchBookRepository.searchBooks(prev.query,
          start: currentStart + 1);
      state = AsyncValue.data(prev.copyWith(
        books: [...prev.books, ...response.data.data],
        start: currentStart + 1,
        hasNext: response.data.hasNext,
      ));
    }
  }

  Future<void> removeHistory(String query) async {
    final prev = state.value ?? SearchBookState();
    final isExist = prev.searchHistories.contains(query);

    if (isExist) {
      await searchBookRepository.deleteSearchHistory(query);
      state = AsyncValue.data(prev.copyWith(
        searchHistories: prev.searchHistories.where((e) => e != query).toList(),
      ));
    }
  }

  Future<(int, bool, bool, bool)> createChallenges(int bookId) async {
    // 책의 모든 챕터 퀴즈 일괄 생성(비동기)
    // await searchBookRepository.generateAllQuizzes(bookId);
    // 목차 기반 챌린지 생성
    final response = await searchBookRepository.createChallenges(bookId);
    return (
      response.data.challengeId,
      response.data.alreadyExists,
      response.data.hasChapter,
      response.data.hasQuiz,
    );
  }
}
