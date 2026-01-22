import 'package:freezed_annotation/freezed_annotation.dart';

part 'challenge_success_detail_response.freezed.dart';
part 'challenge_success_detail_response.g.dart';

@freezed
abstract class ChallengeSuccessDetailResponse
    with _$ChallengeSuccessDetailResponse {
  const factory ChallengeSuccessDetailResponse({
    @Default(-1) int totalTime,
    @Default(-1) int totalCollect,
    @Default(-1) int readingSpeedPerMinute,
    @Default('') String bookTitle,
    @Default('') String bookAuthor,
    @Default('') String bookCover,
    @Default('') String bookPublisher,
  }) = _ChallengeSuccessDetailResponse;

  factory ChallengeSuccessDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$ChallengeSuccessDetailResponseFromJson(json);
}
