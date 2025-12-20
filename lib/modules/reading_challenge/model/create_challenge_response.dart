import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_challenge_response.freezed.dart';
part 'create_challenge_response.g.dart';

enum QuizGenerationStatus {
  PENDING,
  PROCESSING,
  ALREADY_EXISTS,
}

@freezed
abstract class CreateChallengeResponse with _$CreateChallengeResponse {
  const factory CreateChallengeResponse({
    @Default(-1) int challengeId,
    @Default(QuizGenerationStatus.PENDING)
    QuizGenerationStatus quizGenerationStatus,
    @Default(false) bool alreadyExists,
    @Default(false) bool hasChapter,
  }) = _CreateChallengeResponse;

  factory CreateChallengeResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateChallengeResponseFromJson(json);
}
