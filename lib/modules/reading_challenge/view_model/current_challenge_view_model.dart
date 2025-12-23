import 'package:bookstar/modules/book_pick/model/search_book_response.dart';
import 'package:bookstar/modules/reading_challenge/model/challenge_progress_request.dart';
import 'package:bookstar/modules/reading_challenge/model/reading_challenge_request.dart';
import 'package:bookstar/modules/reading_challenge/model/book_rating_request.dart';
import 'package:bookstar/modules/reading_challenge/repository/reading_challenge_repository.dart';
import 'package:bookstar/modules/reading_challenge/view_model/ongoing_challenge_view_model.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:bookstar/modules/auth/view_model/auth_view_model.dart';
import 'package:bookstar/modules/auth/view_model/auth_state.dart';
import 'package:bookstar/modules/reading_challenge/view_model/get_challenges_by_member_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'current_challenge_view_model.freezed.dart';
part 'current_challenge_view_model.g.dart';

@freezed
abstract class CurrentChallengeState with _$CurrentChallengeState {
  const factory CurrentChallengeState({
    SearchBookResponse? book,
    int? totalPages,
    int? challengeId,
    int? lastReadPage,
    String? startPage,
    String? endPage,
    int? progressId,
  }) = _CurrentChallengeState;
}

@Riverpod(keepAlive: true)
class CurrentChallengeViewModel extends _$CurrentChallengeViewModel {
  @override
  CurrentChallengeState build() {
    return const CurrentChallengeState();
  }

  void initializeChallenge({
    required SearchBookResponse book,
    required int totalPages,
    int? challengeId,
  }) {
    state = state.copyWith(
      book: book,
      totalPages: totalPages,
      challengeId: challengeId,
    );
  }

  void setStartPage(String value) {
    state = state.copyWith(startPage: value);
  }

  void setEndPage(String value) {
    state = state.copyWith(endPage: value);
  }

  Future<int> createChallenge(WidgetRef ref) async {
    if (state.book == null ||
        state.totalPages == null ||
        state.startPage == null ||
        state.endPage == null) {
      throw Exception('Book, total pages, and page ranges must be set.');
    }

    final repo = ref.read(readingChallengeRepositoryProvider);
    try {
      final request = ReadingChallengeRequest(
        bookId: state.book!.bookId,
        totalPages: state.totalPages!,
        startPage: int.parse(state.startPage!),
        endPage: int.parse(state.endPage!),
      );
      final res = await repo.createChallenge(request);
      state = state.copyWith(challengeId: res.data.challengeId);
      final user = ref.read(authViewModelProvider).value;
      final memberId = (user is AuthSuccess) ? user.memberId : 0;
      ref.invalidate(
          getChallengesByMemberViewModelProvider(memberId: memberId));
      // 완독한 챌린지 목록도 다시 가져오기
      final notifier = ref.read(ongoingChallengeViewModelProvider.notifier);
      await notifier.initState();
      return res.data.progressId;
    } catch (e) {
      print('Failed to create challenge: $e');
      rethrow;
    }
  }

  Future<int> updateChallengeProgress(WidgetRef ref) async {
    if (state.challengeId == null ||
        state.startPage == null ||
        state.endPage == null) {
      throw Exception('Challenge ID and page range must be set for update.');
    }

    final repo = ref.read(readingChallengeRepositoryProvider);
    try {
      final request = ChallengeProgressRequest(
        startPage: int.parse(state.startPage!),
        endPage: int.parse(state.endPage!),
      );
      final res = await repo.updateChallengeProgress(
        state.challengeId!,
        request,
      );
      state = state.copyWith(
        progressId: res.data.progressId,
      );

      final user = ref.read(authViewModelProvider).value;
      final memberId = (user is AuthSuccess) ? user.memberId : 0;
      ref.invalidate(
          getChallengesByMemberViewModelProvider(memberId: memberId));
      // 완독한 챌린지 목록도 다시 가져오기
      final notifier = ref.read(ongoingChallengeViewModelProvider.notifier);
      await notifier.initState();
      return res.data.progressId;
    } catch (e) {
      debugPrint('Failed to update challenge progress: $e');
      rethrow;
    }
  }

  Future<bool> checkChallengeExists(String bookId) async {
    final repo = ref.read(readingChallengeRepositoryProvider);
    final response = await repo.checkChallengeExists(bookId);
    return response.data;
  }

  Future<void> fetchAndSetChallenge(String bookId) async {
    // final repo = ref.read(readingChallengeRepositoryProvider);
    try {
      // final res = await repo.getChallengeByBookId(bookId);
      // final challengeDetail = res.data;
      // state = state.copyWith(
      //   totalPages: challengeDetail.totalPages,
      //   challengeId: int.tryParse(challengeDetail.challengeId),
      //   lastReadPage: challengeDetail.lastReadPage,
      // );
    } catch (e) {
      // TODO: Handle error
      print('Failed to fetch challenge detail: $e');
    }
  }

  Future<void> deleteBookRating(WidgetRef ref) async {
    if (state.book == null) {
      throw Exception('Book must be set for rating deletion.');
    }

    final repo = ref.read(readingChallengeRepositoryProvider);
    try {
      await repo.deleteBookRating(state.book!.bookId.toString());
    } catch (e) {
      debugPrint('Failed to delete book rating: $e');
      rethrow;
    }
  }

  Future<void> saveBookRating(double rating, WidgetRef ref) async {
    if (state.book == null) {
      throw Exception('Book must be set for rating.');
    }

    final repo = ref.read(readingChallengeRepositoryProvider);
    try {
      final ratingRequest = BookRatingRequest(
        rating: rating.toInt(),
      );
      await repo.createBookRating(state.book!.bookId.toString(), ratingRequest);
    } catch (e) {
      debugPrint('Failed to save book rating: $e');
      rethrow;
    }
  }

  void clear() {
    state = const CurrentChallengeState();
  }

  bool get isButtonEnabled {
    bool isValidStartPage =
        state.startPage != null && state.startPage!.isNotEmpty;
    bool isValidEndPage = state.endPage != null && state.endPage!.isNotEmpty;

    if (!isValidStartPage || !isValidEndPage) {
      return false;
    }

    try {
      int start = int.parse(state.startPage!);
      int end = int.parse(state.endPage!);
      bool isValidRange = start <= end;
      return isValidRange;
    } catch (e) {
      return false;
    }
  }
}
