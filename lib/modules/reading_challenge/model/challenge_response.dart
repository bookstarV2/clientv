import 'package:freezed_annotation/freezed_annotation.dart';

part 'challenge_response.freezed.dart';
part 'challenge_response.g.dart';

@freezed
abstract class ChallengeResponse with _$ChallengeResponse {
  const factory ChallengeResponse({
    @Default(-1) int challengeId,
    @Default(-1) int bookId,
    @Default('') String bookTitle,
    @Default('') String bookAuthor,
    @Default('') String bookImageUrl,
    @Default(-1) int totalPages,
    @Default(-1) int totalChapters,
    @Default(false) bool completed,
    @Default(false) bool abandoned,
    @Default('') String completedAt,
    @Default('') String createdAt,
    @Default(false) bool hasQuiz,
    @Default(0.0) double progressPercentage,
  }) = _ChallengeResponse;

  factory ChallengeResponse.fromJson(Map<String, dynamic> json) =>
      _$ChallengeResponseFromJson(json);
}
