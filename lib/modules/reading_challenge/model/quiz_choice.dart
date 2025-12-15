import 'package:freezed_annotation/freezed_annotation.dart';

part 'quiz_choice.freezed.dart';
part 'quiz_choice.g.dart';

@freezed
abstract class QuizChoice with _$QuizChoice {
  const factory QuizChoice({
    @Default(-1) int choiceId,
    @Default(-1) int choiceOrder,
    @Default('') String choiceText,
  }) = _QuizChoice;

  factory QuizChoice.fromJson(Map<String, dynamic> json) =>
      _$QuizChoiceFromJson(json);
}
