import 'package:bookstar/modules/reading_challenge/model/choice_result.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'submit_quiz_response.freezed.dart';
part 'submit_quiz_response.g.dart';

@freezed
abstract class SubmitQuizResponse with _$SubmitQuizResponse {
  const factory SubmitQuizResponse({
    @Default(-1) int quizId,
    @Default(-1) int attemptId,
    @Default(false) bool isCorrect,
    @Default(-1) int selectedChoiceId,
    @Default(-1) int correctChoiceId,
    @Default([]) List<ChoiceResult> choiceResults,
    @Default(-1) int totalAttempts,
    @Default(0.0) double correctRate,
    @Default(false) bool isChallengeCompleted,
  }) = _SubmitQuizResponse;

  factory SubmitQuizResponse.fromJson(Map<String, dynamic> json) =>
      _$SubmitQuizResponseFromJson(json);
}
