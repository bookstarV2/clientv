import 'dart:async';

import 'package:bookstar/modules/book_pick/model/like_book_state.dart';
import 'package:bookstar/modules/book_pick/repository/book_pick_repository.dart';
import 'package:bookstar/modules/book_pick/state/book_pick_search_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'book_pick_search_view_model.g.dart';

@riverpod
class BookPickSearchViewModel extends _$BookPickSearchViewModel {
  late final BookPickRepository _bookPickRepository;

  @override
  FutureOr<BookPickSearchState> build() async {
    _bookPickRepository = ref.watch(bookPickRepositoryProvider);
    return await initState();
  }

  Future<BookPickSearchState> initState() async {
    final responseLike = await _bookPickRepository.getMyLikes();
    state = AsyncValue.data(BookPickSearchState(
      likeBook: LikeBookState(
        likeBooks: responseLike.data.data,
        hasNext: responseLike.data.hasNext,
        nextCursor: responseLike.data.nextCursor ?? -1,
      ),
    ));
    return state.value ?? BookPickSearchState();
  }

  Future<BookPickSearchState> initLikeBooks({String title = ""}) async {
    final prev = state.value ?? BookPickSearchState();
    final responseLike = await _bookPickRepository.getMyLikes(title: title);
    state = AsyncValue.data(prev.copyWith(
      likeBook: LikeBookState(
        likeBooks: responseLike.data.data,
        hasNext: responseLike.data.hasNext,
        nextCursor: responseLike.data.nextCursor ?? -1,
        title: title,
      ),
    ));
    return state.value ?? BookPickSearchState();
  }

  Future<BookPickSearchState> refreshLikeBooks() async {
    final prev = state.value ?? BookPickSearchState();
    if (prev.likeBook.nextCursor != -1) {
      final responseLike = await _bookPickRepository.getMyLikes(
          cursorId: prev.likeBook.nextCursor, title: prev.likeBook.title);
      state = AsyncValue.data(prev.copyWith(
        likeBook: prev.likeBook.copyWith(
          likeBooks: [...prev.likeBook.likeBooks, ...responseLike.data.data],
          hasNext: responseLike.data.hasNext,
          nextCursor: responseLike.data.nextCursor ?? -1,
          title: prev.likeBook.title,
        ),
      ));
      return state.value ?? BookPickSearchState();
    }
    return prev;
  }
}
