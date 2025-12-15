import 'package:freezed_annotation/freezed_annotation.dart';

part 'submit_quiz_request.freezed.dart';
part 'submit_quiz_request.g.dart';

@freezed
abstract class SubmitQuizRequest with _$SubmitQuizRequest {
  const factory SubmitQuizRequest({
    @Default(-1) int choiceId,
  }) = _SubmitQuizRequest;

  factory SubmitQuizRequest.fromJson(Map<String, dynamic> json) =>
      _$SubmitQuizRequestFromJson(json);
}
