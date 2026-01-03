import 'package:bookstar/modules/reading_challenge/model/challenge_detail_chapter_detail.dart';
import 'package:bookstar/modules/reading_challenge/model/choice_result.dart';
import 'package:bookstar/modules/reading_challenge/model/post_progress_request.dart';
import 'package:bookstar/modules/reading_challenge/model/post_reading_timer_request.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:bookstar/modules/reading_challenge/repository/reading_challenge_repository.dart';

part 'challenge_quiz_view_model.freezed.dart';
part 'challenge_quiz_view_model.g.dart';

@freezed
abstract class ChallengeQuizState with _$ChallengeQuizState {
  const factory ChallengeQuizState({
    @Default(-1) int quizId,
    @Default(ChallengeDetailChapterDetail())
    ChallengeDetailChapterDetail chapter,
    List<ChoiceResult>? choiceResults,
  }) = _ChallengeQuizState;
}

@riverpod
class ChallengeQuizViewModel extends _$ChallengeQuizViewModel {
  late final ReadingChallengeRepository _readingChallengeRepository;

  @override
  FutureOr<ChallengeQuizState> build(int chapterId) async {
    _readingChallengeRepository = ref.watch(readingChallengeRepositoryProvider);

    return await _initState(chapterId);
  }

  Future<ChallengeQuizState> _initState(int chapterId) async {
    final prev = state.value ?? ChallengeQuizState();
    final response = await _readingChallengeRepository.getQuizzes([chapterId]);
    final chapter = response.data.chapters.first;
    state = AsyncValue.data(
        prev.copyWith(chapter: chapter, quizId: chapter.quizId));
    return state.value ?? ChallengeQuizState();
  }

  Future<void> postReadingTimers(
      {required int challengeId, required int totalSeconds}) async {
    await _readingChallengeRepository.postReadingTimers(PostReadingTimerRequest(
        challengeId: challengeId, seconds: totalSeconds));
  }

  Future<void> postProgress(
      {required int challengeId, required int chapterId}) async {
    await _readingChallengeRepository.postProgress(
        challengeId, PostProgressRequest(chapterId: chapterId));
  }

  Future<void> submitQuiz(
      {required int choiceId, required int challengeId}) async {
    final response = await _readingChallengeRepository.submitQuiz(
        state.value!.chapter.quizId, choiceId, challengeId);
    final prev = state.value ?? ChallengeQuizState();
    state = AsyncValue.data(
        prev.copyWith(choiceResults: [...response.data.choiceResults]));
  }
}
