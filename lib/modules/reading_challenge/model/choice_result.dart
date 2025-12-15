import 'package:freezed_annotation/freezed_annotation.dart';

part 'choice_result.freezed.dart';
part 'choice_result.g.dart';

@freezed
abstract class ChoiceResult with _$ChoiceResult {
  const factory ChoiceResult({
    @Default(-1) int choiceId,
    @Default('') String choiceText,
    @Default(false) bool isCorrect,
    @Default('') String explanation,
    @Default(false) bool isSelected,
  }) = _ChoiceResult;

  factory ChoiceResult.fromJson(Map<String, dynamic> json) =>
      _$ChoiceResultFromJson(json);
}
