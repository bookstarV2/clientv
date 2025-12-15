import 'package:bookstar/modules/reading_challenge/model/quiz_choice.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'challenge_detail_chapter_detail.freezed.dart';
part 'challenge_detail_chapter_detail.g.dart';

@freezed
abstract class ChallengeDetailChapterDetail
    with _$ChallengeDetailChapterDetail {
  const factory ChallengeDetailChapterDetail({
    @Default(-1) int chapterId,
    @Default(-1) int chapterNumber,
    @Default('') String chapterTitle,
    @Default(-1) int quizId,
    @Default('') String question,
    @Default([]) List<QuizChoice> choices,
    @Default(-1) int totalAttempts,
    @Default('') String createdAt,
  }) = _ChallengeDetailChapterDetail;

  factory ChallengeDetailChapterDetail.fromJson(Map<String, dynamic> json) =>
      _$ChallengeDetailChapterDetailFromJson(json);
}
